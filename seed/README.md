# Seed

Loads `assets/content/content.json` (the bundled fallback content) into PocketBase.

## 1. Run PocketBase (v0.40.4)

```sh
./pocketbase serve --migrationsDir pb_migrations --hooksDir pb_hooks
```

The migrations create the collections. See `pb_migrations/README.md` for the env vars (SMTP, `PAUL_EMAIL`, `SITE_URL`).

## 2. Create the accounts

A superuser, for the dashboard at `/_/`:

```sh
./pocketbase superuser create you@example.com 'a-long-password'
```

The curator (Paul's account, used by the seed and the site admin). Public sign-up is off, so create it as superuser, either:

- in the dashboard: `/_/` → Collections → `curators` → New record (email, password, verified), or
- with the API:

```sh
TOKEN=$(curl -s -X POST http://127.0.0.1:8090/api/collections/_superusers/auth-with-password \
  -H 'content-type: application/json' \
  -d '{"identity":"you@example.com","password":"a-long-password"}' | node -pe 'JSON.parse(require("fs").readFileSync(0)).token')

curl -s -X POST http://127.0.0.1:8090/api/collections/curators/records \
  -H "Authorization: $TOKEN" -H 'content-type: application/json' \
  -d '{"email":"paul@example.com","password":"another-long-password","passwordConfirm":"another-long-password","verified":true}'
```

## 3. Seed

Node 18 or newer, no dependencies:

```sh
CURATOR_EMAIL=paul@example.com CURATOR_PASSWORD='another-long-password' node seed/seed.mjs
```

`PB_URL` defaults to `http://127.0.0.1:8090`. `CONTENT` overrides the JSON path.

Safe to re-run. Records are matched and updated, not duplicated:

| Collection | Matched by |
| --- | --- |
| works, posts | slug |
| roles | role + org |
| certificates, collection_items | title |
| visitor_notes | name + city + note (the samples are seeded as approved) |
| now | the single record |

Rows that share a key (the `[Certification in progress]` placeholders) pair up with existing records in creation order. Images under `assets/img/...` are uploaded only when the record has no file yet, so an image replaced in the dashboard is kept. Role `linked_work` slugs become work record ids. Collection item `image` values in the JSON are painting keys and go into `painting`.
