import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// GET /api/announcements  — public, same as the news feed on the website;
// a guest browsing the app before ever signing in should still see it.
router.get(
  '/',
  asyncHandler(async (_req, res) => {
    const announcements = await prisma.announcement.findMany({
      where: { active: true },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'desc' }],
    });
    res.json({ announcements });
  })
);

const schema = z.object({
  tag: z.string().trim().min(1),
  title: z.string().trim().min(1),
  body: z.string().trim().min(1),
  date: z.string().trim().optional().default(''),
  active: z.boolean().optional().default(true),
  sortOrder: z.coerce.number().int().optional().default(0),
});

// Create / update / delete: admins, and leaders (the media team runs this
// day to day — restricting it to admins only meant every flyer had to go
// through the pastor's office).
router.post(
  '/',
  authenticate,
  requireRole('LEADER', 'ADMIN'),
  validateBody(schema),
  asyncHandler(async (req, res) => {
    const announcement = await prisma.announcement.create({ data: req.body });
    res.status(201).json({ announcement });
  })
);

router.patch(
  '/:id',
  authenticate,
  requireRole('LEADER', 'ADMIN'),
  validateBody(schema.partial()),
  asyncHandler(async (req, res) => {
    const announcement = await prisma.announcement.update({
      where: { id: req.params.id },
      data: req.body,
    });
    res.json({ announcement });
  })
);

router.delete(
  '/:id',
  authenticate,
  requireRole('LEADER', 'ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.announcement.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
