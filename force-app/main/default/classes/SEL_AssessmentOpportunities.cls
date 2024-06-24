/**
* Assessment Opportunities Selector Layer class.
*
* @author Wayne Solomon
* @date 2020-06-17
*/
public with sharing class SEL_AssessmentOpportunities extends fflib_SObjectSelector {

    private Boolean assertCrud = true;
    private Boolean enforceFls = true;
    private Boolean includeSelectorFields = true;

    /**
     * Creates a new instance of the selector via the application class.
     *
     * @return SEL_AssessmentOpportunities
     */
    public static SEL_AssessmentOpportunities newInstance() {
        return (SEL_AssessmentOpportunities)ORG_Application.selector.newInstance(Assessment_Opportunity__c.SObjectType);
    }

    /**
     * Returns the list of Resourcing fields
     *
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Assessment_Opportunity__c.Business_Assessment__c,
                Assessment_Opportunity__c.Id,
                Assessment_Opportunity__c.Opportunity__c,
                Assessment_Opportunity__c.Total_SB_Gross_Participation__c
        };
    }

    /**
     * Returns SObject type
     *
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Assessment_Opportunity__c.sObjectType;
    }

    /**
     * Set assertCrud field's value. Field can be used when creating instance of fflib_QueryFactory to assert running user's
     * CRUD on object.
     *
     * @param assertCrud
     *
     * @return
     */
    public SEL_AssessmentOpportunities withCrudAssert(Boolean assertCrud) {
        this.assertCrud = assertCrud;
        return this;
    }

    /**
     * Set enforceFls field's value. Field can be used when creating instance of fflib_QueryFactory to enforce running user's
     * FLS on object.
     *
     * @param enforceFls
     *
     * @return
     */
    public SEL_AssessmentOpportunities withFlsEnforced(Boolean enforceFls) {
        this.enforceFls = enforceFls;
        return this;
    }

    /**
     * Set includeSelectorFields field's value. Field can be used when creating instance of fflib_QueryFactory to include SObject's fields returned
     * by getSObjectFieldList method.
     *
     * @param includeSelectorFields
     *
     * @return
     */
    public SEL_AssessmentOpportunities includeSelectorFields(Boolean includeSelectorFields){
        this.includeSelectorFields = includeSelectorFields;
        return this;
    }

    /**
     * Select records filtered by Opportunity Ids
     *
     * @param opportunityIds
     * @param withSharing
     *
     * @return
     */
    public List<Assessment_Opportunity__c> selectByOpportunityId(Set<Id> opportunityIds, Boolean withSharing) {
        String query = newQueryFactory(assertCrud, enforceFls, includeSelectorFields)
                .selectField('Opportunity__r.AccountId')
                .setCondition('Opportunity__c IN :opportunityIds')
                .toSOQL();
        if (withSharing == true) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }
        return new WithoutSharing().selectByOpportunityId(opportunityIds, query);
    }

    /**
     * Select by opportunity Ids with DCP fields
     *
     * @param opportunityIds
     * @param withSharing
     *
     * @return
     */
    public List<Assessment_Opportunity__c> selectByOpportunityIdWithDcpFields(Set<Id> opportunityIds, Boolean withSharing) {
        String query = newQueryFactory(assertCrud, enforceFls, includeSelectorFields)
                .setCondition('Opportunity__c IN :opportunityIds AND Business_Assessment__r.IsDeleted = false')
                .selectField('Business_Assessment__r.Credit_Paper_Application_Created__c')
                .selectField('Business_Assessment__r.Credit_Paper_Application_Created_By__c')
                .selectField('Business_Assessment__r.Credit_Paper_Sent_for_Approval__c')
                .selectField('Business_Assessment__r.Credit_Paper_Sent_for_Approval_By__c')
                .selectField('Business_Assessment__r.Credit_Paper_Approval__c')
                .selectField('Business_Assessment__r.Credit_Paper_Approved_By__c')
                .selectField('Business_Assessment__r.Credit_Paper_ID__c')
                .selectField('Business_Assessment__r.Credit_Paper_URL__c')
                .selectField('Business_Assessment__r.Credit_Paper_Declined__c')
                .selectField('Business_Assessment__r.Credit_Paper_Decline_Reason__c')
                .selectField('Business_Assessment__r.Credit_Paper_Decline_Date__c')
                .selectField('Business_Assessment__r.Credit_Paper_Decline_By__c')
                .selectField('Business_Assessment__r.Name')
                .selectField('Business_Assessment__r.Milestone__c')
                .selectField('Business_Assessment__r.NBAC_Meeting_Date__c')
                .selectField('Business_Assessment__r.NBAC_Committee__c')
                .selectField('Business_Assessment__r.Approval_Milestone_Date__c')
                .selectField('Business_Assessment__r.LastModifiedDate')
                .toSOQL();
        if (withSharing == true) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }
        return new WithoutSharing().selectByOpportunityIdWithDcpFields(opportunityIds, query);
    }

    /**
     * Select records filtered by Business Assessment Ids
     *
     * @param businessAssessmentIds
     * @param withSharing
     *
     * @return
     */
    public List<Assessment_Opportunity__c> selectByBusinessAssessmentId(Set<Id> businessAssessmentIds, Boolean withSharing) {
        String query = newQueryFactory(assertCrud, enforceFls, includeSelectorFields)
                .selectField('Opportunity__r.AccountId')
                .setCondition('Business_Assessment__c IN :businessAssessmentIds')
                .toSOQL();
        if (withSharing == true) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }
        return new WithoutSharing().selectByBusinessAssessmentId(businessAssessmentIds, query);
    }

    /**
     * Select deleted by Business Assessment Ids
     *
     * @param businessAssessmentIds
     * @param withSharing
     *
     * @return
     */
    public List<Assessment_Opportunity__c> selectDeletedByBusinessAssessmentId(Set<Id> businessAssessmentIds, Boolean withSharing) {
        String query = newQueryFactory(assertCrud, enforceFls, includeSelectorFields)
                .setCondition('Business_Assessment__c IN :businessAssessmentIds AND IsDeleted = true')
                .toSOQL() + ' ALL ROWS';
        if (withSharing == true) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }
        return new WithoutSharing().selectDeletedByBusinessAssessmentId(businessAssessmentIds, query);
    }

    private without sharing class WithoutSharing {

        private List<Assessment_Opportunity__c> selectByOpportunityId(Set<Id> opportunityIds, String query) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }

        private List<Assessment_Opportunity__c> selectByOpportunityIdWithDcpFields(Set<Id> opportunityIds, String query) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }

        private List<Assessment_Opportunity__c> selectByBusinessAssessmentId(Set<Id> businessAssessmentIds, String query) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }

        private List<Assessment_Opportunity__c> selectDeletedByBusinessAssessmentId(Set<Id> businessAssessmentIds, String query) {
            return (List<Assessment_Opportunity__c>) Database.query(query);
        }
    }
}