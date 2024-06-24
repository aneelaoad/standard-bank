/*************************************************************************
@ Author        : Manoj Gupta
@ Date          : 03-July-2017
@ Parent Class  : StdBank_Ltn_RegulatoryInfo
@ Description   : US-2134 IUI FAIS - To display FAIS related information on Client details tab page : 
FAIS Status, NAV, AUM and FAIS Review Date
-----------------------------------------------------------------------------
************************************************************************/


@isTest
private class StdBank_Ltn_RegulatoryInfo_test {
    @isTest static void testFAISInfo() {
    
        Account acc = (Account) new BLD_Account().useChild().getRecord();
        acc.FAIS_Status__c = 'FAIS Impacted';
        acc.FAIS_Review_Date__c = Date.Today();
        acc.AUM__c = 1000;
        acc.NAV__c = 2000;
        insert acc;

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCstTeamRankings()
        });
        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
        insert testUser;
    
    }

         System.runAs(testUser){
         Test.startTest();
                 Custom_Client_Team__c clientTeam = new Custom_Client_Team__c(
            Team_Member__c = testUser.Id,
            Account__c = acc.Id,
            Client_Coordinator__c = True,
            Client_Role__c = DMN_ClientTeam.ROLE_ANALYST
            );
        insert clientTeam;

        System.assertEquals(true, StdBank_Ltn_RegulatoryInfo.getHasAccess(acc.Id));
        Test.stopTest();
      //  System.assertNotEquals(0, AccountHierarchy_LTN_CTRL.getContactRoles().size());
      }
        
    }
    }