import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { serializeReport } from '../lib/serialize.js';
import { asyncHandler, forbidden } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';
import { isLeader, scopedBranch, branchWhere } from '../lib/scope.js';

const router = Router();

router.use(authenticate, requireRole('LEADER', 'ADMIN'));

const reportSchema = z.object({
  meetingType: z.string().trim().min(1),
  branch: z.string().trim().min(1),
  date: z.string().trim().min(1),
  attMale: z.coerce.number().int().min(0).default(0),
  attFemale: z.coerce.number().int().min(0).default(0),
  tithe: z.coerce.number().min(0).default(0),
  soulsMale: z.coerce.number().int().min(0).default(0),
  soulsFemale: z.coerce.number().int().min(0).default(0),
  notes: z.string().trim().optional().default(''),
});

// GET /api/reports?type=LOUCS&branch=&from=&to=
// Leaders see only their own branch's records; admins may filter by any branch.
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const { type, branch, from, to } = req.query;
    const where = { ...branchWhere(req.user) };
    if (type) where.meetingType = String(type);
    if (!isLeader(req.user) && branch) where.branch = String(branch);
    if (from || to) {
      where.date = {};
      if (from) where.date.gte = String(from);
      if (to) where.date.lte = String(to);
    }
    const reports = await prisma.report.findMany({ where, orderBy: { date: 'desc' } });
    res.json({ reports: reports.map(serializeReport) });
  })
);

// POST /api/reports
router.post(
  '/',
  validateBody(reportSchema),
  asyncHandler(async (req, res) => {
    // Leaders can only submit records for their own branch.
    const branch = isLeader(req.user) ? scopedBranch(req.user) : req.body.branch;
    const report = await prisma.report.create({
      data: { ...req.body, branch, submittedById: req.user.id },
    });
    res.status(201).json({ report: serializeReport(report) });
  })
);

// DELETE /api/reports/:id
router.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    if (isLeader(req.user)) {
      const existing = await prisma.report.findUnique({ where: { id: req.params.id } });
      if (!existing || existing.branch !== scopedBranch(req.user)) {
        throw forbidden('This record belongs to another branch.');
      }
    }
    await prisma.report.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
