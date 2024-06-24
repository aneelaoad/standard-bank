/**
 * Test class for NewOpportunity_Ctrlr
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest
private with sharing class NewOpportunity_Ctrlr_TEST {

    private static final String CIB_USERNAME = 'userdwadwa@cib.com';
    private static User cibUser {
        get {
            if (cibUser == null) {
                cibUser = [SELECT Id FROM User WHERE Username = :CIB_USERNAME];
            }
            return cibUser;
        }
        set;
    }
    private static final String COMMB_USERNAME = 'userdwakdaw@commb.com';
    private static User commBUser {
        get {
            if (commBUser == null) {
                commBUser = [SELECT Id FROM User WHERE Username = :COMMB_USERNAME];
            }
            return commBUser;
        }
        set;
    }

    @TestSetup
    static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        new BLD_USER(uow).useCib().userName(CIB_USERNAME);
        new BLD_USER(uow).useCommB().userName(COMMB_USERNAME);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
    }

    @IsTest
    static void shouldReturnOpportunityDataForNoAccount() {
        NewOpportunity_Ctrlr result;
        System.runAs(cibUser) {
            Test.startTest();
            result = NewOpportunity_Ctrlr.getOpportunityData(DMN_Account.OBJ_NAME, null);
            Test.stopTest();
        }

        System.assertEquals(2, result.additionalFields.size());
        System.assertEquals(String.valueOf(Opportunity.Game_Changer__c)
            , result.additionalFields[1]);
        System.assertNotEquals(null, result.oppRecord);
        System.assertEquals(false, result.isCommBUser);
        System.assertEquals([SELECT COUNT() FROM Global_Picklist_Value__mdt WHERE Category__c = :NewOpportunity_Ctrlr.LEAD_OPPORTUNITY_PICKLIST_CATEGORY],
            result.stages.size());
    }

    @IsTest
    static void shouldReturnAdditionalFieldsForCommBUser() {
        NewOpportunity_Ctrlr result;
        System.runAs(commBUser) {
            Test.startTest();
            result = NewOpportunity_Ctrlr.getOpportunityData(DMN_Account.OBJ_NAME, null);
            Test.stopTest();
        }

        System.assertEquals(NewOpportunity_Ctrlr.commBAdditionalFields.size(), result.additionalFields.size());
        System.assertEquals(true, result.isCommBUser);
    }

    @IsTest
    static void shouldReturnOpportunityDataForAccount() {
        NewOpportunity_Ctrlr result;
        Account acc;
        System.runAs(cibUser) {
            acc = (Account) new BLD_Account().commitWork().getRecord();
            Test.startTest();
            result = NewOpportunity_Ctrlr.getOpportunityData(DMN_Account.OBJ_NAME, acc.Id);
            Test.stopTest();
        }

        System.assertEquals(acc.Id, result.oppRecord.AccountId);
    }

    @IsTest
    static void shouldSaveOpportunityRecord() {
        Id result;
        System.runAs(cibUser) {
            Opportunity oppRec = (Opportunity) new BLD_Opportunity().getRecord();
            Test.startTest();
            result = NewOpportunity_Ctrlr.save(oppRec, null);
            Test.stopTest();
        }

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void shouldSaveOpportunityRecordForContact() {
        Id result;
        Contact conRec;
        System.runAs(cibUser) {
            Opportunity oppRec = (Opportunity) new BLD_Opportunity().getRecord();
            conRec = (Contact) new BLD_Contact().commitWork().getRecord();
            Test.startTest();
            result = NewOpportunity_Ctrlr.save(oppRec, conRec.Id);
            Test.stopTest();
        }

        System.assertNotEquals(null, result);
        OpportunityContactRole ocrRec = [SELECT ContactId, OpportunityId FROM OpportunityContactRole];
        System.assertEquals(result, ocrRec.OpportunityId);
        System.assertEquals(conRec.Id, ocrRec.ContactId);

    }

}