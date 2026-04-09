/**
 * Compute a simple health score (0–100) from simulation metrics.
 *
 * Formula: 100 - (issueRate × 10) + (transactionsPerDay × 2), clamped to 0–100.
 * Higher is better. Issues hurt; transaction volume helps.
 */
export function computeHealthScore(issueRate: number, transactions: number, durationDays: number): number {
    const transactionsPerDay = durationDays > 0 ? transactions / durationDays : 0;
    const raw = 100 - (issueRate * 10) + (transactionsPerDay * 2);
    return Math.round(Math.max(0, Math.min(100, raw)));
}

/**
 * Return a colour class for a health score.
 */
export function healthScoreColor(score: number): string {
    if (score >= 75) return 'text-green-600 dark:text-green-400';
    if (score >= 50) return 'text-yellow-600 dark:text-yellow-400';
    return 'text-red-600 dark:text-red-400';
}

/**
 * Return a background colour class for a health score badge.
 */
export function healthScoreBgColor(score: number): string {
    if (score >= 75) return 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300';
    if (score >= 50) return 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300';
    return 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300';
}

/**
 * Format a currency amount.
 */
export function formatCurrency(amount: number, currency = 'GBP'): string {
    return new Intl.NumberFormat('en-GB', { style: 'currency', currency }).format(amount);
}

/**
 * Format a number with locale-appropriate separators.
 */
export function formatNumber(n: number): string {
    return n.toLocaleString('en-GB');
}
