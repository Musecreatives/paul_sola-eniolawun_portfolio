// Shared mail helpers. Loaded with require(`${__hooks}/lib/mail.js`) because
// every hook handler runs in its own isolated JS runtime.
//
// SMTP is configured from the environment only (never stored in the database):
//   SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM, SMTP_TLS (optional)

function env(name) {
  return ($os.getenv(name) || "").trim();
}

// Applies SMTP settings from env to the in-memory app settings.
// Returns true when mail can be sent.
function applySmtpFromEnv(app) {
  const host = env("SMTP_HOST");
  const from = env("SMTP_FROM");
  if (!host || !from) {
    return false;
  }

  const settings = app.settings();
  const port = parseInt(env("SMTP_PORT") || "587", 10);
  const tlsRaw = env("SMTP_TLS").toLowerCase();

  settings.smtp.enabled = true;
  settings.smtp.host = host;
  settings.smtp.port = isNaN(port) ? 587 : port;
  settings.smtp.username = env("SMTP_USER");
  settings.smtp.password = env("SMTP_PASS");
  // Implicit TLS when asked for, or by default on port 465; STARTTLS otherwise.
  settings.smtp.tls = tlsRaw ? tlsRaw === "true" || tlsRaw === "1" : settings.smtp.port === 465;
  settings.meta.senderAddress = from;
  if (!settings.meta.senderName) {
    settings.meta.senderName = "Portfolio";
  }
  return true;
}

function smtpMissing() {
  const missing = [];
  if (!env("SMTP_HOST")) missing.push("SMTP_HOST");
  if (!env("SMTP_FROM")) missing.push("SMTP_FROM");
  return missing;
}

module.exports = { env, applySmtpFromEnv, smtpMissing };
