/*************************************************************************
    @ Author        : Abhishek Vaideeswaran
    @ Date          : November 2015
    @ Test File     : OpportunityVisibilityController_Test
    @ Description   : Test class for OpportunityVisibilityController controller which is used to display Opportunity Team members and Sharing information 
    @ Enhancement   : EN-0956
                                                                                  
*************************************************************************/

@isTest
public class OpportunityVisibilityController_Test{

    @TestSetup
    private static void prepareData() {
        List<User> ulst = new List<User>();

        User testuser = (User) new BLD_USER().useSysAdmin().getRecord();
        ulst.add(testuser);

        User testuser1 = (User) new BLD_USER().useCib().getRecord();
        ulst.add(testuser1);
	        system.runAs(new User(Id = UserInfo.getUserId())){
	        	insert ulst;
	        }

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        List<Opportunity> opplst = new List<Opportunity> {
            (Opportunity) new BLD_Opportunity(uow)
                .name('Testopp956')
                .client(
                    new BLD_Account(uow).name('Test956Client')
                )
                .addTeamMember(
                    new BLD_OpportunityTeamMember(uow)
                        .userId(ulst[0].Id)
                        .role('Product Specialist')
                )
                .getRecord()
        };

        uow.commitWork();

        Group shrgrp = new Group(name = 'TestGroup956');
        insert shrgrp;
        
        List<OpportunityShare> oslst = new List<OpportunityShare>();
        OpportunityShare os1 = new OpportunityShare(OpportunityID = opplst[0].ID, RowCause = 'Manual', UserOrGroupID = ulst[1].ID, OpportunityAccessLevel = 'Edit');
        OpportunityShare os2 = new OpportunityShare(OpportunityID = opplst[0].ID, RowCause = 'Manual', UserOrGroupID = shrgrp.ID, OpportunityAccessLevel = 'Edit');
        oslst.add(os1);
        oslst.add(os2);
        
        	insert oslst;
        	insert TEST_DataFactory.getErrorMessages();
    
    }
    static testMethod void testsharepage() {
        Opportunity opp = [Select ID,ownerID, Name from Opportunity where Name = 'Testopp956'];

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        OpportunityVisibilityController ctrl = new OpportunityVisibilityController(controller);
        System.assertequals(ctrl.IsTeamMemberEmpty, False);
        System.assertequals(ctrl.IsShareListEmpty, False);
        for(OpportunityVisibilityController.ShareWrapper wrprec: ctrl.sharewrapperlist){
            if(wrprec.Name == 'Custom Standard User User'){
                System.assertequals(wrprec.oppsharerec.rowcause, 'Manual');
            }
            else if(wrprec.Name == 'TestGroup956'){
                System.assertequals(wrprec.oppsharerec.rowcause, 'Manual');
            }
            else if(wrprec.recID == opp.ownerID){
                System.assertequals(wrprec.oppsharerec.rowcause, 'Owner');
            }
        }
        List<OpportunityTeamMember> otmlist = [Select ID from OpportunityTeamMember where OpportunityID = :opp.ID];
        try{
            delete otmlist;
        }catch(Exception e){
            System.Debug('Exception' +e);
        }
        ctrl = new OpportunityVisibilityController(controller);
        System.assertequals(ctrl.IsTeamMemberEmpty, True);
    }
}