import { createId } from '@paralleldrive/cuid2';

// Common Feedback constants
export const Feedback = {
  None: 0,
  Like: 1,
  Dislike: 2,
  Neutral: 3,
} as const;

export type FeedbackType = (typeof Feedback)[keyof typeof Feedback];

// Helper for ID generation (can be imported across files)
export { createId };
