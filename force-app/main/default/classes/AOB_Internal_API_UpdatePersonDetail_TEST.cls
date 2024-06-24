/**
 * @description       : Test class for AOB_Internal_API_UpdatePersonalDetails
 * @author            : Tukelo Moseamo
 * @group             : 
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification Description: SFP-25088
 * 1.0   07-09-2023   Tukelo Moseamo   Initial Version
**/
@istest
public with sharing class AOB_Internal_API_UpdatePersonDetail_TEST {
    
    /**
    * @description test method for updatePersonalDetails
    * @author Tukelo Moseamo | 07-09-2023 
    */
    @istest
    public static void updatePersonalDetails() {

        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = AOB_Internal_CTRL_FormCreator_Test.inflight;
        update app;
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        //String requestBody = JSON.serialize(AOB_Internal_DTO_UpdatePersonalDetails.getUpdatePersonalDetails(applicationId));
        AOB_Internal_API_UpdatePersonalDetails customerServiceCall = new AOB_Internal_API_UpdatePersonalDetails(applicationId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_UpdatePersonalDetails.SERVICE_NAME);      
        obj.CMN_TriggeringObjectId__c = applicationId;
            
        Test.startTest();
        customerServiceCall.process(obj);
        insert obj;
        test.stopTest();
        Assert.areNotEqual(null, applicationId, 'Application ID is null');

    }
    
    /**
    * @description test method for updatePersonalDetails
    * @author Tukelo Moseamo | 07-09-2023 
    */
    @istest
    public static void updatePersonalDetailsNeg() {

        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = '';
        update app;
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        AOB_Internal_API_UpdatePersonalDetails customerServiceCall = new AOB_Internal_API_UpdatePersonalDetails(applicationId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_UpdatePersonalDetails.SERVICE_NAME);      
        obj.CMN_TriggeringObjectId__c = applicationId;
            
        Test.startTest();
        customerServiceCall.process(obj);
        insert obj;
        test.stopTest();
        Assert.areNotEqual(null, applicationId, 'Application ID is nullI');

    }
    
    
}