/**
 * @description       : Test Class for AOB_CTRL_Internal_CheckComplianceRP
 * @author            : Tukelo Moseamo
 * @group             : 
 * @last modified on  : 07-20-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * 
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
**/
@isTest
public with sharing class AOB_CTRL_Internal_CheckComplianceRP_TEST {
   
    @isTest 
    static void testCheckComplainceRP() {
        AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.PreApplication =  AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(7);
		application.AOB_inflightData__c = JSON.serialize(newInflightData);
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		insert application;

        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        Test.startTest();
		AOB_API_Internal_CheckComplianceRP.DTO_CheckComplianceRPResponse response = AOB_CTRL_Internal_CheckComplianceRP.checkComplianceRP(application.Id);
		Test.stopTest();
		Assert.isNotNull(response, 'checkComplaince callout response is null');
    }
    @isTest
    static void testException() {
        try {
            AOB_CTRL_Internal_CheckComplianceRP.checkComplianceRP(null);
        }
        catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'Error message is not null');
        }
    }
}