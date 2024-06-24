/*************************************************************************
    @ Author        :     Petr Svestka
    @ Date          :     June 20, 2016
    @ Description   :     US-1355 - Ensuring at least 2 Core Team Members exist on Internal Core Meetings
    
    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : July 7, 2016
    @ Last Modified Reason  : US-1414 - Fix due to a change in the core_meeting__c
****************************************************************************/

@IsTest
public class RedirectToAddAttendeesExtensionTest {

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
    static void testRedirectToAddInternalAttendees() {
        Test.startTest();
        
        User cibCc;
        system.runAs(new User(id = UserInfo.getUserId())) {
            cibCc = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }

        
        system.runAs(cibCc) {

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            Call_Report__c er = (Call_Report__c) new BLD_CallReport(uow)
                .linkWithParent(
                    new BLD_Account(uow).usePotential()
                        .proposedClientCoordinator(cibCc)
                )
                .internal()
                .assign(cibCc.Id)
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .commitWork()
                .getRecord();

            PageReference pageRef = Page.RedirectToAddAttendees;
            pageRef.getParameters().put('newId', er.id);
            Test.setCurrentPage(pageRef);
            
            RedirectToAddAttendeesExtension ext = new RedirectToAddAttendeesExtension(new ApexPages.StandardController(er));
            PageReference redirectedPR = ext.redirect();
            
            Test.stopTest();
            
            system.assertEquals(Page.AddInternalAttendee.getUrl() + '?reportid=' + er.id, redirectedPR.getUrl());
        }
    }
    
    @IsTest
    static void testRedirectToEventReportDetail() {
        Test.startTest();
        
        User cibCc;
        system.runAs(new User(id = UserInfo.getUserId())) {
             cibCc = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }
        
        system.runAs(cibCc) {

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            Call_Report__c er = (Call_Report__c) new BLD_CallReport(uow)
                .linkWithParent(
                    new BLD_Account(uow).usePotential()
                        .proposedClientCoordinator(cibCc)
                )
                .internal()
                .assign(cibCc.Id)
                .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
                .commitWork()
                .getRecord();
            
            PageReference pageRef = Page.RedirectToAddAttendees;
            pageRef.getParameters().put('newId', er.id);
            Test.setCurrentPage(pageRef);
            
            RedirectToAddAttendeesExtension ext = new RedirectToAddAttendeesExtension(new ApexPages.StandardController(er));
            PageReference redirectedPR = ext.redirect();
            
            Test.stopTest();
            system.assertEquals(new ApexPages.StandardController(er).view().getUrl(), redirectedPR.getUrl());
        }
    }
}