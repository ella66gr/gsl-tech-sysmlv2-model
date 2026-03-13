/**
 * Counter Page Load Function — CSW Extension Phase 5
 *
 * Fetches the active catalogue on page load so item tiles
 * render immediately without a loading spinner. The catalogue
 * is stable reference data — appropriate for a load function
 * rather than client-side polling.
 */

import type { PageLoad } from './$types';
import type { CatalogueItemView } from '@coffeeshop/shared';

export const load: PageLoad = async ({ fetch }) => {
  try {
    const response = await fetch('/api/catalogue');

    if (!response.ok) {
      console.error(`Catalogue fetch failed: ${response.status}`);
      return { catalogue: [] as CatalogueItemView[], catalogueError: 'Failed to load catalogue' };
    }

    const catalogue: CatalogueItemView[] = await response.json();
    return { catalogue, catalogueError: '' };
  } catch (err) {
    console.error('Catalogue fetch error:', err);
    return { catalogue: [] as CatalogueItemView[], catalogueError: 'Catalogue service unavailable' };
  }
};
