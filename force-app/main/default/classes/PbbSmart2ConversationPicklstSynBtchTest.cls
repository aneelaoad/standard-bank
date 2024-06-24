/**
* Test class for PbbSmart2ConversationPicklistSyncBatch class
*
* @author		Emmanuel Mulea (Nocks)
* @date		18/10/2021
*/
@IsTest
public class PbbSmart2ConversationPicklstSynBtchTest {
static User testUser;
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            testUser = (User) new BLD_USER(uow).userName('testpbbCon@test.com').useSysAdmin().getRecord();
            uow.commitWork();
        }

    }

    private static  List<Conversation_Value__c> getData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List<Conversation_Value__c>  convList = new List<Conversation_Value__c>();
        for(Integer i=0;i<2000;i++) {
            Conversation_Value__c conv = (Conversation_Value__c)new BLD_Conversation_Value(uow)
                    .subcategory('test ' + i)
                    .response('test ' + i)
                    .reason('test ' + i).getRecord();
            convList.add(conv);
        }
        return convList;
    }
    @IsTest
    static void shouldRunBatch() {
        List<SObject> convList =(SObject[])getData();
        testUser = [SELECT Username, Division, IsActive FROM User WHERE Username = 'testpbbCon@test.com' LIMIT 1];
        System.runAs(testUser) {

            Test.startTest();

                PbbSmart2ConversationPicklistSyncBatch bcCreateconvList = new PbbSmart2ConversationPicklistSyncBatch(convList);
                Database.executeBatch(bcCreateconvList, 2000);

            Test.stopTest();
            List<Conversation_Value__c> convCreated = [SELECT Id FROM Conversation_Value__c Limit 2000];
            System.assertEquals(convCreated.size(),2000);

        }
    }
}