/**
* @description Test class to test the Outbound AOB_API_UpdateRpDetailsInformation
* @author Dayakar
* @date jan 25th 2023
*/
@IsTest
public class AOB_API_UpdateRpDetailsInformation_Test {
    
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_UpdateRpDetailsInformation.SERVICE_NAME,
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    
    
    /**
    * @description test method for AOB_SRV_SetDigital.callSetDigitalAPI
    * author dayakar
    */
    @isTest
    public static void callUpadteRPConfig(){
        
        List<string> relpartydataq= new List<string>();
        relpartydataq.add(AOB_Constants.ZACCOF);
        relpartydataq.add(AOB_Constants.ZBUSIN);
        relpartydataq.add(AOB_Constants.ZMEMBE);
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String UUID='b13c55a9-357d-1eed-aca0-3e2a4d36ecc6';
        Test.startTest();
        Integer statusCode=AOB_SRV_UpdateRPConfig.callUpdateRP(relpartydataq,Applicationid,UUID);           
        test.stopTest();
        Assert.areEqual(200, statusCode,'Message');
    }
    
    
        
}