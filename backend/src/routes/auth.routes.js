import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';
import { signToken } from '../lib/jwt.js';
import { publicUser } from '../lib/serialize.js';
import { asyncHandler, badRequest, unauthorized, conflict, notFound } from '../lib/errors.js';
import { validateBody } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { isProd } from '../config/env.js';

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

const forgotPasswordSchema = z.object({
  email: z.string().trim().toLowerCase().email(),
  newPassword: z.string().min(6, 'Password must be at least 6 characters'),
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
      if (!match) {
        throw badRequest('Invalid invite code for the selected role.', [
          { field: 'inviteCode', message: 'Invalid invite code for the selected role.' },
        ]);
      }
    }

    const existing = await prisma.user.findUnique({ where: { email: data.email } });
    if (existing) {
      throw conflict('An account with this email already exists.', [
        { field: 'email', message: 'An account with this email already exists.' },
      ]);
    }

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

// POST /api/auth/forgot-password
//
// DEV-ONLY SHORTCUT: resets the password for a known email with no proof of
// ownership beyond the email address itself, because there is no email
// sender wired up yet to deliver a reset link. Hard-disabled outside
// development (see the isProd check below) so this can't be reached in
// production even by accident — before real users touch this, it needs a
// proper token flow (short-lived signed token emailed to the address,
// confirmed before the password actually changes), and only then should the
// isProd guard come out.
router.post(
  '/forgot-password',
  validateBody(forgotPasswordSchema),
  asyncHandler(async (req, res) => {
    if (isProd) throw notFound('Not found');

    const { email, newPassword } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.active) {
      throw notFound('No account found with that email.', [
        { field: 'email', message: 'No account found with that email.' },
      ]);
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({ where: { email }, data: { passwordHash } });

    res.json({ ok: true });
  })
);

export default router;
