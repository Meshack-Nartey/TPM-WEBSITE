import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler, badRequest } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// Maps stored category -> the plural key the frontend expects (mockData shape).
const CATEGORY_KEYS = {
  branch: 'branches',
  department: 'departments',
  fellowship: 'fellowships',
  basenia: 'basenias',
  membershipStatus: 'membershipStatuses',
  meetingType: 'meetingTypes',
  gender: 'genders',
};

// GET /api/lookups  — PUBLIC: registration dropdowns need these before login.
router.get(
  '/',
  asyncHandler(async (_req, res) => {
    const rows = await prisma.lookup.findMany({ orderBy: [{ category: 'asc' }, { sortOrder: 'asc' }] });
    const grouped = {};
    for (const key of Object.values(CATEGORY_KEYS)) grouped[key] = [];
    for (const row of rows) {
      const key = CATEGORY_KEYS[row.category];
      if (key) grouped[key].push(row.value);
    }
    res.json(grouped);
  })
);

// GET /api/lookups/manage  — admin: raw rows with IDs, grouped by category (for the management UI).
router.get(
  '/manage',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (_req, res) => {
    const rows = await prisma.lookup.findMany({ orderBy: [{ category: 'asc' }, { sortOrder: 'asc' }] });
    res.json({ lookups: rows, categories: CATEGORY_KEYS });
  })
);

const createSchema = z.object({
  category: z.enum(Object.keys(CATEGORY_KEYS)),
  value: z.string().trim().min(1),
  sortOrder: z.coerce.number().int().optional().default(0),
});

// POST /api/lookups  — admin adds a reference value.
router.post(
  '/',
  authenticate,
  requireRole('ADMIN'),
  validateBody(createSchema),
  asyncHandler(async (req, res) => {
    const lookup = await prisma.lookup.create({ data: req.body });
    res.status(201).json({ lookup });
  })
);

// DELETE /api/lookups/:id  — admin removes a reference value.
router.delete(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.lookup.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
