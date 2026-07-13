import { badRequest } from '../lib/errors.js';

// Validates req.body against a zod schema and replaces it with the parsed value.
export function validateBody(schema) {
  return (req, _res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const details = result.error.issues.map((i) => ({
        field: i.path.join('.'),
        message: i.message,
      }));
      return next(badRequest('Validation failed', details));
    }
    req.body = result.data;
    next();
  };
}
