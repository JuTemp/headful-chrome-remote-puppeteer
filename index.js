import { launch } from "puppeteer";
import process from "process";

const browser = await launch({
    headless: false,
    // userDataDir: "./userdata",
    executablePath: "/usr/bin/google-chrome-stable",
    args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-web-security",
        "--disable-features=IsolateOrigins,site-per-process",
        "--use-gl=egl",                  // enable webgl
        "--use-angle=swiftshader",       // enable webgl
        "--remote-debugging-port=9222",
        "--window-size=1750,1050",
        "--window-position=0,0",
    ],
});
browser.on("disconnected", () => process.exit(1));

const page = await browser.newPage();
await page.goto("https://google.com");

console.log("on google.com");
