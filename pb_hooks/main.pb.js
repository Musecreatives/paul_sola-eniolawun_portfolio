/// <reference path="../pb_data/types.d.ts" />
// Configures SMTP from the environment once the app has bootstrapped.

onBootstrap((e) => {
  e.next();

  const mail = require(`${__hooks}/lib/mail.js`);
  if (mail.applySmtpFromEnv(e.app)) {
    console.log("[mail] SMTP configured from env (" + mail.env("SMTP_HOST") + ")");
  } else {
    console.warn("[mail] SMTP not configured, missing env: " + mail.smtpMissing().join(", ") + ". Letters are saved but no email is sent.");
  }
});
