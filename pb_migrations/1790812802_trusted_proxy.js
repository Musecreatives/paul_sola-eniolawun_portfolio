/// <reference path="../pb_data/types.d.ts" />
// PocketBase only ever sits behind the bundled nginx (docker-compose.yml),
// which sets X-Real-IP to the visitor's address. Trusting that header lets
// the per-IP rate limits and logs see real visitors instead of nginx.
// Don't expose port 8090 directly while this is on: a client could then
// send its own X-Real-IP.

migrate(
  (app) => {
    const settings = app.settings();
    settings.trustedProxy.headers = ["X-Real-IP"];
    settings.trustedProxy.useLeftmostIP = false;
    app.save(settings);
  },
  (app) => {
    const settings = app.settings();
    settings.trustedProxy.headers = [];
    app.save(settings);
  },
);
