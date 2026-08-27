// Small helpers for consistent error handling across routes.

export class ApiError extends Error {
  constructor(status, message, details) {
    super(message);
    this.status = status;
    this.details = details;
  }
}

export const badRequest = (msg, details) => new ApiError(400, msg, details);
export const unauthorized = (msg = 'Not authenticated') => new ApiError(401, msg);
export const forbidden = (msg = 'Not authorized') => new ApiError(403, msg);
export const notFound = (msg = 'Not found', details) => new ApiError(404, msg, details);
export const conflict = (msg = 'Already exists', details) => new ApiError(409, msg, details);

// Wrap async route handlers so thrown/rejected errors reach the error middleware.
export const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);
