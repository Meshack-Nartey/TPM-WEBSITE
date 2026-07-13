// Branch-level access scoping.
//
// Leaders may only see/act on data for their OWN branch; admins are unrestricted.
// If a leader somehow has no branch set, we scope to a sentinel that matches
// nothing (fail closed) rather than exposing every branch.

const NO_BRANCH = '__no_branch__';

export function isLeader(user) {
  return user && user.role === 'LEADER';
}

// The branch a leader is confined to (or null for admins / unrestricted callers).
export function scopedBranch(user) {
  if (!isLeader(user)) return null;
  return user.branch || NO_BRANCH;
}

// A Prisma `where` fragment: `{ branch }` for leaders, `{}` for admins.
export function branchWhere(user) {
  const b = scopedBranch(user);
  return b ? { branch: b } : {};
}
