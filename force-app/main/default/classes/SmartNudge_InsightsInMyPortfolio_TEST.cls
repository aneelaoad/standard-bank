/**
 * @author		: Chandrasekhar Mokkala
 * @description : Test class for SmartNudge_InsightsInMyPortfolioHelper
 * @date 		: 12th August 2022
 */
@isTest
public class SmartNudge_InsightsInMyPortfolio_TEST {
    
    /**
     * @description :  This method will test top ten clients nudges
     */
    @isTest
    static void shouldReturnTop10ClientRelevantNudgs(){
        
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight__c.SObjectType,Account.SObjectType};
       	fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(mySObjects);
        
        Integer bpidNumber = 35;
        for(Integer i=0; i < 12; i++){
            String bpid = String.valueOf(bpidNumber);
            new BLD_Account(uow1).bpid(bpid).usePBB();
            bpidNumber++;
        }
        uow1.commitWork();
        
        List<Account> accList = new SEL_Accounts().selectWithoutCondition();
        Test.startTest();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);
        
        for(Integer i=0; i < 12 ; i++){
            Date nudgeExpiryDate = System.today().addDays(i);
        	new BLD_Insight(uow).category('FX TIPS').expiryDate(nudgeExpiryDate).persona('FX Tips').owner(UserInfo.getUserId()).client(accList[i].Id).snoozed(false).eventDate(Date.today()).insight('Test Insight').clientCoordinator(UserInfo.getUserId());
        }
		uow.commitWork(); 
        
        SmartNudge_InsightsInMyPortfolioHelper vfcController = new SmartNudge_InsightsInMyPortfolioHelper();
        vfcController.cstTeamMemberId = UserInfo.getUserId();
        vfcController.cstTeamMemberName = UserInfo.getName();
        vfcController.getFooterClickHereImageURL();
        vfcController.getHeaderImageURL();
        vfcController.getSmartNudgeUrl();
        List<SmartNudge_InsightsInMyPortfolioHelper.InsightWrapper> insightList = vfcController.getMyLatestInsights();
        vfcController.getInsightDetails('Testing Insight Details field has more than 100 characters.Testing Insight Details field has more than 100 characters.');
        vfcController.getInsightDetails('Testing Insight Details field has less than 100 characters.');
       	
        Test.stopTest();
        Assert.areEqual(10, insightList.size(), 'Was expecting top 10 clients insights');
        
    }
	/**
     * @description :  This method will test for more than 10 insights scenario
     */
    @isTest
    static void shouldReturnTop10Insight(){
        Test.startTest();
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight__c.SObjectType};
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);

		for(Integer i=0; i < 12 ; i++){
            Date nudgeExpiryDate = System.today().addDays(i);
        	new BLD_Insight(uow).category('FX TIPS').expiryDate(nudgeExpiryDate).persona('FX Tips').owner(UserInfo.getUserId()).snoozed(false).eventDate(Date.today()).insight('Test Insight').clientCoordinator(UserInfo.getUserId());
        }
		uow.commitWork(); 
        
        SmartNudge_InsightsInMyPortfolioHelper vfcController = new SmartNudge_InsightsInMyPortfolioHelper();
        vfcController.cstTeamMemberId = UserInfo.getUserId();
        vfcController.cstTeamMemberName = UserInfo.getName();
        vfcController.getFooterClickHereImageURL();
        vfcController.getHeaderImageURL();
        vfcController.getSmartNudgeUrl();
        List<SmartNudge_InsightsInMyPortfolioHelper.InsightWrapper> insightList = vfcController.getMyLatestInsights();
        vfcController.getInsightDetails('Testing Insight Details field has more than 100 characters.Testing Insight Details field has more than 100 characters.');
        vfcController.getInsightDetails('Testing Insight Details field has less than 100 characters.');
       	
        Test.stopTest();     
        Assert.areEqual(10, insightList.size(), 'Was expecting to find 10 insights');

        
    }
    /**
     * @description :  This method will test for less than 10 insights scenario
     */
    @isTest
    static void lessThan10InsightFoundTest(){
        Test.startTest();
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight__c.SObjectType};
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);

		BLD_Insight insight = new BLD_Insight(uow).category('FX TIPS');
		insight.owner(UserInfo.getUserId());
        insight.snoozed(false);
        insight.eventDate(Date.today());
        insight.insight('Test Insight');
        insight.clientCoordinator(UserInfo.getUserId());
        uow.commitWork();
        
        SmartNudge_InsightsInMyPortfolioHelper vfcController = new SmartNudge_InsightsInMyPortfolioHelper();
        vfcController.cstTeamMemberId = UserInfo.getUserId();
        vfcController.cstTeamMemberName = UserInfo.getName();
        List<SmartNudge_InsightsInMyPortfolioHelper.InsightWrapper> insightList = vfcController.getMyLatestInsights();
        Test.stopTest();
        Assert.areNotEqual(0, insightList.size(), 'Was expecting to find at least one insight');
        
    }
}