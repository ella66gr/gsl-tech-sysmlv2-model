// =========================================================================
// OPERATIONS — Back office and growth functions
// =========================================================================

package Operations {
    private import ScalarValues::*;

    doc /* Back office and growth functions. Modelled at the lightest level:
         * enough structure to show data flows between operations and
         * clinical service delivery, but not attempting to model the
         * internal workings of accounting or newsletter production.
         * Outer ring. */

    package Finance {
        private import ScalarValues::*;

        doc /* Billing, accounts, Xero integration, financial reporting,
             * payroll interfaces. */

        use case def ProcessInvoice {
            doc /* Generate, issue, and track an invoice. Integrates
                 * with Xero for accounting. */
        }

        use case def ReconcilePayments {
            doc /* Reconcile payments received against invoices issued. */
        }
    }

    package People {
        private import ScalarValues::*;

        doc /* HR, contracts, indemnity arrangements, personnel
             * management. */
    }

    package Marketing {
        private import ScalarValues::*;

        doc /* Acquisition funnel, content production, community
             * development (Mighty Networks, Kit), advertising, SEO.
             *
             * Much of this domain is inherently creative and ad-hoc.
             * The model defines touchpoints and data flows rather than
             * generating execution. */

        use case def ManageAcquisitionFunnel {
            doc /* Track patient acquisition from initial awareness
                 * through to registration. */
        }
    }

    package CRM {
        private import ScalarValues::*;

        doc /* Prospect and patient relationship management,
             * communication preferences, segmentation. */
    }

    package Reporting {
        private import ScalarValues::*;

        doc /* Business intelligence, operational dashboards, regulatory
             * reporting, KPI tracking.
             *
             * If every process, decision, state transition, and constraint
             * evaluation is modelled and tracked, then operational
             * questions are queries over existing event history rather
             * than separate analytics pipelines. */

        use case def GenerateOperationalDashboard {
            doc /* Produce operational dashboard: referral-to-appointment
                 * times, pathway bottlenecks, capacity utilisation. */
        }

        use case def ProduceRegulatoryReport {
            doc /* Generate regulatory reports for CQC, NHS England, or
                 * other bodies from system data. */
        }
    }
}
