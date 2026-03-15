# Concept Graph — Generated Views

*Generated from `pattern-catalogue.sysml` (30 patterns, 51 relationships from SysML).*

## Overview

```mermaid
graph TD

    subgraph BM["Business Meta Model"]
        direction TB
        fourLayerItemModel["Four-layer item model"]
        activityTaxonomy["Activity taxonomy"]
        scenarioComparisonProjection["Scenario comparison and projection"]
        persistencePolicyAsReasoning["Persistence policy as queryable reasoning"]
    end

    subgraph BSM["Business System Meta Model"]
        direction TB
        sysmlAsSingleSourceOfTruth["SysML v2 as single source of truth"]
        twoLayerActionFlow["Two-layer pathway modelling"]
        fiveLayerSelfKnowledge["Five-layer self-knowledge architecture"]
        threeLayerPersistence["Three-persistence-layer architecture"]
        metadataDrivenGeneration["Metadata-driven generation"]
        xstateInTemporal["XState in Temporal"]
        catalogueAsUiContract["Catalogue-as-UI-contract"]
        kanbanAsProcessDashboard["Kanban-as-process-dashboard"]
        splitViewManagementLayout["Split-view management layout"]
        categoryConditionalFormFields["Category-conditional form fields"]
        crossPageDataConsistency["Cross-page data consistency"]
        auditAsTimelineDataSource["Audit-as-timeline data source"]
        processDomainGovernanceUnifiedView["Process + domain + governance unified view"]
        cdrSourceProvenanceBadges["CDR source provenance badges"]
        autoLoadingEntityViews["Auto-loading entity views"]
        infrastructureHealthAsAppConcern["Infrastructure health as application-level concern"]
        multiSourceMetricsAggregation["Multi-source metrics aggregation with graceful degradation"]
        twoLayerModelVisualisation["Two-layer model visualisation in the UI"]
        handCraftedSvgForStablePathways["Hand-crafted SVG for stable pathway diagrams"]
    end

    subgraph CC["Cross-Cutting"]
        direction TB
        coffeeshopDemonstratorAsPractice["Coffee shop demonstrator as standing validation practice"]
    end

    subgraph DEF["Deferred / Conceptual"]
        direction TB
        compositeOrderOrchestration["Composite order / multi-workflow orchestration"]:::deferred
        agencyClassificationOnActions["Agency classification on pathway actions"]:::deferred
        selfAssessmentDashboard["Self-assessment dashboard (KL Increment 3)"]:::deferred
        optionEvaluatorHelpMeChoose["OptionEvaluator / Help Me Choose"]:::deferred
        dataReleaseModel["Data release model (patient-facing)"]:::deferred
        notificationTriggersOnTransitions["Notification triggers on state transitions"]:::deferred
    end

    fourLayerItemModel -.->|enables| persistencePolicyAsReasoning
    fourLayerItemModel -.->|enables| catalogueAsUiContract
    persistencePolicyAsReasoning -->|depends on| fourLayerItemModel
    persistencePolicyAsReasoning -->|depends on| threeLayerPersistence
    sysmlAsSingleSourceOfTruth -.->|enables| metadataDrivenGeneration
    twoLayerActionFlow -->|generalises| compositeOrderOrchestration
    fiveLayerSelfKnowledge -.->|enables| scenarioComparisonProjection
    coffeeshopDemonstratorAsPractice -.->|validates| twoLayerActionFlow
    coffeeshopDemonstratorAsPractice -.->|validates| fourLayerItemModel
    coffeeshopDemonstratorAsPractice -.->|validates| threeLayerPersistence
    coffeeshopDemonstratorAsPractice -.->|validates| catalogueAsUiContract
    threeLayerPersistence -.->|enables| persistencePolicyAsReasoning
    metadataDrivenGeneration -.->|enables| xstateInTemporal
    metadataDrivenGeneration -.->|enables| twoLayerActionFlow
    catalogueAsUiContract -->|depends on| fourLayerItemModel
    kanbanAsProcessDashboard -->|depends on| xstateInTemporal
    splitViewManagementLayout <-->|composed| kanbanAsProcessDashboard
    splitViewManagementLayout <-->|composed| autoLoadingEntityViews
    categoryConditionalFormFields -->|depends on| catalogueAsUiContract
    crossPageDataConsistency -->|depends on| catalogueAsUiContract
    auditAsTimelineDataSource -->|depends on| twoLayerActionFlow
    processDomainGovernanceUnifiedView -->|depends on| twoLayerActionFlow
    processDomainGovernanceUnifiedView -->|depends on| xstateInTemporal
    cdrSourceProvenanceBadges -->|depends on| threeLayerPersistence
    autoLoadingEntityViews -->|depends on| threeLayerPersistence
    multiSourceMetricsAggregation -->|depends on| threeLayerPersistence
    multiSourceMetricsAggregation -->|depends on| infrastructureHealthAsAppConcern
    twoLayerModelVisualisation -->|depends on| twoLayerActionFlow
    handCraftedSvgForStablePathways -->|extends| twoLayerModelVisualisation
    compositeOrderOrchestration -->|depends on| xstateInTemporal
    compositeOrderOrchestration -->|depends on| twoLayerActionFlow
    agencyClassificationOnActions -->|depends on| twoLayerActionFlow
    agencyClassificationOnActions -.->|enables| optionEvaluatorHelpMeChoose
    selfAssessmentDashboard -->|depends on| fiveLayerSelfKnowledge
    selfAssessmentDashboard -->|depends on| infrastructureHealthAsAppConcern
    optionEvaluatorHelpMeChoose -->|depends on| fiveLayerSelfKnowledge
    dataReleaseModel -->|depends on| threeLayerPersistence
    dataReleaseModel -->|depends on| agencyClassificationOnActions
    notificationTriggersOnTransitions -->|depends on| xstateInTemporal

    classDef deferred stroke-dasharray: 5 5,fill:#fce4ec
```

## Dependencies

```mermaid
graph TD

    catalogueAsUiContract["Catalogue-as-UI-contract"]:::validated
    threeLayerPersistence["Three-persistence-layer architecture"]:::validated
    fiveLayerSelfKnowledge["Five-layer self-knowledge architecture"]:::validated
    auditAsTimelineDataSource["Audit-as-timeline data source"]:::validated
    cdrSourceProvenanceBadges["CDR source provenance badges"]:::validated
    twoLayerModelVisualisation["Two-layer model visualisation in the UI"]:::validated
    notificationTriggersOnTransitions["Notification triggers on state transitions"]:::discussion
    processDomainGovernanceUnifiedView["Process + domain + governance unified view"]:::validated
    crossPageDataConsistency["Cross-page data consistency"]:::validated
    compositeOrderOrchestration["Composite order / multi-workflow orchestration"]:::discussion
    kanbanAsProcessDashboard["Kanban-as-process-dashboard"]:::validated
    optionEvaluatorHelpMeChoose["OptionEvaluator / Help Me Choose"]:::designed
    autoLoadingEntityViews["Auto-loading entity views"]:::validated
    multiSourceMetricsAggregation["Multi-source metrics aggregation with graceful degradation"]:::validated
    persistencePolicyAsReasoning["Persistence policy as queryable reasoning"]:::validated
    xstateInTemporal["XState in Temporal"]:::validated
    categoryConditionalFormFields["Category-conditional form fields"]:::validated
    agencyClassificationOnActions["Agency classification on pathway actions"]:::designed
    twoLayerActionFlow["Two-layer pathway modelling"]:::validated
    infrastructureHealthAsAppConcern["Infrastructure health as application-level concern"]:::validated
    fourLayerItemModel["Four-layer item model"]:::validated
    dataReleaseModel["Data release model (patient-facing)"]:::discussion
    selfAssessmentDashboard["Self-assessment dashboard (KL Increment 3)"]:::designed

    persistencePolicyAsReasoning --> fourLayerItemModel
    persistencePolicyAsReasoning --> threeLayerPersistence
    catalogueAsUiContract --> fourLayerItemModel
    kanbanAsProcessDashboard --> xstateInTemporal
    categoryConditionalFormFields --> catalogueAsUiContract
    crossPageDataConsistency --> catalogueAsUiContract
    auditAsTimelineDataSource --> twoLayerActionFlow
    processDomainGovernanceUnifiedView --> twoLayerActionFlow
    processDomainGovernanceUnifiedView --> xstateInTemporal
    cdrSourceProvenanceBadges --> threeLayerPersistence
    autoLoadingEntityViews --> threeLayerPersistence
    multiSourceMetricsAggregation --> threeLayerPersistence
    multiSourceMetricsAggregation --> infrastructureHealthAsAppConcern
    twoLayerModelVisualisation --> twoLayerActionFlow
    compositeOrderOrchestration --> xstateInTemporal
    compositeOrderOrchestration --> twoLayerActionFlow
    agencyClassificationOnActions --> twoLayerActionFlow
    selfAssessmentDashboard --> fiveLayerSelfKnowledge
    selfAssessmentDashboard --> infrastructureHealthAsAppConcern
    optionEvaluatorHelpMeChoose --> fiveLayerSelfKnowledge
    dataReleaseModel --> threeLayerPersistence
    dataReleaseModel --> agencyClassificationOnActions
    notificationTriggersOnTransitions --> xstateInTemporal

    classDef validated fill:#2d6a4f,color:#fff,stroke:#1b4332
    classDef implemented fill:#40916c,color:#fff,stroke:#2d6a4f
    classDef designed fill:#e9c46a,color:#000,stroke:#f4a261
    classDef discussion fill:#e76f51,color:#fff,stroke:#e63946
```

## Motivation

```mermaid
graph LR

    subgraph PRIN["Architectural Principles"]
        direction TB
        separationOfRepresentationAndExecution[["Separation of representation and execution"]]:::principle
        selfDescribingSystem[["Self-describing system"]]:::principle
        modelGeneratesEverything[["Model generates everything"]]:::principle
        coffeeshopFirst[["Validate in coffee shop before clinical"]]:::principle
        deterministicOverProbabilistic[["Deterministic/auditable reasoning over probabilistic inference"]]:::principle
        patientAutonomy[["Patient autonomy and informed choice"]]:::principle
        clinicalGovernanceAsFirstClass[["Clinical governance as first-class system concern"]]:::principle
    end

    subgraph PAT["Patterns"]
        direction TB
        coffeeshopDemonstratorAsPractice["Coffee shop demonstrator as standing validation practice"]
        fiveLayerSelfKnowledge["Five-layer self-knowledge architecture"]
        auditAsTimelineDataSource["Audit-as-timeline data source"]
        agencyClassificationOnActions["Agency classification on pathway actions"]
        optionEvaluatorHelpMeChoose["OptionEvaluator / Help Me Choose"]
        sysmlAsSingleSourceOfTruth["SysML v2 as single source of truth"]
        persistencePolicyAsReasoning["Persistence policy as queryable reasoning"]
        twoLayerActionFlow["Two-layer pathway modelling"]
        dataReleaseModel["Data release model (patient-facing)"]
    end

    persistencePolicyAsReasoning -->|motivated by| selfDescribingSystem
    sysmlAsSingleSourceOfTruth -->|motivated by| separationOfRepresentationAndExecution
    sysmlAsSingleSourceOfTruth -->|motivated by| modelGeneratesEverything
    twoLayerActionFlow -->|motivated by| clinicalGovernanceAsFirstClass
    fiveLayerSelfKnowledge -->|motivated by| selfDescribingSystem
    coffeeshopDemonstratorAsPractice -->|motivated by| coffeeshopFirst
    auditAsTimelineDataSource -->|motivated by| clinicalGovernanceAsFirstClass
    agencyClassificationOnActions -->|motivated by| patientAutonomy
    optionEvaluatorHelpMeChoose -->|motivated by| patientAutonomy
    optionEvaluatorHelpMeChoose -->|motivated by| deterministicOverProbabilistic
    dataReleaseModel -->|motivated by| patientAutonomy
    dataReleaseModel -->|motivated by| clinicalGovernanceAsFirstClass

    classDef principle fill:#e8daef,stroke:#7d3c98
```

## Analogues

```mermaid
graph LR

    subgraph CSW["Coffee Shop (CSW)"]
        direction TB
        cswActivityTaxonomy["Csw Activity Taxonomy"]:::csw
        cswCatalogueAsUiContract["Csw Catalogue As Ui Contract"]:::csw
        cswFiveLayerSelfKnowledge["Csw Five Layer Self Knowledge"]:::csw
        cswFourLayerItemModel["Csw Four Layer Item Model"]:::csw
        cswScenarioComparison["Csw Scenario Comparison"]:::csw
        cswSysmlAsSingleSourceOfTruth["Csw Sysml As Single Source Of Truth"]:::csw
        cswThreeLayerPersistence["Csw Three Layer Persistence"]:::csw
        cswTwoLayerActionFlow["Csw Two Layer Action Flow"]:::csw
    end

    subgraph GSL["Gender-Affirming Care (GSL)"]
        direction TB
        gslActivityTaxonomy["Gsl Activity Taxonomy"]:::gsl
        gslCatalogueAsUiContract["Gsl Catalogue As Ui Contract"]:::gsl
        gslFiveLayerSelfKnowledge["Gsl Five Layer Self Knowledge"]:::gsl
        gslFourLayerItemModel["Gsl Four Layer Item Model"]:::gsl
        gslScenarioComparison["Gsl Scenario Comparison"]:::gsl
        gslSysmlAsSingleSourceOfTruth["Gsl Sysml As Single Source Of Truth"]:::gsl
        gslThreeLayerPersistence["Gsl Three Layer Persistence"]:::gsl
        gslTwoLayerActionFlow["Gsl Two Layer Action Flow"]:::gsl
    end

    cswActivityTaxonomy <-.->|Activity Taxonomy| gslActivityTaxonomy
    cswCatalogueAsUiContract <-.->|Catalogue As Ui Contract| gslCatalogueAsUiContract
    cswFiveLayerSelfKnowledge <-.->|Five Layer Self Knowledge| gslFiveLayerSelfKnowledge
    cswFourLayerItemModel <-.->|Four Layer Item Model| gslFourLayerItemModel
    cswScenarioComparison <-.->|Scenario Comparison| gslScenarioComparison
    cswSysmlAsSingleSourceOfTruth <-.->|Sysml As Single Source Of Truth| gslSysmlAsSingleSourceOfTruth
    cswThreeLayerPersistence <-.->|Three Layer Persistence| gslThreeLayerPersistence
    cswTwoLayerActionFlow <-.->|Two Layer Action Flow| gslTwoLayerActionFlow

    classDef csw fill:#d4edda,stroke:#28a745
    classDef gsl fill:#cce5ff,stroke:#007bff
```

## Maturity

```mermaid
graph TD

    fourLayerItemModel["Four-layer item model"]:::validated
    activityTaxonomy["Activity taxonomy"]:::validated
    scenarioComparisonProjection["Scenario comparison and projection"]:::validated
    persistencePolicyAsReasoning["Persistence policy as queryable reasoning"]:::validated
    sysmlAsSingleSourceOfTruth["SysML v2 as single source of truth"]:::validated
    twoLayerActionFlow["Two-layer pathway modelling"]:::validated
    fiveLayerSelfKnowledge["Five-layer self-knowledge architecture"]:::validated
    coffeeshopDemonstratorAsPractice["Coffee shop demonstrator as standing validation practice"]:::validated
    threeLayerPersistence["Three-persistence-layer architecture"]:::validated
    metadataDrivenGeneration["Metadata-driven generation"]:::validated
    xstateInTemporal["XState in Temporal"]:::validated
    catalogueAsUiContract["Catalogue-as-UI-contract"]:::validated
    kanbanAsProcessDashboard["Kanban-as-process-dashboard"]:::validated
    splitViewManagementLayout["Split-view management layout"]:::validated
    categoryConditionalFormFields["Category-conditional form fields"]:::validated
    crossPageDataConsistency["Cross-page data consistency"]:::validated
    auditAsTimelineDataSource["Audit-as-timeline data source"]:::validated
    processDomainGovernanceUnifiedView["Process + domain + governance unified view"]:::validated
    cdrSourceProvenanceBadges["CDR source provenance badges"]:::validated
    autoLoadingEntityViews["Auto-loading entity views"]:::validated
    infrastructureHealthAsAppConcern["Infrastructure health as application-level concern"]:::validated
    multiSourceMetricsAggregation["Multi-source metrics aggregation with graceful degradation"]:::validated
    twoLayerModelVisualisation["Two-layer model visualisation in the UI"]:::validated
    handCraftedSvgForStablePathways["Hand-crafted SVG for stable pathway diagrams"]:::validated
    compositeOrderOrchestration["Composite order / multi-workflow orchestration"]:::discussion
    agencyClassificationOnActions["Agency classification on pathway actions"]:::designed
    selfAssessmentDashboard["Self-assessment dashboard (KL Increment 3)"]:::designed
    optionEvaluatorHelpMeChoose["OptionEvaluator / Help Me Choose"]:::designed
    dataReleaseModel["Data release model (patient-facing)"]:::discussion
    notificationTriggersOnTransitions["Notification triggers on state transitions"]:::discussion

    classDef validated fill:#2d6a4f,color:#fff,stroke:#1b4332
    classDef implemented fill:#40916c,color:#fff,stroke:#2d6a4f
    classDef designed fill:#e9c46a,color:#000,stroke:#f4a261
    classDef discussion fill:#e76f51,color:#fff,stroke:#e63946
```
