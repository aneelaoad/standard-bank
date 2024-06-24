/**
 * @description       : 
 * @author            : Emmanuel Mulea
 * @group             : 
 * @Created Date      : 19-07-2023
**/
@isTest
public with sharing class BCH_UserMaintenance_Test {
    private static String mriTableName = 'ACNT_EXCTV';
    private static String emailBcbAr = 'bcbar@test.com';
    private static String emailBcbSa = 'bcbsa@test.com';
    private static String division = 'Business Banking';
    private static String area = 'BCC';
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_USER userBld;
        BLD_REFERENCED_DATA refBld;

        userBld = new BLD_USER(emailBcbAr, uow);
        userBld.setField(User.ProfileId, UTL_Profile.getProfileId('BCC AR Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, area)
            .setField(User.User_Division__c, division)
            .setField(User.EmployeeNumber, 'A24B44B')
            .setField(User.Portfolio_Codes__c, '00BBB7,00BBB4');

            userBld = new BLD_USER(emailBcbSa+'.bcw', uow);
            userBld.setField(User.ProfileId, UTL_Profile.getProfileId('BCC Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, area)
            .setField(User.User_Division__c, division)
            .setField(User.AE_Number__c, 'A24BB4B');
            uow.commitWork();

            userBld = new BLD_USER('bccsaone@test.com.bcw', uow);
            userBld.setField(User.ProfileId, UTL_Profile.getProfileId('BCC Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, area)
            .setField(User.User_Division__c, division)
            .setField(User.AE_Number__c, 'AE92984');
            uow.commitWork();

            refBld = new BLD_REFERENCED_DATA(uow2);
            refBld.setAOBValue(emailBcbSa)
                  .setAOBCode('AE92984')
                  .setAOBSAPField(mriTableName)
                  .setAOBSAPExternalId('ACNT_EXCTVAE92984');

            refBld = new BLD_REFERENCED_DATA(uow2);
            refBld.setAOBValue(emailBcbAr)
                .setAOBCode('A24B44B')
                .setAOBSAPField(mriTableName)
                .setAOBSAPExternalId('ACNT_EXCTVA24B44B');
            uow2.commitWork();
            

    }

    @IsTest
    static void runTest() {


        Test.startTest();
            BCH_UserMaintenance.runTest();
            BCH_UserMaintenance.run();
            try{

                BCH_UserMaintenance.schedule();
            }
            catch (Exception e) {
                Assert.areNotEqual(e.getMessage(), null, 'Error message not null');
            }

        Test.stopTest();

        User urs = [SELECT Id, Username, AE_Number__c FROM User WHERE Username =:emailBcbSa+'.bcw'];
        Assert.areEqual(urs.AE_Number__c, 'AE92984', 'correct AE');

    }
}