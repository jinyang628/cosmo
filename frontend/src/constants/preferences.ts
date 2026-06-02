import { z } from 'zod';

export const DISTANCE_MIN_METERS = 100;
export const DISTANCE_MAX_METERS = 50000;
export const BUDGET_OPTIONS = z.enum(['$', '$$', '$$$', '$$$$']);
export const DIET_OPTIONS = z.enum(['Spicy ok', 'Vegetarian', 'Vegan', 'Pescatarian', 'No carbs']);
