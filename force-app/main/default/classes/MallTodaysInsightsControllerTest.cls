/**
 * 
 * @description MallTodaysInsightsControllerTest
 * @author Ankit Kumar
 * @since 
 */
@isTest
public with sharing class MallTodaysInsightsControllerTest {
     
    @IsTest
    public static void getInsightInfo(){
        String mallContext='{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." , "mallUserSelectedLanguage" : "en-US"}';
        
        Provider__c provider = new Provider__c();
        provider.Name = 'test';
        insert provider;
        
        Offering__c prod= new Offering__c();
        prod.Name='Test1';
        prod.Provider__c=provider.id;
        insert prod;
        
        List<String> taglist=new List<String>();
        Tag__c tg1 = new Tag__c();
        tg1.Position__c=1;
        tg1.Name='Country';
        
        Insert tg1;
        
        taglist.add( prod.Provider__c);

        MallDataServiceHandler.userContentLanguage = 'en-US';
        
        Test.startTest();
        MallTodaysInsightsController.InsightRequest insightRequest = new MallTodaysInsightsController.InsightRequest();
        insightRequest.mallContext = mallContext;
        insightRequest.rootTagNames = new List<String> {'Country', 'Category'};
        insightRequest.tagIds = new List<String>{tg1.id};
        insightRequest.recordTypes = new List<String>{'Insight'};
        List<DenormalizedContent> insights = MallTodaysInsightsController.getInsightsInfo(System.JSON.serialize(insightRequest));
        Assert.areNotEqual(insights, NULL , 'should not be null');
        Test.stopTest();  
    }
}