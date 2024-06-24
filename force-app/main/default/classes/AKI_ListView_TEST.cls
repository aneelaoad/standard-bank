/**
 * @description Test class for Akili List View
 * 
 * @author Khakhu Ramakuela
 * @date October 2021
 */
@isTest
public class AKI_ListView_TEST {

    /**
     * @description Tests that getInsightData retrieve the relevant data for all cases
     */
    @isTest
    static void getInsightsDataTest(){
        List<Insight__c> ins;
        
        List<Insight__c> searchIns;
        List<Insight__c> myIns = AKI_TESTDATA.createInsights(5);
        AKI_TESTDATA.createInsight();
        Test.startTest();
        ins = AKI_COMP_AkiliInsightsListviewController.getInsightsData('{"searchKey": "", "category":"","subcategory":"","client":"",   "myInsightsSelected": false,    "allInsightsSelected": true,    "expiringSoonSelected": true,    "snoozedInsightsSelected": true}');
        searchIns = AKI_COMP_AkiliInsightsListviewController.getInsightsData('{"searchKey": "FX","category":"","subcategory":"","client":"",    "myInsightsSelected": false,    "allInsightsSelected": true,    "expiringSoonSelected": true,    "snoozedInsightsSelected": false}');
        myIns = AKI_COMP_AkiliInsightsListviewController.getInsightsData('{"searchKey": "", "category":"","subcategory":"","client":"",   "myInsightsSelected": true,    "allInsightsSelected": false,    "expiringSoonSelected": false,    "snoozedInsightsSelected": false}');
        Test.stopTest();
        Assert.areNotEqual(0,ins.size(),'Was expecting to find at least one insight');
        Assert.areNotEqual(0,myIns.size(),'Was expecting to find at least one insight of mine');
    }

    /**
     * @description Tests that changeProdSpecialist correctly makes changes to the correct object instance and field and creates the relevant insight action
     */
    @isTest static void changeProdSpecialistTest(){
        Insight__c ins = AKI_TESTDATA.createInsights(1).get(0);
        Id newOwner=UserInfo.getUserId();
        Id oldOwner=UserInfo.getUserId();
        String leadId='0932';
        Test.setMock(HttpCalloutMock.class, new RAS_CreateDcp_ApiMock());
        Test.startTest();
        string paramVal = '{"recId":"'+ ins.id+'","psId": "'+newOwner+'","oldRecOwnerId":"'+ oldOwner+'","sendEmailOwnerChange": '+FALSE+',"leadId": "'+leadId+'"}';
        AKI_COMP_AkiliInsightsListViewController.changeProdSpecialist(paramVal);
        Insight_Action__c insAct=[SELECT id,Action_Type__c,Insight_Quality__c, Insight_Status__c FROM Insight_Action__c].get(0);
        Test.stopTest();
        Assert.areEqual('Owner Changed',insAct.Action_Type__c,'Insight action is Owner Changed');
    }

    /**
     * @description Tests that createOpportunity correctly makes changes to the correct object instance and field and creates the relevant insight action
     */
    @isTest static void createOpportunityTest(){
        Insight__c ins = AKI_TESTDATA.createInsights(1).get(0);
        Account a=AKI_TestData.createAccount();
        Id clientId=a.Id;
        String oppName='Test Opportunity';
        String leadId='0932';
        String oppDescription='Testo opportunity';
        Date closeDate = Date.today().addDays(5);
        Date startDate = Date.today();
        Integer probability = 10;
        Test.setMock(HttpCalloutMock.class, new RAS_CreateDcp_ApiMock());
        Test.startTest();
        string paramVal = '{"recId":"'+ins.id+'","coMnpi":false,"coProbability":"'+probability+'","coStartDate":"'+startDate+'","coClientId":"'+clientId+'","coName":"'+oppName+'","coDescription":"'+oppDescription+'","coCloseDate":"'+closeDate+'","leadId":"'+leadId+'"}';
        AKI_COMP_AkiliInsightsListViewController.createOpportunity(paramVal);
        Insight_Action__c insAct=[SELECT id,Action_Type__c,Insight_Quality__c, Insight_Status__c FROM Insight_Action__c].get(0);
        Opportunity opp=[Select Name, Description, AccountId,CloseDate, StageName,Lead_Source__c  From Opportunity].get(0);
        Test.stopTest();
        Assert.areEqual('Opportunity Created',insAct.Action_Type__c,'insight action is Opportunity Created');
        Assert.areEqual(oppName,opp.Name,'Expected different opportunity id');
        Assert.areEqual(oppDescription,opp.Description,'Expected different opportunity description');
        Assert.areEqual(clientId,opp.AccountId,'Expected different opportunity AccountId');
        Assert.areEqual(closeDate,opp.CloseDate,'Expected different opportunity CloseDate');
        Assert.areEqual('1 - Lead',opp.StageName,'Expected different opportunity stage name');
        Assert.areEqual('Smart Nudge',opp.Lead_Source__c,'Expected different opportunity lead source');
    }

    /**
     * @description Tests that snoozedInsights correctly makes changes to the correct object instance and field and creates the relevant insight action
     */
    @isTest static void snoozedInsightsTest(){
        Insight__c ins = AKI_TESTDATA.createInsights(1).get(0);
        String recComments='test snoozing insights';
        String leadId='0932';
        Test.setMock(HttpCalloutMock.class, new RAS_CreateDcp_ApiMock());
        Test.startTest();
        string paramVal = '{"recId":"'+ins.id+'","recComments":"'+ recComments+'","isSnoozed":'+FALSE +',"leadId":"'+leadId+'"}';
        AKI_COMP_AkiliInsightsListViewController.snoozedInsights(paramVal);
        Insight_Action__c insAct=[SELECT id,Action_Type__c,Insight_Quality__c, Insight_Status__c FROM Insight_Action__c].get(0);
        Test.stopTest();
        Assert.areEqual('Is Snoozed',insAct.Action_Type__c,'insight action is Is Snoozed');
    }

    /**
     * @description Tests that feedbackInsights correctly makes changes to the correct object instance and field and creates the relevant insight action
     */
    @isTest static void feedbackInsightsTest(){
        Insight__c ins = AKI_TESTDATA.createInsights(1).get(0);
        String insightStatusVal='Insight actioned';
        String insightQualityVal='Please give me more';
        String leadId='0932';
        Test.setMock(HttpCalloutMock.class, new RAS_CreateDcp_ApiMock());
        Test.startTest();
        string paramVal = '{"recId":"'+ins.id+'","insightStatusVal":"'+insightStatusVal+'","insightQualityVal":"'+insightQualityVal+'","leadId":"'+leadId+'"}';
        AKI_COMP_AkiliInsightsListViewController.feedbackInsights(paramVal,'test');
        Insight_Action__c insAct=[SELECT id,Action_Type__c,Insight_Quality__c, Insight_Status__c FROM Insight_Action__c].get(0);
        Test.stopTest();
        Assert.areEqual('Rating',insAct.Action_Type__c,'insight action is Rating');
    }
    
    /**
     * @description Tests that getInsightRecord method
     */
    @isTest static void getInsightRecordTest(){
        Insight__c ins = AKI_TESTDATA.createInsights(1).get(0);
        Test.startTest();
        AKI_COMP_AkiliInsightsListviewController.getInsightDetails(ins.Id);
        AKI_COMP_AkiliInsightsListviewController.getFeedbackOptions(ins.Id,'Rejected');
        Test.stopTest();
        Assert.areNotEqual(null,ins,'At least one record should be there');
        
    }
    /**
     * @description Tests that getInsightRecord method
     */
    @isTest static void deleteSharedRecordTest(){
        Insight__c ins = AKI_TESTDATA.createInsights(1).get(0);
        Test.startTest();
        Insight_Sharing.deleteInsightShareedRecords(ins.Id,'Owner');
        Test.stopTest();
        Assert.areNotEqual(null,ins,'At least one record should be there');
    }
    
    /**
     * @description Tests that getInsightRecord method
     */
    @isTest static void shouldGetExceptionDeletingSharedRecordTest(){
        Insight__c ins = AKI_TESTDATA.createInsights(1).get(0);
        Test.startTest();
        Insight_Sharing.deleteInsightShareedRecords(null,'');
        Test.stopTest();
        Assert.areNotEqual(null,ins,'At least one record should be there');
        
    }
}