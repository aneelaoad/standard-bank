@IsTest
private class TestLightningSharing {

    private static final String TEST_USER_NAME = 'stdBank@nbac.com';
    private static final String TEST_ADMIN_USER_NAME = 'stdBankAdmin@nbac.com';

    @IsTest
    static void testSOSL() {
        String result = LightningSharing.doSOSL('McLaughlin', 'Lead');
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testReturning() {
        string uq = LightningSharing.getReturning('User');
        system.assertEquals(uq, 'User(Id, Name, UserType WHERE UserType in (\'Standard\', \'PowerCustomerSuccess\', \'PowerPartner\'))');
        uq = LightningSharing.getReturning('Group');
        system.assertEquals(uq, 'Group(Id, Name, Type)');
        uq = LightningSharing.getReturning('Custom__c');
        system.assertEquals(uq, 'Custom__c(Id, Name)');
        uq = LightningSharing.getReturning('Lead');
        system.assertEquals(uq, 'Lead(Id, Name)');
  }

    @IsTest
    static void testUserTypes() {
        LightningSharing.huh('PowerCustomerSuccess');
        LightningSharing.huh('PowerPartner');
        LightningSharing.huh('CustomerSuccess');
        LightningSharing.huh('CsnOnly');
        LightningSharing.huh('CSPLitePortal');
        System.assertEquals('MadeUpStuff', LightningSharing.huh('MadeUpStuff'));
  }

    @IsTest
    static void testInnerClass(){
        LightningSharing.sharingHolder sh = new LightningSharing.sharingHolder();
        sh.UserOrGroupName = 'test';
        sh.SubType = 'test';
        sh.UserOrGroupType = 'test';
        sh.UserOrGroupID = 'test';
        sh.AccessLevel = 'test';
        sh.RowCause = 'test';

        system.assertEquals(sh.UserOrGroupName, 'test');
        system.assertEquals(sh.SubType, 'test');
        system.assertEquals(sh.UserOrGroupType, 'test');
        system.assertEquals(sh.UserOrGroupID, 'test');
        system.assertEquals(sh.AccessLevel, 'test');
        system.assertEquals(sh.RowCause, 'test');
  }

    @IsTest
    static void testGetSharings() {
        try {
            list<lead> l = [select id from lead];
            LightningSharing.getSharings(l[0].id);
            list<Opportunity> o = [select id from Opportunity];
            LightningSharing.getSharings(o[0].id);
            list<Business_Assessment__c> ptos = [select id from Business_Assessment__c];
            list<Credit_Risk_Appetite__c> rotos = [select id from Credit_Risk_Appetite__c];
            LightningSharing.getSharings(ptos[0].id);
            LightningSharing.getSharings(rotos[0].id);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
  }

    @IsTest
    static void testCanIEditPermsAdmin() {
        list<lead> l = [select id from lead];
        LightningSharing.canIEditPerms(l[0].id);

        list<Business_Assessment__c> ptos = [select id from Business_Assessment__c];
        list<Credit_Risk_Appetite__c> rotos = [select id from Credit_Risk_Appetite__c];

        boolean perm = LightningSharing.canIEditPerms(ptos[0].id);
        system.assertEquals(perm, true);
        perm = LightningSharing.canIEditPerms(rotos[0].id);
        system.assertEquals(perm, true);
    }

    @IsTest
    static void testCanIEditPermsAdminNonOwner() {
        list<Business_Assessment__c> ptos = [select id from Business_Assessment__c];
        list<Credit_Risk_Appetite__c> rotos = [select id from Credit_Risk_Appetite__c];
        user u = getAdminUser();
        boolean perm1;
        boolean perm2;

        system.runAs(u){
          perm1 =LightningSharing.canIEditPerms(ptos[0].id);
          perm2 =LightningSharing.canIEditPerms(rotos[0].id);
        }

        system.assertEquals(perm1, true);
        system.assertEquals(perm2, true);
  }

    @IsTest
    static void testDelete() {
        try {
            list<Business_Assessment__c> ptos = [select Id from Business_Assessment__c];
            user u = getUsers()[0];
            LightningSharing.upsertPerm(u.id, ptos[0].id, 'Edit');
            LightningSharing.deletePerm(u.id, ptos[0].id);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
  }

    @IsTest
    static void testUpsertPerm() {
        list<Opportunity> o = [select id from Opportunity];
        list<lead> l = [select id from Lead];
        list<Business_Assessment__c> ptos = [select id from Business_Assessment__c];
        list<Credit_Risk_Appetite__c> rotos = [select id from Credit_Risk_Appetite__c];
        user u = getUsers()[0];
        try {
            LightningSharing.upsertPerm(u.id, ptos[0].id, 'Edit');
            LightningSharing.upsertPerm(u.id, ptos[0].id, 'Read');
            LightningSharing.upsertPerm(u.id, ptos[0].id, 'Edit');
            LightningSharing.getSharings(ptos[0].id);
            LightningSharing.deletePerm(u.id, ptos[0].id);
            LightningSharing.upsertPerm(u.id, rotos[0].id, 'Edit');
            LightningSharing.getSharings(rotos[0].id);
            LightningSharing.deletePerm(u.id, rotos[0].id);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }

  	try {
  		LightningSharing.upsertPerm(u.id, o[0].id, 'Edit');
  		LightningSharing.deletePerm(u.id, o[0].id);
  	} catch (exception e){
  		//ok, sharing may not be on
  		system.debug(e);
  	}

  	try {
  		LightningSharing.upsertPerm(u.id, o[0].id, 'Read');
  		LightningSharing.deletePerm(u.id, o[0].id);
  	} catch (exception e){
  		system.debug(e);
  		//ok, sharing may not be on
  	}

  	try {
  		LightningSharing.upsertPerm(u.id, l[0].id, 'Edit');
  		LightningSharing.deletePerm(u.id, l[0].id);
  	} catch (exception e){
  		//ok, sharing may not be on
  		system.debug(e);
  	}

  	try {
  		LightningSharing.upsertPerm(u.id, l[0].id, 'Read');
  		LightningSharing.deletePerm(u.id, l[0].id);
  	} catch (exception e){
  		system.debug(e);
  		//ok, sharing may not be on
  	}
  }

    @IsTest
    static void testStringStuff(){
        try {
            LightningSharing.getLookupField('Account');
            LightningSharing.getAccessLevelField('Account');
            LightningSharing.getSharingTableName('Account');
            LightningSharing.getLookupField('Custom__c');
            LightningSharing.getAccessLevelField('Custom__c');
            LightningSharing.getSharingTableName('Custom__c');
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
  }

    @IsTest
    static void testBuildQuery(){
        list<lead> l = [select id from lead];
        String query = LightningSharing.buildQuery(l[0].id);
        System.assertNotEquals(null, query);
  }

    @IsTest
    static void testCanIEditPermsNonAdmin() {
        List<Business_Assessment__c> ptos = [select id from Business_Assessment__c];
        List<Credit_Risk_Appetite__c> rotos = [select id from Credit_Risk_Appetite__c];
        List<user> users = getUsers();
        LightningSharing.upsertPerm(users[0].id, ptos[0].id, 'Edit');
        LightningSharing.upsertPerm(users[0].id, rotos[0].id, 'Edit');
        System.RunAs(users[0]){
            System.assertEquals(LightningSharing.canIEditPerms(ptos[0].id), false);
            System.assertEquals(LightningSharing.canIEditPerms(rotos[0].id), false);
        }
    }

    @IsTest
    static void testGroupStuff() {
        List<group> groups = [select id from group where Name = 'the knights who say nee'];
        List<lead> l = [select id from lead];
        List<Business_Assessment__c> ptos = [select id from Business_Assessment__c];
        List<Credit_Risk_Appetite__c> rotos = [select id from Credit_Risk_Appetite__c];
        List<user> users = getUsers();
        List<GroupMember> gms = new list<GroupMember>();
        gms.add(new GroupMember(GroupId=groups[0].id, UserOrGroupId=users[0].id));
        gms.add(new GroupMember(GroupId=groups[0].id, UserOrGroupId=users[1].id));
        insert gms;

        Test.startTest();
            try {
                System.RunAs(getAdminUser()) {
                    LightningSharing.upsertPerm(groups[0].id, ptos[0].id, 'Read');
                    LightningSharing.getSharings(l[0].id);
                    LightningSharing.getSharings(ptos[0].id);
                    LightningSharing.getSharings(rotos[0].id);
                }
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        Test.stopTest();
    }

  @testSetup static void makeData(){

    fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
    System.runAs(new User(Id = UserInfo.getUserId())){
            
            new BLD_USER(uow).userName(TEST_ADMIN_USER_NAME).useSysAdmin().syncContact();
            new BLD_USER(uow).userName(TEST_USER_NAME+'1').useCib().syncContact();
            new BLD_USER(uow).userName(TEST_USER_NAME+'2').useCib().syncContact();
    
            uow.commitWork();
    } 
    Test.startTest();
    Test.stopTest(); 
    	//make some object for testing, like a lead
    	lead l = new lead();
    	l.Lastname = 'McLaughlin';
    	l.company = 'Salesforce';
    	l.email = 'm.shane.mclaughlin@gmail.com';
    	insert l;

    	account a = new account();
    	a.Name = 'Ink, inc.';
    	insert a;

    	contact c = new contact();
    	c.accountId = a.id;
    	c.FirstName = 'Sarah';
    	c.LastName = 'McLaughlin';
    	c.Email = 'sarah@gmail.com';
    	insert c;

    	Opportunity o = new Opportunity();
    	o.accountId = a.id;
    	o.closeDate = system.today();
    	o.Name = 'biggest deal ever';

    	o.StageName = [select MasterLabel from OpportunityStage where IsClosed = false][0].MasterLabel;
    	insert o;

      BLD_BusinessAssessment baBld = new BLD_BusinessAssessment(uow).client(a.Id);

      BLD_CreditRiskAppetite riskApetiteBld = (BLD_CreditRiskAppetite) new BLD_CreditRiskAppetite(uow)
                            .setField(Credit_Risk_Appetite__c.Country__c, DMN_Account.CTRY_OF_RISK)
                            .setField(Credit_Risk_Appetite__c.Sector__c, DMN_Account.SEC_CUSTOMER)
                            .setField(Credit_Risk_Appetite__c.Sub_Sector__c, DMN_Account.SUB_SEC_AGRICULTURE)
                            .setField(Credit_Risk_Appetite__c.Sector_Credit_Appetite__c, DMN_RiskAppettite.RISK_HOLD)
                            .setField(Credit_Risk_Appetite__c.Country_Credit_Appetite__c, DMN_RiskAppettite.RISK_HOLD);
      uow.commitWork();

      group g = new group();
      g.Name = 'the knights who say nee';
      g.Type = 'Regular';

      insert g;



  }

  private static User[] getUsers(){ 
        return  [  SELECT Username  
                        FROM User
                        WHERE UserName in: (new String[]{TEST_USER_NAME+'1', TEST_USER_NAME+'2'})];
  }

  private static User getAdminUser(){ 
        return  [  SELECT Username  
                        FROM User
                        WHERE UserName =:TEST_ADMIN_USER_NAME LIMIT 1];
  }


  /*public static user createAdmin(){
  	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

		// create User
		User u = new User();

		u.FirstName = 'A';
		u.LastName = 'S';
		u.Email = 'test@testLightningSharing2017.com';
		u.Username = 'astest@testLightningSharing2017.com';
		u.Alias = 'astest';
		u.ProfileId = p.Id;
		u.TimeZoneSidKey    = 'America/Denver';
		u.LocaleSidKey      = 'en_US';
		u.EmailEncodingKey  = 'UTF-8';
		u.LanguageLocaleKey = 'en_US';

		insert u;
		system.debug('u contains ' + u);
		return u;
	}

	public static list<user> createUsers(integer numberOfUsers){
		list<user> users = new list<user>();

		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];


		for (integer i=0; i<numberOfUsers; i++){
			string x = string.valueOf(i);
			User u = new User(Alias = 't'+x, Email='standarduser'+x+'@testLightningSharing2017.msm',
				EmailEncodingKey='UTF-8', LastName='Testing' + x, LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+x+'@testLightningSharing2017.msm');
			users.add(u);
		}

		insert users;
		return users;
	}*/

}