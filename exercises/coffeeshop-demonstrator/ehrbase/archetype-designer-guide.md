# Archetype Designer — Step-by-Step Guide (Revised)
## Coffee Shop CDR Exercise: ORDER_RECORD Archetype + Template

**Tool:** https://tools.openehr.org/designer/
**Goal:** Create one archetype (ORDER_RECORD) and one template (order-composition),
export the Operational Template (OPT), and upload it to EHRbase.

---

## Part 2: Create the ORDER_RECORD Archetype

### 2.1 Create a new archetype — DONE

You've created `openEHR-EHR-OBSERVATION.order_record.v0` in the `coffeeshop-exercise` repository.

### 2.2 Understanding the tree

The Tree tab shows:
```
order_record
  └─ data
      └─ Any event
          ├─ data          ← THIS is where we add our fields
          └─ (state, if visible)
  └─ protocol
```

The **inner `data`** node (under "Any event") is the container for our data elements.
The breadcrumb should read: `order_record > data > Any event > data`

### 2.3 Add data elements

**How to add:** Click the inner **`data`** node to select it. You'll see a row of coloured action
buttons appear next to it: a blue **+**, copy, cut, etc. Click the **blue +** button to add a
child element.

When you click **+**, you'll get options for what to add. You want **ELEMENT** for each of
our data fields. (The left sidebar icons can also be used — the ones labelled T, Q, etc.
are shortcuts for different data types. But using the **+** button and selecting ELEMENT
is the clearest path.)

#### Field 1: Drink name

1. Select the inner **`data`** node (under Any event)
2. Click the **blue +** button
3. Choose to add an **ELEMENT** (you may see element type options or a dialog)
4. Once the element appears in the tree, click on it to select it
5. In the right panel (Constraints area), set:
   - **Name / Node name:** `Drink name`
   - Find the **data type** selector — it should default to or offer **DV_TEXT**. 
     Select **DV_TEXT** if not already selected
6. Optionally add a **Description** (look for a Description tab or field): 
   `The name of the drink ordered`

#### Field 2: Drink size

1. Select the inner **`data`** node again
2. Click the **blue +** → add another **ELEMENT**
3. Click the new element to select it
4. Set **Name:** `Drink size`
5. Change **data type** to **DV_CODED_TEXT**
6. Once DV_CODED_TEXT is selected, look for a terminology/value set section 
   (it may appear below the data type, or under a "Terminology" area in the right panel)
7. Add three coded terms — look for an "Add" or "+" button in the terminology area:
   - Text: `Small`
   - Text: `Medium`
   - Text: `Large`
   (The at-codes like at0010, at0011, at0012 will be auto-assigned)
8. Description: `Size of the drink ordered`

**Tip:** If you can't find where to add coded terms, try the **Terminology** tab at the 
top of the main editor area (next to Tree, Mindmap, Tabbed, ADL, etc.)

#### Field 3: Milk choice

1. Select inner **`data`** → **blue +** → **ELEMENT**
2. **Name:** `Milk choice`
3. **Data type:** **DV_CODED_TEXT**
4. Add five coded terms:
   - `None`
   - `Whole milk`
   - `Semi-skimmed milk`
   - `Oat milk`
   - `Soy milk`
5. Description: `Type of milk requested`

#### Field 4: Extras

1. Select inner **`data`** → **blue +** → **ELEMENT**
2. **Name:** `Extras`
3. **Data type:** **DV_TEXT**
4. **Occurrences:** Look for an Occurrences field in the right panel (Constraints area).
   Set minimum to `0` and maximum to `*` (or leave max blank / tick "unbounded").
   This makes the field optional and repeatable.
5. Description: `Additional modifications to the drink`

#### Field 5: Price

1. Select inner **`data`** → **blue +** → **ELEMENT**
2. **Name:** `Price`
3. **Data type:** **DV_TEXT**
   (Using text rather than DV_QUANTITY because openEHR quantities expect clinical
   UCUM units — currency doesn't fit naturally. "3.50" as text works for the exercise.)
4. Description: `Price of the drink`

### 2.4 Review

Your tree should now show:
```
order_record
  └─ data
      └─ Any event
          └─ data
              ├─ Drink name       [DV_TEXT]
              ├─ Drink size       [DV_CODED_TEXT: Small, Medium, Large]
              ├─ Milk choice      [DV_CODED_TEXT: None, Whole milk, ...]
              ├─ Extras           [DV_TEXT, 0..*]
              └─ Price            [DV_TEXT]
      └─ protocol
```

### 2.5 Save

Click **Save** in the top menu bar (you can see it between "Repositories" and "Export").

---

## Part 3: Create the Order Composition Template

### 3.1 Create a new template

1. Click **Repositories** in the top menu bar to go back to the dashboard
2. Inside your `coffeeshop-exercise` repository, look for a way to create a new item
   — there should be a **"New"** or **"+"** button, possibly with a dropdown to choose
   between Archetype and Template
3. Select **Template**
4. Fill in:
   - **Template ID:** `coffeeshop-order-composition.v1`
   - **RM Type:** **COMPOSITION** (should be default for templates)
5. Click **Create**

### 3.2 Add the archetype to the template

1. You'll see a COMPOSITION root node in the tree
2. Select the COMPOSITION node → click the **blue +** button (or look for "Add" options)
3. You should be able to search for or browse archetypes — find `order_record`
4. Select it → it appears under the COMPOSITION content

### 3.3 Save

Click **Save** in the top menu bar.

---

## Part 4: Export the Operational Template (OPT)

1. With the template open, click **Export** in the top menu bar
2. Select **Export OPT** (or "Operational Template")
3. Browser downloads an XML file
4. Move it to:
   ```
   ~/Developer/gsl-tech/gsl-sysml-model/exercises/coffeeshop-demonstrator/ehrbase/
   ```

---

## Part 5: Upload the OPT to EHRbase

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model/exercises/coffeeshop-demonstrator

# Upload (adjust filename to match what was downloaded)
curl -u ehrbase-user:SuperSecretPassword \
  -X POST \
  -H "Content-Type: application/xml" \
  -d @ehrbase/coffeeshop-order-composition.v1.opt \
  http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4

# Verify it's listed
curl -u ehrbase-user:SuperSecretPassword \
  http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4
```

---

## Left Sidebar Icons (for reference)

The icons down the left side of the tree are shortcuts for adding specific element types:
- **T** — Text element (DV_TEXT)
- **T̲** — Coded text element (DV_CODED_TEXT)  
- **Q** — Quantity element (DV_QUANTITY)
- **1:2** — Ordinal (DV_ORDINAL)
- **1₂₃** — Count (DV_COUNT)
- And others for Boolean, Date/Time, Multimedia, etc.

You can use these as a shortcut instead of blue + → ELEMENT → change type.
For example, clicking **T** while `data` is selected would add a DV_TEXT element directly.

---

## Troubleshooting

**Blue + doesn't show options I expect:**
The + adds a child to whatever node is selected. Make sure the inner `data` node 
(breadcrumb: `order_record > data > Any event > data`) is selected.

**Can't find data type selector:**
After adding an element and selecting it, look in the right panel under "Constraints". 
The data type may appear as a dropdown or as clickable type badges.

**DV_CODED_TEXT — can't find where to add terms:**
Look below the data type selector in the right panel for "Local terminology" or 
"Value set". Also check the **Terminology** tab in the top tab bar of the editor.

**Template — archetype doesn't appear in search:**
Save the archetype first. Templates can only reference saved archetypes.
