// Run this once from your terminal to seed Firestore with:
//  - 1 admin user document (after creating the account via Firebase Console)
//  - 8 sample products
//
// Prerequisites:
//   npm install firebase-admin
//
// Usage:
//   GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node seed_firebase.js
//
// Download your serviceAccountKey.json from:
//   Firebase Console → Project Settings → Service Accounts → Generate new private key

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

// ────────────────────────────────────────────────────────────────────
//         Manually create an admin account in Firebase Auth Console
//         then paste the UID below.
// ────────────────────────────────────────────────────────────────────
const ADMIN_UID   = 'W090l1BewLeuYXy4xQJUj3ZmKcY2';
const ADMIN_EMAIL = 'admin@retailhub.com';

async function seedAdmin() {
  await db.collection('users').doc(ADMIN_UID).set({
    email:       ADMIN_EMAIL,
    displayName: 'Admin',
    role:        'admin',
    createdAt:   admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log('Admin user document created.');
}

async function seedProducts() {
  const products = [
    {
      name: 'Fast Rocking Chair',
      sku: 'MDC-FRC-001',
      category: 'Designer Chairs',
      basePrice: 85000.00,
      discountedPrice: 85000.00,
      stockQuantity: 4,
      description: 'Designed by Muddycap. Crafted from maple wood with jagged side profiles that simulate motion blur, creating the illusion of constant movement even when still.',
      supplier: 'Muddycap',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/JYHCRCr.jpeg',
    },
    {
      name: 'Bone Chair',
      sku: 'MDC-BON-002',
      category: 'Designer Chairs',
      basePrice: 95000.00,
      discountedPrice: 90000.00,
      stockQuantity: 2,
      description: 'Designed by Muddycap. A silver-toned skeletal structure encased within a frosted outer shell, giving the impression of bones suspended in translucent material.',
      supplier: 'Muddycap',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/c5rIkMP.jpeg',
    },
    {
      name: 'Snail Chair',
      sku: 'MDC-SNL-003',
      category: 'Designer Chairs',
      basePrice: 92000.00,
      discountedPrice: 92000.00,
      stockQuantity: 2,
      description: 'Designed by Muddycap. A sculptural lounge chair whose silhouette traces the spiral geometry of a snail shell.',
      supplier: 'Muddycap',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/lSJhxkU.jpeg',
    },
    {
      name: 'Crystal Chair',
      sku: 'MDC-CRY-004',
      category: 'Designer Chairs',
      basePrice: 105000.00,
      discountedPrice: 105000.00,
      stockQuantity: 4,
      description: 'Designed by Muddycap. A faceted lounge chair whose entire structure is rendered in transparent crystal.',
      supplier: 'Muddycap',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/H7CKQ70.png',
    },
    {
      name: 'Nature Chair',
      sku: 'MDC-NAT-005',
      category: 'Designer Chairs',
      basePrice: 90000.00,
      discountedPrice: 90000.00,
      stockQuantity: 3,
      description: 'Designed by Muddycap. A mushroom cluster grows within a glass-clear structure, blurring the boundary between organic form and functional furniture.',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/GUw9SxD.png',
    },
    {
      name: 'Donut Chair',
      sku: 'MDC-DNT-006',
      category: 'Designer Chairs',
      basePrice: 79000.00,
      discountedPrice: 79000.00,
      stockQuantity: 1,
      description: 'Designed by Muddycap. A lounge chair assembled from a stack of oversized glazed donuts — each ring is a distinct layer, stacked and compressed into a fully seated form.',
      supplier: 'Muddycap',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/R7RtZRg.jpeg',
    },
    {
      name: 'Gem Stone Chair',
      sku: 'MDC-GEM-007',
      category: 'Designer Chairs',
      basePrice: 98000.00,
      discountedPrice: 98000.00,
      stockQuantity: 5,
      description: 'Designed by Muddycap. A lounge chair carved entirely from the form of a raw gemstone — irregular facets run across the seat, backrest, and legs, replicating the natural cleavage planes of a cut mineral.',
      supplier: 'Muddycap',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/jyTyniR.jpeg',
    },
    {
      name: 'Jimseung Chair',
      sku: 'CDG-008-CRM',
      category: 'MDC-JIM-008',
      basePrice: 89000.00,
      discountedPrice: 89000.00,
      stockQuantity: 0,
      description: 'Designed by Muddycap. Jimseung — Korean for beast — is a lounge chair that earns its name. The structure takes on an animalistic silhouette, with a low crouching stance, thick limbs, and a form that feels more creature than furniture.',
      supplier: 'Muddycap',
      dateAdded: admin.firestore.Timestamp.now(),
      imageUrl: 'https://i.imgur.com/fXnHDHn.png',
    }
  ];

  const batch = db.batch();
  for (const product of products) {
    const ref = db.collection('products').doc();
    batch.set(ref, product);
  }
  await batch.commit();
  console.log(`${products.length} products seeded.`);
}

(async () => {
  try {
    await seedAdmin();
    await seedProducts();
    console.log('\nFirebase seed complete!');
    process.exit(0);
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  }
})();