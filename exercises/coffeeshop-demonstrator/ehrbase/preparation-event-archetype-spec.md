# PREPARATION_EVENT Archetype — Design Specification

**Date:** 7 March 2026
**Phase:** CDR Exercise Phase D — Governance Audit
**Purpose:** Guide for building the PREPARATION_EVENT archetype in Archetype Designer

---

## 1. Archetype Identity

| Field | Value |
|---|---|
| Archetype ID | `openEHR-EHR-ACTION.preparation_event.v0` |
| RM class | ACTION |
| Concept | Preparation event |
| Description | Records the preparation of a coffee drink, including method, barista, timing, and notes |

---

## 2. Why ACTION?

The openEHR ACTION class models **interventions** — things that are done to or for the subject. An ACTION has a built-in state machine (`ism_transition`) that tracks the activity through its lifecycle: planned → scheduled → active → completed (and other states). This maps naturally to drink preparation: the barista starts preparing (active) and finishes (completed).

For the coffee shop exercise, the key implication is that an ACTION composition carries an `ism_transition` element alongside the `description` data. Archetype Designer handles this structure — you design the data elements in the description tree, and the ISM transition states are part of the RM class automatically.

**Clinical analogy:** An ACTION archetype is used for things like "medication administered", "procedure performed", "investigation performed". Preparation of a drink is analogous to performing a procedure.

---

## 3. Data Elements

These go in the ACTION's **description** (ITEM_TREE). In Archetype Designer, when you create an ACTION archetype, the description tree is where you add your data elements.

| Element | Proposed Node ID | Data type | Coded terms / constraints | Notes |
|---|---|---|---|---|
| Preparation method | at0002 | DV_CODED_TEXT | Hot path (at0007), Cold path (at0008) | How the drink was prepared |
| Barista name | at0003 | DV_TEXT | Free text | Who prepared the drink |
| Start time | at0004 | DV_DATE_TIME | — | When preparation started |
| End time | at0005 | DV_DATE_TIME | — | When preparation finished |
| Preparation notes | at0006 | DV_TEXT | Free text, 0..1 | Optional notes (e.g. "customer requested extra hot") |

**Note on at-codes:** Archetype Designer auto-assigns at-codes, so the actual codes may differ from these proposed values. The important thing is the element names, data types, and coded term values. Record the actual at-codes assigned by the designer — we'll need them for the composition builder.

---

## 4. ISM Transition

The ACTION RM class includes ISM (Instruction State Machine) transitions. For this exercise, we need at minimum:

- **active** (careflow_step: "Preparation started") — when the barista begins
- **completed** (careflow_step: "Preparation completed") — when the drink is ready

In Archetype Designer, the ISM transition section is typically part of the ACTION archetype configuration. You may see a "Careflow steps" or "ISM transitions" section. If the designer doesn't make this easily configurable, we can set the ISM transition values in the composition builder code instead — the archetype only needs to define the description data elements.

**Pragmatic approach:** If configuring ISM transitions in Archetype Designer is complex or unclear, skip it. We'll set the ISM transition to "completed" in the composition builder (since we're recording preparation events after the fact). The key data is in the description tree.

---

## 5. Steps in Archetype Designer

1. **Create new archetype:**
   - RM Type: ACTION
   - Concept name: `preparation_event`
   - This creates `openEHR-EHR-ACTION.preparation_event.v0`

2. **Add data elements** in the description tree:
   - Add "Preparation method" — DV_CODED_TEXT, Internal coded
     - Add coded terms: "Hot path" and "Cold path"
   - Add "Barista name" — DV_TEXT (free text)
   - Add "Start time" — DV_DATE_TIME
   - Add "End time" — DV_DATE_TIME
   - Add "Preparation notes" — DV_TEXT, occurrences 0..1

3. **Create COMPOSITION archetype** (if needed):
   - RM Type: COMPOSITION
   - Concept name: `preparation_composition`
   - This creates `openEHR-EHR-COMPOSITION.preparation_composition.v0`

4. **Create template:**
   - Template ID: `coffeeshop-preparation-composition.v1`
   - Root archetype: the preparation_composition COMPOSITION
   - Add the preparation_event ACTION into the content slot

5. **Export OPT:**
   - Use Firefox (Chrome hangs on OPT export)
   - Export to OPT
   - Save as `coffeeshop-preparation-composition.v1.opt`

6. **Upload to EHRbase:**
   ```bash
   curl -X POST \
     -u ehrbase-user:SuperSecretPassword \
     -H "Content-Type: application/xml" \
     --data-binary @coffeeshop-preparation-composition.v1.opt \
     http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4
   ```

7. **Verify upload:**
   ```bash
   curl -u ehrbase-user:SuperSecretPassword \
     http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4
   ```
   Should list `coffeeshop-preparation-composition.v1` alongside the existing two templates.

---

## 6. Important Reminders

- **Edit terms in the archetype, not the template** (Phase A lesson)
- **Use Firefox for OPT export** (Chrome hangs — Phase A finding)
- **Record the actual at-codes** assigned by Archetype Designer — paste them back so I can build the composition builder with correct codes
- **Database may need reset** if you need to re-upload a corrected OPT:
  ```bash
  cd exercises/coffeeshop-demonstrator
  docker compose -f docker-compose.ehrbase.yml down -v
  docker compose -f docker-compose.ehrbase.yml up -d
  ```
  Then re-upload ALL templates (order, feedback, preparation)

---

## 7. What I Need Back

Once you've built the archetype and template, please provide:

1. **The actual at-codes** for each data element (from the tree view with NodeId column)
2. **The at-codes for the coded terms** under Preparation method (Hot path / Cold path)
3. **The at-code for the description root** (the ITEM_TREE node, likely at0001)
4. **Confirmation that the OPT exported and uploaded successfully**
5. **Copy the OPT file** to `exercises/coffeeshop-demonstrator/ehrbase/coffeeshop-preparation-composition.v1.opt`

With that information I can immediately write `preparation-composition-builder.ts` and the test data seeding script.

---

*Specification prepared for Phase D, CDR Exercise, 7 March 2026.*
