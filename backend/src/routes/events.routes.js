import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// GET /api/events (any authenticated user).
router.get(
  '/',
  authenticate,
  asyncHandler(async (_req, res) => {
    const events = await prisma.event.findMany({
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    res.json({ events });
  })
);

const schema = z.object({
  tag: z.string().trim().min(1),
  title: z.string().trim().min(1),
  location: z.string().trim().min(1),
  when: z.string().trim().min(1),
  day: z.string().trim().optional(),
  month: z.string().trim().optional(),
  description: z.string().trim().min(1),
  image: z.string().trim().min(1),
  sortOrder: z.coerce.number().int().optional().default(0),
});

router.post(
  '/',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema),
  asyncHandler(async (req, res) => {
    const event = await prisma.event.create({ data: req.body });
    res.status(201).json({ event });
  })
);

router.patch(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema.partial()),
  asyncHandler(async (req, res) => {
    const event = await prisma.event.update({
      where: { id: req.params.id },
      data: req.body,
    });
    res.json({ event });
  })
);

router.delete(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.event.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
