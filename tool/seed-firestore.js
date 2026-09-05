const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const ROOT = path.join(__dirname, '..');
const serviceAccount = require(path.join(__dirname, 'service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

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
    const project = data.projects[i];
    await db.collection('projects').doc(project.slug).set({ ...project, order: i });
    console.log(`[${project.slug}] written (order=${i})`);
  }

  console.log('Seed complete.');
}

main().then(() => process.exit(0)).catch((err) => {
  console.error(err);
  process.exit(1);
});
