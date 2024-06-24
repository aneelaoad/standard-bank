/************************************************************************
* @author       Vaishali Singh  
* @date         Apr -2013
* @description  Test class for AddInternalAttendeesCtrl -EN-0658
    
    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : June 15, 2016
    @ Last Modified Reason  : US-1355 - Ensuring at least 2 Core Team Members exist on Internal Core Meetings

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : July 7, 2016
    @ Last Modified Reason  : US-1414 - changing the condition when the check on 2 core team members happens
    
    @Last Modified By   : Manoj Gupta
    @Last Modified Date : Jan 13, 2017
    @Last Modified Reason: Replaced Continous Integration User with Release Manager to fix test class failures
************************************************************************/

@isTest(SeeAllData = False)
public class AddInternalAttendeesCtrl_Test {
    
    @TestSetup
    static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCcSettings()
        });
    }

    @IsTest
    private static void testAddInternalAttendee(){
        User custStandardUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            custStandardUser = (User) new BLD_USER().useCib().syncContact()
                .commitWork()
                .getRecord();
        }
      
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Contact conBuilder = new BLD_Contact(uow).useBankContact();

        BLD_CallReport crBuilder = new BLD_CallReport(uow)
            .internal()
            .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
            .addAttendee(
                new BLD_CallReportAttendee(uow)
                    .contact(conBuilder)
            );

        new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
            .addContact(conBuilder)
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .role(DMN_ClientTeam.ROLE_CREDIT_OFFICER)
                    .user(custStandardUser.Id)
            )
            .addEventReport(crBuilder);

        uow.commitWork();

        PageReference pgRef = Page.AddInternalAttendee;
        Map<String, String> pageParameters = pgRef.getParameters();
        pageParameters.put('reportid', crBuilder.getRecordId());
        
        Test.setCurrentPage(pgRef);
        
        Test.startTest();
        AddInternalAttendeesCtrl  controllerInstance = new AddInternalAttendeesCtrl();
        controllerInstance.save();
        controllerInstance.cancel();
        Test.stopTest();
    }
    
    @IsTest
    static void testHavingOneCoreCstMember() {
        Test.startTest();
        
        User sysAdmin = [SELECT id, profile.name FROM User WHERE name = 'Release Manager'];
        // attempting to create a sysAdmin user, the @Future method triggered for the cibCc user doesn't receive the User id and so doesn't create the Contact

        User cibCc =  (User) new BLD_USER().userName('TestUserInternalAtt1@test.com').useCib().syncContact().getRecord();
        system.runAs(sysAdmin) {
            insert cibCc;
        }
        
        Account potAcc;
        Call_Report__c er;
        System.runAs(cibCc) {

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            BLD_Account accBuilder = new BLD_Account(uow).usePotential()
                .proposedClientCoordinator(cibCc);
            potAcc = (Account) accBuilder.getRecord();

            er = (Call_Report__c) new BLD_CallReport(uow)
                .internal()
                .linkWithParent(accBuilder)
                .assign(cibCc.Id)
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .getRecord();

            uow.commitWork();
        }

        system.runAs(sysAdmin) {
            Test.stopTest(); // @Future method inserting a Contact and updating the User needs to run as sysAdmin
        }
        
        system.runAs(cibCc) {
            User u2 = [SELECT id, contact_sync_id__c FROM User WHERE id = :cibCc.id];
            system.assertNotEquals(null, u2.contact_sync_id__c);
            
            PageReference pageRef = Page.AddInternalAttendee;
            pageRef.getParameters().put('reportid', er.id);
            Test.setCurrentPage(pageRef);
            
            AddInternalAttendeesCtrl cont = new AddInternalAttendeesCtrl();
            for (AddInternalAttendeesCtrl.InternalAttendeeWrapper att: cont.lstAttendees) {
                if (att.sObjAttendee.contact_id__c != null) {
                    att.bChecked = true;
                }
            }
            cont.save();
            
            system.assertEquals(1, ApexPages.getMessages().size());
            
            String errorMessageStart = 'Internal core client team meetings require at least 2';
            system.assert(ApexPages.getMessages().get(0).getSummary().startsWith(errorMessageStart));
        }
    }

    @IsTest
    static void testHavingTwoCstMembers() {
        Test.startTest();
        
        User sysAdmin = [SELECT id, profile.name FROM User WHERE name = 'Release Manager'];
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User cibCc =  (User) new BLD_USER(uow).userName('TestUserInternalAtt1@test.com').useCib().syncContact().getRecord();
        User u2 = (User) new BLD_USER(uow).userName('TestUserInternalAtt2@test.com').useCib().syncContact().getRecord();
        system.runAs(sysAdmin) {
            uow.commitWork();
        }

        Account potAcc;
        System.runAs(cibCc) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            potAcc = (Account) new BLD_Account(uow).usePotential()
                .proposedClientCoordinator(cibCc)
                .addClientTeam(
                    new BLD_ClientTeam(uow)
                        .user(u2.Id)
                        .role(DMN_ClientTeam.ROLE_EXEC_SPONSOR)
                )
                .commitWork()
                .getRecord();

        }
        system.runAs(sysAdmin) {
            Test.stopTest();
        }
        System.runAs(cibCc) {
            Call_Report__c er = (Call_Report__c) new BLD_CallReport()
                .internal()
                .linkWithParent(potAcc.Id)
                .assign(cibCc.Id)
                .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
                .commitWork()
                .getRecord();

            PageReference pageRef = Page.AddInternalAttendee;
            pageRef.getParameters().put('reportid', er.id);
            Test.setCurrentPage(pageRef);
            
            AddInternalAttendeesCtrl cont = new AddInternalAttendeesCtrl();
            for (AddInternalAttendeesCtrl.InternalAttendeeWrapper att: cont.lstAttendees) {
                if (att.sObjAttendee.contact_id__c != null) { // it shows 2 CST members and 4 other records (not sure what they are)
                    att.bChecked = true; // checkbox needs to be checked before attempting to save()
                }
            }
            cont.save();
            
            system.assertEquals(0, ApexPages.getMessages().size());
        }
    }

}