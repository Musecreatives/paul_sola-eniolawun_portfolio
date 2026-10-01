/// <reference path="../pb_data/types.d.ts" />
// Emails Paul about every new letter. Recipient: env PAUL_EMAIL.
// Never fails the request: the letter is already saved when this runs.

onRecordAfterCreateSuccess((e) => {
  e.next();

  const mail = require(`${__hooks}/lib/mail.js`);
  const letter = e.record;
  const to = mail.env("PAUL_EMAIL");

  if (!to) {
    console.warn("[letters] PAUL_EMAIL is not set, skipping email for letter " + letter.id);
    e.app.logger().warn("letter email skipped: PAUL_EMAIL not set", "letterId", letter.id);
    return;
  }

  // Re-apply in case settings were reloaded from the dashboard.
  if (!mail.applySmtpFromEnv(e.app)) {
    const missing = mail.smtpMissing().join(", ");
    console.warn("[letters] SMTP not configured (missing " + missing + "), skipping email for letter " + letter.id);
    e.app.logger().warn("letter email skipped: SMTP not configured", "missing", missing, "letterId", letter.id);
    return;
  }

  // Strip line breaks from anything that ends up in a header.
  const oneLine = (v) => v.replace(/[\r\n]+/g, " ").trim();
  const name = oneLine(letter.getString("name"));
  const email = oneLine(letter.getString("email"));
  const purpose = oneLine(letter.getString("purpose"));
  const body = [
    "New letter from the portfolio.",
    "",
    "Name: " + name,
    "Email: " + email,
    "Purpose: " + (purpose || "-"),
    "",
    letter.getString("message"),
    "",
    "Reply to this email to answer " + name + ".",
  ].join("\n");

  try {
    const message = new MailerMessage({
      from: {
        address: e.app.settings().meta.senderAddress,
        name: e.app.settings().meta.senderName,
      },
      to: [{ address: to }],
      subject: "Letter from " + name + (purpose ? " (" + purpose + ")" : ""),
      text: body,
      headers: { "Reply-To": email },
    });
    e.app.newMailClient().send(message);
  } catch (err) {
    console.error("[letters] failed to send email for letter " + letter.id + ": " + err);
    e.app.logger().error("letter email failed", "letterId", letter.id, "error", String(err));
  }
}, "letters");
