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
