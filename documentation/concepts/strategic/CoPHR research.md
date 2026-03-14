<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Many years back now, some colleagues of mine wrote a paper on, I think, something like a blueprint for a patient-held record, setting out what would be needed for that. I may have a digital copy buried somewhere.

Can you have a look online and see what exists along these lines.

A substantial body of work now exists on blueprints and design frameworks for patient‑held or person‑centred records, mostly under the banners of “personal health records” (PHRs), “co‑produced” records, and national single patient record architectures.[^1_1][^1_2][^1_3][^1_4][^1_5]

## Core conceptual models

Modern work typically distinguishes between:

- Patient‑held personal health records (owned/managed by the patient, may be standalone or tethered to a portal).[^1_6][^1_5]
- Person‑centred records embedded in provider systems but explicitly designed around the person’s goals, needs and shared decision‑making.[^1_3]
- National “single patient record” architectures that unify data at point of use via standards, but still assume strong patient access and control.[^1_7]

Key conceptual themes:

- Lifelong, universal, electronic resource, managed by the individual, separate from legal provider record.[^1_6]
- Data flowing from providers, the individual, devices and sometimes family/carers, into a patient‑controlled space.[^1_2][^1_4]


## Example blueprints and frameworks

- Apperta “Blueprint for a Co‑Produced Personal Health Record (CoPHR)” sets out nine principles plus a core schema and governance framework for a co‑produced PHR, including provenance, audit, and explicit patient control over contributions and access.[^1_1]
- A “person‑centred health record” architecture (personalized PHR) proposes modules for registration/personalisation, data management, services/updates, and notification/authorisation, generating a condition‑tailored PHR that evolves over time.[^1_2]
- NHS Scotland’s “Design Principles to Create Person Centred Records” provide a practical framework for record designers, mandating that records capture individual goals, support shared decision‑making and multidisciplinary planning, and remain legally and professionally compliant.[^1_3]
- Nuffield Trust’s report on electronic PHRs reviews concepts, models and definitions, including paper and digital patient‑held records, and discusses implementation models in the UK context.[^1_5]
- Orion Health’s “National Blueprint for the Single Patient Record” (more on architecture than patient‑held per se) argues for federated, real‑time, data‑level interoperability using FHIR/openEHR/SNOMED, with strong audit and medico‑legal defensibility.[^1_7]


## Common design requirements for a patient‑held record

Across these sources, a reasonably convergent “requirements blueprint” emerges:

- Governance and control
    - Patient ownership/management of the PHR; control of who can view and contribute, including revocation of access.[^1_4][^1_1][^1_6]
    - Clear separation from the provider’s formal medico‑legal record while still supporting clinicians’ defensive documentation needs and audit trails.[^1_1][^1_7][^1_3]
- Information model and standards
    - Core schema that can meet most stakeholders’ needs, with governed extensions for specific use cases.[^1_1]
    - Use of open standards (e.g. FHIR, openEHR, SNOMED CT) to enable semantic consistency and interoperability across settings.[^1_7][^1_2]
- Provenance, audit and legality
    - Explicit recording of contributor identity and role, timestamps, device identity, versioning, and traceability to source.[^1_7][^1_1]
    - Design of record structures to support succinct, legally sound, contemporaneous documentation consistent with professional codes and public records legislation where applicable.[^1_3][^1_7]
- Person‑centred content and workflow
    - Capture of individual goals, preferences, care plans and self‑management information, not just clinical observations.[^1_2][^1_3]
    - Alignment of record design with real clinical workflows and multidisciplinary communication, including handover and shared decision‑making.[^1_8][^1_9][^1_3]
- Personalisation and engagement
    - Condition‑based tailoring of the record structure and views so that it is understandable and meaningful to the patient.[^1_2]
    - Support for delegation of access (family, carers) and integration of “everyday” data (maternity, child health, long‑term conditions, end‑of‑life).[^1_4]
- Technical qualities
    - Secure, usable, online access, with robust authentication and privacy protections under patient control.[^1_5][^1_6][^1_4]
    - Real‑time or near‑real‑time updates from source systems, shifting from document‑level to data‑level interoperability.[^1_7][^1_2]


## Brief comparison of key exemplars

| Work/document | Focus | Relevance to “blueprint” for patient‑held record |
| :-- | :-- | :-- |
| Apperta Co‑Produced PHR Blueprint[^1_1] | Co‑produced personal health record, UK | Very close: principles, schema, governance, provenance, patient control |
| Person‑Centred Health Record architecture[^1_2] | Conceptual PHR architecture and modules | Strong: conceptual modules and personalisation model |
| NHS Scotland person‑centred record principles[^1_3] | Design principles for person‑centred records | Strong on requirements and design criteria, less on technical schema |
| Nuffield Trust EPHR report[^1_5] | Landscape review of electronic PHRs | Helpful for context, models and definitions rather than a single schema |
| National Single Patient Record blueprint[^1_7] | Federated national architecture | Useful for interoperability and medico‑legal requirements, less specifically patient‑held |

If you can recall any distinctive phrases, authors, institutions, or an approximate year from your colleagues’ paper, I can help narrow the search to see if that specific work (or its descendants) is online.
<span style="display:none">[^1_10][^1_11][^1_12][^1_13][^1_14][^1_15]</span>

<div align="center">⁂</div>

[^1_1]: https://apperta.org/assets/Apperta_A_Blueprint_for_a_Co-produced_Personal_Health_Record_Ecosystem.pdf

[^1_2]: https://pmc.ncbi.nlm.nih.gov/articles/PMC5333233/

[^1_3]: https://www.healthcareimprovementscotland.scot/wp-content/uploads/2024/04/NHS-Scotland-Design-Principles-Create-Person-Centred-Records-March-2024.pdf

[^1_4]: https://www.digitalhealth.net/2022/10/what-is-a-personal-health-record-anyway/

[^1_5]: https://www.nuffieldtrust.org.uk/sites/default/files/2017-01/electronic-personal-health-records-uk-web-final.pdf

[^1_6]: https://en.wikipedia.org/wiki/Personal_health_record

[^1_7]: https://orionhealth.com/wp-content/uploads/Orion-Health-and-HIC-National-Blueprint-for-the-Patient-Record-Whitepaper-2025.pdf

[^1_8]: https://bmjopen.bmj.com/content/11/9/e046965

[^1_9]: https://etheses.bham.ac.uk/id/eprint/14534/7/Joseph2024PhD_Redacted.pdf

[^1_10]: https://pmc.ncbi.nlm.nih.gov/articles/PMC3409830/

[^1_11]: https://www.recordnations.com/blog/medical-records-retention-times/

[^1_12]: https://journal.ahima.org/Portals/0/archives/AHIMA files/Retaining Healthcare Business Records.pdf

[^1_13]: https://www.cms.gov/files/document/mln4840534-medical-record-maintenance-and-access-requirements.pdf

[^1_14]: https://chartpath.com/blog/medical-records-retention-laws-by-state-a-compliance-guide-for-ltpac-practices

[^1_15]: https://www.fda.gov/food/food-safety-modernization-act-fsma/fsma-final-rule-requirements-additional-traceability-records-certain-foods


---

# I was thinking of the Apperta document. I worked with several of its authors.

That makes sense; the Apperta coPHR blueprint is exactly in the space you were remembering.[^2_1][^2_2]

## Quick refresher on what Apperta’s coPHR does

- It defines a **co‑produced** personal health record where patient, carers and HCPs are all first‑class contributors, but with explicit, fine‑grained access controls and role‑based permissions.[^2_1]
- The record is implemented as an openEHR‑based “coPHR Schema” (core plus governed extensions), with data‑level interoperability and no dependency on a single app or vendor.[^2_2][^2_1]
- The ecosystem is modular: multiple clinical data repositories, apps, and identity services can coexist as long as they implement the coPHR interfaces, so a patient can choose apps while maintaining a single definitive record.[^2_2][^2_1]


## Key design/requirements highlights

- Nine high‑level principles, including: shared openEHR data model, patient control of who can view/contribute, irrevocable access to historic data relied on for care, mandatory provenance, and full audit trail.[^2_1]
- Technical building blocks:
    - Data Repository (openEHR CDR plus FHIR demographics),
    - Authentication and Identity Assurance Service,
    - Discovery service for locating records and components,
    - coPHR‑compliant apps using a simplified API.[^2_1]
- Governance framework covering information/clinical governance, technical governance, legal agreements between ecosystem parties, and a “trusted body” to oversee the model.[^2_1]

If it’s useful, I can pull out or re‑express specific sections (e.g. the nine principles, schema core, or governance model) into something you could reuse directly in GenderSci documentation or as a requirements checklist.
<span style="display:none">[^2_10][^2_11][^2_12][^2_13][^2_14][^2_15][^2_3][^2_4][^2_5][^2_6][^2_7][^2_8][^2_9]</span>

<div align="center">⁂</div>

[^2_1]: https://apperta.org/assets/Apperta_A_Blueprint_for_a_Co-produced_Personal_Health_Record_Ecosystem.pdf

[^2_2]: https://apperta.org

[^2_3]: https://apperta.org/coPHR/

[^2_4]: https://www.linkedin.com/posts/kanthan-theivendran-46381140_a-blueprint-for-a-co-produced-personal-health-activity-7341390831922114561-lYc7

[^2_5]: http://www.sabien.upv.es/event/openEHR2019Valencia/slideshows/IanMcN_openEHR_Day_Valencia_Oct2019.pdf

[^2_6]: https://apperta.org/assets/Apperta_Defining_an_Open_Platform_April.pdf

[^2_7]: https://theprsb.org/wp-content/uploads/2020/11/Core-Information-Standard-Final-Report-v1.2-9.11.20.pdf

[^2_8]: https://www.linkedin.com/posts/nevesaluisa_check-out-our-latest-opinion-piece-led-activity-7382036760513548288-EA1R

[^2_9]: https://theprsb.org/wp-content/uploads/2019/09/Core-Information-Standard-Final-Report-1.1.pdf

[^2_10]: https://www.linuxfoundation.org/hubfs/LF Research/lfr_healthdata2024_110524a.pdf?hsLang=en

[^2_11]: https://www.slideshare.net/slideshow/openehr-revolution-sardinia-2019/149211936

[^2_12]: https://www.linkedin.com/posts/lloydgprice_citizen-ownership-is-the-only-path-to-a-single-activity-7358542169768349697-LGZX

[^2_13]: https://pdfs.semanticscholar.org/3085/18cf724626c6df78617c2a6e53f4fb4a8d03.pdf

[^2_14]: https://www.digitalhealth.net/2019/02/lhcres-purpose-always-clear/

[^2_15]: https://apperta.org/openEHR-templates/

