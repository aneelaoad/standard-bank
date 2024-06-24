/**************************************************************************************
    @ Created By      :   Andrei O
    @ Created On      :   17.10.2016
    @ Description     :   Controller for 'Develop Prospect' button on prospect clients
***************************************************************************************/

public with sharing class Develop_Prospect_LEX_Controller {

    @AuraEnabled
    public Id potentialClientRecordTypeId;
    @AuraEnabled
    public String[] fieldsToQuery;

    /** this will hold flag to indicate if we are not commB user
     */
    @AuraEnabled
    public Boolean is_comm_b;

    @TestVisible
    private static final Set<SObjectField> DESIRED_FIELDS = new Set<SObjectField>{
        Account.Id,
        Account.Primary_Relationship_Holder__c,
        Account.Name,
        Account.Status__c,
        Account.BillingStreet,
        Account.Registration_Number__c,
        Account.BillingCity,
        Account.KYC_Contact__c,
        Account.BillingState,
        Account.BillingCountry,
        Account.Phone,
        Account.Website,
        Account.Description,
        Account.Client_Co_ordinator__c,
        Account.Client_Relationship_Hierarchy__c,
        Account.Market_Segments__c,
        Account.ParentId,
        Account.Client_Sector__c,
        Account.Proposed_Group_Parent__c,
        Account.Client_Sub_Sector__c,
        Account.Proposed_Immediate_Parent__c,
        Account.Long_Term_Strategy__c,
        Account.Short_Term_Objectives__c,
        Account.Client_Current_Relationship__c,
        Account.Client_Strategy__c,
        Account.Client_Current_Relationship__c,
        Account.Client_Marketing_Strategy__c,
        Account.RecordTypeId,
        Account.Industry_Code__c,
        Account.Update_Path__c,
        Account.ISIC_C_ode__c
    };

    @AuraEnabled
    public static Develop_Prospect_LEX_Controller getComponentAttributes() {
        Develop_Prospect_LEX_Controller response = new Develop_Prospect_LEX_Controller();

        response.potentialClientRecordTypeId = getPotentialClientRecordTypeId();
        response.fieldsToQuery = getFieldsToQuery();
        response.is_comm_b = isCommbUser();

        System.debug( 'IS CommB ' + response.is_comm_b );

        return response;
    }



    /** this function will determine if the current user
     *  is a commB user or not
     *  @param none
     *  @return will return true if the current user is commB
     */
    private static Boolean isCommbUser(){

        String profile_name;            //will hold the profile name

        try{

            //get current user profile name
            profile_name = [ SELECT Name
                             FROM Profile
                             WHERE Id =: UserInfo.getProfileId() ].Name;

        }
        catch( QueryException query_exception ){

            System.debug( query_exception );        //print exception message
            return false;               //assume not commB

        }//try-catch

        //return result
        return ( profile_name == 'Commercial Banking Custom Std User - Mobile' ) ||
                ( profile_name == 'Commercial Banking Communities User' );

    }//end of function definition




    private static Id getPotentialClientRecordTypeId() {
        return UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT);
    }

    private static String[] getFieldsToQuery() {
        String[] fieldsToQuery = new String[]{};
        for (SObjectField sObjField : DESIRED_FIELDS) {
            if (sObjField.getDescribe().isAccessible()) {
                fieldsToQuery.add(String.valueOf(sObjField));
            }
        }
        return fieldsToQuery;
    }

}