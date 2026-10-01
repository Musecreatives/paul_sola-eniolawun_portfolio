/// <reference path="../pb_data/types.d.ts" />
// GET /api/journal/rss.xml: RSS 2.0 feed of the latest 20 public posts.
// Links use env SITE_URL (e.g. "paulsola.dev" or "https://paulsola.dev"),
// falling back to the request host.

routerAdd("GET", "/api/journal/rss.xml", (e) => {
  function xml(v) {
    return String(v == null ? "" : v)
      .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&apos;");
  }

  function toDate(dt) {
    // types.DateTime string form: "2026-10-01 12:00:00.000Z"
    if (!dt || dt.isZero()) return null;
    const d = new Date(dt.string().replace(" ", "T"));
    return isNaN(d.getTime()) ? null : d;
  }

  const proto = e.request.header.get("X-Forwarded-Proto") || (e.request.tls ? "https" : "http");
  const requestBase = proto + "://" + e.request.host;
  let base = ($os.getenv("SITE_URL") || "").trim();
  if (!base) {
    base = requestBase;
  } else if (!/^https?:\/\//i.test(base)) {
    base = "https://" + base;
  }
  base = base.replace(/\/+$/, "");

  // Same visibility as the public posts listRule.
  const filter =
    '(status = "published" && (publish_at = "" || publish_at <= @now))' +
    ' || (status = "scheduled" && publish_at != "" && publish_at <= @now)';
  const records = e.app.findRecordsByFilter("posts", filter, "-publish_at,-created", 200, 0);

  const posts = records
    .map((r) => ({ r: r, date: toDate(r.getDateTime("publish_at")) || toDate(r.getDateTime("created")) }))
    .sort((a, b) => (b.date ? b.date.getTime() : 0) - (a.date ? a.date.getTime() : 0))
    .slice(0, 20);

  const items = posts.map((p) => {
    const r = p.r;
    const link = base + "/journal/" + encodeURIComponent(r.getString("slug"));
    const lines = [
      "    <item>",
      "      <title>" + xml(r.getString("title")) + "</title>",
      "      <link>" + xml(link) + "</link>",
      '      <guid isPermaLink="true">' + xml(link) + "</guid>",
    ];
    if (r.getString("excerpt")) lines.push("      <description>" + xml(r.getString("excerpt")) + "</description>");
    if (r.getString("category")) lines.push("      <category>" + xml(r.getString("category")) + "</category>");
    if (p.date) lines.push("      <pubDate>" + p.date.toUTCString() + "</pubDate>");
    lines.push("    </item>");
    return lines.join("\n");
  });

  const latest = posts.length && posts[0].date ? posts[0].date : new Date();
  const body = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">',
    "  <channel>",
    "    <title>Journal · Paul Sola-Eniolawun</title>",
    "    <link>" + xml(base + "/journal") + "</link>",
    "    <description>Essays and field notes on engineering, design and the examined life.</description>",
    "    <language>en</language>",
    "    <lastBuildDate>" + latest.toUTCString() + "</lastBuildDate>",
    '    <atom:link href="' + xml(requestBase + "/api/journal/rss.xml") + '" rel="self" type="application/rss+xml"/>',
  ]
    .concat(items)
    .concat(["  </channel>", "</rss>", ""])
    .join("\n");

  e.response.header().set("Content-Type", "application/rss+xml; charset=utf-8");
  e.response.header().set("Cache-Control", "public, max-age=600");
  return e.blob(200, "application/rss+xml; charset=utf-8", body);
});
