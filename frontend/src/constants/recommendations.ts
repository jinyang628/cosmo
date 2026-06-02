export type FoodMood = 'fast' | 'fresh' | 'cozy' | 'treat';

export type Recommendation = {
  id: string;
  name: string;
  cuisine: string;
  dish: string;
  distance: string;
  etaMinutes: number;
  price: '$' | '$$' | '$$$';
  rating: number;
  mood: FoodMood;
  reason: string;
  tags: string[];
  accentColor: string;
};

export const foodMoods: { id: FoodMood; label: string }[] = [
  { id: 'fast', label: 'Fast' },
  { id: 'fresh', label: 'Fresh' },
  { id: 'cozy', label: 'Cozy' },
  { id: 'treat', label: 'Treat' },
];

export const recommendations: Recommendation[] = [
  {
    id: 'golden-noodle-bowl',
    name: 'Golden Noodle Bowl',
    cuisine: 'Vietnamese',
    dish: 'lemongrass chicken banh mi',
    distance: '0.3 mi',
    etaMinutes: 9,
    price: '$',
    rating: 4.8,
    mood: 'fast',
    reason: 'Quick, savory, and easy to eat between plans.',
    tags: ['high-protein', 'takeout', 'crisp'],
    accentColor: '#F6C453',
  },
  {
    id: 'little-leaf-kitchen',
    name: 'Little Leaf Kitchen',
    cuisine: 'Mediterranean',
    dish: 'herbed falafel grain bowl',
    distance: '0.5 mi',
    etaMinutes: 14,
    price: '$$',
    rating: 4.7,
    mood: 'fresh',
    reason: 'Bright greens, warm grains, and enough crunch to feel alive.',
    tags: ['vegetarian', 'balanced', 'walkable'],
    accentColor: '#65B891',
  },
  {
    id: 'stone-soup-corner',
    name: 'Stone Soup Corner',
    cuisine: 'Japanese',
    dish: 'miso ramen with ajitama',
    distance: '0.7 mi',
    etaMinutes: 18,
    price: '$$',
    rating: 4.6,
    mood: 'cozy',
    reason: 'Warm broth, low decision fatigue, excellent rainy-day energy.',
    tags: ['comfort', 'dine-in', 'warm'],
    accentColor: '#E07A5F',
  },
  {
    id: 'mango-hour',
    name: 'Mango Hour',
    cuisine: 'Thai',
    dish: 'green curry with jasmine rice',
    distance: '0.8 mi',
    etaMinutes: 16,
    price: '$$',
    rating: 4.9,
    mood: 'treat',
    reason: 'A little creamy, a little spicy, very worth stepping out for.',
    tags: ['spicy', 'dinner', 'popular'],
    accentColor: '#F28482',
  },
];

export const diningSignals = [
  {
    label: 'Distance',
    value: 'Under 1 mi',
  },
  {
    label: 'Timing',
    value: 'Ready in 20 min',
  },
  {
    label: 'Budget',
    value: '$-$$',
  },
  {
    label: 'Diet',
    value: 'Flexible',
  },
];
