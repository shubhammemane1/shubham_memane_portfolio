const fs = require('fs');
const path = require('path');
const https = require('https');
const admin = require('firebase-admin');

const ROOT = path.join(__dirname, '..');
const serviceAccount = require(path.join(__dirname, 'service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // Hardcoded: this project's bucket uses the newer .firebasestorage.app
  // suffix, not the legacy `${project_id}.appspot.com` pattern — do not derive this from project_id.
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

  let buffer;
  if (source.startsWith('http')) {
    buffer = await fetchBuffer(source);
  } else {
    buffer = fs.readFileSync(path.join(ROOT, source));
  }

  await file.save(buffer, { contentType: 'image/webp' });
  await file.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${destPath}`;
}

const LOCAL_ICONS = {
  'riise': 'assets/images/riise-icon.webp',
  'mo-private-wealth': 'assets/images/mo-private-wealth-icon.webp',
  'mo-trader': 'assets/images/mo-trader-icon.webp',
  'torus-banking-trading-demat': 'assets/images/torus-icon.webp',
};

async function migrateProject(project, order) {
  const slug = project.slug;
  console.log(`[${slug}] uploading images...`);

  const iconSource = LOCAL_ICONS[slug] || project.imageUrl;
  const imageUrl = iconSource ? await uploadImage(slug, 'icon', iconSource) : null;

  const screenshots = [];
  for (let i = 0; i < project.screenshots.length; i++) {
    const url = await uploadImage(slug, `screenshot-${i + 1}`, project.screenshots[i]);
    screenshots.push(url);
  }

  const migrated = {
    ...project,
    imageUrl,
    screenshots,
    order,
  };

  await db.collection('projects').doc(slug).set(migrated);
  console.log(`[${slug}] done (${screenshots.length} screenshots)`);
}

async function main() {
  const raw = fs.readFileSync(path.join(ROOT, 'assets/data/portfolio.json'), 'utf8');
  const data = JSON.parse(raw);

  const meta = {
    personalInfo: data.personalInfo,
    skills: data.skills,
    experiences: data.experiences,
    education: data.education,
    contactInfo: data.contactInfo,
    copyrightText: data.copyrightText,
  };
  await db.collection('portfolio').doc('meta').set(meta);
  console.log('portfolio/meta written');

  for (let i = 0; i < data.projects.length; i++) {
    await migrateProject(data.projects[i], i);
  }

  console.log('Migration complete.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
