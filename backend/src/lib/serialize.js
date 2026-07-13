// Convert DB records into safe JSON for the client.

// Never leak the password hash.
export function publicUser(u) {
  if (!u) return null;
  const { passwordHash, ...rest } = u;
  return rest;
}

// Prisma returns Decimal for `tithe`; make it a plain number for JSON.
export function serializeReport(r) {
  if (!r) return null;
  return { ...r, tithe: r.tithe != null ? Number(r.tithe) : 0 };
}
