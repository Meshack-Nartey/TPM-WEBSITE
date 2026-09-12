import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// GET /api/books — the Books & Resources shelf (any authenticated user).
router.get(
  '/',
  authenticate,
  asyncHandler(async (_req, res) => {
    const books = await prisma.book.findMany({
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    res.json({ books });
  })
);

const schema = z.object({
  title: z.string().trim().min(1),
  author: z.string().trim().min(1),
  cover: z.string().trim().min(1),
  sortOrder: z.coerce.number().int().optional().default(0),
});

router.post(
  '/',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema),
  asyncHandler(async (req, res) => {
    const book = await prisma.book.create({ data: req.body });
    res.status(201).json({ book });
  })
);

router.patch(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  validateBody(schema.partial()),
  asyncHandler(async (req, res) => {
    const book = await prisma.book.update({
      where: { id: req.params.id },
      data: req.body,
    });
    res.json({ book });
  })
);

router.delete(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    await prisma.book.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
