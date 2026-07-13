import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler, forbidden } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';
import { isLeader, scopedBranch, branchWhere } from '../lib/scope.js';

const router = Router();

// Member registry is for leaders and admins.
router.use(authenticate, requireRole('LEADER', 'ADMIN'));

const memberSchema = z.object({
  firstName: z.string().trim().min(1),
  middleName: z.string().trim().optional().default(''),
  lastName: z.string().trim().min(1),
  dob: z.string().trim().optional().default(''),
  gender: z.string().trim().optional().default(''),
  phone: z.string().trim().optional().default(''),
  email: z.string().trim().toLowerCase().optional().default(''),
  address: z.string().trim().optional().default(''),
  branch: z.string().trim().optional().default(''),
  department: z.string().trim().optional().default(''),
  fellowship: z.string().trim().optional().default(''),
  dateJoined: z.string().trim().optional().default(''),
  membershipStatus: z.string().trim().optional().default(''),
  emergencyContactName: z.string().trim().optional().default(''),
  emergencyContactPhone: z.string().trim().optional().default(''),
});

// GET /api/members?branch=&status=&search=
// Leaders are restricted to their own branch; admins may filter by any branch.
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const { branch, status, search } = req.query;
    const where = { ...branchWhere(req.user) };
    if (!isLeader(req.user) && branch) where.branch = String(branch);
    if (status) where.membershipStatus = String(status);
    if (search) {
      where.OR = [
        { fullName: { contains: String(search), mode: 'insensitive' } },
        { phone: { contains: String(search), mode: 'insensitive' } },
        { email: { contains: String(search), mode: 'insensitive' } },
      ];
    }
    const members = await prisma.member.findMany({ where, orderBy: { createdAt: 'desc' } });
    res.json({ members });
  })
);

// POST /api/members
router.post(
  '/',
  validateBody(memberSchema),
  asyncHandler(async (req, res) => {
    const d = req.body;
    // Leaders can only register members into their own branch.
    const branch = isLeader(req.user) ? scopedBranch(req.user) : d.branch;
    const member = await prisma.member.create({
      data: {
        ...d,
        branch,
        fullName: `${d.firstName} ${d.lastName}`,
        registeredById: req.user.id,
      },
    });
    res.status(201).json({ member });
  })
);

// Ensures a leader may only touch a member in their own branch.
async function assertBranchAccess(req, memberId) {
  if (!isLeader(req.user)) return;
  const existing = await prisma.member.findUnique({ where: { id: memberId } });
  if (!existing || existing.branch !== scopedBranch(req.user)) {
    throw forbidden('This member belongs to another branch.');
  }
}

// PATCH /api/members/:id
router.patch(
  '/:id',
  validateBody(memberSchema.partial()),
  asyncHandler(async (req, res) => {
    await assertBranchAccess(req, req.params.id);
    const data = { ...req.body };
    if (isLeader(req.user)) delete data.branch; // leaders can't move a member to another branch
    if (data.firstName || data.lastName) {
      const current = await prisma.member.findUnique({ where: { id: req.params.id } });
      const first = data.firstName || current?.firstName || '';
      const last = data.lastName || current?.lastName || '';
      data.fullName = `${first} ${last}`.trim();
    }
    const member = await prisma.member.update({ where: { id: req.params.id }, data });
    res.json({ member });
  })
);

// DELETE /api/members/:id
router.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    await assertBranchAccess(req, req.params.id);
    await prisma.member.delete({ where: { id: req.params.id } });
    res.json({ ok: true });
  })
);

export default router;
