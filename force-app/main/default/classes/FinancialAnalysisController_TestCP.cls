/*************************************************************************\
    @ Author        :     Aneske Meiring
    @ Date          :     26/09/2013
    @ Description   :     Test Class for PublicFinancialAnalysisController
    
    @ Author        :     Charles Mutsu
    @ Date          :     28/02/2013
    @description    :     Updated API version from 28 to 29
**************************************************************************/
@isTest
public class FinancialAnalysisController_TestCP{
 
    @IsTest
    static void publicFinancialAnalysisController() {
        
        TEST_DataFactory.generateConfiguration();
        
        // create standard user 
        User admUser = (User) new BLD_USER().useSysAdmin().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert admUser;
        }

        //create account
        List<Account> lstAcc = new List<Account> {
            (Account) new BLD_Account()
                .clientCoordinator(admUser)
                .getRecord()
        };
        insert lstAcc;
         Client_Financial_Analysis__c pfa = New Client_Financial_Analysis__c(
         Client_Name__c = lstAcc[0].Id,
         Statement_Date__c = Date.newInstance(1980 , 10 ,20),
         Total_Revenue__c = 50000
         );
           insert pfa;
           
           Client_Plan__c cplan = new Client_Plan__c();
            cplan.Client_Name__c =lstAcc[0].Id;
            insert cplan;
            
            Client_Capital_and_Revenue__c ccr = new Client_Capital_and_Revenue__c();
            ccr.Client__c = lstAcc[0].Id;
            ccr.Capital_Utilisation_USD__c =  12.23 ;
            ccr.Capital_Utilisation_ZAR__c = 23.21;
            ccr.CROC_ZAR__c = 23.33 ;
            
            insert ccr ;
           
            ccr.Client__c = lstAcc[0].Id;
            update ccr;
            
            Credit_Line__c cLine = new Credit_Line__c();
            cLine.Client_Name__c = lstAcc[0].Id;
            cLine.Credit_Limit__c = 20.22;
            cLine.Product__c = 'GBB';
            cLine.Total_utilisation__c = 22.32 ; 
            
            insert cLine ;

        Boolean isExceptionThrown = false;
        test.startTest();
        try {
            PageReference pageRef = Page.ClientPlan;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('id', lstAcc[0].Id);

            PublicFinancialAnalysisController pfaComponent = new PublicFinancialAnalysisController();
            pfaComponent.cplanFinResult = pfaComponent.getFin();
            pfaComponent.thisFinAnalysisDataId = string.valueof(lstAcc[0].Id);

            list<PublicFinancialAnalysisController.cPlanCreditLines> cPlanCL = pfaComponent.getcl();

            ApexPages.StandardController controller = new ApexPages.StandardController(lstAcc[0]);
            PublicFinancialAnalysisController pFAClass = new PublicFinancialAnalysisController(controller);
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
        test.stopTest();
        
    }
    
    @IsTest
    static void publicFinancialAnalysisController2() {
        
        TEST_DataFactory.generateConfiguration();
        
        // create standard user 
        User admUser = (User) new BLD_USER().useSysAdmin().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert admUser;
        }
        
        //create account
        List<Account> lstAcc = new List<Account> {
            (Account) new BLD_Account()
                .clientCoordinator(admUser)
                .getRecord()
        };
        insert lstAcc;
        
         Client_Financial_Analysis__c pfa = New Client_Financial_Analysis__c(
         Client_Name__c = lstAcc[0].Id, 
      //   Public_Information__c = True,
         Statement_Date__c = Date.newInstance(1980 , 10 ,20),
         Total_Revenue__c = 50000
         );
           insert pfa;
           
            Client_Plan__c cplan = new Client_Plan__c();
            cplan.Client_Name__c =lstAcc[0].Id;
            cPlan.CurrencyIsoCode = 'USD';
            insert cplan;
            
            Client_Capital_and_Revenue__c ccr = new Client_Capital_and_Revenue__c();
            ccr.Client__c = lstAcc[0].Id;
            ccr.Capital_Utilisation_USD__c =  12.23 ;
            ccr.Capital_Utilisation_ZAR__c = 23.21;
            ccr.CROC_ZAR__c = 23.33 ;
            
            insert ccr ;
           
            ccr.Client__c = lstAcc[0].Id;
            update ccr;
            
            Credit_Line__c cLine = new Credit_Line__c();
            cLine.Client_Name__c = lstAcc[0].Id;
            cLine.Credit_Limit__c = 20.22;
            cLine.Product__c = 'GBB';
            cLine.Total_utilisation__c = 22.32 ; 
            
            insert cLine ;

            Boolean isExceptionThrown = false;
            test.startTest();
            try {
                PageReference pageRef = Page.ClientPlan;
                Test.setCurrentPage(pageRef);

                ApexPages.currentPage().getParameters().put('id', lstAcc[0].Id);


                PublicFinancialAnalysisController pfaComponent = new PublicFinancialAnalysisController();
                pfaComponent.cplanFinResult = pfaComponent.getFin();
                pfaComponent.thisFinAnalysisDataId = string.valueof(lstAcc[0].Id);

                PublicFinancialAnalysisController.cPlanCreditLines cCredit = new PublicFinancialAnalysisController.cPlanCreditLines();

                PublicFinancialAnalysisController.cPlanFinAnalysis cFin = new PublicFinancialAnalysisController.cPlanFinAnalysis();

                list<PublicFinancialAnalysisController.cPlanCreditLines> cPlanCL = pfaComponent.getcl();

                ApexPages.StandardController controller = new ApexPages.StandardController(lstAcc[0]);
                PublicFinancialAnalysisController pFAClass = new PublicFinancialAnalysisController(controller);
            }
            catch(Exception ex) {
                isExceptionThrown = true;
            }
            test.stopTest();
        System.assert(!isExceptionThrown);
        
    } // end testMethod  
}