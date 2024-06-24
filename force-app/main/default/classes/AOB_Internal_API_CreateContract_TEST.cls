/**
* @description       : Test class for AOB_Internal_API_CreateContract
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 07-11-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification: SFP-25088
* 1.0   05-12-2023   Tukelo Moseamo   Initial Version
**/
@isTest
public class AOB_Internal_API_CreateContract_TEST {
    
    /*
	* @description tests AOB_Internal_API_CreateContract
	*/
    @isTest
    private static void testContractAPIPositive() {
         String applicationId = AOB_DAL_TestFactory.createAppWithInflightKey();
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        
        Test.startTest();
        AOB_Internal_API_CreateContract customerServiceCall = new AOB_Internal_API_CreateContract(applicationId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_CreateContract.SERVICE_NAME);
        obj.CMN_TriggeringObjectId__c = applicationId;
        customerServiceCall.process(obj);
        insert obj;
        Test.stopTest();
        Assert.areEqual(customerServiceCall.callResult.statusCode, String.valueOf(CMN_API_HttpBase.HTTP_OK), 'callout did not return status 200');
    }
}