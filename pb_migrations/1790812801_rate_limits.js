/// <reference path="../pb_data/types.d.ts" />
// Turns on PocketBase's built-in rate limiter. The public write endpoints
// (POST /api/collections/{letters,visitor_notes,subscribers}/records) get a
// tight per-IP limit for guests; everything else keeps PocketBase's defaults.
//
// Collection routes are matched by tag labels first ("letters:create", then
// "*:create"), so a "POST /api/collections/..." path label would never be
// reached there. The tags are what actually apply.

const PUBLIC_WRITES = ["letters:create", "visitor_notes:create", "subscribers:create"];

const DEFAULT_RULES = [
  { label: "*:auth", audience: "", duration: 3, maxRequests: 2 },
  { label: "*:create", audience: "", duration: 5, maxRequests: 20 },
  { label: "/api/batch", audience: "", duration: 1, maxRequests: 3 },
  { label: "/api/", audience: "", duration: 10, maxRequests: 300 },
];

migrate(
  (app) => {
    const settings = app.settings();
    const kept = [];
    for (const rule of settings.rateLimits.rules || []) {
      if (PUBLIC_WRITES.indexOf(rule.label) === -1) kept.push(rule);
    }
    const rules = kept.length ? kept : DEFAULT_RULES.slice();
    for (const label of PUBLIC_WRITES) {
      rules.push({ label: label, audience: "@guest", duration: 60, maxRequests: 5 });
    }
    settings.rateLimits.rules = rules;
    settings.rateLimits.enabled = true;
    app.save(settings);
  },
  (app) => {
    const settings = app.settings();
    const rules = [];
    for (const rule of settings.rateLimits.rules || []) {
      if (PUBLIC_WRITES.indexOf(rule.label) === -1) rules.push(rule);
    }
    settings.rateLimits.rules = rules;
    settings.rateLimits.enabled = false;
    app.save(settings);
  },
);
