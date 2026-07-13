import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { signToken } from '../lib/jwt.js';
import { publicUser } from '../lib/serialize.js';
import { asyncHandler, badRequest, unauthorized, conflict } from '../lib/errors.js';
import { validateBody } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

const registerSchema = z.object({
  firstName: z.string().trim().min(1),
  lastName: z.string().trim().min(1),
  email: z.string().trim().toLowerCase().email(),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  role: z.enum(['MEMBER', 'LEADER', 'ADMIN']).default('MEMBER'),
  inviteCode: z.string().trim().optional(),
  phone: z.string().trim().optional().default(''),
  branch: z.string().trim().optional().default(''),
  department: z.string().trim().optional().default(''),
  fellowship: z.string().trim().optional().default(''),
  dateJoined: z.string().trim().optional().default(''),
});

const loginSchema = z.object({
  email: z.string().trim().toLowerCase().email(),
  password: z.string().min(1),
});

// POST /api/auth/register
router.post(
  '/register',
  validateBody(registerSchema),
  asyncHandler(async (req, res) => {
    const data = req.body;

    // Leader/admin roles must present a valid, active invite code.
    if (data.role !== 'MEMBER') {
      const code = (data.inviteCode || '').toUpperCase();
      const match = await prisma.inviteCode.findFirst({
        where: { code, role: data.role, active: true },
      });
      if (!match) throw badRequest('Invalid invite code for the selected role.');
    }

    const existing = await prisma.user.findUnique({ where: { email: data.email } });
    if (existing) throw conflict('An account with this email already exists.');

    const passwordHash = await bcrypt.hash(data.password, 12);
    const user = await prisma.user.create({
      data: {
        firstName: data.firstName,
        lastName: data.lastName,
        fullName: `${data.firstName} ${data.lastName}`,
        email: data.email,
        passwordHash,
        role: data.role,
        phone: data.phone,
        branch: data.branch,
        department: data.department,
        fellowship: data.fellowship,
        dateJoined: data.dateJoined,
      },
    });

    const token = signToken(user);
    res.status(201).json({ token, user: publicUser(user) });
  })
);

// POST /api/auth/login
router.post(
  '/login',
  validateBody(loginSchema),
  asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.active) throw unauthorized('Invalid email or password.');

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) throw unauthorized('Invalid email or password.');

    const token = signToken(user);
    res.json({ token, user: publicUser(user) });
  })
);

// GET /api/auth/me
router.get(
  '/me',
  authenticate,
  asyncHandler(async (req, res) => {
    res.json({ user: publicUser(req.user) });
  })
);

export default router;
