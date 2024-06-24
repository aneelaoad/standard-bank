/****************************************************************************

    @ Last Modified By      :   Petr Roubal
    @ Last Modified On      :   15 Mar 2016
    @ Last Modified Reason  :   EN - 1174: RTB - Compliance: Rename of Opportunity Owner User Fields (APIs) and CIB Global Area

****************************************************************************/

@isTest
public class UserTriggerUtility_Oppty_Test{

    static testMethod void testOpptyupdate() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        // Create test user based on the standard user profile
        User user1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        BLD_Account accBld = new BLD_Account(uow);
        uow.commitWork();
        
        System.runAs(user1) {
            List<Opportunity> olstOpportunity = new List<Opportunity> {
                (Opportunity) new BLD_Opportunity(uow)
                    .client(accBld)
                    .stage(DMN_Opportunity.ST_DEVELOP)
                    .getRecord(),
                (Opportunity) new BLD_Opportunity(uow)
                    .client(accBld)
                    .closedLost()
                    .getRecord()
            };
            uow.commitWork();

            Test.StartTest();
            user1.User_Division__c = 'Business Enablers';
            user1.City = 'Johannesburg';
            update user1;
            Test.StopTest();
            Opportunity opp = [Select ID, Opportunity_Owner_Division__c, Opportunity_Owner_City__c from Opportunity where ID = :olstOpportunity[0].ID];
            System.assertEquals(opp.Opportunity_Owner_Division__c , user1.User_Division__c);
            System.assertEquals(opp.Opportunity_Owner_City__c , user1.City);

            Opportunity opp1 = [Select ID, Opportunity_Owner_Division__c, Opportunity_Owner_City__c from Opportunity where ID = :olstOpportunity[1].ID];
            System.assertNotEquals(opp1.Opportunity_Owner_City__c , user1.City);
            System.assertNotEquals(opp1.Opportunity_Owner_Division__c , user1.User_Division__c);

        }

    }
}