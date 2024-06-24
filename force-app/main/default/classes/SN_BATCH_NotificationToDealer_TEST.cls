/**
* @author		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
* @description  : SFP-28741 - Test class for SN_BATCH_NotificationToDealer
* @date 		: Oct 2023
*/
@isTest
public class SN_BATCH_NotificationToDealer_TEST {
    
    /**
    * @description : creating insight
    */
    @TestSetup
    static void setup() {
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight__c.SObjectType};
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);
        
        BLD_Insight insight = new BLD_Insight(uow).category('FX TIPS');
        insight.persona('Client');
        insight.owner(UserInfo.getUserId());
        insight.snoozed(false);
        insight.eventDate(Date.today());
        insight.insight('Test Insight');
        insight.clientCoordinator(UserInfo.getUserId());
        uow.commitWork();
        
    }
    /**
    * @description :  This method will test sending notifcation to dealer
    */
    @isTest 
    static void sendEmailNotificationsToDealer() {
        contact testContact = initializeContact();
        List<Insight__c> insightList = new SEL_Insights().selectWithoutCondition();
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight_Client_Relationship__c.SObjectType};
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);
        
        BLD_InsightClientRelationship insightClientRelationShip = new BLD_InsightClientRelationship(uow);
        insightClientRelationShip.setContact(testContact.Id);
        insightClientRelationShip.setInsight(insightList[0].Id);
        uow.commitWork();
        
        Test.startTest();
        SN_BATCH_NotificationToDealer sch = new SN_BATCH_NotificationToDealer();
        String chroneExpression = '0 0 23 * * ?'; 
        System.schedule('Dealer Notification', chroneExpression, sch);
        Test.stopTest();
        Assert.areNotEqual(0, insightList.size(), 'Was expecting to find at least one insight');
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