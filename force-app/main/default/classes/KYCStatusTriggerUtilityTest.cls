/* @Class Name   : KYCStatusTriggerUtilityTest
 * @Description  : Test class for KYCStatusTriggerUtility
 * @Created By   : Manoj Gupta
 * @Created On   : 17 Feb 2016
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------

 
 * ---------------------------------------------------------------------------------------------------
*/

@IsTest(SeeAllData=false)
private class KYCStatusTriggerUtilityTest {

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getOpenKycReviewStatuses()
        });
    }

    /**********************************************************
     @vishnu(26-03-2015) : EN-694 : Test method to test tasks notification to escalated to business users
    **********************************************************/
    @IsTest
    static void testUpdateOfGroupKYCReviewStatus() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        List<Account> lstTestAccount = new List<Account> {
            (Account) new BLD_Account(uow).useGroupParent().CIF('11223344').getRecord(),
            (Account) new BLD_Account(uow).useImmediateParent().getRecord(),
            (Account) new BLD_Account(uow).getRecord()
        };

        uow.commitWork();

        lstTestAccount[1].Group_Parent__c = lstTestAccount[0].Id;
        lstTestAccount[2].Group_Parent__c = lstTestAccount[0].Id;

        update lstTestAccount ;

        // create standard user
        User user01 = (User) new BLD_USER().useKyc().title('Senior').getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert user01;
        }

        List<KYC_Status__c> lstKYCToInsert = new List<KYC_Status__c>();

        KYC_Status__c kyc = new KYC_Status__c();
        kyc.Client__c = lstTestAccount[0].Id ;
        kyc.Entity_Code__c = 'SBSA';
        kyc.KYC_Review_Status__c = 'In progress';
        lstKYCToInsert.add(kyc);

        KYC_Status__c kyc2 = new KYC_Status__c();
        kyc2.Client__c = lstTestAccount[1].Id ;
        kyc2.Entity_Code__c = 'SBSA';
        kyc2.KYC_Review_Status__c = 'KYC Processing Documents';
        lstKYCToInsert.add(kyc2);

        KYC_Status__c kyc3 = new KYC_Status__c();
        kyc3.Client__c = lstTestAccount[0].Id ;
        kyc3.Entity_Code__c = 'ARG';
        kyc3.KYC_Review_Status__c = 'KYC Processing Documents';
        lstKYCToInsert.add(kyc3);

        KYC_Status__c kyc4 = new KYC_Status__c();
        kyc4.Client__c = lstTestAccount[2].Id ;
        kyc4.Entity_Code__c = 'SBSA';
        kyc4.KYC_Review_Status__c = 'Entities Still to Contact';
        lstKYCToInsert.add(kyc4);

        insert lstKYCToInsert;

        System.runAs(user01) {
            Test.startTest();
            kyc.KYC_Review_Status__c = 'Closed';
            kyc.Closure_Suspended_Reason__c = 'Exited';
            kyc.Review_Completed_Date__c = Date.today();

            kyc2.KYC_Review_Status__c = 'Suspended';
            kyc2.Closure_Suspended_Reason__c = 'Pending';
            kyc2.Review_Completed_Date__c = Date.today();

            kyc3.KYC_Review_Status__c = 'Closed';
            kyc3.Closure_Suspended_Reason__c = 'Exited';
            kyc3.Review_Completed_Date__c = Date.today();

            kyc4.KYC_Review_Status__c = 'In Progress';
            kyc4.Closure_Suspended_Reason__c = 'Pending';
            kyc4.Review_Completed_Date__c = Date.today();
            update lstKYCToInsert;
            Test.stopTest();

            Account acc0 = [SELECT Id,Group_KYC_Review_In_Progress__c FROM Account WHERE Id = :lstTestAccount[0].Id];

            System.assertEquals(false, acc0.Group_KYC_Review_In_Progress__c);

            Account acc1 = [SELECT Id,Group_KYC_Review_In_Progress__c FROM Account WHERE Id = :lstTestAccount[1].Id];

            System.assertEquals(true, acc1.Group_KYC_Review_In_Progress__c);

        }

    }


}