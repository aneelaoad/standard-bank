/**
* @author		: Chandrasekhar Mokkala
* @description : SFP-28741 - Test class for SmartNudge_NotificationToClient_CTRL
* @date 		: 23 August 2023
*/
@isTest
public class SmartNudge_NotifyToClient_CTRL_Test {
    /**
    * @description :  shouldReturnTopThreeDealerNudges
    */
    @isTest
    static void shouldReturnTopThreeDealerNudges(){
        
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight__c.SObjectType,Account.SObjectType};
       	fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(mySObjects);
        
        Integer bpidNumber = 35;
        for(Integer i=0; i < 10; i++){
            String bpid = String.valueOf(bpidNumber);
            new BLD_Account(uow1).bpid(bpid).usePBB();
            bpidNumber++;
        }
        uow1.commitWork();
        
        List<Account> accList = new SEL_Accounts().selectWithoutCondition();
        Test.startTest();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);
        
        for(Integer i=0; i < 10 ; i++){
            Date nudgeExpiryDate = System.today().addDays(i);
        	new BLD_Insight(uow).category('FX TIPS').expiryDate(nudgeExpiryDate).persona('Client').owner(UserInfo.getUserId()).client(accList[0].Id).snoozed(false).eventDate(Date.today()).insight('Test Insight').clientCoordinator(UserInfo.getUserId());
        }
		uow.commitWork();
        
        SmartNudge_NotificationToClient_CTRL vfcController = new SmartNudge_NotificationToClient_CTRL();
        vfcController.nudgeOwnerId = UserInfo.getUserId();
        vfcController.getHeaderImageURL();
        List<SmartNudge_NotificationToClient_CTRL.InsightWrapper> myInsightList = vfcController.getDealerOrContactInsights();
        Test.stopTest();
        Assert.areEqual(3, myInsightList.size(),'It should return top 3 nudges only'); 
    }
    
    /**
    * @description :  This method will test for less than 10 insights scenario
    */
    @isTest
    static void shouldReturnContactNudges(){
        Contact testContact = initializeContact();

        Test.startTest();
        List<Schema.SObjectType> mySObjects = new Schema.SObjectType[]{Insight__c.SObjectType,Insight_Client_Relationship__c.SObjectType};
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(mySObjects);
        
        BLD_Insight insight = new BLD_Insight(uow).category('FX TIPS');
        insight.owner(UserInfo.getUserId());
        insight.snoozed(false);
        insight.eventDate(Date.today());
        insight.persona('Client');
        insight.insight('Test Insight');
        insight.clientCoordinator(UserInfo.getUserId());
        uow.commitWork();
        List<Insight__c> insightList = new SEL_Insights().selectWithoutCondition();

        BLD_InsightClientRelationship insightClientRelationShip = new BLD_InsightClientRelationship(uow);
        insightClientRelationShip.setContact(testContact.Id);
        insightClientRelationShip.setInsight(insightList[0].Id);
        uow.commitWork();

        SmartNudge_NotificationToClient_CTRL vfcController = new SmartNudge_NotificationToClient_CTRL();
        vfcController.contactRecordId = testContact.Id;
        vfcController.getDealerOrContactInsights();
        Test.stopTest();
        List<Insight_Client_Relationship__c> myInsightList = [Select Id,Name from Insight_Client_Relationship__c Where Contact__c =: testContact.Id];
        Assert.areNotEqual(null, myInsightList, 'It should return at least one record which is under the contact');
        
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