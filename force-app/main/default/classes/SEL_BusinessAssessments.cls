/**
* @description Business Assessment Selector Layer class.
*
* @author Wayne Solomon
* @date Jun 2020
*/
public with sharing class SEL_BusinessAssessments extends fflib_SObjectSelector {

    private Boolean assertCrud = true;
    private Boolean enforceFls = true;
    private Boolean includeSelectorFields = true;

    /**
    * @description Creates a new instance of the selector via the application class.
    * @return SEL_BusinessAssessments
    */
    public static SEL_BusinessAssessments newInstance(){
        return (SEL_BusinessAssessments) ORG_Application.selector.newInstance(Business_Assessment__c.SObjectType);
    }

    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Business_Assessment__c.Id,
                Business_Assessment__c.Name,
                Business_Assessment__c.Milestone__c,
                Business_Assessment__c.Approval_Milestone_Date__c,
                Business_Assessment__c.Updated_to_Submitted__c,
                Business_Assessment__c.Economic_Group_Client_Sector__c,
                Business_Assessment__c.Economic_Group_Client_Country_of_Risk__c,
                Business_Assessment__c.Economic_Group_Sector_Risk_Appetite__c,
                Business_Assessment__c.Risk_Classification__c,
                Business_Assessment__c.Complexity__c,
                Business_Assessment__c.Decision_Emphasis__c,
                Business_Assessment__c.Client_LGD__c,
                Business_Assessment__c.Group_Parent_Client_Name__c,
                Business_Assessment__c.Guarantor_Name__c,
                Business_Assessment__c.Nature_of_Business__c,
                Business_Assessment__c.Transaction_Profile__c,
                Business_Assessment__c.Strategic_Rationale__c,
                Business_Assessment__c.Underwrite_Amount__c,
                Business_Assessment__c.Amount_Held__c,
                Business_Assessment__c.SBSA_Role__c,
                Business_Assessment__c.Credit_Requirement__c,
                Business_Assessment__c.Listed_Instruments__c,
                Business_Assessment__c.Risk_Commentary__c,
                Business_Assessment__c.GCCR_Status__c,
                Business_Assessment__c.KYC_Status__c,
                Business_Assessment__c.EDD_PEP__c,
                Business_Assessment__c.Sanctions__c,
                Business_Assessment__c.Transaction_Risk__c,
                Business_Assessment__c.Client_Risk__c,
                Business_Assessment__c.Reference_Number__c,
                Business_Assessment__c.Transaction_on_the_Exceptions_List__c,
                Business_Assessment__c.Link_to_ENS__c,
                Business_Assessment__c.ENS_status__c,
                Business_Assessment__c.Business_Sponsor__c,
                Business_Assessment__c.Bank_Role__c,
                Business_Assessment__c.SB_Gross_Participation__c,
                Business_Assessment__c.SB_Hold__c,
                Business_Assessment__c.SB_Sell_Down__c,
                Business_Assessment__c.Transaction_Type__c,
                Business_Assessment__c.Market_Deal_Size__c,
                Business_Assessment__c.Transaction_Description__c,
                Business_Assessment__c.Group_Parent_CIF_Number__c,
                Business_Assessment__c.Committee_commentary__c,
                Business_Assessment__c.Approval_Status__c, 
                Business_Assessment__c.Submission_Type__c 
        };
    }

    /**
     * @description getSObjectType
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Business_Assessment__c.sObjectType;
    }

    /**
    * @description Set assertCrud field's value. Field can be used when creating instance of fflib_QueryFactory to assert running user's
    * CRUD on object.
    *
    * @param assertCrud
    *
    * @return SEL_BusinessAssessments
    */
    public SEL_BusinessAssessments withCrudAssert(Boolean assertCrud) {
        this.assertCrud = assertCrud;
        return this;
    }

    /**
     * @description Set enforceFls field's value. Field can be used when creating instance of fflib_QueryFactory to enforce running user's
     * FLS on object.
     *
     * @param enforceFls
     *
     * @return SEL_BusinessAssessments
     */
    public SEL_BusinessAssessments withFlsEnforced(Boolean enforceFls) {
        this.enforceFls = enforceFls;
        return this;
    }

    /**
     * @description Set includeSelectorFields field's value. Field can be used when creating instance of fflib_QueryFactory to include SObject's fields returned
     * by getSObjectFieldList method.
     *
     * @param includeSelectorFields
     *
     * @return SEL_BusinessAssessments
     */
    public SEL_BusinessAssessments includeSelectorFields(Boolean includeSelectorFields){
        this.includeSelectorFields = includeSelectorFields;
        return this;
    }

    /**
     * @description selectByIdsWithAssessmentOppChildren
     * @param recIds set of ids
     * @return List<Business_Assessment__c>
     */
    public List<Business_Assessment__c> selectByIdsWithAssessmentOppChildren(Set<Id> recIds) {
        fflib_QueryFactory baQF = newQueryFactory().selectField('Account__r.CIF__c');
        fflib_QueryFactory aoQF = new SEL_AssessmentOpportunities().addQueryFactorySubselect(baQF, 'Assessment_Opportunities__r');
        new SEL_Opportunities().configureQueryFactoryFields(aoQF, 'Opportunity__r');
        return new SEL_BusinessAssessmentsWithoutSharing().selectByIdsWithAssessmentOppChildren(recIds, baQF.setCondition('Id IN :recIds').toSOQL());
    }

    /**
     * @description Select Business Assessments by Ids
     *
     * @param ids
     * @param withSharing
     *
     * @return List<Business_Assessment__c>
     */
    public List<Business_Assessment__c> selectByIds(Set<Id> ids, Boolean withSharing){
        String query = newQueryFactory(assertCrud, enforceFls, includeSelectorFields).setCondition('Id IN :ids').toSOQL();
        if(withSharing == true){
            return (List<Business_Assessment__c>) Database.query(query);
        }
        return new SEL_BusinessAssessmentsWithoutSharing().selectByIds(ids, query);
    }

    private without sharing class SEL_BusinessAssessmentsWithoutSharing {
        private List<Business_Assessment__c> selectByIdsWithAssessmentOppChildren(Set<Id> recIds, String query) {
            return (List<Business_Assessment__c>) Database.query(query);
        }

        /**
         * @description Select records by Ids without enforcing CRUD and FLS
         *
         * @param ids
         * @param query
         *
         * @return List<Business_Assessment__c>
         */
        private List<Business_Assessment__c> selectByIds(Set<Id> ids, String query){
            return (List<Business_Assessment__c>) Database.query(query);
        }
    }

    /**
     * @description Select records by Ids without enforcing CRUD and FLS
     *
     * @param ids
     *
     * @return List<Business_Assessment__c>
     */
    public List<Business_Assessment__c> selectByIdsWithoutCrudAndFlsEnforcement(Set<Id> ids){
        return Database.query(newQueryFactory(false, false, true).setCondition('Id IN :ids').toSOQL());
    }
    
    /**
     * @description Prepare the SOQL query by Created Date and Record Type Ids
     *
     * @param lastJobTimeStamp
     * @param recordTypeIds
     *
     * @return String
     */
    public String getQueryToSelectByCreatedDateAndRecordTypeIds(Datetime lastJobTimeStamp, Set<Id> recordTypeIds) {
        return newQueryFactory(assertCrud, enforceFls, includeSelectorFields)
            .selectField('Id')
            .selectField('Name')
            .selectField('Account__r.CIF__c')
            .setCondition('CreatedDate >= :lastJobTimeStamp AND Account__r.CIF__c != null AND RecordTypeId IN :recordTypeIds')
            .toSOQL();
    }
}