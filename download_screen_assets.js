const fs = require("fs");
const path = require("path");
const https = require("https");

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return downloadFile(res.headers.location, dest).then(resolve).catch(reject);
      }
      res.pipe(file);
      file.on("finish", () => {
        file.close(resolve);
      });
    }).on("error", (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
  });
}

async function main() {
  const dir = "StitchData";
  const files = fs.readdirSync(dir).filter(f => f.startsWith("screen_2550662649142951551_") && f.endsWith(".json"));
  
  for (const f of files) {
    const fullPath = path.join(dir, f);
    const content = JSON.parse(fs.readFileSync(fullPath, "utf8"));
    const screenData = JSON.parse(content.result.content[0].text);
    const titleSlug = (screenData.title || "screen").toLowerCase().replace(/[^a-z0-9]+/g, "_");
    const sId = screenData.name.split("/").pop();

    console.log(`Processing: ${screenData.title} (${sId}) -> slug: ${titleSlug}`);

    if (screenData.htmlCode && screenData.htmlCode.downloadUrl) {
      const htmlPath = path.join(dir, `${titleSlug}_${sId}.html`);
      console.log(`Downloading HTML to ${htmlPath}...`);
      await downloadFile(screenData.htmlCode.downloadUrl, htmlPath);
    }

    if (screenData.screenshot && screenData.screenshot.downloadUrl) {
      const pngPath = path.join(dir, `${titleSlug}_${sId}.png`);
      console.log(`Downloading Screenshot to ${pngPath}...`);
      await downloadFile(screenData.screenshot.downloadUrl, pngPath);
    }
  }
  console.log("All screens downloaded!");
}

main().catch(console.error);
