export function distanceProgressToMeters(progress: number, minMeters: number, maxMeters: number) {
  const clamped = clamp(progress);
  const ratio = maxMeters / minMeters;
  const rawMeters = minMeters * Math.pow(ratio, clamped);

  if (rawMeters < 1000) {
    return Math.round(rawMeters / 10) * 10;
  }

  return Math.round(rawMeters / 100) * 100;
}

export function formatDistance(meters: number) {
  if (meters < 1000) {
    return `${meters}m`;
  }

  return `${Number((meters / 1000).toFixed(meters >= 10000 ? 0 : 1))}km`;
}

export function clamp(value: number) {
  return Math.max(0, Math.min(1, value));
}
