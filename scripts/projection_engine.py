#!/usr/bin/env python3
"""
GenderSense Projection Engine — Phases 4-5, Business Meta Model Implementation

Reads scenario parameters (hard-coded from the SysML model) and produces
a monthly time-series financial projection.

Source parameters: model/business-model.sysml :: ScenarioModelling
Source formulas:   gsl-service-business-meta-modelling.md section 7.2

Usage:
    python scripts/projection_engine.py                          # console + JSON
    python scripts/projection_engine.py --format=csv             # CSV export
    python scripts/projection_engine.py --format=markdown        # Markdown summary
    python scripts/projection_engine.py --format=all             # All formats
    python scripts/projection_engine.py --scenario=full-platform
    python scripts/projection_engine.py --scenario=coffeeshop-kiosk
    python scripts/projection_engine.py --scenario=coffeeshop-cafe
    python scripts/projection_engine.py --sensitivity            # Sensitivity analysis
    python scripts/projection_engine.py --sensitivity --scenario=full-platform
    python scripts/projection_engine.py --compare=lean-clinical,full-platform

No external dependencies — Python stdlib only.
"""

import argparse
import copy
import csv
import json
import math
import sys
from datetime import datetime, timezone
from io import StringIO
from pathlib import Path


# =========================================================================
# SCENARIO PARAMETER SETS
# =========================================================================
# Each parameter set is drawn directly from the SysML model.
# Comments reference the source part usage in business-model.sysml.
#
# REVENUE MODEL NOTE (Phase 4 finding):
# The SysML model defines monitoringFeePerQuarter = £150 (paramMonitoringFee).
# Applied as £150/3 = £50/patient/month, this produces revenue approximately
# 40-50% below the illustrative ProjectionOutput values. The illustrative
# values imply an effective ongoing revenue of ~£134/patient/month (~£400/quarter).
#
# This gap arises because monitoringFeePerQuarter captures only the quarterly
# blood review fee. Active patients — especially those in the initiation phase —
# also generate revenue from titration appointments, prescription reviews, and
# ad-hoc consultations. The effective blended revenue per active patient is
# substantially higher.
#
# The engine uses an explicit effectiveMonthlyRevenuePerPatient parameter.
# This should be set based on actual pricing intentions and clinical
# appointment patterns.  The default value of £134/month is calibrated
# against the illustrative SysML values and should be validated against
# actual clinical pricing before use for business decisions.

LEAN_CLINICAL_PARAMS = {
    "scenarioName": "Lean Clinical (Variant A)",
    "description": "Assessment and hormone therapy only. 1 clinician, per-episode pricing.",
    "timelineMonths": 24,
    "domain": "clinical",

    # Revenue — paramAssessmentFee, paramMonitoringFee
    "assessmentFeePerPatient": 600.0,
    "monitoringFeePerQuarter": 150.0,       # quarterly blood review only
    "effectiveMonthlyRevenuePerPatient": 134.0,  # see revenue model note above

    # Resource cost — paramClinicianCost, paramAdminCost, etc.
    "clinicianCostPerFTEPerMonth": 5000.0,
    "adminFTE": 0.3,                          # paramAdminFTE
    "adminCostPerFTEPerMonth": 1800.0,         # paramAdminCost
    "platformCostPerMonth": 200.0,             # paramPlatformCost
    "insurancePerMonth": 250.0,                # paramInsuranceCost
    "labCostPerBloodPanel": 45.0,              # paramLabCost
    "overheadPercentage": 25.0,                # paramOverheadPercentage

    # Clinician FTE step function — paramClinicianFTEEarly, paramClinicianFTELater
    "clinicianFTESchedule": {
        "early": {"fte": 0.5, "months": (1, 9)},
        "later": {"fte": 0.8, "months": (10, 24)},
    },

    # Clinical pathway derived — paramBloodPanelsInitiation, paramBloodPanelsMonitoring
    "bloodPanelsPerInitiationEpisode": 5.0,
    "bloodPanelsPerMonitoringQuarter": 1.0,

    # Growth — paramNewPatientsYear1, paramNewPatientsYear2
    "newPatientsSchedule": {
        "year1": {"count": 4, "months": (1, 12)},
        "year2": {"count": 6, "months": (13, 24)},
    },

    # Conversion and retention — paramAssessmentConversion, etc.
    "assessmentToInitiationConversion": 0.85,
    "initiationToStableConversion": 0.90,
    "initiationDurationMonths": 9,
    "churnRatePerQuarter": 0.05,

    # Utilisation — from formulaUtilisation notes
    "availableHoursPerFTEPerMonth": 140.0,
    "assessmentHoursPerPatient": 2.0,          # from assessmentUnitEconomics
    "initiationHoursPerPatientPerMonth": 0.5,  # estimate: bloods review, dose adjustments
    "monitoringHoursPerReview": 0.5,           # from monitoringUnitEconomics
}


# -- Full Platform (Variant B) -------------------------------------------
#
# Inherits all clinical parameters from Lean Clinical. Overrides and adds:
# - Subscription revenue (£99/month per active subscriber, 100% uptake)
# - Coach cost (0.5 FTE at £3,000/FTE/month)
# - Moderator cost (0.2 FTE at £2,000/FTE/month)
# - Higher platform cost (£500/month vs £200/month)
# - Two-clinician FTE schedule (faster scaling)
#
# Source: business-model.sysml :: ScenarioModelling :: fullPlatformScenario
# All values are illustrative placeholders per Phase 5 guardrail G1.

FULL_PLATFORM_PARAMS = {
    **LEAN_CLINICAL_PARAMS,

    "scenarioName": "Full Platform (Variant B)",
    "description": "Clinical care plus coaching, education, and community. 2 clinicians, subscription + per-episode.",

    # Subscription revenue — fpParamSubscriptionFee, fpParamSubscriptionUptake
    "subscriptionFeePerMonth": 99.0,
    "subscriptionUptakeRate": 1.0,             # 100% — all active patients are subscribers

    # Coach — fpParamCoachFTE, fpParamCoachCost
    "coachFTE": 0.5,
    "coachCostPerFTEPerMonth": 3000.0,

    # Moderator — fpParamModeratorFTE, fpParamModeratorCost
    "moderatorFTE": 0.2,
    "moderatorCostPerFTEPerMonth": 2000.0,

    # Higher platform cost — fpParamPlatformCost
    "platformCostPerMonth": 500.0,

    # Two-clinician FTE schedule — fpParamClinician1/2 early/later
    # Clinician 1: 0.5 FTE months 1-5, 0.8 FTE from month 6
    # Clinician 2: 0.5 FTE from month 6, 1.0 FTE from month 12
    # Total:       0.5 → 1.3 → 1.8
    "clinicianFTESchedule": {
        "phase1": {"fte": 0.5, "months": (1, 5)},
        "phase2": {"fte": 1.3, "months": (6, 11)},
        "phase3": {"fte": 1.8, "months": (12, 24)},
    },
}


# -- Coffee shop scenarios (from coffeeshop-scenarios.sysml) ---------------

COFFEESHOP_KIOSK_PARAMS = {
    "scenarioName": "Coffee Shop — Small Kiosk",
    "description": "1 barista, 50 drinks/day, limited menu, low rent.",
    "timelineMonths": 12,
    "domain": "coffeeshop",

    "dailyDrinksStart": 50,
    "dailyDrinksEnd": 80,
    "growthShape": "linear",
    "inflectionMonth": 0,
    "pricePerDrink": 3.50,
    "ingredientCostPerDrink": 0.80,
    "baristaMonthlyCost": 2100.0,
    "baristaCount": 1,
    "rentPerMonth": 500.0,
    "otherFixedCosts": 200.0,
    "overheadPercentage": 15.0,
    "tradingDaysPerMonth": 26,
}

COFFEESHOP_CAFE_PARAMS = {
    "scenarioName": "Coffee Shop — Full Café",
    "description": "3 baristas, 120-200 drinks/day, food menu, high street rent.",
    "timelineMonths": 12,
    "domain": "coffeeshop",

    "dailyDrinksStart": 120,
    "dailyDrinksEnd": 200,
    "growthShape": "sCurve",
    "inflectionMonth": 6,
    "pricePerDrink": 4.00,
    "ingredientCostPerDrink": 0.85,
    "baristaMonthlyCost": 2100.0,
    "baristaCount": 3,
    "rentPerMonth": 2500.0,
    "otherFixedCosts": 500.0,
    "overheadPercentage": 15.0,
    "tradingDaysPerMonth": 26,
}


# =========================================================================
# SENSITIVITY PARAMETER DEFINITIONS
# =========================================================================

# Lean Clinical — from SysML SensitivityParameter usages
LEAN_CLINICAL_SENSITIVITY = [
    {
        "parameterName": "newPatientsPerMonth (year 1)",
        "paramKey": "newPatientsSchedule.year1.count",
        "base": 4, "pessimistic": 2, "optimistic": 6,
        "sysmlPrediction": "±6 months",
    },
    {
        "parameterName": "assessmentFeePerPatient",
        "paramKey": "assessmentFeePerPatient",
        "base": 600.0, "pessimistic": 450.0, "optimistic": 750.0,
        "sysmlPrediction": "±3 months",
    },
    {
        "parameterName": "clinicianCostPerFTEPerMonth",
        "paramKey": "clinicianCostPerFTEPerMonth",
        "base": 5000.0, "pessimistic": 6000.0, "optimistic": 4000.0,
        "sysmlPrediction": "±2 months",
    },
    {
        "parameterName": "overheadPercentage",
        "paramKey": "overheadPercentage",
        "base": 25.0, "pessimistic": 35.0, "optimistic": 20.0,
        "sysmlPrediction": "±2 months",
    },
]

# Full Platform — from SysML fpSensitivity* usages
# Includes shared patient growth sensitivity plus Variant B-specific params
FULL_PLATFORM_SENSITIVITY = [
    {
        "parameterName": "newPatientsPerMonth (year 1)",
        "paramKey": "newPatientsSchedule.year1.count",
        "base": 4, "pessimistic": 2, "optimistic": 6,
        "sysmlPrediction": "shared with Variant A",
    },
    {
        "parameterName": "subscriptionFeePerMonth",
        "paramKey": "subscriptionFeePerMonth",
        "base": 99.0, "pessimistic": 59.0, "optimistic": 149.0,
        "sysmlPrediction": "subscription price sensitivity",
    },
    {
        "parameterName": "subscriptionUptakeRate",
        "paramKey": "subscriptionUptakeRate",
        "base": 1.0, "pessimistic": 0.6, "optimistic": 1.0,
        "sysmlPrediction": "60% uptake vs 100%",
    },
]

SENSITIVITY_BY_SCENARIO = {
    "lean-clinical": LEAN_CLINICAL_SENSITIVITY,
    "full-platform": FULL_PLATFORM_SENSITIVITY,
}

# Backward compatibility alias
SENSITIVITY_VARIATIONS = LEAN_CLINICAL_SENSITIVITY


# =========================================================================
# GROWTH TRAJECTORY FUNCTIONS
# =========================================================================

def linear_growth(month, total_months, start, end):
    """Linear interpolation from start to end over total_months."""
    if total_months <= 1:
        return end
    t = (month - 1) / (total_months - 1)
    return start + (end - start) * t


def s_curve_growth(month, total_months, start, end, inflection_month):
    """Logistic S-curve growth with specified inflection point."""
    if total_months <= 1:
        return end
    k = 0.8
    x = month - inflection_month
    logistic = 1.0 / (1.0 + math.exp(-k * x))
    logistic_start = 1.0 / (1.0 + math.exp(-k * (1 - inflection_month)))
    logistic_end = 1.0 / (1.0 + math.exp(-k * (total_months - inflection_month)))
    if abs(logistic_end - logistic_start) < 1e-9:
        return end
    normalised = (logistic - logistic_start) / (logistic_end - logistic_start)
    return start + (end - start) * normalised


# =========================================================================
# CLINICAL PROJECTION (two-stage patient model)
# =========================================================================

def run_clinical_projection(params):
    """
    Run a projection for a clinical scenario.

    Patient model: new patients are assessed, a proportion convert
    (85% × 90% = 76.5% combined rate) and enter the active patient pool
    immediately. The 9-month initiation period affects cost (higher blood
    panel consumption during titration) but patients generate revenue from
    their first month in the active pool. This matches the clinical reality
    that initiation patients ARE being monitored and generating appointments.

    The initiation pipeline is tracked separately for lab cost calculation.

    Subscription revenue (Variant B): if the params contain
    subscriptionFeePerMonth, subscription revenue is computed as
    activePool × uptakeRate × monthlyFee and added to total revenue.
    If absent, the function produces identical output to Phase 4
    (Variant A regression safety).
    """
    timeline = params["timelineMonths"]

    quarterly_churn = params["churnRatePerQuarter"]
    monthly_churn = 1.0 - (1.0 - quarterly_churn) ** (1.0 / 3.0)
    initiation_duration = params["initiationDurationMonths"]
    combined_conversion = (params["assessmentToInitiationConversion"]
                           * params["initiationToStableConversion"])

    effective_revenue = params["effectiveMonthlyRevenuePerPatient"]

    # Subscription params (Variant B — absent for Variant A)
    has_subscription = "subscriptionFeePerMonth" in params
    subscription_fee = params.get("subscriptionFeePerMonth", 0.0)
    subscription_uptake = params.get("subscriptionUptakeRate", 0.0)

    # Additional cost params (Variant B — absent or zero for Variant A)
    coach_fte = params.get("coachFTE", 0.0)
    coach_cost_rate = params.get("coachCostPerFTEPerMonth", 0.0)
    moderator_fte = params.get("moderatorFTE", 0.0)
    moderator_cost_rate = params.get("moderatorCostPerFTEPerMonth", 0.0)

    # Initiation pipeline: tracks patients in first 9 months (for lab costs)
    initiation_pipeline = []
    active_pool = 0.0
    cumulative_cash_flow = 0.0

    months = []

    for m in range(1, timeline + 1):
        new_patients = _get_new_patients(params, m)
        clinician_fte = _get_clinician_fte(params, m)

        # Conversion: combined assessment→initiation→stable
        entering_active = new_patients * combined_conversion

        # Track initiation pipeline for lab cost (cost-only concern)
        initiation_pipeline.append({
            "entered_month": m,
            "size": new_patients * params["assessmentToInitiationConversion"],
            "months_left": initiation_duration,
        })
        remaining_pipeline = []
        for cohort in initiation_pipeline:
            cohort["months_left"] -= 1
            if cohort["months_left"] > 0:
                remaining_pipeline.append(cohort)
        initiation_pipeline = remaining_pipeline
        patients_in_initiation = sum(c["size"] for c in initiation_pipeline)

        # Active pool: add converts, subtract churn
        active_pool += entering_active
        churned = active_pool * monthly_churn
        active_pool -= churned
        active_pool = max(0.0, active_pool)

        total_active = new_patients + active_pool

        # -- Revenue --
        assessment_revenue = new_patients * params["assessmentFeePerPatient"] / 2.0
        monitoring_revenue = active_pool * effective_revenue

        # Subscription revenue (Variant B only)
        subscription_revenue = 0.0
        if has_subscription:
            active_subscribers = active_pool * subscription_uptake
            subscription_revenue = active_subscribers * subscription_fee

        total_revenue = assessment_revenue + monitoring_revenue + subscription_revenue

        # -- Costs --
        clinician_cost = clinician_fte * params["clinicianCostPerFTEPerMonth"]
        admin_cost = params["adminFTE"] * params["adminCostPerFTEPerMonth"]
        platform_cost = params["platformCostPerMonth"]
        insurance_cost = params["insurancePerMonth"]

        # Coach and moderator cost (Variant B; zero for Variant A)
        coach_cost = coach_fte * coach_cost_rate
        moderator_cost = moderator_fte * moderator_cost_rate

        # Lab: initiation patients consume panels spread over 9 months,
        # stable patients consume 1 panel per quarter
        initiation_panels = (patients_in_initiation
                             * params["bloodPanelsPerInitiationEpisode"]
                             / initiation_duration)
        stable_patients = max(0.0, active_pool - patients_in_initiation)
        monitoring_panels = stable_patients * params["bloodPanelsPerMonitoringQuarter"] / 3.0
        total_panels = initiation_panels + monitoring_panels
        lab_cost = total_panels * params["labCostPerBloodPanel"]

        direct_cost = (clinician_cost + admin_cost + platform_cost
                       + insurance_cost + coach_cost + moderator_cost + lab_cost)
        overhead = direct_cost * params["overheadPercentage"] / 100.0
        total_cost = direct_cost + overhead

        # -- Margin and cash flow --
        margin = total_revenue - total_cost
        cumulative_cash_flow += margin

        # -- Clinician utilisation --
        activity_hours = (
            new_patients * params["assessmentHoursPerPatient"]
            + patients_in_initiation * params["initiationHoursPerPatientPerMonth"]
            + (stable_patients / 3.0) * params["monitoringHoursPerReview"]
        )
        available_hours = clinician_fte * params["availableHoursPerFTEPerMonth"]
        utilisation = (activity_hours / available_hours * 100.0) if available_hours > 0 else 0.0

        # -- Confidence profile --
        if m <= 3:
            confidence = "low — early months, envelope-level overhead estimate"
        elif m <= 12:
            confidence = "moderate — growth assumptions dominate"
        elif m <= 18:
            confidence = "moderate — conversion and churn assumptions becoming significant"
        else:
            confidence = "moderate — long-term churn assumption least validated"

        # -- Build revenue dict --
        revenue_dict = {
            "assessment": round(assessment_revenue, 2),
            "monitoring": round(monitoring_revenue, 2),
            "total": round(total_revenue, 2),
        }
        if has_subscription:
            revenue_dict["subscription"] = round(subscription_revenue, 2)

        # -- Build cost dict --
        cost_dict = {
            "clinician": round(clinician_cost, 2),
            "admin": round(admin_cost, 2),
            "platform": round(platform_cost, 2),
            "insurance": round(insurance_cost, 2),
            "lab": round(lab_cost, 2),
            "directTotal": round(direct_cost, 2),
            "overhead": round(overhead, 2),
            "total": round(total_cost, 2),
        }
        if coach_fte > 0:
            cost_dict["coach"] = round(coach_cost, 2)
        if moderator_fte > 0:
            cost_dict["moderator"] = round(moderator_cost, 2)

        months.append({
            "month": m,
            "periodLabel": f"Month {m}",
            "patients": {
                "newThisMonth": round(new_patients, 1),
                "enteringActive": round(entering_active, 1),
                "inInitiationPeriod": round(patients_in_initiation, 1),
                "activePool": round(active_pool, 1),
                "churnedThisMonth": round(churned, 1),
                "totalActive": round(total_active, 1),
            },
            "revenue": revenue_dict,
            "cost": cost_dict,
            "margin": round(margin, 2),
            "cumulativeCashFlow": round(cumulative_cash_flow, 2),
            "clinicianUtilisation": round(utilisation, 1),
            "confidenceProfile": confidence,
        })

    return months


def _get_new_patients(params, month):
    schedule = params["newPatientsSchedule"]
    for period in schedule.values():
        lo, hi = period["months"]
        if lo <= month <= hi:
            return period["count"]
    return 0


def _get_clinician_fte(params, month):
    schedule = params["clinicianFTESchedule"]
    for period in schedule.values():
        lo, hi = period["months"]
        if lo <= month <= hi:
            return period["fte"]
    return 0.0


# =========================================================================
# COFFEE SHOP PROJECTION (single-stage volume model)
# =========================================================================

def run_coffeeshop_projection(params):
    """
    Run a projection for a coffee shop scenario. Single-stage volume model:
    daily drinks × growth trajectory → monthly revenue and cost.
    """
    timeline = params["timelineMonths"]
    cumulative_cash_flow = 0.0
    months = []

    for m in range(1, timeline + 1):
        if params["growthShape"] == "linear":
            daily_drinks = linear_growth(
                m, timeline, params["dailyDrinksStart"], params["dailyDrinksEnd"])
        elif params["growthShape"] == "sCurve":
            daily_drinks = s_curve_growth(
                m, timeline, params["dailyDrinksStart"], params["dailyDrinksEnd"],
                params["inflectionMonth"])
        else:
            daily_drinks = params["dailyDrinksStart"]

        monthly_drinks = daily_drinks * params["tradingDaysPerMonth"]
        total_revenue = monthly_drinks * params["pricePerDrink"]

        ingredient_cost = monthly_drinks * params["ingredientCostPerDrink"]
        barista_cost = params["baristaCount"] * params["baristaMonthlyCost"]
        rent = params["rentPerMonth"]
        other_fixed = params["otherFixedCosts"]
        direct_cost = ingredient_cost + barista_cost + rent + other_fixed
        overhead = direct_cost * params["overheadPercentage"] / 100.0
        total_cost = direct_cost + overhead

        margin = total_revenue - total_cost
        cumulative_cash_flow += margin

        months.append({
            "month": m,
            "periodLabel": f"Month {m}",
            "volume": {
                "dailyDrinks": round(daily_drinks, 1),
                "monthlyDrinks": round(monthly_drinks, 0),
            },
            "revenue": {"total": round(total_revenue, 2)},
            "cost": {
                "ingredients": round(ingredient_cost, 2),
                "baristas": round(barista_cost, 2),
                "rent": round(rent, 2),
                "otherFixed": round(other_fixed, 2),
                "directTotal": round(direct_cost, 2),
                "overhead": round(overhead, 2),
                "total": round(total_cost, 2),
            },
            "margin": round(margin, 2),
            "cumulativeCashFlow": round(cumulative_cash_flow, 2),
        })

    return months


# =========================================================================
# PROJECTION RUNNER
# =========================================================================

def run_projection(params):
    if params["domain"] == "clinical":
        months = run_clinical_projection(params)
    elif params["domain"] == "coffeeshop":
        months = run_coffeeshop_projection(params)
    else:
        raise ValueError(f"Unknown domain: {params['domain']}")

    summary = compute_summary(months, params)

    return {
        "scenario": params["scenarioName"],
        "description": params["description"],
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "timelineMonths": params["timelineMonths"],
        "parameters": _serialisable_params(params),
        "months": months,
        "summary": summary,
    }


def compute_summary(months, params):
    break_even_month = None
    was_negative = False
    max_deficit = 0.0
    max_deficit_month = 0

    for row in months:
        ccf = row["cumulativeCashFlow"]
        if ccf < 0:
            was_negative = True
            if ccf < max_deficit:
                max_deficit = ccf
                max_deficit_month = row["month"]
        if was_negative and ccf >= 0 and break_even_month is None:
            break_even_month = row["month"]

    last = months[-1]
    summary = {
        "breakEvenMonth": break_even_month,
        "maxCashDeficit": round(max_deficit, 2),
        "maxCashDeficitMonth": max_deficit_month,
        "marginAtFinalMonth": last["margin"],
        "cumulativeCashFlowAtFinalMonth": last["cumulativeCashFlow"],
    }

    if params["domain"] == "clinical":
        summary["activePatientsAtFinalMonth"] = last["patients"]["activePool"]
        summary["clinicianUtilisationAtFinalMonth"] = last["clinicianUtilisation"]
        # Revenue stream count for comparison output
        summary["revenueStreams"] = 2  # assessment + monitoring
        if "subscriptionFeePerMonth" in params:
            summary["revenueStreams"] = 3  # + subscription
        # Total staff FTE at final month
        final_month = last["month"]
        summary["clinicianFTEAtFinalMonth"] = _get_clinician_fte(params, final_month)
        total_staff = summary["clinicianFTEAtFinalMonth"] + params["adminFTE"]
        total_staff += params.get("coachFTE", 0.0)
        total_staff += params.get("moderatorFTE", 0.0)
        summary["totalStaffFTEAtFinalMonth"] = round(total_staff, 1)

    return summary


def _serialisable_params(params):
    result = {}
    for k, v in params.items():
        if isinstance(v, dict):
            result[k] = {
                sk: {ik: (list(iv) if isinstance(iv, tuple) else iv)
                     for ik, iv in sv.items()}
                if isinstance(sv, dict) else sv
                for sk, sv in v.items()
            }
        else:
            result[k] = v
    return result


# =========================================================================
# SENSITIVITY ANALYSIS
# =========================================================================

def run_sensitivity(base_params, variations):
    results = []
    for var in variations:
        row = {
            "parameterName": var["parameterName"],
            "sysmlPrediction": var["sysmlPrediction"],
            "runs": {},
        }
        for label, value in [("pessimistic", var["pessimistic"]),
                              ("base", var["base"]),
                              ("optimistic", var["optimistic"])]:
            test_params = copy.deepcopy(base_params)
            _set_param(test_params, var["paramKey"], value)
            projection = run_projection(test_params)
            row["runs"][label] = {
                "value": value,
                "breakEvenMonth": projection["summary"]["breakEvenMonth"],
                "maxCashDeficit": projection["summary"]["maxCashDeficit"],
                "marginAtFinalMonth": projection["summary"]["marginAtFinalMonth"],
                "cumulativeCashFlowAtFinalMonth": projection["summary"]["cumulativeCashFlowAtFinalMonth"],
            }
        results.append(row)
    return results


def _set_param(params, key_path, value):
    parts = key_path.split(".")
    target = params
    for part in parts[:-1]:
        target = target[part]
    target[parts[-1]] = value


# =========================================================================
# COMPARISON
# =========================================================================

def run_comparison(scenario_keys):
    """Run projections for multiple scenarios and produce comparison data."""
    results = {}
    for key in scenario_keys:
        params = SCENARIOS[key]
        results[key] = run_projection(params)
    return results


def format_comparison_markdown(results):
    """Produce a side-by-side comparison markdown table."""
    lines = []
    lines.append("# Scenario Comparison")
    lines.append("")
    lines.append(f"Generated: {datetime.now(timezone.utc).strftime('%Y-%m-%d')}")
    lines.append("")

    # Build header from scenario names
    keys = list(results.keys())
    names = [results[k]["scenario"] for k in keys]
    header = "| Metric | " + " | ".join(names) + " |"
    separator = "|---|" + "|".join(["---:" for _ in keys]) + "|"

    lines.append(header)
    lines.append(separator)

    # Metrics rows
    summaries = [results[k]["summary"] for k in keys]

    def _fmt_be(s):
        v = s["breakEvenMonth"]
        return str(v) if v else "Not reached"

    def _fmt_money(v):
        return f"£{v:,.0f}"

    metrics = [
        ("Break-even month", lambda s: _fmt_be(s)),
        ("Max cash deficit", lambda s: _fmt_money(s["maxCashDeficit"])),
        ("Max deficit month", lambda s: str(s["maxCashDeficitMonth"])),
        ("Margin at month 24", lambda s: _fmt_money(s["marginAtFinalMonth"])),
        ("Cumulative CF at month 24", lambda s: _fmt_money(s["cumulativeCashFlowAtFinalMonth"])),
    ]

    # Clinical-specific metrics
    if all("activePatientsAtFinalMonth" in s for s in summaries):
        metrics.extend([
            ("Active patients at month 24", lambda s: f"{s['activePatientsAtFinalMonth']:.0f}"),
            ("Clinician FTE at month 24", lambda s: f"{s['clinicianFTEAtFinalMonth']:.1f}"),
            ("Total staff FTE at month 24", lambda s: f"{s['totalStaffFTEAtFinalMonth']:.1f}"),
            ("Revenue streams", lambda s: str(s.get("revenueStreams", "—"))),
            ("Clinician utilisation at month 24", lambda s: f"{s['clinicianUtilisationAtFinalMonth']:.0f}%"),
        ])

    for label, fn in metrics:
        vals = [fn(s) for s in summaries]
        lines.append(f"| {label} | " + " | ".join(vals) + " |")

    lines.append("")

    # Investment estimate (from params)
    lines.append("## Investment Estimate")
    lines.append("")
    for key in keys:
        s = results[key]["summary"]
        deficit = abs(s["maxCashDeficit"])
        lines.append(f"- **{results[key]['scenario']}:** ~£{deficit:,.0f} "
                      f"(maximum cash deficit, month {s['maxCashDeficitMonth']})")
    lines.append("")

    # Structural observations
    lines.append("## Structural Observations")
    lines.append("")
    if len(keys) == 2:
        s_a, s_b = summaries
        be_a = s_a["breakEvenMonth"] or 99
        be_b = s_b["breakEvenMonth"] or 99
        deficit_a = abs(s_a["maxCashDeficit"])
        deficit_b = abs(s_b["maxCashDeficit"])

        if be_a < be_b:
            lines.append(f"- {names[0]} reaches break-even {be_b - be_a} months earlier than {names[1]}")
        elif be_b < be_a:
            lines.append(f"- {names[1]} reaches break-even {be_a - be_b} months earlier than {names[0]}")

        if deficit_b > deficit_a:
            ratio = deficit_b / deficit_a if deficit_a > 0 else 0
            lines.append(f"- {names[1]} requires ~{ratio:.1f}x the capital of {names[0]} "
                          f"(£{deficit_b:,.0f} vs £{deficit_a:,.0f})")

        margin_a = s_a["marginAtFinalMonth"]
        margin_b = s_b["marginAtFinalMonth"]
        if margin_b > margin_a:
            lines.append(f"- {names[1]} has £{margin_b - margin_a:,.0f}/month higher margin at month 24")

        streams_a = s_a.get("revenueStreams", 0)
        streams_b = s_b.get("revenueStreams", 0)
        if streams_b > streams_a:
            lines.append(f"- {names[1]} has more diversified revenue ({streams_b} streams vs {streams_a})")

    lines.append("")
    lines.append("*All values are illustrative placeholders. This comparison tests structural "
                 "capability, not validated business projections.*")
    lines.append("")
    return "\n".join(lines)


def format_comparison_console(results):
    """Produce a console-friendly comparison summary."""
    lines = []
    keys = list(results.keys())
    names = [results[k]["scenario"] for k in keys]
    summaries = [results[k]["summary"] for k in keys]

    width = max(len(n) for n in names) + 4
    lines.append(f"{'=' * 60}")
    lines.append("  Scenario Comparison")
    lines.append(f"{'=' * 60}")
    lines.append("")

    header = f"  {'Metric':<30}"
    for name in names:
        header += f"  {name:>{width}}"
    lines.append(header)
    lines.append(f"  {'-' * 30}" + f"  {'-' * width}" * len(names))

    def _row(label, fn):
        row = f"  {label:<30}"
        for s in summaries:
            row += f"  {fn(s):>{width}}"
        lines.append(row)

    _row("Break-even month", lambda s: str(s["breakEvenMonth"] or "Never"))
    _row("Max cash deficit", lambda s: f"£{s['maxCashDeficit']:,.0f}")
    _row("Final month margin", lambda s: f"£{s['marginAtFinalMonth']:,.0f}")
    _row("Final cumulative CF", lambda s: f"£{s['cumulativeCashFlowAtFinalMonth']:,.0f}")

    if all("activePatientsAtFinalMonth" in s for s in summaries):
        _row("Active patients (final)", lambda s: f"{s['activePatientsAtFinalMonth']:.0f}")
        _row("Clinician FTE (final)", lambda s: f"{s['clinicianFTEAtFinalMonth']:.1f}")
        _row("Total staff FTE (final)", lambda s: f"{s['totalStaffFTEAtFinalMonth']:.1f}")
        _row("Revenue streams", lambda s: str(s.get("revenueStreams", "—")))
        _row("Utilisation (final)", lambda s: f"{s['clinicianUtilisationAtFinalMonth']:.0f}%")

    lines.append("")
    return "\n".join(lines)


# =========================================================================
# OUTPUT FORMATTERS
# =========================================================================

def format_json(result):
    return json.dumps(result, indent=2, ensure_ascii=False)


def format_csv(result):
    buf = StringIO()
    months = result["months"]
    if not months:
        return ""
    fieldnames = _flatten_keys(months[0])
    writer = csv.DictWriter(buf, fieldnames=fieldnames)
    writer.writeheader()
    for row in months:
        writer.writerow(_flatten_row(row))
    return buf.getvalue()


def _flatten_keys(d, prefix=""):
    keys = []
    for k, v in d.items():
        full = f"{prefix}{k}" if not prefix else f"{prefix}.{k}"
        if isinstance(v, dict):
            keys.extend(_flatten_keys(v, full))
        else:
            keys.append(full)
    return keys


def _flatten_row(d, prefix=""):
    flat = {}
    for k, v in d.items():
        full = f"{prefix}{k}" if not prefix else f"{prefix}.{k}"
        if isinstance(v, dict):
            flat.update(_flatten_row(v, full))
        else:
            flat[full] = v
    return flat


def format_markdown(result):
    lines = []
    s = result["summary"]
    lines.append(f"# {result['scenario']} — Projection Summary")
    lines.append("")
    lines.append(f"Generated: {result['generatedAt'][:10]}")
    lines.append(f"Timeline: {result['timelineMonths']} months")
    lines.append("")
    lines.append("## Key Metrics")
    lines.append("")

    be = s["breakEvenMonth"]
    lines.append(f"- **Break-even month:** {be if be else 'Not reached'}")
    lines.append(f"- **Maximum cash deficit:** £{s['maxCashDeficit']:,.0f} (month {s['maxCashDeficitMonth']})")
    lines.append(f"- **Margin at final month:** £{s['marginAtFinalMonth']:,.0f}/month")
    lines.append(f"- **Cumulative cash flow at final month:** £{s['cumulativeCashFlowAtFinalMonth']:,.0f}")

    if "activePatientsAtFinalMonth" in s:
        lines.append(f"- **Active patients at final month:** {s['activePatientsAtFinalMonth']:.0f}")
        lines.append(f"- **Clinician utilisation at final month:** {s['clinicianUtilisationAtFinalMonth']:.0f}%")

    lines.append("")
    lines.append("## Monthly Projection")
    lines.append("")

    months = result["months"]
    domain = result["parameters"].get("domain", "clinical")

    if domain == "clinical":
        # Check if subscription revenue is present
        has_sub = "subscription" in months[0].get("revenue", {})

        if has_sub:
            lines.append("| Month | New | Pool | Total | Clin Rev | Sub Rev | Total Rev | Cost | Margin | Cumulative | Util % |")
            lines.append("|------:|----:|-----:|------:|---------:|--------:|----------:|-----:|-------:|-----------:|-------:|")
            for row in months:
                p = row["patients"]
                r = row["revenue"]
                lines.append(
                    f"| {row['month']:2d} "
                    f"| {p['newThisMonth']:.0f} "
                    f"| {p['activePool']:.0f} "
                    f"| {p['totalActive']:.0f} "
                    f"| £{r['assessment'] + r['monitoring']:,.0f} "
                    f"| £{r.get('subscription', 0):,.0f} "
                    f"| £{r['total']:,.0f} "
                    f"| £{row['cost']['total']:,.0f} "
                    f"| £{row['margin']:,.0f} "
                    f"| £{row['cumulativeCashFlow']:,.0f} "
                    f"| {row['clinicianUtilisation']:.0f}% |"
                )
        else:
            lines.append("| Month | New | Pool | Total | Revenue | Cost | Margin | Cumulative | Util % |")
            lines.append("|------:|----:|-----:|------:|--------:|-----:|-------:|-----------:|-------:|")
            for row in months:
                p = row["patients"]
                lines.append(
                    f"| {row['month']:2d} "
                    f"| {p['newThisMonth']:.0f} "
                    f"| {p['activePool']:.0f} "
                    f"| {p['totalActive']:.0f} "
                    f"| £{row['revenue']['total']:,.0f} "
                    f"| £{row['cost']['total']:,.0f} "
                    f"| £{row['margin']:,.0f} "
                    f"| £{row['cumulativeCashFlow']:,.0f} "
                    f"| {row['clinicianUtilisation']:.0f}% |"
                )
    else:
        lines.append("| Month | Daily | Monthly | Revenue | Cost | Margin | Cumulative |")
        lines.append("|------:|------:|--------:|--------:|-----:|-------:|-----------:|")
        for row in months:
            v = row["volume"]
            lines.append(
                f"| {row['month']:2d} "
                f"| {v['dailyDrinks']:.0f} "
                f"| {v['monthlyDrinks']:.0f} "
                f"| £{row['revenue']['total']:,.0f} "
                f"| £{row['cost']['total']:,.0f} "
                f"| £{row['margin']:,.0f} "
                f"| £{row['cumulativeCashFlow']:,.0f} |"
            )

    lines.append("")
    return "\n".join(lines)


def format_sensitivity_markdown(results, scenario_name=None):
    lines = []
    title = scenario_name or "Sensitivity Analysis"
    lines.append(f"# {title} — Sensitivity Analysis")
    lines.append("")
    lines.append(f"Generated: {datetime.now(timezone.utc).strftime('%Y-%m-%d')}")
    lines.append("")
    lines.append("## Break-Even Month by Parameter Variation")
    lines.append("")
    lines.append("| Parameter | Pessimistic | Base | Optimistic | SysML Prediction |")
    lines.append("|---|---:|---:|---:|---|")

    for r in results:
        runs = r["runs"]
        def _be(label):
            v = runs[label]["breakEvenMonth"]
            return str(v) if v else "Never"
        lines.append(
            f"| {r['parameterName']} "
            f"| {_be('pessimistic')} "
            f"| {_be('base')} "
            f"| {_be('optimistic')} "
            f"| {r['sysmlPrediction']} |"
        )

    lines.append("")
    lines.append("## Detailed Metrics per Variation")
    lines.append("")

    for r in results:
        lines.append(f"### {r['parameterName']}")
        lines.append("")
        lines.append("| Metric | Pessimistic | Base | Optimistic |")
        lines.append("|---|---:|---:|---:|")
        runs = r["runs"]
        for metric, label in [("breakEvenMonth", "Break-even month"),
                               ("maxCashDeficit", "Max cash deficit"),
                               ("marginAtFinalMonth", "Margin at final month"),
                               ("cumulativeCashFlowAtFinalMonth", "Cumulative cash flow")]:
            vals = []
            for scenario in ["pessimistic", "base", "optimistic"]:
                v = runs[scenario][metric]
                if metric == "breakEvenMonth":
                    vals.append(str(v) if v else "Never")
                else:
                    vals.append(f"£{v:,.0f}")
            lines.append(f"| {label} | {vals[0]} | {vals[1]} | {vals[2]} |")
        lines.append("")

    lines.append("## Dominant Sensitivity")
    lines.append("")
    max_spread = 0
    dominant = None
    for r in results:
        runs = r["runs"]
        be_p = runs["pessimistic"]["breakEvenMonth"] or 99
        be_o = runs["optimistic"]["breakEvenMonth"] or 0
        spread = be_p - be_o
        if spread > max_spread:
            max_spread = spread
            dominant = r["parameterName"]
    if dominant:
        lines.append(
            f"**{dominant}** dominates, with a break-even spread of "
            f"approximately {max_spread} months between pessimistic and optimistic values."
        )
    elif results:
        lines.append("No clear dominant parameter — break-even not reached in multiple scenarios.")
    lines.append("")
    return "\n".join(lines)


def format_console(result):
    lines = []
    s = result["summary"]
    lines.append(f"{'=' * 60}")
    lines.append(f"  {result['scenario']}")
    lines.append(f"  {result['timelineMonths']}-month projection")
    lines.append(f"{'=' * 60}")
    lines.append("")

    be = s["breakEvenMonth"]
    lines.append(f"  Break-even month:       {be if be else 'Not reached'}")
    lines.append(f"  Max cash deficit:       £{s['maxCashDeficit']:,.0f} (month {s['maxCashDeficitMonth']})")
    lines.append(f"  Final month margin:     £{s['marginAtFinalMonth']:,.0f}/month")
    lines.append(f"  Final cumulative CF:    £{s['cumulativeCashFlowAtFinalMonth']:,.0f}")

    if "activePatientsAtFinalMonth" in s:
        lines.append(f"  Final active patients:  {s['activePatientsAtFinalMonth']:.0f}")
        lines.append(f"  Final utilisation:      {s['clinicianUtilisationAtFinalMonth']:.0f}%")

    lines.append("")

    months = result["months"]
    domain = result["parameters"].get("domain", "clinical")

    if domain == "clinical":
        has_sub = "subscription" in months[0].get("revenue", {})
        if has_sub:
            lines.append(f"  {'Mo':>3}  {'New':>3}  {'Pool':>4}  {'Tot':>4}  {'ClinRev':>8}  {'SubRev':>7}  {'TotRev':>8}  {'Cost':>8}  {'Margin':>8}  {'CumCF':>9}  {'Util':>5}")
            lines.append(f"  {'---':>3}  {'---':>3}  {'----':>4}  {'----':>4}  {'--------':>8}  {'-------':>7}  {'--------':>8}  {'--------':>8}  {'--------':>8}  {'---------':>9}  {'-----':>5}")
            for row in months:
                p = row["patients"]
                r = row["revenue"]
                clin_rev = r["assessment"] + r["monitoring"]
                sub_rev = r.get("subscription", 0)
                lines.append(
                    f"  {row['month']:3d}  {p['newThisMonth']:3.0f}  {p['activePool']:4.0f}  {p['totalActive']:4.0f}"
                    f"  {clin_rev:8,.0f}  {sub_rev:7,.0f}  {r['total']:8,.0f}  {row['cost']['total']:8,.0f}  {row['margin']:8,.0f}"
                    f"  {row['cumulativeCashFlow']:9,.0f}  {row['clinicianUtilisation']:4.0f}%"
                )
        else:
            lines.append(f"  {'Mo':>3}  {'New':>3}  {'Pool':>4}  {'Tot':>4}  {'Revenue':>8}  {'Cost':>8}  {'Margin':>8}  {'CumCF':>9}  {'Util':>5}")
            lines.append(f"  {'---':>3}  {'---':>3}  {'----':>4}  {'----':>4}  {'--------':>8}  {'--------':>8}  {'--------':>8}  {'---------':>9}  {'-----':>5}")
            for row in months:
                p = row["patients"]
                lines.append(
                    f"  {row['month']:3d}  {p['newThisMonth']:3.0f}  {p['activePool']:4.0f}  {p['totalActive']:4.0f}"
                    f"  {row['revenue']['total']:8,.0f}  {row['cost']['total']:8,.0f}  {row['margin']:8,.0f}"
                    f"  {row['cumulativeCashFlow']:9,.0f}  {row['clinicianUtilisation']:4.0f}%"
                )
    else:
        lines.append(f"  {'Mo':>3}  {'Daily':>5}  {'Revenue':>8}  {'Cost':>8}  {'Margin':>8}  {'CumCF':>9}")
        lines.append(f"  {'---':>3}  {'-----':>5}  {'--------':>8}  {'--------':>8}  {'--------':>8}  {'---------':>9}")
        for row in months:
            v = row["volume"]
            lines.append(
                f"  {row['month']:3d}  {v['dailyDrinks']:5.0f}  {row['revenue']['total']:8,.0f}"
                f"  {row['cost']['total']:8,.0f}  {row['margin']:8,.0f}  {row['cumulativeCashFlow']:9,.0f}"
            )

    lines.append("")
    return "\n".join(lines)


# =========================================================================
# VERIFICATION AGAINST ILLUSTRATIVE SYSML VALUES
# =========================================================================

SYSML_ILLUSTRATIVE = {
    "lean-clinical": {
        1:  {"revenue": 1200, "cost": 4488, "margin": -3288, "cumCF": -3288,   "patients": 4,  "util": 15},
        6:  {"revenue": 2550, "cost": 4750, "margin": -2200, "cumCF": -15500,  "patients": 20, "util": 35},
        12: {"revenue": 4800, "cost": 5050, "margin": -250,  "cumCF": -18500,  "patients": 38, "util": 55},
        18: {"revenue": 7500, "cost": 6250, "margin": 1250,  "cumCF": -12500,  "patients": 52, "util": 72},
        24: {"revenue": 10500, "cost": 6650, "margin": 3850, "cumCF": -1200,   "patients": 65, "util": 85},
    },
    "full-platform": {
        1:  {"revenue": 1900,  "cost": 8000,  "margin": -6100,  "cumCF": -6100,    "patients": 4,  "util": 15},
        6:  {"revenue": 5400,  "cost": 13000, "margin": -7600,  "cumCF": -40000,   "patients": 20, "util": 25},
        12: {"revenue": 9400,  "cost": 16500, "margin": -7100,  "cumCF": -80000,   "patients": 38, "util": 30},
        18: {"revenue": 13500, "cost": 16000, "margin": -2500,  "cumCF": -100000,  "patients": 52, "util": 40},
        24: {"revenue": 16500, "cost": 16000, "margin": 500,    "cumCF": -92000,   "patients": 65, "util": 50},
    },
}


def verify_against_illustrative(result, scenario_key):
    illustrative = SYSML_ILLUSTRATIVE.get(scenario_key)
    if not illustrative:
        return f"\n  No illustrative values defined for scenario '{scenario_key}'.\n"

    lines = []
    lines.append("")
    lines.append(f"Verification against SysML illustrative ProjectionOutput values ({scenario_key}):")
    lines.append(f"  {'Mo':>3}  {'Metric':>10}  {'Engine':>9}  {'SysML':>9}  {'Δ%':>7}  {'Status'}")
    lines.append(f"  {'---':>3}  {'----------':>10}  {'---------':>9}  {'---------':>9}  {'-------':>7}  {'------'}")

    months_by_num = {row["month"]: row for row in result["months"]}
    all_ok = True

    for m, expected in sorted(illustrative.items()):
        if m not in months_by_num:
            continue
        actual = months_by_num[m]

        checks = [
            ("revenue", actual["revenue"]["total"], expected["revenue"]),
            ("cost", actual["cost"]["total"], expected["cost"]),
            ("margin", actual["margin"], expected["margin"]),
            ("cumCF", actual["cumulativeCashFlow"], expected["cumCF"]),
            ("patients", actual["patients"]["activePool"], expected["patients"]),
            ("util%", actual["clinicianUtilisation"], expected["util"]),
        ]

        for label, eng_val, exp_val in checks:
            if exp_val == 0:
                pct = 0 if eng_val == 0 else 999
            else:
                pct = (eng_val - exp_val) / abs(exp_val) * 100

            # Wider tolerance for Variant B (hand-estimated, not calibrated)
            tolerance = 20 if scenario_key == "lean-clinical" else 40
            status = "✓" if abs(pct) <= tolerance else f"⚠ >{tolerance}%"
            if abs(pct) > tolerance:
                all_ok = False

            lines.append(
                f"  {m:3d}  {label:>10}  {eng_val:9,.0f}  {exp_val:9,.0f}  {pct:+6.1f}%  {status}"
            )

    lines.append("")
    if all_ok:
        tolerance = 20 if scenario_key == "lean-clinical" else 40
        lines.append(f"  All values within {tolerance}% tolerance. ✓")
    else:
        lines.append("  ⚠ Some values diverge beyond tolerance — see session report for analysis.")
    lines.append("")

    return "\n".join(lines)


# =========================================================================
# MAIN
# =========================================================================

SCENARIOS = {
    "lean-clinical": LEAN_CLINICAL_PARAMS,
    "full-platform": FULL_PLATFORM_PARAMS,
    "coffeeshop-kiosk": COFFEESHOP_KIOSK_PARAMS,
    "coffeeshop-cafe": COFFEESHOP_CAFE_PARAMS,
}


def main():
    parser = argparse.ArgumentParser(
        description="GenderSense Projection Engine — Phases 4-5"
    )
    parser.add_argument(
        "--scenario", default="lean-clinical",
        choices=list(SCENARIOS.keys()),
        help="Scenario to project (default: lean-clinical)",
    )
    parser.add_argument(
        "--format", default="console",
        choices=["console", "json", "csv", "markdown", "all"],
        help="Output format (default: console)",
    )
    parser.add_argument(
        "--sensitivity", action="store_true",
        help="Run sensitivity analysis",
    )
    parser.add_argument(
        "--verify", action="store_true",
        help="Compare against SysML illustrative values",
    )
    parser.add_argument(
        "--compare", default=None,
        help="Compare scenarios (comma-separated, e.g. lean-clinical,full-platform)",
    )
    parser.add_argument(
        "--output-dir", default=None,
        help="Directory for file outputs (default: generated/projections/)",
    )

    args = parser.parse_args()

    script_dir = Path(__file__).parent.parent
    output_dir = Path(args.output_dir) if args.output_dir else script_dir / "generated" / "projections"
    output_dir.mkdir(parents=True, exist_ok=True)

    # -- Comparison mode --
    if args.compare:
        scenario_keys = [k.strip() for k in args.compare.split(",")]
        for k in scenario_keys:
            if k not in SCENARIOS:
                print(f"Unknown scenario: {k}. Available: {', '.join(SCENARIOS.keys())}",
                      file=sys.stderr)
                sys.exit(1)
        results = run_comparison(scenario_keys)

        # Console output
        print(format_comparison_console(results))

        # Markdown output
        md_str = format_comparison_markdown(results)
        compare_name = "-vs-".join(scenario_keys)
        md_path = output_dir / f"{compare_name}-comparison.md"
        md_path.write_text(md_str, encoding="utf-8")
        print(f"  Comparison markdown written to {md_path}", file=sys.stderr)

        # JSON output
        json_data = {k: {
            "scenario": v["scenario"],
            "summary": v["summary"],
        } for k, v in results.items()}
        json_path = output_dir / f"{compare_name}-comparison.json"
        json_path.write_text(json.dumps(json_data, indent=2), encoding="utf-8")
        print(f"  Comparison JSON written to {json_path}", file=sys.stderr)

        return

    # -- Single scenario mode --
    params = SCENARIOS[args.scenario]
    result = run_projection(params)

    # -- Output --
    if args.format == "console" or args.format == "all":
        print(format_console(result))

    if args.format == "json" or args.format == "all":
        json_str = format_json(result)
        if args.format == "json":
            print(json_str)
        json_path = output_dir / f"{args.scenario}-projection.json"
        json_path.write_text(json_str, encoding="utf-8")
        print(f"  JSON written to {json_path}", file=sys.stderr)

    if args.format == "csv" or args.format == "all":
        csv_str = format_csv(result)
        if args.format == "csv":
            print(csv_str)
        csv_path = output_dir / f"{args.scenario}-projection.csv"
        csv_path.write_text(csv_str, encoding="utf-8")
        print(f"  CSV written to {csv_path}", file=sys.stderr)

    if args.format == "markdown" or args.format == "all":
        md_str = format_markdown(result)
        if args.format == "markdown":
            print(md_str)
        md_path = output_dir / f"{args.scenario}-summary.md"
        md_path.write_text(md_str, encoding="utf-8")
        print(f"  Markdown written to {md_path}", file=sys.stderr)

    # -- Verification --
    if args.verify:
        print(verify_against_illustrative(result, args.scenario))

    # -- Sensitivity --
    if args.sensitivity:
        variations = SENSITIVITY_BY_SCENARIO.get(args.scenario)
        if not variations:
            print(f"No sensitivity parameters defined for scenario '{args.scenario}'.",
                  file=sys.stderr)
            sys.exit(1)
        sensitivity_results = run_sensitivity(params, variations)
        sens_md = format_sensitivity_markdown(sensitivity_results, params["scenarioName"])
        print(sens_md)
        sens_path = output_dir / f"{args.scenario}-sensitivity.md"
        sens_path.write_text(sens_md, encoding="utf-8")
        print(f"  Sensitivity written to {sens_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
