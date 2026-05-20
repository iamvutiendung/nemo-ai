import express from "express";
import cors from "cors";
import fs from "fs";
import path from "path";
import { v4 as uuidv4 } from "uuid";
import YTDlpWrap from "yt-dlp-wrap";

const app = express();
const requestMap = new Map();

const PORT = process.env.PORT || 3000;
const FILE_TTL_MS = 30 * 60 * 1000; // tự xóa file sau 30 phút
const CLEANUP_INTERVAL_MS = 5 * 60 * 1000; // quét file cũ mỗi 5 phút

app.use(cors());

app.use(
  express.json({
    limit: "10mb",
  })
);

const downloadsDir = path.join(process.cwd(), "downloads");

if (!fs.existsSync(downloadsDir)) {
  fs.mkdirSync(downloadsDir, { recursive: true });
}

function cleanupOldFiles() {
  fs.readdir(downloadsDir, (err, files) => {
    if (err) return;

    const now = Date.now();

    files.forEach((file) => {
      const filePath = path.join(downloadsDir, file);

      fs.stat(filePath, (statErr, stats) => {
        if (statErr) return;

        const fileAge = now - stats.mtimeMs;

        if (fileAge > FILE_TTL_MS) {
          fs.unlink(filePath, () => {});
        }
      });
    });
  });
}

cleanupOldFiles();
setInterval(cleanupOldFiles, CLEANUP_INTERVAL_MS);

app.use("/downloads", express.static(downloadsDir));

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Nemo Downloader API is running",
  });
});

app.post("/api/download-video", async (req, res) => {
  try {
    const ip =
      req.headers["x-forwarded-for"] ||
      req.socket.remoteAddress ||
      "unknown";

    const lastRequestTime = requestMap.get(ip);

    if (lastRequestTime) {
      const diff = Date.now() - lastRequestTime;

      if (diff < 8000) {
        return res.status(429).json({
          success: false,
          message: "Bạn thao tác quá nhanh. Vui lòng đợi vài giây.",
        });
      }
    }

    requestMap.set(ip, Date.now());

    const { url, platform } = req.body;

    if (!url) {
      return res.status(400).json({
        success: false,
        message: "Thiếu link video",
      });
    }

    const isTikTok =
      url.includes("tiktok.com") || url.includes("vt.tiktok.com");

    const isFacebook =
      url.includes("facebook.com") ||
      url.includes("fb.watch") ||
      url.includes("m.facebook.com");

    if (!isTikTok && !isFacebook) {
      return res.status(400).json({
        success: false,
        message: "Chỉ hỗ trợ TikTok hoặc Facebook",
      });
    }

    const fileId = uuidv4();
    const safePlatform = platform || (isTikTok ? "tiktok" : "facebook");
    const fileName = `${safePlatform}-${fileId}.mp4`;
    const outputPath = path.join(downloadsDir, fileName);

    const ytDlpWrap = new YTDlpWrap();

    await ytDlpWrap.execPromise([
      url,
      "-o",
      outputPath,
      "-f",
      "bestvideo+bestaudio/best",
      "--merge-output-format",
      "mp4",
      "--no-warnings",
      "--no-check-certificates",
      "--socket-timeout",
      "30",
      "--retries",
      "10",
      "--fragment-retries",
      "10",
      "--concurrent-fragments",
      "5",
      "--force-overwrites",
    ]);

    const publicBaseUrl =
      process.env.PUBLIC_BASE_URL || `http://localhost:${PORT}`;

    return res.json({
      success: true,
      message: "Tải video thành công",
      fileName,
      downloadUrl: `${publicBaseUrl}/downloads/${fileName}`,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message:
        "Không tải được video. Link có thể riêng tư, bị chặn hoặc nền tảng không cho tải.",
      error: String(error),
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Nemo Downloader API running on port ${PORT}`);
});