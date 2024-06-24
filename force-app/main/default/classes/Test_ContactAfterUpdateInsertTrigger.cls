/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 13/2010
    @description   : Test Class for trigger ContactAfterUpdateInsert
    
    @ Last Modified : 13/06/2011
    @ Modified By   : C Reinecke
    @ Reason        : Removed redundant fields for regression project
    
    
    @ Last Modified By  :   Anand Nancharla
    @ Last Modified On  :   17th Aug 2011
    @ Modified Reason   :   Code comments @ // Domain_UserName__c is no longer used.
                            Case C-00000178
                            
    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26/10/2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c'  (line 36)
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Move test methods into external class  
                               Case #6521- Change contact to use TestFatcory    
                               API Version moved from 22 to 25 
    @ Last Modified By: Charles Mutsu
    @ Last Modified Date: 01/02/2013
    @ Description:  Implemented TestDataUtilityClass for generating Test Data                            
   					Changed the version from 20 to 27.

    @ Last Modified By: Petr Roubal
    @ Last Modified Date: 5 Jan 2016
    @ Description:  EN-0498 - Client Sector Fields - Deletion of fields (Clean-up)
******************************************************************************************************/
@isTest(SeeAllData = False)

private class Test_ContactAfterUpdateInsertTrigger {

    @IsTest
    static void testTrigger() {

        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert testUser;
        }

        try {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            BLD_Account accBld = new BLD_Account(uow).useChild()
                    .name(DMN_Account.STANDARD_BANK_EMPLOYEES);

            new BLD_Contact(uow).useBankContact()
                    .account(accBld);

            BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact()
                    .name('Axel', 'Rose')
                    .account(accBld)
                    .email('gunsNroses@SweetChild-O-Mine.com')
                    .birthDayMonth('11/12');

            uow.commitWork();

            clientConBld.name('Zenek', 'Martyniuk')
                    .email('zenek@tweOczyZielone.com')
                    .birthDayMonth('13/12')
                    .ownerId(testUser.Id);
            uow.registerDirty(clientConBld);
            uow.commitWork();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

}