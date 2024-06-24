/**
* @author       Sandile mathe
* @description  This test class for PBBLifeStyleConversationCtrl
*               
* @date         April 2021
**/
@isTest
public class PBBLifeStyleConversationCtrl_Test {
    private static final String GUID_CLIENT_NAME = 'Account With GUID Test';
    private static final String NO_GUID_CLIENT_NAME = 'Account Without GUID Test';
    private static final String INTERNAL_SERVER_ERROR = 'Internal server error';
    
    private static final String EXAMPLE_SUB_CATEGORY = 'VAF Optimiser';
    private static final String EXAMPLE_RESPONSE = 'Accept Offer';
    private static final String EXAMPLE_REASON = 'Application approved';
    
    @TestSetup
    private static  void setupData() {
        
	    fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account account = new BLD_Account(uow)
                .name('test')
                .guid('4554f98f7ch50135000000000ab6f434')
                .bpid('0530754246')
                .addConversation(
                new BLD_Conversation(uow)
                        .externalId('4536456')
                        .externalIdLeadKey('123a')
                        .isActive(true))
                .addConversation(
                new BLD_Conversation(uow)
                        .externalId('435654')
                        .externalIdLeadKey('123b')
                        .isActive(true))
                .addConversation(
                new BLD_Conversation(uow)
                        .externalId('43565478')
                        .externalIdLeadKey('123c')
                        .isActive(true));
        uow.commitWork();
    }

    @IsTest
    private static void testgetRecord() {
        List<Conversation__c> conv = new SEL_Conversations().selectByExternalIdLeadKey( new Set<String> {'123c'});
        Test.startTest();
        PBBLifeStyleConversationCtrl.getRecord(conv[0].Id);
        Test.stopTest();
        System.assert(Conversation__c.Id != null, 'No Value found');
    }

    @IsTest
    private static void testGetCategoryFieldValue() {
        
        Test.startTest();
        PBBLifeStyleConversationCtrl.getCategoryFieldValue();
        Test.stopTest();
        System.assertEquals(8,Conversation__c.Category__c.getDescribe().getPicklistValues().size());
    }
    
    @IsTest
    private static void testCreateNewConversation() {
        Conversation__c conv = new Conversation__c(OwnerId=UserInfo.getUserId(),Reason__c=EXAMPLE_REASON );
        Test.startTest();
        PBBLifeStyleConversationCtrl.createNewConversation(conv);
        PBBLifeStyleConversationCtrl.saveData(conv);
        Test.stopTest();
        List<Conversation__c> convs = new SEL_Conversations().selectByExternalIdLeadKey( new Set<String> {'123c'});
        System.assertEquals(null,convs[0].Subcategory__c,'Record did not save');
        System.assert(true,conv.IsActive__c);
    }
    @IsTest
    private static void testGetHighValueFieldValue() {
        Test.startTest();
        PBBLifeStyleConversationCtrl.getHighValueFieldValue();
        Test.stopTest();
        System.assertEquals(2,Conversation__c.PBB_HighValueCD__c.getDescribe().getPicklistValues().size());
    }
    @IsTest
    private static void testGetConversations() {
        List<Account> acc = new SEL_Accounts().selectByRegisteredName(new Set<String> {'test'});
        Test.startTest();
        PBBLifeStyleConversationCtrl.getConversations(acc[0].Id);
        Test.stopTest();
        System.assert(Conversation__c.Client__c != null,'No Conversation was retrieved');
    }
    @IsTest
    private static void testNewConversation() {

        List<Account> acc = new SEL_Accounts().selectByRegisteredName(new Set<String> {'test'});
        Test.startTest();
        PBBLifeStyleConversationCtrl.newConversation(acc[0].Id);
        Test.stopTest();
        List<Conversation__c> conv = new SEL_Conversations().selectByExternalIdLeadKey( new Set<String> {'123c'});
        System.assert(conv[0].IsActive__c,'New Conversation was not added');
    }

    @IsTest
    private static void testGetArrangedDependancies() {
       	List<Conversation__c> con = new SEL_Conversations().selectByExternalIdLeadKey( new Set<String> {'123c'});
        Test.startTest();
        PBBLifeStyleConversationCtrl.getArrangedDependancies();
        Test.stopTest();
        System.assertEquals('Application approved',EXAMPLE_REASON);
    }
    
    @IsTest
    private static void testGetArrangedDependanciesWithNullResponse() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
     	BLD_Conversation_Value convalue = new BLD_Conversation_Value(uow).subcategory('EAP Digital');
        uow.commitWork();
        Test.startTest();
        PBBLifeStyleConversationCtrl.getArrangedDependancies();
        Test.stopTest();
        List<Conversation_Value__c> con = new SEL_ConversationValues().selectConversationValueBySubCat(new Set<String> {'EAP Digital'});
        System.assertEquals(null,con[0].Response__c,'Response Values are not matching');
    }
}