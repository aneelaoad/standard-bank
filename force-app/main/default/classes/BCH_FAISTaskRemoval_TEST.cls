/**
 * Test class for BCH_FAISTaskRemoval
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest
private with sharing class BCH_FAISTaskRemoval_TEST {

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getSystemAdminBAprofileIDtaskDeletion()
        });
    }

    @IsTest
    static void shouldScheduleBatchJob() {
        Test.startTest();
        System.schedule('BCH_FAISTaskRemoval', '0 0 0 15 3 ?', new BCH_FAISTaskRemoval());
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = :BCH_FAISTaskRemoval.class.getName() AND Status = 'Queued']);
        Test.stopTest();
    }

    @IsTest
    static void shouldDeleteTasksAndUpdateRelatedAccounts() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Task taskRec = (Task) new BLD_Task(uow)
            .status(DMN_Task.STATUS_COMPLETED)
            .subject('Update FAIS Information of test')
            .linkToParent(
                new BLD_Account(uow).useChild()
            ).getRecord();
        uow.commitWork();

        Test.startTest();
        Database.executeBatch(new BCH_FAISTaskRemoval());
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE Id = :taskRec.Id]);
        System.assertEquals('NO_NEED', [SELECT FAIS_reminder__c FROM Account WHERE Id = :taskRec.WhatId].FAIS_reminder__c);
    }

}