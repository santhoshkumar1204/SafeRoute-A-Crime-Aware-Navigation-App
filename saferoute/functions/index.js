/* eslint-disable */
/**
 * SafeRoute Cloud Functions — Email OTP Verification
 *
 * Two callable HTTPS functions:
 *   1. sendOtp   — generates a 6-digit OTP, SHA-256 hashes it, stores in
 *                  Firestore `otp_verifications/{email}`, and emails it via
 *                  Nodemailer (Gmail SMTP).
 *   2. verifyOtp — accepts email + user-entered OTP, hashes it, compares with
 *                  Firestore record, enforces expiry / max-attempts / rate limit.
 *
 * SETUP:
 *   firebase functions:config:set \
 *     smtp.email="safetyroutefind@gmail.com" \
 *     smtp.password="YOUR_GMAIL_APP_PASSWORD"
 *
 *   firebase deploy --only functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const crypto = require("crypto");
const cors = require("cors")({ origin: true });

admin.initializeApp();
const db = admin.firestore();

// ─── helpers ────────────────────────────────────────────────────────────────

/** SHA-256 hash (hex). */
function sha256(str) {
  return crypto.createHash("sha256").update(str).digest("hex");
}

/** Generate a cryptographically-random 6-digit OTP. */
function generateOtp() {
  return crypto.randomInt(100000, 999999).toString();
}

/** Get SMTP transporter using Firebase environment config. */
function getTransporter() {
  const config = functions.config();
  const email = config.smtp.email;
  const password = config.smtp.password;

  return nodemailer.createTransport({
    service: "gmail",
    auth: { user: email, pass: password },
  });
}

/** Build the HTML email body. */
function buildEmailHtml(otp) {
  return `
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:24px;border:1px solid #e0e0e0;border-radius:12px;">
      <div style="text-align:center;margin-bottom:16px;">
        <h2 style="color:#1a73e8;">SafeRoute</h2>
      </div>
      <p style="font-size:15px;color:#333;">Your verification code is:</p>
      <div style="text-align:center;margin:24px 0;">
        <span style="font-size:32px;letter-spacing:8px;font-weight:bold;color:#1a73e8;background:#f0f4ff;padding:12px 24px;border-radius:8px;">${otp}</span>
      </div>
      <p style="font-size:13px;color:#666;">This code expires in <strong>5 minutes</strong>.</p>
      <p style="font-size:13px;color:#666;">If you did not request this code, please ignore this email.</p>
      <hr style="border:none;border-top:1px solid #eee;margin:20px 0;" />
      <p style="font-size:11px;color:#999;text-align:center;">SafeRoute — AI-Powered Crime-Aware Navigation</p>
    </div>
  `;
}

// ─── sendOtp ────────────────────────────────────────────────────────────────

exports.sendOtp = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({ success: false, error: "Method not allowed" });
      }

      const { email } = req.body;
      if (!email || typeof email !== "string") {
        return res.status(400).json({ success: false, error: "Email is required" });
      }

      const normalizedEmail = email.trim().toLowerCase();
      const docRef = db.collection("otp_verifications").doc(normalizedEmail);

      // ── Rate-limit: 60 s between sends ──────────────────────────
      const existing = await docRef.get();
      if (existing.exists) {
        const data = existing.data();
        const createdAt = data.createdAt?.toDate();
        if (createdAt) {
          const secondsSinceLast = (Date.now() - createdAt.getTime()) / 1000;
          if (secondsSinceLast < 60) {
            return res.status(429).json({
              success: false,
              error: `Please wait ${Math.ceil(60 - secondsSinceLast)} seconds before requesting a new OTP.`,
            });
          }
        }
      }

      // ── Generate, hash, store ───────────────────────────────────
      const otp = generateOtp();
      const hashedOtp = sha256(otp);
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 5 * 60 * 1000) // 5 minutes
      );

      await docRef.set({
        hashedOtp,
        expiresAt,
        attempts: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // ── Send email ──────────────────────────────────────────────
      const transporter = getTransporter();
      const smtpEmail = functions.config().smtp.email;

      await transporter.sendMail({
        from: `"SafeRoute" <${smtpEmail}>`,
        to: normalizedEmail,
        subject: "Your SafeRoute Verification Code",
        html: buildEmailHtml(otp),
      });

      console.log(`[sendOtp] OTP sent to ${normalizedEmail}`);
      return res.status(200).json({ success: true });
    } catch (err) {
      console.error("[sendOtp] Error:", err);
      return res.status(500).json({ success: false, error: "Failed to send OTP. Please try again." });
    }
  });
});

// ─── verifyOtp ──────────────────────────────────────────────────────────────

exports.verifyOtp = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({ success: false, error: "Method not allowed" });
      }

      const { email, otp } = req.body;
      if (!email || !otp) {
        return res.status(400).json({ success: false, error: "Email and OTP are required" });
      }

      const normalizedEmail = email.trim().toLowerCase();
      const docRef = db.collection("otp_verifications").doc(normalizedEmail);
      const doc = await docRef.get();

      if (!doc.exists) {
        return res.status(404).json({ success: false, error: "No OTP found. Please request a new one." });
      }

      const data = doc.data();

      // ── Check expiry ────────────────────────────────────────────
      const expiresAt = data.expiresAt?.toDate();
      if (!expiresAt || Date.now() > expiresAt.getTime()) {
        await docRef.delete();
        return res.status(410).json({ success: false, error: "OTP has expired. Please request a new one." });
      }

      // ── Check max attempts (5) ─────────────────────────────────
      if ((data.attempts || 0) >= 5) {
        await docRef.delete();
        return res.status(429).json({ success: false, error: "Too many attempts. Please request a new OTP." });
      }

      // ── Compare hashes ─────────────────────────────────────────
      const inputHash = sha256(otp.trim());
      if (inputHash !== data.hashedOtp) {
        await docRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
        const remaining = 5 - (data.attempts || 0) - 1;
        return res.status(401).json({
          success: false,
          error: `Invalid OTP. ${remaining} attempt${remaining !== 1 ? "s" : ""} remaining.`,
        });
      }

      // ── Success → delete OTP doc ───────────────────────────────
      await docRef.delete();
      console.log(`[verifyOtp] OTP verified for ${normalizedEmail}`);
      return res.status(200).json({ success: true });
    } catch (err) {
      console.error("[verifyOtp] Error:", err);
      return res.status(500).json({ success: false, error: "Verification failed. Please try again." });
    }
  });
});
