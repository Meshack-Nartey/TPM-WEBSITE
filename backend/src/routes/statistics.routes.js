import { Router } from 'express';
import { prisma } from '../lib/prisma.js';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { branchWhere } from '../lib/scope.js';

const router = Router();

router.use(authenticate, requireRole('LEADER', 'ADMIN'));

const attendanceOf = (r) => Number(r.attMale || 0) + Number(r.attFemale || 0);
const soulsOf = (r) => Number(r.soulsMale || 0) + Number(r.soulsFemale || 0);

// GET /api/statistics  — real aggregates computed from reports + members.
router.get(
  '/',
  asyncHandler(async (req, res) => {
    // Leaders see only their branch's figures; admins see the whole church.
    const scope = branchWhere(req.user);
    const [totalMembers, reports] = await Promise.all([
      prisma.member.count({ where: scope }),
      prisma.report.findMany({ where: scope, orderBy: { date: 'asc' } }),
    ]);

    const now = new Date();
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
      .toISOString()
      .slice(0, 10);
    const monthPrefix = now.toISOString().slice(0, 7); // "YYYY-MM"

    let attendanceThisWeek = 0;
    let titheThisMonth = 0;
    let soulsWon = 0;
    const byDate = new Map();
    const byBranch = new Map();

    for (const r of reports) {
      const date = String(r.date || '');
      if (date >= weekAgo) attendanceThisWeek += attendanceOf(r);
      if (date.startsWith(monthPrefix)) {
        titheThisMonth += Number(r.tithe || 0);
        soulsWon += soulsOf(r);
      }
      byDate.set(date, (byDate.get(date) || 0) + attendanceOf(r));
      if (r.branch) byBranch.set(r.branch, (byBranch.get(r.branch) || 0) + attendanceOf(r));
    }

    // Attendance trend: last 8 distinct dates.
    const trendDates = [...byDate.keys()].sort().slice(-8);
    const attendanceTrends = {
      labels: trendDates,
      data: trendDates.map((d) => byDate.get(d)),
    };

    // Branch comparison: sorted by attendance desc.
    const branchEntries = [...byBranch.entries()].sort((a, b) => b[1] - a[1]);
    const branchComparisons = {
      labels: branchEntries.map((e) => e[0]),
      attendance: branchEntries.map((e) => e[1]),
    };

    res.json({
      statistics: {
        totalMembers,
        attendanceThisWeek,
        titheThisMonth: Math.round(titheThisMonth * 100) / 100,
        soulsWon,
      },
      attendanceTrends,
      branchComparisons,
    });
  })
);

export default router;
