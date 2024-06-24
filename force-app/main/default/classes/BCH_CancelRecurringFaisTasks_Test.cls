/**
 * Test class for BCH_CancelRecurringFaisTasks class
 *
 * @author		JP Basson (jabasson@deloitte.co.za)
 * @date		April 2021
 */
@IsTest
public class BCH_CancelRecurringFaisTasks_Test {
    static User batchUser;
    static List<Task> tasks = new List<Task>();
    static final String TASK_SUBJECT = 'Update FAIS Information of recurring batch test acc';

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            batchUser = (User) new BLD_USER(uow).userName('BCHCancelRecurringFaisTasksUser@test.com').useCib().division('Transactional Products and Services').syncContact().getRecord();
            uow.commitWork();
        }

        System.runAs(batchUser) {
            Task taskRec = (Task) new BLD_Task(uow)
                    .subject(TASK_SUBJECT)
                    .itemToAction()
                    .linkToParent(
                        new BLD_Account(uow).useChild()
                    ).getRecord();
            uow.commitWork();
        }
        
    }

    static void getData() {
        tasks = [SELECT Id,
                        WhatId,
                        Status,
                        Subject,            
                        Item_to_action__c,
                        IsRecurrence, 
                        RecurrenceActivityId
                FROM TASK
                WHERE subject =: TASK_SUBJECT];
    }

    @IsTest
    static void shouldSetBatchTaskItemToActionJobToFalse() {
        getData();
        Test.startTest();
        Database.executeBatch(new BCH_CancelRecurringFaisTasks(tasks), 1);
        Test.stopTest();

        System.assertEquals(false, [SELECT Item_to_action__c FROM Task WHERE subject =: TASK_SUBJECT].Item_to_action__c);
    }

}