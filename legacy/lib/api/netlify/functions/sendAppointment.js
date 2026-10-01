// netlify/functions/sendAppointment.js

import sgMail from "@sendgrid/mail";

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

export async function handler(event) {
  try {
    const { name, email, message } = JSON.parse(event.body);

    // basic validation
    if (!name || !email || !message) {
      return { statusCode: 400, body: "Missing fields" };
    }

    const msg = {
      to: "you@yourdomain.com",           // your inbox
      from: "no-reply@yourdomain.com",    // a verified sender
      subject: `New appointment from ${name}`,
      text: `Name: ${name}\nEmail: ${email}\n\n${message}`,
      html: `
        <p><strong>Name:</strong> ${name}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Message:</strong></p>
        <p>${message.replace(/\n/g, "<br>")}</p>
      `,
    };

    await sgMail.send(msg);
    return { statusCode: 200, body: JSON.stringify({ ok: true }) };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message }),
    };
  }
}
