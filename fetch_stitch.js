const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");
const https = require("https");

const apiKey = process.env.STITCH_API_KEY || "";

const child = spawn("npx", [
  "-y",
  "mcp-remote",
  "https://stitch.googleapis.com/mcp",
  "--header",
  `X-Goog-Api-Key: ${apiKey}`
], { stdio: ["pipe", "pipe", "inherit"] });

let msgId = 1;
const pendingCalls = new Map();

function send(method, params = {}) {
  return new Promise((resolve, reject) => {
    const id = msgId++;
    pendingCalls.set(id, { resolve, reject });
    const req = { jsonrpc: "2.0", id, method, params };
    child.stdin.write(JSON.stringify(req) + "\n");
  });
}

let buffer = "";
child.stdout.on("data", (chunk) => {
  buffer += chunk.toString();
  const lines = buffer.split("\n");
  buffer = lines.pop();
  for (const line of lines) {
    if (!line.trim()) continue;
    try {
      const msg = JSON.parse(line);
      if (msg.id && pendingCalls.has(msg.id)) {
        const { resolve } = pendingCalls.get(msg.id);
        pendingCalls.delete(msg.id);
        resolve(msg);
      }
    } catch (e) {
      // ignore
    }
  }
});

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (res) => {
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

async function run() {
  console.log("Initializing MCP connection...");
  await send("initialize", {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "lastminute-fetcher", version: "1.0.0" }
  });

  const outDir = path.join(__dirname, "StitchData");
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  const projectIds = ["2550662649142951551", "7251014060582631050"];

  for (const pId of projectIds) {
    console.log(`\n--- Processing project ${pId} ---`);
    const screensRes = await send("tools/call", {
      name: "list_screens",
      arguments: { projectId: pId }
    });
    fs.writeFileSync(path.join(outDir, `screens_${pId}.json`), JSON.stringify(screensRes, null, 2));

    let screens = [];
    try {
      const text = screensRes.result.content[0].text;
      const parsed = JSON.parse(text);
      screens = parsed.screens || [];
    } catch (e) {
      console.log(`Could not parse screens JSON for ${pId}:`, e.message);
    }

    console.log(`Project ${pId} has ${screens.length} screens.`);
    for (const s of screens) {
      console.log(`Fetching screen details: ${s.name} (${s.title || s.id})`);
      const screenRes = await send("tools/call", {
        name: "get_screen",
        arguments: { name: s.name }
      });
      const sId = s.name.split("/").pop();
      fs.writeFileSync(path.join(outDir, `screen_${pId}_${sId}.json`), JSON.stringify(screenRes, null, 2));

      // Check for screenshot downloadUrl or html
      try {
        const sText = screenRes.result.content[0].text;
        const sData = JSON.parse(sText);
        if (sData.htmlCode) {
          fs.writeFileSync(path.join(outDir, `screen_${pId}_${sId}.html`), sData.htmlCode);
        }
        if (sData.screenshot && sData.screenshot.downloadUrl) {
          console.log(`Downloading screenshot for ${sId}...`);
          await downloadFile(sData.screenshot.downloadUrl, path.join(outDir, `screenshot_${pId}_${sId}.png`));
        }
      } catch (err) {
        console.log(`Error saving screen assets: ${err.message}`);
      }
    }
  }

  console.log("\nAll Stitch data and screens fetched successfully!");
  child.kill();
  process.exit(0);
}

run().catch(err => {
  console.error("Error:", err);
  child.kill();
  process.exit(1);
});
