@IsTest
public class AOB_FLOW_GetAppProcessData_Test {
    
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_CompanyDetails.SERVICE_NAME,
            UserInfo.getUserId()
        );
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
    }
    
    @IsTest
    public static void isBPGUIDOnPingTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        List<String> apps=new List<String>();
        apps.add(applicationId);
        Test.startTest();
        AOB_FLOW_GetAppProcessData.isBPGUIDOnPing(apps);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId);
    }

}