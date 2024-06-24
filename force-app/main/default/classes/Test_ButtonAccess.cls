/************************************************************************
* @author       Vaishali Singh  
* @date         Apr -2013
* @description  Test class for ButtonAccess EN- 0658 

    @ Last Modified By  :      
    @ Last Modified On  :   
************************************************************************/

@isTest
private class Test_ButtonAccess {

    @IsTest
    static void testButtonAccess() {
         System.runAs(new User(Id = UserInfo.getUserId())) {
             insert TEST_DataFactory.getEnvironmentVariable();
         }

         User sysAdminUser = TEST_DataFactory.sysAdmin;

         fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

         Contact conRec = (Contact) new BLD_Contact(uow).useBankContact()
            .accountId(TEST_DataFactory.stdBankEmpAcc.Id)
            .commitWork()
            .getRecord();
        
        Call_Report__c defaultEventReport = new Call_Report__c();
        defaultEventReport.Relate_to_Client__c = TEST_DataFactory.stdBankEmpAcc.Id ;
        defaultEventReport.Subject__c = 'Test Subject';
        defaultEventReport.Meeting_Audience__c = 'Internal';
        defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
        defaultEventReport.Start__c = System.now();
        defaultEventReport.End__c = System.now();
        defaultEventReport.Description__c = 'Test Description';
        insert defaultEventReport;
        
        Call_Report_Attendees__c sObjCallAttendees = new Call_Report_Attendees__c();
        sObjCallAttendees.Contact_id__c = conRec.Id;
        sObjCallAttendees.Call_Report__c = defaultEventReport.Id;
        sObjCallAttendees.Status__c='Invited';
        insert sObjCallAttendees;
        
        User custStandardUser = (User) new BLD_USER().useCib().contactSyncId(conRec.Id).getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
        	 insert custStandardUser;
        }
        
        Test.startTest();
        System.runAs(sysAdminUser){
            Boolean result = ButtonAccess.checkInternalAttendeeButton(sysAdminUser.Id, defaultEventReport.Id);
            System.assert(result);
        }
	}

}