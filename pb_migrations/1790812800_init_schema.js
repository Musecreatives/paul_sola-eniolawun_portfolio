/// <reference path="../pb_data/types.d.ts" />
// Initial schema for the portfolio CMS (PocketBase v0.40.4).
// Field names match lib/data/models.dart and assets/content/content.json.

const CURATOR = '@request.auth.collectionName = "curators"';
const PUBLIC = "";

const IMAGE_MIME = ["image/jpeg", "image/png", "image/webp", "image/gif", "image/avif", "image/svg+xml"];
const SLUG_PATTERN = "^[a-z0-9]+(?:-[a-z0-9]+)*$";
const POST_CATEGORIES = ["Engineering", "Design", "Leadership", "Notes"];

// Every collection gets created/updated autodate fields.
function timestamps() {
  return [
    { name: "created", type: "autodate", onCreate: true, onUpdate: false },
    { name: "updated", type: "autodate", onCreate: true, onUpdate: true },
  ];
}

function text(name, opts) {
  return Object.assign({ name: name, type: "text", max: 5000 }, opts || {});
}

function imageFile(name, maxSelect) {
  return {
    name: name,
    type: "file",
    maxSelect: maxSelect || 1,
    maxSize: 10 * 1024 * 1024,
    mimeTypes: IMAGE_MIME,
    thumbs: ["400x0", "1200x0"],
  };
}

// Curator-only writes, public reads.
function publicRead(extra) {
  return Object.assign(
    {
      listRule: PUBLIC,
      viewRule: PUBLIC,
      createRule: CURATOR,
      updateRule: CURATOR,
      deleteRule: CURATOR,
    },
    extra || {},
  );
}

migrate(
  (app) => {
    // curators: Paul's single account. No public sign-up (createRule null:
    // only superusers can create curators, from the dashboard or CLI).
    const curators = new Collection({
      type: "auth",
      name: "curators",
      listRule: "id = @request.auth.id",
      viewRule: "id = @request.auth.id",
      createRule: null,
      updateRule: "id = @request.auth.id",
      deleteRule: null,
      fields: [text("name", { max: 120 })].concat(timestamps()),
      passwordAuth: { enabled: true, identityFields: ["email"] },
    });
    app.save(curators);

    // posts (the Journal)
    const postsVisible =
      '(status = "published" && (publish_at = "" || publish_at <= @now))' +
      ' || (status = "scheduled" && publish_at != "" && publish_at <= @now)';
    const posts = new Collection(
      publicRead({
        type: "base",
        name: "posts",
        listRule: CURATOR + " || " + postsVisible,
        viewRule: CURATOR + " || " + postsVisible,
        fields: [
          text("title", { required: true, max: 300 }),
          text("slug", { required: true, max: 200, pattern: SLUG_PATTERN }),
          text("body", { max: 500000 }),
          text("excerpt", { max: 1000 }),
          { name: "category", type: "select", maxSelect: 1, values: POST_CATEGORIES },
          { name: "tags", type: "json", maxSize: 0 },
          imageFile("cover"),
          text("cover_painting", { max: 100 }),
          { name: "status", type: "select", required: true, maxSelect: 1, values: ["draft", "scheduled", "published"] },
          { name: "publish_at", type: "date" },
          text("date_label", { max: 100 }),
          { name: "sample", type: "bool" },
        ].concat(timestamps()),
        indexes: [
          "CREATE UNIQUE INDEX idx_posts_slug ON posts (slug)",
          "CREATE INDEX idx_posts_status_publish_at ON posts (status, publish_at)",
        ],
      }),
    );
    app.save(posts);

    // works (the Works room and case studies)
    const works = new Collection(
      publicRead({
        type: "base",
        name: "works",
        listRule: CURATOR + " || visible = true",
        viewRule: CURATOR + " || visible = true",
        fields: [
          text("title", { required: true, max: 300 }),
          text("slug", { required: true, max: 200, pattern: SLUG_PATTERN }),
          text("numeral", { max: 20 }),
          text("inventory", { max: 100 }),
          text("headline", { max: 500 }),
          text("summary", { max: 2000 }),
          text("lede", { max: 2000 }),
          text("body", { max: 500000 }),
          text("medium", { max: 300 }),
          text("tags", { max: 500 }),
          text("role", { max: 200 }),
          text("year", { max: 50 }),
          text("dated", { max: 100 }),
          text("team", { max: 200 }),
          text("platforms", { max: 200 }),
          { name: "links", type: "json", maxSize: 0 },
          imageFile("images", 30),
          { name: "featured", type: "bool" },
          { name: "visible", type: "bool" },
          { name: "order", type: "number", onlyInt: true },
          { name: "extra", type: "json", maxSize: 0 },
        ].concat(timestamps()),
        indexes: ["CREATE UNIQUE INDEX idx_works_slug ON works (slug)"],
      }),
    );
    app.save(works);

    // roles (the Chronicle)
    const roles = new Collection(
      publicRead({
        type: "base",
        name: "roles",
        listRule: CURATOR + " || visible = true",
        viewRule: CURATOR + " || visible = true",
        fields: [
          text("role", { required: true, max: 200 }),
          text("org", { required: true, max: 200 }),
          text("location", { max: 200 }),
          text("start", { max: 20 }),
          text("end", { max: 20 }),
          { name: "current", type: "bool" },
          text("dates", { max: 100 }),
          text("year", { max: 20 }),
          text("summary", { max: 2000 }),
          { name: "highlights", type: "json", maxSize: 0 },
          {
            name: "linked_work",
            type: "relation",
            collectionId: works.id,
            maxSelect: 1,
            cascadeDelete: false,
          },
          { name: "order", type: "number", onlyInt: true },
          { name: "visible", type: "bool" },
        ].concat(timestamps()),
      }),
    );
    app.save(roles);

    // certificates
    const certificates = new Collection(
      publicRead({
        type: "base",
        name: "certificates",
        fields: [
          text("title", { required: true, max: 300 }),
          text("issuer", { max: 200 }),
          text("year", { max: 20 }),
          imageFile("image"),
          { name: "verify_url", type: "url" },
          { name: "status", type: "select", required: true, maxSelect: 1, values: ["earned", "in_progress"] },
          { name: "progress", type: "number", min: 0, max: 100, onlyInt: true },
          text("target", { max: 100 }),
          { name: "order", type: "number", onlyInt: true },
        ].concat(timestamps()),
      }),
    );
    app.save(certificates);

    // collection_items (Room VII, The Collection)
    const items = new Collection(
      publicRead({
        type: "base",
        name: "collection_items",
        fields: [
          { name: "kind", type: "select", required: true, maxSelect: 1, values: ["book", "record", "chess", "art", "sport", "game"] },
          text("title", { required: true, max: 300 }),
          text("subtitle", { max: 300 }),
          imageFile("image"),
          text("painting", { max: 100 }),
          text("note", { max: 1000 }),
          { name: "order", type: "number", onlyInt: true },
        ].concat(timestamps()),
      }),
    );
    app.save(items);

    // now (single record placard)
    const now = new Collection(
      publicRead({
        type: "base",
        name: "now",
        fields: [text("building", { max: 300 }), text("reading", { max: 300 })].concat(timestamps()),
      }),
    );
    app.save(now);
    const placard = new Record(now);
    placard.set("building", "");
    placard.set("reading", "");
    app.save(placard);

    // letters (Correspondence form): public create only; curators read,
    // mark as read (update) and delete.
    // `website` is a honeypot: humans never see it, bots fill it.
    const letters = new Collection({
      type: "base",
      name: "letters",
      listRule: CURATOR,
      viewRule: CURATOR,
      // Rejected when the honeypot is filled or when the sender tries to set `read`.
      createRule:
        CURATOR +
        ' || ((@request.body.website:isset = false || @request.body.website = "")' +
        " && (@request.body.read:isset = false || @request.body.read = false))",
      updateRule: CURATOR,
      deleteRule: CURATOR,
      fields: [
        text("name", { required: true, max: 120 }),
        { name: "email", type: "email", required: true },
        text("purpose", { max: 120 }),
        text("message", { required: true, max: 5000 }),
        text("website", { max: 500 }),
        // Unread/read in the admin overview. Curators only.
        { name: "read", type: "bool" },
      ].concat(timestamps()),
      indexes: ["CREATE INDEX idx_letters_read ON letters (read, created)"],
    });
    app.save(letters);

    // visitor_notes (guest book): public create, public read once approved.
    const notes = new Collection({
      type: "base",
      name: "visitor_notes",
      listRule: CURATOR + " || approved = true",
      viewRule: CURATOR + " || approved = true",
      createRule:
        CURATOR + " || @request.body.approved:isset = false || @request.body.approved = false",
      updateRule: CURATOR,
      deleteRule: CURATOR,
      fields: [
        text("name", { required: true, max: 80 }),
        text("city", { max: 80 }),
        text("note", { required: true, max: 140 }),
        { name: "approved", type: "bool" },
      ].concat(timestamps()),
    });
    app.save(notes);

    // subscribers (Journal newsletter): public create only.
    const subscribers = new Collection({
      type: "base",
      name: "subscribers",
      listRule: CURATOR,
      viewRule: CURATOR,
      createRule: "",
      updateRule: CURATOR,
      deleteRule: CURATOR,
      fields: [{ name: "email", type: "email", required: true }].concat(timestamps()),
      indexes: ["CREATE UNIQUE INDEX idx_subscribers_email ON subscribers (email COLLATE NOCASE)"],
    });
    app.save(subscribers);
  },
  (app) => {
    const names = [
      "subscribers",
      "visitor_notes",
      "letters",
      "now",
      "collection_items",
      "certificates",
      "roles",
      "works",
      "posts",
      "curators",
    ];
    for (const name of names) {
      try {
        app.delete(app.findCollectionByNameOrId(name));
      } catch (err) {
        // already gone
      }
    }
  },
);
