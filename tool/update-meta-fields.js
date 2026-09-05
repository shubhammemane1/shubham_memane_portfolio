const admin = require('firebase-admin');
const path = require('path');
const serviceAccount = require(path.join(__dirname, 'service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function main() {
  await db.collection('portfolio').doc('meta').set({
    contactInfo: { resumeUrl: '' },
    copyrightText: '© 2026 Shubham Memane. Built with Flutter',
  }, { merge: true });
  console.log('portfolio/meta patched: contactInfo.resumeUrl, copyrightText');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
