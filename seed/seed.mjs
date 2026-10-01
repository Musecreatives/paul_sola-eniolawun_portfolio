#!/usr/bin/env node
// Loads assets/content/content.json into PocketBase. Idempotent: run it as
// often as you like, existing records are updated instead of duplicated.
//
//   CURATOR_EMAIL=... CURATOR_PASSWORD=... node seed/seed.mjs
//
// Env: PB_URL (default http://127.0.0.1:8090), CURATOR_EMAIL, CURATOR_PASSWORD,
//      CONTENT (optional path to the content JSON).
// Node 18+, no dependencies.

import { readFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const PB_URL = (process.env.PB_URL || "http://127.0.0.1:8090").replace(/\/+$/, "");
const CONTENT = process.env.CONTENT || path.join(ROOT, "assets/content/content.json");
const EMAIL = process.env.CURATOR_EMAIL;
const PASSWORD = process.env.CURATOR_PASSWORD;

const MIME = { ".webp": "image/webp", ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".gif": "image/gif", ".svg": "image/svg+xml", ".avif": "image/avif" };

let token = "";
const summary = {};
const warnings = [];

function count(collection, action) {
  summary[collection] ??= { created: 0, updated: 0, files: 0 };
  summary[collection][action]++;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function api(method, urlPath, body) {
  const headers = {};
  if (token) headers.Authorization = token;
  let payload;
  if (body instanceof FormData) {
    payload = body;
  } else if (body !== undefined) {
    headers["Content-Type"] = "application/json";
    payload = JSON.stringify(body);
  }
  for (let attempt = 0; ; attempt++) {
    const res = await fetch(PB_URL + urlPath, { method, headers, body: payload });
    if (res.status === 429 && attempt < 8) {
      await sleep(1000 * (attempt + 1)); // rate limited, back off
      continue;
    }
    const text = await res.text();
    const data = text ? JSON.parse(text) : null;
    if (!res.ok) {
      const err = new Error(`${method} ${urlPath} -> ${res.status}: ${text}`);
      err.status = res.status;
      throw err;
    }
    return data;
  }
}

// Quote a value for a PocketBase filter expression.
const q = (v) => `"${String(v ?? "").replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`;

async function listAll(collection, filter = "") {
  const items = [];
  for (let page = 1; ; page++) {
    const params = new URLSearchParams({ page: String(page), perPage: "200", sort: "created,id", skipTotal: "1" });
    if (filter) params.set("filter", filter);
    const res = await api("GET", `/api/collections/${collection}/records?${params}`);
    items.push(...res.items);
    if (res.items.length < 200) return items;
  }
}

// Drops "_"-prefixed keys (comments) and "id".
function clean(row) {
  const out = {};
  for (const [k, v] of Object.entries(row)) {
    if (k.startsWith("_") || k === "id") continue;
    out[k] = v;
  }
  return out;
}

async function loadFile(relPath) {
  const abs = path.join(ROOT, relPath);
  if (!existsSync(abs)) {
    warnings.push(`file not found: ${relPath}`);
    return null;
  }
  const type = MIME[path.extname(abs).toLowerCase()] || "application/octet-stream";
  return { blob: new Blob([await readFile(abs)], { type }), name: path.basename(abs) };
}

// Creates or updates a record. `files` maps field -> repo path(s); files are
// only uploaded when the existing record has none in that field, so re-runs
// never duplicate uploads or overwrite images replaced in the dashboard.
async function save(collection, existing, data, files = {}) {
  const uploads = [];
  for (const [field, rels] of Object.entries(files)) {
    const current = existing?.[field];
    if (current && (!Array.isArray(current) || current.length)) continue;
    for (const rel of [].concat(rels ?? [])) {
      const file = await loadFile(rel);
      if (file) uploads.push([field, file]);
    }
  }

  let body = data;
  if (uploads.length) {
    body = new FormData();
    for (const [k, v] of Object.entries(data)) {
      if (v === undefined) continue;
      body.append(k, v !== null && typeof v === "object" ? JSON.stringify(v) : String(v ?? ""));
    }
    for (const [k, file] of uploads) body.append(k, file.blob, file.name);
  }

  const rec = existing
    ? await api("PATCH", `/api/collections/${collection}/records/${existing.id}`, body)
    : await api("POST", `/api/collections/${collection}/records`, body);
  count(collection, existing ? "updated" : "created");
  summary[collection].files += uploads.length;
  return rec;
}

// Upserts rows matched by a natural key. Rows sharing a key (e.g. several
// "[Certification in progress]" placeholders) pair up with existing records
// of that key in creation order.
async function upsertAll(collection, rows, keyOf, prepare) {
  const existing = await listAll(collection);
  const pool = new Map();
  for (const rec of existing) {
    const k = keyOf(rec);
    if (!pool.has(k)) pool.set(k, []);
    pool.get(k).push(rec);
  }
  const saved = [];
  for (const raw of rows) {
    const row = clean(raw);
    const { data, files } = prepare ? prepare(row) : { data: row, files: {} };
    const match = pool.get(keyOf(data))?.shift() ?? null;
    saved.push(await save(collection, match, data, files));
  }
  return saved;
}

async function main() {
  if (!EMAIL || !PASSWORD) {
    console.error("Set CURATOR_EMAIL and CURATOR_PASSWORD (the curators account, not the superuser).");
    process.exit(1);
  }

  const content = JSON.parse(await readFile(CONTENT, "utf8"));
  const auth = await api("POST", "/api/collections/curators/auth-with-password", { identity: EMAIL, password: PASSWORD });
  token = auth.token;
  console.log(`Signed in to ${PB_URL} as ${auth.record.email}`);

  // works (by slug)
  const works = await upsertAll("works", content.works ?? [], (r) => r.slug, (row) => {
    const { images, ...data } = row;
    const files = {};
    // Only repo paths are uploadable; anything else (placeholders) is skipped.
    const paths = (images ?? []).filter((p) => typeof p === "string" && p.startsWith("assets/"));
    if (paths.length) files.images = paths;
    return { data, files };
  });
  const workIds = Object.fromEntries(works.map((w) => [w.slug, w.id]));

  // posts (by slug)
  await upsertAll("posts", content.posts ?? [], (r) => r.slug, (row) => {
    const { cover, ...data } = row;
    const files = {};
    if (typeof cover === "string" && cover.startsWith("assets/")) files.cover = cover;
    else if (typeof cover === "string" && cover && !data.cover_painting) data.cover_painting = cover;
    return { data, files };
  });

  // roles (by title + org; linked_work slug -> works id)
  await upsertAll("roles", content.roles ?? [], (r) => `${r.role}\u0000${r.org}`, (row) => {
    const data = { ...row };
    if (data.linked_work) {
      const id = workIds[data.linked_work];
      if (!id) warnings.push(`roles/${row.role}: unknown linked_work "${data.linked_work}"`);
      data.linked_work = id ?? "";
    }
    return { data, files: {} };
  });

  // certificates (by title)
  await upsertAll("certificates", content.certificates ?? [], (r) => r.title, (row) => {
    const { image, ...data } = row;
    const files = {};
    if (typeof image === "string" && image.startsWith("assets/")) files.image = image;
    return { data, files };
  });

  // collection_items (by title); `image` in content.json is a painting key
  await upsertAll("collection_items", content.collection_items ?? [], (r) => r.title, (row) => {
    const { image, ...data } = row;
    const files = {};
    if (typeof image === "string" && image.startsWith("assets/")) files.image = image;
    else if (typeof image === "string" && image) data.painting = image;
    return { data, files };
  });

  // visitor notes (sample notes, seeded as approved; by name + city + note)
  await upsertAll("visitor_notes", content.visitor_notes ?? [], (r) => `${r.name}\u0000${r.city}\u0000${r.note}`, (row) => ({
    data: { ...row, approved: true },
    files: {},
  }));

  // now (single record)
  if (content.now) {
    const [current] = await listAll("now");
    await save("now", current ?? null, clean(content.now));
  }

  console.log("\nSeed summary");
  for (const [name, s] of Object.entries(summary)) {
    console.log(`  ${name.padEnd(17)} created ${String(s.created).padStart(2)}  updated ${String(s.updated).padStart(2)}  files ${s.files}`);
  }
  for (const w of warnings) console.warn(`  warning: ${w}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
