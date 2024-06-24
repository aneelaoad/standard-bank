/***************************************************************************************
@Author            : Dayakar Deekonda 
@Date              : jan 25th 2023
@Name of the Class : AOB_API_CompleteAO_IDV_TEST
@description       : class to test the Outbound AOB_API_CompleteAO_IDV API call
@Last Modified By  : Narendra 
@Last Modified On  : 23rd July 2023
@Modification Description : SFP-27748
***************************************************************************************/
@IsTest
private class AOB_API_CompleteAO_IDV_TEST {
    /**
* @description To setup the List of Webservice Call Queue
*
* @return A list of queue items
*/
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_CompleteAO_IDV.SERVICE_NAME,
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    @IsTest
    public static void CompleteAOTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_WFR.completeAoIdvAPICall(applicationId);
        Test.stopTest();  
        
    }
    
}