/*************************************************************************\
    @ Author        :     Manu Erwin 
    @ Date          :     Mar 2009
    @ Test File     :     This Class
    @ Description   :     Allows for the product redirection to be tested
                          
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 15 August 2011
    @ Last Modified Reason  : Regression - New Role Hierarchy Implementation: Removed role DCM User from th ...
    
    @ Last Modified By  : Nikhita Reddy 
    @ Last Modified On  : 01/03/2013
    @ Last Modified Reason  : Added test data and used best practices.
                                Moved the AP version to 27.
                                
    @ Last Modified By  : Shubham Khilauria 
    @ Last Modified On  : 16/01/2014
    @ Last Modified Reason  : Rewritten whole class to accomodate Positive and Negative Scenarios/ Follow Best Practices.
                             
****************************************************************************/
@isTest(SeeAllData=false) 
private class StdBank_OpptyProdRedirect_Vf_Ext_Test {
    
    /**********************************************************
	Scenario - Navigate the user to create product when running user is same as opportunity owner
	**********************************************************/
    static testMethod void testCreateNewProduct() {
        User testUser = (User) new BLD_USER().useSysAdmin().outlookId('Exc123').getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert testUser;
        }
		
        insert TEST_DataFactory.getSystemParameters();
        insert TEST_DataFactory.getEnvironmentVariable();

        //Create test data
        // get Client collection object
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Opportunity oppRec = (Opportunity) new BLD_Opportunity(uow)
            .ownerId(testUser.Id)
            .client(
                new BLD_Account(uow).useChild()
            )
            .getRecord();

        uow.commitWork();

        ApexPages.StandardController std_Controller = new ApexPages.StandardController(oppRec);
		
		PageReference testPage_OpptyProdRedirect_Ref 	= Page.StdBank_OpptyProductRedirect_Vf;
		
		// start test
		test.startTest();
		
		System.RunAs(testUser){
			
	        Test.setCurrentPage(testPage_OpptyProdRedirect_Ref);
	        
	        StdBank_OpptyProdRedirect_Vf_Ext controller = new StdBank_OpptyProdRedirect_Vf_Ext(std_Controller);
	        
	        //Call PageRedirect method
	        Pagereference pageRef = controller.redirect();
	        system.assertNotEquals(pageRef,null);
		}
		
        test.stopTest();
    }
    
    /**********************************************************
	Scenario - Navigate the user to mass draw down update page when running user is 
			   not admin profile and products for opportunity are already existing.
	**********************************************************/
    static testMethod void testNonAdminMassDrawDownUpdate() {
        // TO DO: implement unit test
        //User
        User testUser = (User) new BLD_USER().useCib().outlookId('Exc123').getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert testUser;
        }
		
		//insert sys parameter custom setting
        insert TEST_DataFactory.getSystemParameters();
        insert TEST_DataFactory.getEnvironmentVariable();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Opportunity oppRec = (Opportunity) new BLD_Opportunity(uow)
            .ownerId(testUser.Id)
            .closeDate(System.today() + 30)
            .client(
                new BLD_Account(uow).useChild()
            )
            .addProduct(
                new BLD_Product(uow)
                    .addDrawDownProfile(
                        new BLD_DrawDownProfile(uow)
                            .drawDate(System.today() + 1)
                            .funding(100)
                    )
            )
            .getRecord();

        uow.commitWork();

        ApexPages.StandardController std_Controller = new ApexPages.StandardController(oppRec);
		
		PageReference testPage_OpptyProdRedirect_Ref 	= Page.StdBank_OpptyProductRedirect_Vf;
		
		// start test
		test.startTest();
		
		System.RunAs(testUser){
			
	        Test.setCurrentPage(testPage_OpptyProdRedirect_Ref);
	        
	        StdBank_OpptyProdRedirect_Vf_Ext controller = new StdBank_OpptyProdRedirect_Vf_Ext(std_Controller);
	        
	        //Call PageRedirect method
	        Pagereference pageRef = controller.redirect();
	        system.assertNotEquals(pageRef,null);
		}
		
        test.stopTest();
    }
    
    /**********************************************************
	Scenario - Navigate the user to Add mass draw down page when running user is 
			   of admin profile and Draw Down records does not exist 
	**********************************************************/
    static testMethod void testMassDrawDownUpdatewithoutDrawDown() {
        User testUser = (User) new BLD_USER().useCib().outlookId('Exc123').getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
        	 insert testUser;
        }

        insert TEST_DataFactory.getSystemParameters();
        Environment_Variable__c envVariable = TEST_DataFactory.getEnvironmentVariable();
        envVariable.Draw_Down_Product_Record_Types__c = 'Advisory';
        envVariable.Draw_Down_Grand_Parent_Products__c = 'Advisory Fees';
        insert envVariable;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Opportunity oppRec = (Opportunity) new BLD_Opportunity(uow)
            .ownerId(testUser.Id)
            .closeDate(System.today() + 30)
            .client(
                new BLD_Account(uow).useChild()
            )
            .addProduct(
                new BLD_Product(uow).useAdvisory()
            )
            .getRecord();

        uow.commitWork();

        ApexPages.StandardController std_Controller = new ApexPages.StandardController(oppRec);
		
		PageReference testPage_OpptyProdRedirect_Ref 	= Page.StdBank_OpptyProductRedirect_Vf;
		
		// start test
		test.startTest();
		
		System.RunAs(testUser){
			
	        Test.setCurrentPage(testPage_OpptyProdRedirect_Ref);
	        
	        StdBank_OpptyProdRedirect_Vf_Ext controller = new StdBank_OpptyProdRedirect_Vf_Ext(std_Controller);
	        
	        //Call PageRedirect method
	        Pagereference pageRef = controller.redirect();
	        system.assertNotEquals(pageRef,null);
		}
		
        test.stopTest();
    }
    
}