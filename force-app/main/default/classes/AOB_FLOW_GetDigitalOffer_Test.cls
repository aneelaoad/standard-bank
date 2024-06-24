@IsTest
public class AOB_FLOW_GetDigitalOffer_Test {
    
    @IsTest
    public static void AOB_FLOW_GetDigitalOfferTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        List<String> apps=new List<String>();
        apps.add(applicationId);
        Test.startTest();
        AOB_FLOW_GetDigitalOffer.callGetDigitalOfferAPI(apps);
        Test.stopTest();  
        Assert.areNotEqual(0, [Select id from AOB_ApplicationLineItem__c where AOB_Application__c =:applicationId].size());
    }

}