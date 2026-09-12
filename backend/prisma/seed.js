import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const LOOKUPS = {
  branch: [
    'DAYSPRING', 'GLORYSPRING', 'GOODNEWSSPRING', 'FAITHSPRING',
    'LOYALTYSPRING', 'GRACESPRING', 'UNITYSPRING', 'PEACESPRING', 'SALVATIONSPRING',
  ],
  fellowship: [
    'Transformed Men Fellowship', 'Transformed Law', 'Transformed Shepherds',
    'Transformed Couples', 'Transformed Women Fellowship', 'Transformed Youth Fellowship',
  ],
  basenia: [
    'HeavenSpring Basenia', 'LoveSpring Basenia', 'GraceSpring Basenia',
    'FaithSpring Basenia', 'HopeSpring Basenia', 'JoySpring Basenia',
    'PeaceSpring Basenia', 'GlorySpring Basenia',
  ],
  // Shown as "Worker Groups" in the portal. Names match the public website (join-us.html).
  department: [
    'Communion Stewards', 'Ushering', 'Protocol', 'Hospitality and Welfare',
    'Pure Word', 'Media and Publicity', 'Music', 'Theatre and Arts',
    'Finance', 'Organizing', 'Sounds and Technical', 'Growth',
    'Literature', 'Miscellaneous', "The Pastor's Office",
  ],
  membershipStatus: ['New Convert', 'Regular Member', 'Worker', 'Leader'],
  gender: ['Male', 'Female'],
  meetingType: [
    'LOUCS Report', 'Basenia', 'Friday Service',
    'General Meeting', 'Tithe Collection', 'Souls Won',
  ],
};

const OFFICE_EMAIL = 'tprojectministries@gmail.com';
const OFFICE_PHONE = '0554476730';
const OFFICE_ADDRESS = 'MC3V+2JF, Kumasi';

// Richer than LOOKUPS.branch (name only) — the public branch directory.
const BRANCHES = [
  { name: 'DAYSPRING', region: 'Branch', address: OFFICE_ADDRESS, phone: OFFICE_PHONE, email: OFFICE_EMAIL },
  { name: 'GLORYSPRING', region: 'Branch', address: 'Kumasi' },
  { name: 'GOODNEWSSPRING', region: 'Branch', address: 'Kumasi' },
  { name: 'FAITHSPRING', region: 'Branch', address: 'Kumasi' },
  { name: 'LOYALTYSPRING', region: 'Branch', address: 'Kumasi' },
  { name: 'GRACESPRING', region: 'Branch', address: 'Kumasi' },
  { name: 'UNITYSPRING', region: 'Branch', address: 'Kumasi' },
  { name: 'PEACESPRING', region: 'Branch', address: 'Kumasi' },
  { name: 'SALVATIONSPRING', region: 'Branch', address: 'Kumasi' },
];

// Richer than LOOKUPS.department (name only) — the "Get Involved" descriptions.
const WORKER_GROUPS = [
  { name: 'Communion Stewards', photo: 'assets/team/communion-stewards.jpg', blurb: "Serves with deep reverence in the preparation and administration of the Lord's Supper, upholding the sanctity of one of the Church's most sacred practices." },
  { name: 'Ushering', photo: 'assets/team/ushering.jpg', blurb: 'The first point of contact for members and visitors — warm, professional, and attentive to seating and order throughout the service.' },
  { name: 'Protocol', photo: 'assets/team/protocol.jpg', blurb: "Coordinates ministers, guests, and leadership at every special service and programme, upholding the honour of God's house with precision." },
  { name: 'Hospitality and Welfare', photo: 'assets/team/hospitality-welfare.jpg', blurb: "Cares for members and guests in need — welfare support, refreshments, and visiting the sick — God's hands extended in practical love." },
  { name: 'Pure Word', photo: 'assets/team/pure-word.jpg', blurb: 'Supports discipleship and Bible study so sound doctrine stays the foundation of everything at TPM.' },
  { name: 'Media and Publicity', photo: 'assets/team/media-publicity.jpg', blurb: 'Handles the visual, digital, and communication needs of the ministry — flyers, social media, recording, and content that carries the message beyond the building.' },
  { name: 'Music', photo: 'assets/team/music.jpg', blurb: "Leads the congregation into God's presence through anointed worship — instrumentalists, vocalists, and choir together." },
  { name: 'Theatre and Arts', photo: 'assets/team/theatre-arts.jpg', blurb: 'Brings biblical stories and spiritual truths to life through drama, dance, and mime.' },
  { name: 'Finance', photo: 'assets/team/finance.jpg', blurb: "Faithful stewards of the church's resources — offerings, records, and allocation, with integrity and transparency." },
  { name: 'Organizing', photo: 'assets/team/organizing.jpg', blurb: 'The backbone of every TPM event — planning, logistics, and scheduling so each gathering runs with order and purpose.' },
  { name: 'Sounds and Technical', photo: 'assets/team/sounds-technical.jpg', blurb: 'Runs the audio, lighting, projection, and livestream — mostly behind the scenes, always critical to the service.' },
  { name: 'Growth', photo: 'assets/team/growth.jpg', blurb: 'Follows up with new converts and connects visitors into the church community, so no one falls through the cracks.' },
  { name: 'Literature', photo: 'assets/team/literature.jpg', blurb: "Distributes the ministry's books and devotionals — including the founder's own — to members and the wider public." },
  { name: "The Pastor's Office", photo: 'assets/team/pastors-office.jpg', blurb: "Provides administrative and pastoral support to TPM's leadership — scheduling, correspondence, and day-to-day coordination." },
];

const MINISTRY_NAME = 'Transformation Project Ministries';

// The office's real MoMo/bank accounts, shown on the Give screen.
const GIVING_CHANNELS = [
  { name: 'MTN Momo Pay ID', logo: 'assets/give/mtn-momo.png', accountName: MINISTRY_NAME, number: '074 329', numberLabel: 'Pay ID' },
  { name: 'MTN Mobile Money', logo: 'assets/give/mtn-momo.png', accountName: MINISTRY_NAME, number: '055 447 6730', numberLabel: 'Number' },
  { name: 'Telecel Cash', logo: 'assets/give/telecel-cash.png', accountName: 'Ofori Andrews', number: '050 091 0191', numberLabel: 'Number' },
  { name: 'Stanbic Bank Ghana', logo: 'assets/give/stanbic-bank.png', accountName: MINISTRY_NAME, number: '904 000 970 3211', numberLabel: 'Account Number', isBank: true },
];

const FOUNDER = 'Apostle Andrews Amoh Ofori';

// The Books & Resources shelf.
const BOOKS = [
  { title: 'Daily Drops of Transformation', author: `Volume I · ${FOUNDER}`, cover: 'assets/books/ddot-1.png' },
  { title: 'Daily Drops of Transformation', author: `Volume II · ${FOUNDER}`, cover: 'assets/books/ddot-2.jpg' },
  { title: 'Crossing the Red Sea', author: FOUNDER, cover: 'assets/books/red-sea.jpg' },
  { title: 'New Believer’s Handbook', author: 'TPM Discipleship', cover: 'assets/books/cover-3.png' },
  { title: 'Prayer & Fasting Guide', author: 'TPM Discipleship', cover: 'assets/books/cover-4.png' },
  { title: 'Worker’s Commitment Guide', author: 'TPM Discipleship', cover: 'assets/books/cover-5.png' },
  { title: 'TPM Welcome Guide', author: 'TPM Discipleship', cover: 'assets/books/cover-6.png' },
];

// NOTE: No sample leaders, announcements, reports, or members are seeded.
// The database starts clean — all operational data comes from real leader input.
// Only essential config is seeded: reference lists, invite codes, and one admin.

async function main() {
  // Reference lookups (idempotent via unique [category, value]).
  for (const [category, values] of Object.entries(LOOKUPS)) {
    for (let i = 0; i < values.length; i++) {
      await prisma.lookup.upsert({
        where: { category_value: { category, value: values[i] } },
        update: { sortOrder: i },
        create: { category, value: values[i], sortOrder: i },
      });
    }
  }
  console.log('✓ Lookups seeded');

  // Branch directory (idempotent via unique name).
  for (let i = 0; i < BRANCHES.length; i++) {
    const { name, ...data } = BRANCHES[i];
    await prisma.branchInfo.upsert({
      where: { name },
      update: { ...data, sortOrder: i },
      create: { name, ...data, sortOrder: i },
    });
  }
  console.log('✓ Branch directory seeded');

  // Worker groups (idempotent via unique name).
  for (let i = 0; i < WORKER_GROUPS.length; i++) {
    const { name, ...data } = WORKER_GROUPS[i];
    await prisma.workerGroupInfo.upsert({
      where: { name },
      update: { ...data, sortOrder: i },
      create: { name, ...data, sortOrder: i },
    });
  }
  console.log('✓ Worker groups seeded');

  // Giving channels (idempotent via unique name).
  for (let i = 0; i < GIVING_CHANNELS.length; i++) {
    const { name, ...data } = GIVING_CHANNELS[i];
    await prisma.givingChannel.upsert({
      where: { name },
      update: { ...data, sortOrder: i },
      create: { name, ...data, sortOrder: i },
    });
  }
  console.log('✓ Giving channels seeded');

  // Books (no natural unique key — two titles share a name across volumes —
  // so this only seeds once, on an empty table, rather than upserting).
  if ((await prisma.book.count()) === 0) {
    await prisma.book.createMany({
      data: BOOKS.map((b, i) => ({ ...b, sortOrder: i })),
    });
    console.log('✓ Books seeded');
  } else {
    console.log('• Books already seeded');
  }

  // Invite codes (idempotent via unique code).
  const leaderCode = (process.env.SEED_LEADER_CODE || 'TPM-LEADER-2026').toUpperCase();
  const adminCode = (process.env.SEED_ADMIN_CODE || 'TPM-ADMIN-2026').toUpperCase();
  await prisma.inviteCode.upsert({ where: { code: leaderCode }, update: { active: true, role: 'LEADER' }, create: { code: leaderCode, role: 'LEADER' } });
  await prisma.inviteCode.upsert({ where: { code: adminCode }, update: { active: true, role: 'ADMIN' }, create: { code: adminCode, role: 'ADMIN' } });
  console.log('✓ Invite codes seeded');

  // Optional first admin account.
  const adminEmail = (process.env.SEED_ADMIN_EMAIL || '').trim().toLowerCase();
  const adminPassword = process.env.SEED_ADMIN_PASSWORD || '';
  if (adminEmail && adminPassword) {
    const existing = await prisma.user.findUnique({ where: { email: adminEmail } });
    if (!existing) {
      await prisma.user.create({
        data: {
          firstName: 'TPM', lastName: 'Admin', fullName: 'TPM Admin',
          email: adminEmail, passwordHash: await bcrypt.hash(adminPassword, 12),
          role: 'ADMIN', branch: 'Accra Central', dateJoined: new Date().toISOString().slice(0, 10),
        },
      });
      console.log(`✓ Admin account created: ${adminEmail}`);
    } else {
      console.log(`• Admin account already exists: ${adminEmail}`);
    }
  }

  console.log('Seed complete.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
