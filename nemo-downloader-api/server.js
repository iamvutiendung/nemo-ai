import express from "express";
import cors from "cors";
import fs from "fs";
import path from "path";
import { v4 as uuidv4 } from "uuid";
import youtubedl from "yt-dlp-exec";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const downloadsDir = path.join(process.cwd(), "downloads");

if (!fs.existsSync(downloadsDir)) {
  fs.mkdirSync(downloadsDir);
}

app.use("/downloads", express.static(downloadsDir));

app.post("/api/download-video", async (req, res) => {
  try {
    const { url, platform } = req.body;

    if (!url) {
      return res.status(400).json({
        success: false,
        message: "Thiếu link video",
      });
    }

    if (!url.includes("tiktok.com") && !url.includes("facebook.com") && !url.includes("fb.watch")) {
      return res.status(400).json({
        success: false,
        message: "Chỉ hỗ trợ link TikTok hoặc Facebook",
      });
    }

    const fileId = uuidv4();
    const fileName = `${platform || "video"}-${fileId}.mp4`;
    const outputPath = path.join(downloadsDir, fileName);

    await youtubedl(url, {
      output: outputPath,
      format: "mp4/best",
      noWarnings: true,
      noCheckCertificates: true
    });

    return res.json({
      success: true,
      message: "Tải video thành công",
      fileName,
      downloadUrl: `http://localhost:${PORT}/downloads/${fileName}`,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: "Không tải được video. Link có thể riêng tư, bị chặn hoặc nền tảng không cho tải.",
      error: String(error),
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Nemo Downloader API running on port ${PORT}`);
});