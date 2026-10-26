// Regenerates every raster brand asset from the master mark (assets/branding/ijodkor-mark.svg):
// launcher icons (Android legacy + adaptive foreground, iOS), splash images (light and dark),
// the Play Store icon. Run from the repo root:
//   NODE_PATH=$(npm root -g) node tool/gen_brand_assets.mjs
// Rules (brand decision of AI Ijodkor Lab): the app icon is the ONLY place with a filled amber
// background (mark in ink); everywhere else the mark is amber in a white badge.
import { createRequire } from "node:module";
import { existsSync, mkdirSync, readdirSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";

const { chromium } = createRequire(import.meta.url)("playwright");

const AMBER = "#F2A93B";
const INK = "#241C10";
const PAGE = "#FFFCF6";
const BORDER = "#ECE1CB";
const PAGE_DARK = "#171310";
const CARD_DARK = "#211B14";
const BORDER_DARK = "#3B3122";

const RES = "android/app/src/main/res";
const IOS = "ios/Runner/Assets.xcassets";

// The drawing lives in the SVG file, so it is never redrawn here.
const paths = (color) =>
  readFileSync("assets/branding/ijodkor-mark.svg", "utf8")
    .match(/<(path|circle)[^>]*>(<\/(path|circle)>)?/g)
    .join("")
    .replaceAll("#F2A93B", color);

/** The mark scaled so its 40-unit box is `box` px wide, its visual centre (20, 19) at (cx, cy). */
const mark = (color, box, cx, cy) => {
  const k = box / 40;
  return `<g transform="translate(${cx - 20 * k} ${cy - 19 * k}) scale(${k})">${paths(color)}</g>`;
};
const svg = (size, body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">${body}</svg>`;

// --- the drawings ---------------------------------------------------------------------------
const iconFull = (s) => svg(s, `<rect width="${s}" height="${s}" fill="${AMBER}"/>${mark(INK, s * 0.78, s / 2, s / 2)}`);
const iconLegacy = (s) =>
  svg(s, `<rect width="${s}" height="${s}" rx="${s * 0.22}" fill="${AMBER}"/>${mark(INK, s * 0.78, s / 2, s / 2)}`);
const adaptiveForeground = (s) => svg(s, mark(INK, s * 0.85, s / 2, s / 2));
const android12Icon = (s) => svg(s, mark(AMBER, s * 0.62, s / 2, s / 2));
const splash = (s, dark) => {
  const b = s * 0.5;
  const o = (s - b) / 2;
  const fill = dark ? CARD_DARK : "#fff";
  const stroke = dark ? BORDER_DARK : BORDER;
  return svg(
    s,
    `<rect x="${o + 0.5}" y="${o + 0.5}" width="${b - 1}" height="${b - 1}" rx="${b * 0.227}" fill="${fill}" stroke="${stroke}" stroke-width="${Math.max(1, s / 288)}"/>${mark(AMBER, b * 0.75, s / 2, s / 2)}`,
  );
};
const solid = (color) => `<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"><rect width="1" height="1" fill="${color}"/></svg>`;

// --- the targets ---------------------------------------------------------------------------
const jobs = [];
const add = (file, size, drawing, opaque = false) => jobs.push({ file, size, drawing, opaque });
const sizeOf = (file) => {
  // PNG header: width at bytes 16..19
  const b = readFileSync(file);
  return b.readUInt32BE(16);
};

add("assets/branding/icon.png", 1024, iconFull, true);
add("assets/branding/icon_foreground.png", 1024, adaptiveForeground);
add("assets/branding/splash.png", 1152, (s) => splash(s, false));
add("assets/branding/splash_dark.png", 1152, (s) => splash(s, true));
add("assets/branding/splash_android12.png", 960, android12Icon);
add("docs/play-assets/icon-512.png", 512, iconFull, true);

for (const [dir, px] of [["mdpi", 48], ["hdpi", 72], ["xhdpi", 96], ["xxhdpi", 144], ["xxxhdpi", 192]]) {
  add(`${RES}/mipmap-${dir}/ic_launcher.png`, px, iconLegacy);
}
for (const dir of ["mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"]) {
  const fg = `${RES}/drawable-${dir}/ic_launcher_foreground.png`;
  const sp = `${RES}/drawable-${dir}/splash.png`;
  const a12 = `${RES}/drawable-${dir}/android12splash.png`;
  add(fg, sizeOf(fg), adaptiveForeground);
  add(sp, sizeOf(sp), (s) => splash(s, false));
  add(a12, sizeOf(a12), android12Icon);
  add(`${RES}/drawable-night-${dir}/splash.png`, sizeOf(sp), (s) => splash(s, true));
  add(`${RES}/drawable-night-${dir}/android12splash.png`, sizeOf(a12), android12Icon);
}
for (const dir of ["drawable", "drawable-v21"]) {
  add(`${RES}/${dir}/background.png`, 1, () => solid(PAGE), true);
  add(`${RES}/${dir.replace("drawable", "drawable-night")}/background.png`, 1, () => solid(PAGE_DARK), true);
}
add(`${IOS}/LaunchBackground.imageset/background.png`, 1, () => solid(PAGE), true);
for (const f of readdirSync(`${IOS}/LaunchImage.imageset`).filter((n) => n.endsWith(".png"))) {
  add(`${IOS}/LaunchImage.imageset/${f}`, sizeOf(`${IOS}/LaunchImage.imageset/${f}`), (s) => splash(s, false));
}
for (const f of readdirSync(`${IOS}/AppIcon.appiconset`).filter((n) => n.endsWith(".png"))) {
  add(`${IOS}/AppIcon.appiconset/${f}`, sizeOf(`${IOS}/AppIcon.appiconset/${f}`), iconFull, true);
}

const browser = await chromium.launch();
for (const { file, size, drawing, opaque } of jobs) {
  mkdirSync(dirname(file), { recursive: true });
  const page = await browser.newPage({ viewport: { width: size, height: size } });
  await page.setContent(`<body style="margin:0;background:transparent">${drawing(size)}</body>`);
  await page.screenshot({ path: file, omitBackground: !opaque });
  await page.close();
}
await browser.close();
console.log(`${jobs.length} files`);
