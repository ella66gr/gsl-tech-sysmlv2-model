/**
 * GenderSense — Tau Prolog Feasibility Spike
 * =============================================
 *
 * Tests whether Tau Prolog (pure JavaScript Prolog) is viable for
 * Tier 2 inference reasoning within the GenderSense architecture.
 *
 * Evaluation criteria:
 * 1. Loads and runs — basic program consultation and query
 * 2. Negation as failure — \+ for "why not eligible" queries
 * 3. Arithmetic comparison — numeric comparisons (Weeks > Required)
 * 4. Multiple answers — enumerate all reasons for non-eligibility
 * 5. Performance — query response time < 10ms for individual queries
 * 6. Explanation traces — extract which rules fired
 * 7. Temporal compatibility — theoretical assessment (no Node APIs)
 * 8. Bundle size — Tau Prolog module size
 * 9. Rule generation — could a generator produce Prolog from SysML?
 *
 * Phase 5, Stage 5 of Knowledge Layer Elaboration.
 *
 * Usage:
 *   cd spikes/tau-prolog-spike
 *   npm install tau-prolog
 *   node spike.mjs
 */

import pl from 'tau-prolog';

// ---------------------------------------------------------------
// Clinical rules as Prolog program
// ---------------------------------------------------------------

const CLINICAL_RULES = `
% ============================================================
% GenderSense Clinical Rules — Tau Prolog Spike
%
% These rules model a subset of the GenderSense constraint
% library and self-knowledge architecture as Prolog facts
% and rules. In a real system, facts would be asserted
% dynamically from CDR query results and Temporal state.
% ============================================================

% --- Patient facts (normally derived from CDR queries) ---

patient(patient_001).
patient(patient_002).
patient(patient_003).

% Patient 001: fully eligible, monitoring up to date
has_consent(patient_001).
has_information_provided(patient_001).
has_baseline_bloods_resulted(patient_001).
has_baseline_bloods_reviewed(patient_001).
has_clinical_review(patient_001).
weeks_since_last_test(patient_001, 8).
required_monitoring_interval(patient_001, 12).
prescription_status(patient_001, active).

% Patient 002: missing consent, monitoring overdue
has_information_provided(patient_002).
has_baseline_bloods_resulted(patient_002).
has_baseline_bloods_reviewed(patient_002).
has_clinical_review(patient_002).
weeks_since_last_test(patient_002, 16).
required_monitoring_interval(patient_002, 12).
prescription_status(patient_002, active).

% Patient 003: has consent but baseline bloods not reviewed
has_consent(patient_003).
has_information_provided(patient_003).
has_baseline_bloods_resulted(patient_003).
weeks_since_last_test(patient_003, 4).
required_monitoring_interval(patient_003, 12).


% ============================================================
% Tier 1 constraint rules (mirrors ConstraintLibrary)
% ============================================================

% ConsentRecordedConstraint
consent_recorded(P) :-
    patient(P),
    has_consent(P).

% PatientInformationProvidedConstraint
information_provided(P) :-
    patient(P),
    has_information_provided(P).

% BaselineBloodsReviewedConstraint
baseline_bloods_reviewed(P) :-
    patient(P),
    has_baseline_bloods_resulted(P),
    has_baseline_bloods_reviewed(P).

% ClinicalReviewCompletedConstraint
clinical_review_completed(P) :-
    patient(P),
    has_clinical_review(P).

% BloodMonitoringIntervalConstraint
monitoring_up_to_date(P) :-
    patient(P),
    weeks_since_last_test(P, Weeks),
    required_monitoring_interval(P, Required),
    Weeks =< Required.

monitoring_overdue(P) :-
    patient(P),
    weeks_since_last_test(P, Weeks),
    required_monitoring_interval(P, Required),
    Weeks > Required.


% ============================================================
% Compound eligibility (Tier 2 — inference chain)
% ============================================================

% A patient is eligible for hormone therapy if ALL prerequisites met
eligible_for_hormone_therapy(P) :-
    consent_recorded(P),
    information_provided(P),
    baseline_bloods_reviewed(P),
    clinical_review_completed(P).

% Explanation: why is a patient eligible?
why_eligible(P, 'All prerequisites met: consent, information, baseline bloods reviewed, clinical review completed') :-
    eligible_for_hormone_therapy(P).

% Explanation: why is a patient NOT eligible?
why_not_eligible(P, 'Missing consent record') :-
    patient(P),
    \\+ has_consent(P).

why_not_eligible(P, 'Patient information not provided') :-
    patient(P),
    \\+ has_information_provided(P).

why_not_eligible(P, 'Baseline bloods not yet resulted') :-
    patient(P),
    \\+ has_baseline_bloods_resulted(P).

why_not_eligible(P, 'Baseline bloods not yet reviewed by clinician') :-
    patient(P),
    has_baseline_bloods_resulted(P),
    \\+ has_baseline_bloods_reviewed(P).

why_not_eligible(P, 'Clinical review not completed') :-
    patient(P),
    \\+ has_clinical_review(P).


% ============================================================
% Compound deficit reasoning (Tier 2 value proposition)
% ============================================================

% A deficit exists when an expected condition is not met
deficit(P, monitoring_overdue, warning) :-
    monitoring_overdue(P).

deficit(P, consent_missing, critical) :-
    patient(P),
    \\+ has_consent(P).

deficit(P, bloods_not_reviewed, critical) :-
    patient(P),
    has_baseline_bloods_resulted(P),
    \\+ has_baseline_bloods_reviewed(P).

deficit(P, no_clinical_review, critical) :-
    patient(P),
    \\+ has_clinical_review(P).

% Compound risk: multiple interacting deficits
compound_risk(P) :-
    deficit(P, D1, _),
    deficit(P, D2, _),
    D1 \\= D2.

% Count deficits for a patient (using findall)
% Note: findall requires the lists module in Tau Prolog

% Remediation suggestions
remediation(P, monitoring_overdue, 'Schedule blood test') :-
    monitoring_overdue(P).

remediation(P, consent_missing, 'Obtain informed consent') :-
    patient(P),
    \\+ has_consent(P).

remediation(P, bloods_not_reviewed, 'Arrange clinical review of baseline bloods') :-
    patient(P),
    has_baseline_bloods_resulted(P),
    \\+ has_baseline_bloods_reviewed(P).
`;


// ---------------------------------------------------------------
// Test runner
// ---------------------------------------------------------------

const results = {
    tests: [],
    passed: 0,
    failed: 0,
};

function logTest(name, passed, detail = '') {
    const status = passed ? '✓' : '✗';
    const line = `  ${status} ${name}${detail ? ': ' + detail : ''}`;
    console.log(line);
    results.tests.push({ name, passed, detail });
    if (passed) results.passed++;
    else results.failed++;
}

/**
 * Query Tau Prolog and collect all answers.
 */
function queryAll(session, queryStr) {
    return new Promise((resolve, reject) => {
        const answers = [];
        session.query(queryStr, {
            success: () => {
                function getNext() {
                    session.answer({
                        success: (answer) => {
                            answers.push(pl.format_answer(answer));
                            getNext();
                        },
                        fail: () => resolve(answers),
                        error: (err) => reject(err),
                    });
                }
                getNext();
            },
            error: (err) => reject(err),
        });
    });
}

/**
 * Query and return true/false (does at least one solution exist?).
 */
async function queryExists(session, queryStr) {
    const answers = await queryAll(session, queryStr);
    return answers.length > 0;
}


// ---------------------------------------------------------------
// Main spike execution
// ---------------------------------------------------------------

async function main() {
    console.log('GenderSense — Tau Prolog Feasibility Spike');
    console.log('==========================================\n');

    // Create session
    const session = pl.create();

    // -------------------------------------------------------
    // Test 1: Load and run
    // -------------------------------------------------------
    console.log('Test 1: Load and run');
    try {
        await new Promise((resolve, reject) => {
            session.consult(CLINICAL_RULES, {
                success: () => resolve(),
                error: (err) => reject(err),
            });
        });
        logTest('Program consultation', true, 'loaded without errors');
    } catch (err) {
        logTest('Program consultation', false, String(err));
        console.log('\nFATAL: Cannot load program. Aborting spike.\n');
        process.exit(1);
    }

    // Basic query: enumerate patients
    try {
        const patients = await queryAll(session, 'patient(X).');
        logTest('Basic query (enumerate patients)', patients.length === 3,
            `found ${patients.length} patients: ${patients.join(', ')}`);
    } catch (err) {
        logTest('Basic query', false, String(err));
    }

    // -------------------------------------------------------
    // Test 2: Tier 1 constraint evaluation
    // -------------------------------------------------------
    console.log('\nTest 2: Tier 1 constraint evaluation');

    try {
        const p1Eligible = await queryExists(session, 'eligible_for_hormone_therapy(patient_001).');
        logTest('Patient 001 eligible', p1Eligible === true, 'all prerequisites met');
    } catch (err) {
        logTest('Patient 001 eligible', false, String(err));
    }

    try {
        const p2Eligible = await queryExists(session, 'eligible_for_hormone_therapy(patient_002).');
        logTest('Patient 002 not eligible', p2Eligible === false, 'missing consent');
    } catch (err) {
        logTest('Patient 002 not eligible', false, String(err));
    }

    try {
        const p3Eligible = await queryExists(session, 'eligible_for_hormone_therapy(patient_003).');
        logTest('Patient 003 not eligible', p3Eligible === false, 'bloods not reviewed');
    } catch (err) {
        logTest('Patient 003 not eligible', false, String(err));
    }

    // -------------------------------------------------------
    // Test 3: Arithmetic comparison
    // -------------------------------------------------------
    console.log('\nTest 3: Arithmetic comparison');

    try {
        const p1MonitoringOk = await queryExists(session, 'monitoring_up_to_date(patient_001).');
        logTest('Patient 001 monitoring up to date', p1MonitoringOk === true,
            '8 weeks <= 12 weeks');
    } catch (err) {
        logTest('Patient 001 monitoring', false, String(err));
    }

    try {
        const p2Overdue = await queryExists(session, 'monitoring_overdue(patient_002).');
        logTest('Patient 002 monitoring overdue', p2Overdue === true,
            '16 weeks > 12 weeks');
    } catch (err) {
        logTest('Patient 002 monitoring', false, String(err));
    }

    // -------------------------------------------------------
    // Test 4: Negation as failure
    // -------------------------------------------------------
    console.log('\nTest 4: Negation as failure');

    try {
        const reasons = await queryAll(session, 'why_not_eligible(patient_002, Reason).');
        logTest('Why not eligible (patient 002)',
            reasons.length >= 1 && reasons.some(r => r.includes('consent')),
            `${reasons.length} reason(s): ${reasons.join('; ')}`);
    } catch (err) {
        logTest('Why not eligible (patient 002)', false, String(err));
    }

    try {
        const reasons3 = await queryAll(session, 'why_not_eligible(patient_003, Reason).');
        logTest('Why not eligible (patient 003)',
            reasons3.length >= 1 && reasons3.some(r => r.includes('reviewed')),
            `${reasons3.length} reason(s): ${reasons3.join('; ')}`);
    } catch (err) {
        logTest('Why not eligible (patient 003)', false, String(err));
    }

    // -------------------------------------------------------
    // Test 5: Multiple answers (enumerate all deficits)
    // -------------------------------------------------------
    console.log('\nTest 5: Multiple answers — deficit enumeration');

    try {
        const deficits2 = await queryAll(session, 'deficit(patient_002, Type, Severity).');
        logTest('Patient 002 deficits', deficits2.length >= 2,
            `${deficits2.length} deficit(s): ${deficits2.join('; ')}`);
    } catch (err) {
        logTest('Patient 002 deficits', false, String(err));
    }

    try {
        const deficits3 = await queryAll(session, 'deficit(patient_003, Type, Severity).');
        logTest('Patient 003 deficits', deficits3.length >= 1,
            `${deficits3.length} deficit(s): ${deficits3.join('; ')}`);
    } catch (err) {
        logTest('Patient 003 deficits', false, String(err));
    }

    // -------------------------------------------------------
    // Test 6: Compound risk detection
    // -------------------------------------------------------
    console.log('\nTest 6: Compound risk detection');

    try {
        const compound2 = await queryExists(session, 'compound_risk(patient_002).');
        logTest('Patient 002 compound risk', compound2 === true,
            'multiple deficits interact');
    } catch (err) {
        logTest('Patient 002 compound risk', false, String(err));
    }

    try {
        const compound1 = await queryExists(session, 'compound_risk(patient_001).');
        logTest('Patient 001 no compound risk', compound1 === false,
            'no deficits');
    } catch (err) {
        logTest('Patient 001 compound risk', false, String(err));
    }

    // -------------------------------------------------------
    // Test 7: Remediation suggestions
    // -------------------------------------------------------
    console.log('\nTest 7: Remediation suggestions');

    try {
        const rems = await queryAll(session, 'remediation(patient_002, Type, Action).');
        logTest('Patient 002 remediations', rems.length >= 1,
            `${rems.length} remediation(s): ${rems.join('; ')}`);
    } catch (err) {
        logTest('Patient 002 remediations', false, String(err));
    }

    // -------------------------------------------------------
    // Test 8: Performance
    // -------------------------------------------------------
    console.log('\nTest 8: Performance');

    try {
        const iterations = 100;
        const start = performance.now();
        for (let i = 0; i < iterations; i++) {
            await queryExists(session, 'eligible_for_hormone_therapy(patient_001).');
        }
        const elapsed = performance.now() - start;
        const perQuery = elapsed / iterations;
        logTest(`Eligibility query (${iterations}x)`,
            perQuery < 10,
            `${perQuery.toFixed(2)}ms per query (target: <10ms)`);
    } catch (err) {
        logTest('Performance', false, String(err));
    }

    try {
        const iterations = 100;
        const start = performance.now();
        for (let i = 0; i < iterations; i++) {
            await queryAll(session, 'deficit(patient_002, Type, Severity).');
        }
        const elapsed = performance.now() - start;
        const perQuery = elapsed / iterations;
        logTest(`Deficit enumeration (${iterations}x)`,
            perQuery < 10,
            `${perQuery.toFixed(2)}ms per query (target: <10ms)`);
    } catch (err) {
        logTest('Performance (deficit)', false, String(err));
    }

    // -------------------------------------------------------
    // Summary
    // -------------------------------------------------------
    console.log('\n==========================================');
    console.log(`Results: ${results.passed} passed, ${results.failed} failed out of ${results.tests.length} tests`);
    console.log('==========================================\n');

    // -------------------------------------------------------
    // Qualitative assessments
    // -------------------------------------------------------
    console.log('Qualitative assessments:');
    console.log('');
    console.log('  Temporal compatibility:');
    console.log('    Tau Prolog is pure JavaScript — no Node.js-specific APIs');
    console.log('    (no fs, net, child_process, etc.). Should run in Temporal\'s');
    console.log('    deterministic V8 isolate without issues. Same compatibility');
    console.log('    profile as XState (validated in Phase C demonstrator).');
    console.log('');
    console.log('  Bundle size:');

    try {
        const fs = await import('fs');
        const path = await import('path');
        const tauPath = path.default.dirname(
            (await import('url')).fileURLToPath(
                import.meta.resolve('tau-prolog')
            )
        );
        // Check the main file size
        const mainFile = path.default.join(tauPath, 'modules', 'core.js');
        const altFile = path.default.join(tauPath, 'tau-prolog.js');
        let size = 0;
        for (const f of [mainFile, altFile]) {
            try {
                const stat = fs.default.statSync(f);
                size = stat.size;
                console.log(`    ${f}: ${(size / 1024).toFixed(0)} KiB`);
            } catch { /* ignore */ }
        }
        if (size === 0) {
            // Try the package directory
            const pkgDir = path.default.resolve('node_modules/tau-prolog');
            if (fs.default.existsSync(pkgDir)) {
                let totalSize = 0;
                const walk = (dir) => {
                    for (const entry of fs.default.readdirSync(dir, { withFileTypes: true })) {
                        const full = path.default.join(dir, entry.name);
                        if (entry.isDirectory()) walk(full);
                        else totalSize += fs.default.statSync(full).size;
                    }
                };
                walk(pkgDir);
                console.log(`    Total tau-prolog package: ${(totalSize / 1024).toFixed(0)} KiB`);
            }
        }
    } catch {
        console.log('    (could not determine — check node_modules/tau-prolog manually)');
    }

    console.log('');
    console.log('  Rule generation feasibility:');
    console.log('    SysML constraint defs have a consistent shape: typed inputs,');
    console.log('    boolean expression, satisfy relationship. A generator could');
    console.log('    produce Prolog rules from this: each constraint becomes a');
    console.log('    rule, each input becomes a fact query. The why_not_eligible');
    console.log('    pattern (negation as failure for each prerequisite) is');
    console.log('    mechanical — one negated rule per input.');
    console.log('');
    console.log('    Compound deficit reasoning is where Prolog adds value beyond');
    console.log('    Tier 1 TypeScript: reasoning about relationships between');
    console.log('    multiple deficits, priority ordering, and interaction effects');
    console.log('    is natural in Prolog but awkward in imperative code.');
    console.log('');

    process.exit(results.failed > 0 ? 1 : 0);
}

main().catch(err => {
    console.error('FATAL:', err);
    process.exit(1);
});
