const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const nodemailer = require("nodemailer");

const gmailAppPassword = defineSecret("GMAIL_APP_PASSWORD");
const NOTIFY_TO = "petitworksdev@gmail.com";
const NOTIFY_FROM = "petitworksdev@gmail.com";

// 「日本の未来マップ」で不適切な投稿が通報されたら、運営に即座にメール通知する。
// App Store Guideline 1.2(UGC)対応: 通報から24時間以内の対応を実効的にするため。
exports.notifyOnReport = onDocumentCreated(
  {
    document: "reports/{reportId}",
    database: "japanfuturemap",
    region: "asia-northeast1",
    secrets: [gmailAppPassword],
  },
  async (event) => {
    const report = event.data?.data();
    if (!report) {
      logger.warn("Report document has no data", event.params.reportId);
      return;
    }

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: NOTIFY_FROM,
        pass: gmailAppPassword.value(),
      },
    });

    const lines = [
      `新しい通報が届きました（reportId: ${event.params.reportId}）`,
      "",
      `種別: ${report.contentType ?? "不明"}`,
      `対象ID: ${report.contentId ?? "不明"}`,
      report.challengeId ? `課題ID: ${report.challengeId}` : null,
      `理由: ${report.reason ?? "（未記入）"}`,
      `通報者UID: ${report.reportedBy ?? "不明"}`,
      "",
      "Firebase Console → Firestore Database → japanfuturemap → reports コレクションで詳細を確認し、",
      "対象コンテンツの削除・悪質な場合はユーザーのブロック対応を24時間以内に行ってください。",
    ].filter(Boolean);

    try {
      await transporter.sendMail({
        from: NOTIFY_FROM,
        to: NOTIFY_TO,
        subject: "【日本の未来マップ】不適切な投稿の通報があります",
        text: lines.join("\n"),
      });
      logger.info("Report notification email sent", event.params.reportId);
    } catch (e) {
      logger.error("Failed to send report notification email", e);
    }
  },
);
