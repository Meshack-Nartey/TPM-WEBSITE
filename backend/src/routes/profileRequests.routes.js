import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { asyncHandler, badRequest, notFound } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { validateBody } from '../middleware/validate.js';

const router = Router();

// Maps the human-readable field label (as shown in the portal) to the
// User column it updates when a request is approved.
const FIELD_TO_COLUMN = {
  'First Name': 'firstName',
  'Last Name': 'lastName',
  Phone: 'phone',
  Branch: 'branch',
  'Worker Group': 'department',
  Department: 'department',
  Fellowship: 'fellowship',
};

const createSchema = z.object({
  field: z.string().trim().min(1),
  newValue: z.string().trim().min(1),
});

// POST /api/profile-requests  — any authenticated user requests a change to their own profile.
router.post(
  '/',
  authenticate,
  validateBody(createSchema),
  asyncHandler(async (req, res) => {
    const { field, newValue } = req.body;
    const column = FIELD_TO_COLUMN[field];
    if (!column) throw badRequest(`Field "${field}" cannot be changed via request.`);

    const oldValue = req.user[column] || '—';
    const request = await prisma.profileRequest.create({
      data: {
        userId: req.user.id,
        memberName: req.user.fullName,
        memberEmail: req.user.email,
        field,
        oldValue: String(oldValue),
        newValue,
        status: 'PENDING',
      },
    });
    res.status(201).json({ request });
  })
);

// GET /api/profile-requests?status=PENDING  — admin review queue.
router.get(
  '/',
  authenticate,
  requireRole('ADMIN'),
  asyncHandler(async (req, res) => {
    const { status } = req.query;
    const where = {};
    if (status) where.status = String(status).toUpperCase();
    const requests = await prisma.profileRequest.findMany({ where, orderBy: { createdAt: 'desc' } });
    res.json({ requests });
  })
);

const decisionSchema = z.object({
  status: z.enum(['APPROVED', 'REJECTED']),
});

// PATCH /api/profile-requests/:id  — admin approves/rejects. Approving APPLIES the change.
router.patch(
  '/:id',
  authenticate,
  requireRole('ADMIN'),
  validateBody(decisionSchema),
  asyncHandler(async (req, res) => {
    const { status } = req.body;
    const request = await prisma.profileRequest.findUnique({ where: { id: req.params.id } });
    if (!request) throw notFound('Request not found.');
    if (request.status !== 'PENDING') throw badRequest('This request has already been reviewed.');

    const result = await prisma.$transaction(async (tx) => {
      const updated = await tx.profileRequest.update({
        where: { id: request.id },
        data: { status, reviewedById: req.user.id },
      });

      // Apply the change to the user's profile on approval.
      if (status === 'APPROVED') {
        const column = FIELD_TO_COLUMN[request.field];
        const target = request.userId
          ? await tx.user.findUnique({ where: { id: request.userId } })
          : await tx.user.findUnique({ where: { email: request.memberEmail } });

        if (column && target) {
          const data = { [column]: request.newValue };
          if (column === 'firstName' || column === 'lastName') {
            const first = column === 'firstName' ? request.newValue : target.firstName;
            const last = column === 'lastName' ? request.newValue : target.lastName;
            data.fullName = `${first} ${last}`.trim();
          }
          await tx.user.update({ where: { id: target.id }, data });
        }
      }
      return updated;
    });

    res.json({ request: result });
  })
);

export default router;
