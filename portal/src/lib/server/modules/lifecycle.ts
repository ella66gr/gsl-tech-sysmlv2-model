import type { OperationalState, InstallationState } from '$lib/types.js';

// ── Operational state machine ────────────────────────────────────────

// Legal operational transitions: [from, to]
const OPERATIONAL_TRANSITIONS: [OperationalState, OperationalState][] = [
    ['draft', 'active'],
    ['active', 'paused'],
    ['active', 'stopped'],
    ['paused', 'active'],
    ['paused', 'stopped'],
    ['stopped', 'draft']
];

export function validateOperationalTransition(
    from: OperationalState,
    to: OperationalState
): { valid: boolean; reason?: string } {
    const legal = OPERATIONAL_TRANSITIONS.some(([f, t]) => f === from && t === to);
    if (legal) return { valid: true };
    return {
        valid: false,
        reason: `Cannot transition operational state from '${from}' to '${to}'. Legal transitions from '${from}': ${
            OPERATIONAL_TRANSITIONS.filter(([f]) => f === from).map(([, t]) => `'${t}'`).join(', ') || 'none'
        }.`
    };
}

// ── Installation state machine ───────────────────────────────────────

const INSTALLATION_TRANSITIONS: [InstallationState, InstallationState][] = [
    ['installed', 'trashed'],
    ['trashed', 'installed']
];

export function validateInstallationTransition(
    from: InstallationState,
    to: InstallationState
): { valid: boolean; reason?: string } {
    const legal = INSTALLATION_TRANSITIONS.some(([f, t]) => f === from && t === to);
    if (legal) return { valid: true };
    return {
        valid: false,
        reason: `Cannot transition installation state from '${from}' to '${to}'.`
    };
}

// ── State display metadata ───────────────────────────────────────────

export interface StateDisplay {
    label: string;
    badgeColor: 'yellow' | 'green' | 'orange' | 'red' | 'gray';
    dotClass: string;
    borderClass: string;
}

export function getOperationalStateDisplay(state: OperationalState): StateDisplay {
    switch (state) {
        case 'draft':   return { label: 'Draft',   badgeColor: 'yellow', dotClass: 'bg-yellow-400', borderClass: 'border-l-yellow-400' };
        case 'active':  return { label: 'Active',  badgeColor: 'green',  dotClass: 'bg-green-500',  borderClass: 'border-l-green-500'  };
        case 'paused':  return { label: 'Paused',  badgeColor: 'orange', dotClass: 'bg-orange-400', borderClass: 'border-l-orange-400' };
        case 'stopped': return { label: 'Stopped', badgeColor: 'red',    dotClass: 'bg-red-400',    borderClass: 'border-l-red-400'    };
    }
}

// ── Available actions from each state ────────────────────────────────

export interface LifecycleAction {
    verb: string;
    targetState: OperationalState;
    style: 'primary' | 'warning' | 'danger' | 'secondary';
}

export function getAvailableActions(state: OperationalState): LifecycleAction[] {
    switch (state) {
        case 'draft':
            return [{ verb: 'Activate', targetState: 'active', style: 'primary' }];
        case 'active':
            return [
                { verb: 'Pause',  targetState: 'paused',  style: 'warning' },
                { verb: 'Stop',   targetState: 'stopped', style: 'danger'  }
            ];
        case 'paused':
            return [
                { verb: 'Resume', targetState: 'active',  style: 'primary'  },
                { verb: 'Stop',   targetState: 'stopped', style: 'danger'   }
            ];
        case 'stopped':
            return [{ verb: 'Reset', targetState: 'draft', style: 'secondary' }];
    }
}

// Primary (most natural) action for dashboard cards
export function getPrimaryAction(state: OperationalState): LifecycleAction {
    const actions = getAvailableActions(state);
    return actions[0];
}

// ── Compound trash logic ──────────────────────────────────────────────

// Returns the operational state to record before trashing (if any)
export function getPreTrashStop(operationalState: OperationalState): OperationalState | null {
    if (operationalState === 'active' || operationalState === 'paused') {
        return 'stopped';
    }
    return null;
}
