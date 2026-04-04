import { goto } from '$app/navigation';
import { getContext } from 'svelte';
import type { NavigationEntry, PageStateContract, JourneyExport } from '$lib/types/navigation';

const SESSION_KEY = 'ontara-nav-stack';

class NavigationStore {
  stack = $state<NavigationEntry[]>([]);
  currentIndex = $state(-1);

  canGoBack = $derived(this.currentIndex > 0);
  canGoForward = $derived(this.currentIndex < this.stack.length - 1);

  get currentEntry(): NavigationEntry | null {
    return this.stack[this.currentIndex] ?? null;
  }

  private contract: PageStateContract | null = null;

  constructor() {
    if (typeof window !== 'undefined') {
      const saved = sessionStorage.getItem(SESSION_KEY);
      if (saved) {
        try {
          const parsed = JSON.parse(saved);
          this.stack = parsed.stack ?? [];
          this.currentIndex = parsed.currentIndex ?? -1;
        } catch {
          // Corrupt session data — start fresh
        }
      }
    }
  }

  register(contract: PageStateContract): void {
    this.contract = contract;
    const entry = this.stack[this.currentIndex];
    if (entry?.pageState) {
      contract.restoreState(entry.pageState);
    }
  }

  refineCurrentLabel(label: string): void {
    if (this.currentIndex >= 0 && this.stack[this.currentIndex]) {
      this.stack[this.currentIndex] = { ...this.stack[this.currentIndex], label };
      this.persist();
    }
  }

  navigateTo(opts: {
    route: string;
    label: string;
    relationship?: string;
    query?: Record<string, string>;
  }): void {
    // Capture current page state before navigating away
    if (this.contract && this.currentIndex >= 0) {
      const state = this.contract.captureState();
      this.stack[this.currentIndex] = { ...this.stack[this.currentIndex], pageState: state };
    }

    // Truncate any forward history
    const newStack = this.stack.slice(0, this.currentIndex + 1);

    // Push new entry
    const entry: NavigationEntry = {
      id: crypto.randomUUID(),
      route: opts.route,
      label: opts.label,
      relationship: opts.relationship,
      timestamp: new Date().toISOString(),
    };
    newStack.push(entry);
    this.stack = newStack;
    this.currentIndex = this.stack.length - 1;

    this.persist();

    const queryString = opts.query
      ? '?' + new URLSearchParams(opts.query).toString()
      : '';
    goto(opts.route + queryString);
  }

  goBack(): void {
    if (!this.canGoBack) return;
    this.captureCurrentState();
    this.currentIndex--;
    this.persist();
    goto(this.stack[this.currentIndex].route);
  }

  goForward(): void {
    if (!this.canGoForward) return;
    this.captureCurrentState();
    this.currentIndex++;
    this.persist();
    goto(this.stack[this.currentIndex].route);
  }

  goToIndex(index: number): void {
    if (index < 0 || index >= this.stack.length || index === this.currentIndex) return;
    this.captureCurrentState();
    this.currentIndex = index;
    this.persist();
    goto(this.stack[this.currentIndex].route);
  }

  reset(): void {
    this.stack = [];
    this.currentIndex = -1;
    this.contract = null;
    if (typeof window !== 'undefined') {
      sessionStorage.removeItem(SESSION_KEY);
    }
  }

  exportJourney(): JourneyExport {
    return {
      startTime: this.stack[0]?.timestamp ?? new Date().toISOString(),
      exportTime: new Date().toISOString(),
      steps: this.stack.map((e) => ({
        label: e.label,
        route: e.route,
        relationship: e.relationship,
        timestamp: e.timestamp,
      })),
    };
  }

  private captureCurrentState(): void {
    if (this.contract && this.currentIndex >= 0) {
      const state = this.contract.captureState();
      this.stack[this.currentIndex] = { ...this.stack[this.currentIndex], pageState: state };
    }
  }

  private persist(): void {
    if (typeof window !== 'undefined') {
      sessionStorage.setItem(
        SESSION_KEY,
        JSON.stringify({ stack: this.stack, currentIndex: this.currentIndex })
      );
    }
  }
}

export function createNavigationStore(): NavigationStore {
  return new NavigationStore();
}

export function useNavigation(): NavigationStore {
  return getContext<NavigationStore>('navigation-store');
}
