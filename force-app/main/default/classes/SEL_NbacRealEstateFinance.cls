/**
 * @description Selector class for NBAC_Real_Estate_Finance__c SObject
 *
 * @author Stane Murhula (stane.murhula@standardbank.co.za)
 * @date December 2023
 * 
 */
    public with sharing class SEL_NbacRealEstateFinance extends fflib_SObjectSelector {
        /**
         * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
         * and inject a mock instead of this class or to switch out this class for a new version.
         * @return SEL_NbacRealEstateFinance class instance
         */
        public static SEL_NbacRealEstateFinance newInstance() {
            return (SEL_NbacRealEstateFinance) ORG_Application.selector
                .newInstance(NBAC_Real_Estate_Finance__c.SObjectType);
        }

        /**
         * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
         * queries.
         * @return NBAC_Real_Estate_Finance__c object type
         */
        public SObjectType getSObjectType() {
            return NBAC_Real_Estate_Finance__c.SObjectType;
        }

        /**
         * @description Returns the SObject fields on this sObject
         * @return NBAC_Real_Estate_Finance__c fields list
         */
        public List<SObjectField> getSObjectFieldList() {
            return new List<Schema.SObjectField>{
                NBAC_Real_Estate_Finance__c.Id, 
                NBAC_Real_Estate_Finance__c.Business_Assessment__c, 
                NBAC_Real_Estate_Finance__c.Land_Cost__c, 
                NBAC_Real_Estate_Finance__c.Improvement_Cost_Construction_Cost__c,
                NBAC_Real_Estate_Finance__c.General_Sundry_Costs__c, 
                NBAC_Real_Estate_Finance__c.Other_Finance_Cost__c, 
                NBAC_Real_Estate_Finance__c.Consultant_Professional_Fees__c, 
                NBAC_Real_Estate_Finance__c.Capital_Amount__c, 
                NBAC_Real_Estate_Finance__c.Interest_Limit__c, 
                NBAC_Real_Estate_Finance__c.Structuring_Fee__c, 
                NBAC_Real_Estate_Finance__c.Facility_Amount__c, 
                NBAC_Real_Estate_Finance__c.Equity__c, 
                NBAC_Real_Estate_Finance__c.Total_Budgeted_Development_Cost__c, 
                NBAC_Real_Estate_Finance__c.Metric__c,
                NBAC_Real_Estate_Finance__c.Development_Period__c,
                NBAC_Real_Estate_Finance__c.Gross_Building_Area__c,
                NBAC_Real_Estate_Finance__c.Loan_to_Cost__c 
            };
        }

        /**
         * @description Select NBAC_Real_Estate_Finance__c filtered by Business Assesment ID
         * @param baIds Assessment ID set of Ids of Business_Assessment__c
         *
         * @return list of NBAC_Real_Estate_Finance__c
         */
        public List<NBAC_Real_Estate_Finance__c> selectRefByBaId(Set<String> baIds) {
            return (List<NBAC_Real_Estate_Finance__c>) Database.query(
                newQueryFactory()
                    .selectField('Business_Assessment__r.Development_Funding_Loan__c')
                    .selectField('Business_Assessment__r.Milestone__c')
                    .setCondition('Business_Assessment__c IN: baIds')
                    .toSOQL()
            );
        }

        /**
         * @description Select NBAC_Real_Estate_Finance__c filtered by Real Estate Finance ID
         * @param refIds set of Ids of NBAC_Real_Estate_Finance__c
         *
         * @return list of NBAC_Real_Estate_Finance__c
         */
        public List<NBAC_Real_Estate_Finance__c> selectRefByRefId(List<String> refIds) {
            return (List<NBAC_Real_Estate_Finance__c>) Database.query(
                newQueryFactory()
                    .selectField('Id')
                    .setCondition('Id IN: refIds')
                    .toSOQL()
            );
        }
    }