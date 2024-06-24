/*****************************************************************************************************************************************************************************************************************
    @ Author        : Shubham Khilauria
    @ Date          : 05 - June - 2014
    @ Description   : Test Class for OppTeamCreationController.cls. This class will test the Unit test for Opportunity Team Page
                      which will include creating Existing Team Members, New Members and display Client Team Members.
******************************************************************************************************************************************************************************************************************/

@isTest(seealldata = false)
private class Test_OppTeamCreationController {
    /************************************************************************************************
    Scenario - Positive - Test Existing Opportunity Team Records and Client Team Records. Save the records 
    on screen. This will save all the records which were selected.             
    *************************************************************************************************/
    static testMethod void testExistingOppTeamRecord() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User custUser = (User) new BLD_USER(uow).useCib().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
            List<SObject> settings = new List<SObject>();
            settings.add(TEST_DataFactory.getEnvironmentVariable());
            settings.addAll((List<SObject>) TEST_DataFactory.getUserProfileIds());
            settings.addAll((List<SObject>) TEST_DataFactory.getCcSettings());
            settings.addAll((List<SObject>) TEST_DataFactory.getCstTeamRankings());
            settings.addAll((List<SObject>) TEST_DataFactory.getCSTManyPerRegionTeamRoles());
            settings.addAll((List<SObject>) TEST_DataFactory.getErrorMessages());
            insert settings;
        }

        Opportunity oppRec = (Opportunity) new BLD_Opportunity(uow)
            .client(
                new BLD_Account(uow).useChild()
                    .addClientTeam(
                        new BLD_ClientTeam(uow)
                            .user(admUser.Id)
                            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                    )
                    .addClientTeam(
                        new BLD_ClientTeam(uow)
                            .user(custUser.Id)
                            .role(DMN_ClientTeam.ROLE_CLIENT_ANALYST)
                    )
            )
            .addTeamMember(
                new BLD_OpportunityTeamMember(uow)
                    .role('Product Specialist')
                    .userId(custUser.Id)
            )
            .getRecord();

        uow.commitWork();
        
        test.startTest();
        system.runAs(admUser){
            
            ApexPages.StandardController std_Controller = new ApexPages.StandardController(oppRec);
            PageReference testPage  = Page.oppTeamCreation;
            testPage.getParameters().put('oppId',oppRec.Id);        // passing the Record ID of associated Opportunity
            Test.setCurrentPage(testPage);
            system.assertEquals(ApexPages.currentPage().getParameters().get('oppId'),oppRec.Id);
            oppTeamCreationController oppTeam = new oppTeamCreationController(std_controller);
            
            //Save the records
            oppTeam.save();  
            oppTeam.saveltng();      
        }   
    
       test.stopTest();
    }
    
    /************************************************************************************************
    Scenario - Negative - Test Existing Opportunity Team Records. But remove the User selected, to receive
    error on screen.           
    *************************************************************************************************/
    static testMethod void testNegativeOppTeamRecord() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User custUser = (User) new BLD_USER(uow).useCib().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Opportunity oppRec = (Opportunity) new BLD_Opportunity(uow)
            .client(
                new BLD_Account(uow).useChild()
            )
            .addTeamMember(
                new BLD_OpportunityTeamMember(uow)
                    .role('Product Specialist')
                    .userId(custUser.Id)
            )
            .getRecord();

        uow.commitWork();

        test.startTest();
        system.runAs(admUser){
            
            ApexPages.StandardController std_Controller = new ApexPages.StandardController(oppRec);
            PageReference testPage  = Page.oppTeamCreation;
            testPage.getParameters().put('oppId',oppRec.Id);        // passing the Record ID of associated Opportunity
            Test.setCurrentPage(testPage);
            system.assertEquals(ApexPages.currentPage().getParameters().get('oppId'),oppRec.Id);
            oppTeamCreationController oppTeam = new oppTeamCreationController(std_controller);
            
            //system.assertEquals(oppTeam.lstOppTeamRole.size(),6);
            // Add a new User to the List and also new record with checkbox selected and other values are empty.
            oppTeam.lstOppTeamRole.add(new oppTeamCreationController.oppTeamWrapper('',new OpportunityTeamMember(OpportunityId=oppRec.Id,UserId=custUser.Id,TeamMemberRole='GM Champion')));
            oppTeam.lstOppTeamRole[5].checked = true;
            
            // Add Blank Opp Team Member
            oppTeam.lstOppTeamRole.add(new oppTeamCreationController.oppTeamWrapper('',new OpportunityTeamMember(OpportunityId=oppRec.Id)));
            oppTeam.lstOppTeamRole[2].checked = true;
            
            //Save the records
            oppTeam.save();     
            oppTeam.saveltng();  
            
            //Error displayed. Cancel the record
            oppTeam.cancel();   
            oppTeam.cancelltng();
        }   
    
       test.stopTest();
    }
    
}