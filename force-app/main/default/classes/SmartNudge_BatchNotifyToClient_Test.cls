/**
 * @author		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
 * @description : SFP-28741 - Test class for SmartNudge_BatchNotificationToClient
 * @date 		: 23 August 2023
 */
@isTest
public class SmartNudge_BatchNotifyToClient_Test {

    /**
    * @description :  sendEmailNotificationsToClient
    */
    @isTest
    static void sendEmailNotificationsToClient(){
        Contact testContact = initializeContact();
        Test.startTest();
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight__c.SObjectType,Insight_Client_Relationship__c.SObjectType};
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);

		BLD_Insight insight = new BLD_Insight(uow).category('FX TIPS');
        insight.persona('Client');
		insight.owner(UserInfo.getUserId());
        insight.snoozed(false);
        insight.eventDate(Date.today());
        insight.insight('Test Insight');
        insight.clientCoordinator(UserInfo.getUserId());
        uow.commitWork();
        
        List<Insight__c> insightList = new SEL_Insights().selectWithoutCondition();

        BLD_InsightClientRelationship insightClientRelationShip = new BLD_InsightClientRelationship(uow);
        insightClientRelationShip.setContact(testContact.Id);
        insightClientRelationShip.setInsight(insightList[0].Id);
        uow.commitWork();
        
        SmartNudge_BatchNotificationToClient sch = new SmartNudge_BatchNotificationToClient();
		String chroneExpression = '0 0 23 * * ?'; 
        System.schedule('My latest insights', chroneExpression, sch);
        Test.stopTest();
        List<Insight_Client_Relationship__c> myInsightList = [Select Id,Name from Insight_Client_Relationship__c Where Contact__c =: testContact.Id];
        Assert.areNotEqual(null, myInsightList, 'Was expecting a contact got access to at least one insight');
        Integer cronJobGetInsights = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'My latest insights'];
        Assert.areEqual(1, cronJobGetInsights , 'Job scheduled successfully');
    }
    
    /**
    * @description :  This method will return the contact
    * @return Contact
    */
    private static Contact initializeContact() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact con = (Contact) new BLD_Contact(uow)
            .ownerId(UserInfo.getUserId())
            .account(new BLD_Account(uow))
            .getRecord();
        
        uow.commitWork();
        
        return con;
    }
}