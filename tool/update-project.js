const fs = require('fs');
const path = require('path');
const https = require('https');
const admin = require('firebase-admin');

const ROOT = path.join(__dirname, '..');
const serviceAccount = require(path.join(__dirname, 'service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'shubhammemaneportfolio-e4dd0.firebasestorage.app',
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

function fetchBuffer(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        fetchBuffer(res.headers.location).then(resolve, reject);
        return;
      }
      if (res.statusCode !== 200) {
        reject(new Error(`GET ${url} -> ${res.statusCode}`));
        return;
      }
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => resolve(Buffer.concat(chunks)));
      res.on('error', reject);
    }).on('error', reject);
  });
}

async function uploadImage(slug, label, source) {
  const destPath = `projects/${slug}/${label}.webp`;
  const file = bucket.file(destPath);
  const buffer = await fetchBuffer(source);
  await file.save(buffer, { contentType: 'image/webp' });
  await file.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${destPath}`;
}

const OLD_SLUG = 'weather-app';
const NEW_SLUG = 'enrich-beauty';

async function main() {
  const raw = fs.readFileSync(path.join(ROOT, 'assets/data/portfolio.json'), 'utf8');
  const data = JSON.parse(raw);

  const order = data.projects.findIndex((p) => p.slug === NEW_SLUG);
  if (order === -1) throw new Error(`${NEW_SLUG} not found in portfolio.json`);

  const project = data.projects[order];

  console.log(`[${NEW_SLUG}] uploading icon...`);
  const imageUrl = await uploadImage(NEW_SLUG, 'icon', project.imageUrl);

  console.log(`[${NEW_SLUG}] uploading ${project.screenshots.length} screenshots...`);
  const screenshots = [];
  for (let i = 0; i < project.screenshots.length; i++) {
    screenshots.push(await uploadImage(NEW_SLUG, `screenshot-${i + 1}`, project.screenshots[i]));
  }

  const migrated = { ...project, imageUrl, screenshots, order };

  await db.collection('projects').doc(NEW_SLUG).set(migrated);
  console.log(`[${NEW_SLUG}] written to Firestore (order=${order})`);

  if (OLD_SLUG !== NEW_SLUG) {
    await db.collection('projects').doc(OLD_SLUG).delete();
    console.log(`[${OLD_SLUG}] old doc deleted`);
  }
}

main().then(() => process.exit(0)).catch((err) => {
  console.error(err);
  process.exit(1);
});
