@isTest
public class CI_CreditControllerTest {

    private static void setupTestData() {   
           
        Account client = new Account( Name = 'Google Inc',
                                        Internal_Credit_Rating__c = 'SB01', 
                                        VAT_Number__c='Vat1', 
                                        CIF__c ='CIF3', 
                                        BPID__c='BPID1',
                                        Country_Risk__c='South Africa',
                                        Client_Sub_Sector__c='Transport'); //Positive test

        Account client1 = new Account(Name = 'Yahoo', 
                                        VAT_Number__c='Vat2', 
                                        CIF__c ='CIF2', 
                                        BPID__c='BPID2'); //Negative test

        insert client;
        insert client1;

        List<Credit_Line__c> creditLines = new List<Credit_Line__c>();

        Credit_Line__c creditLine0 = new Credit_Line__c();
        creditLine0.Credit_Limit__c = 50;
        creditLine0.Total_utilisation__c = 100;
        creditLine0.Client_Name__r = client;
        creditLine0.Client_Name__c = client.Id;
        creditLine0.Product__c = 'TestProd';
        creditLines.add(creditLine0);
        
        Credit_Line__c creditLine1 = new Credit_Line__c();
        creditLine1.Credit_Limit__c = 50;
        creditLine1.Total_utilisation__c = 100;
        creditLine1.Client_Name__r = client;
        creditLine1.Client_Name__c = client.Id;
        creditLine1.Product__c = 'TestProd1';
        creditLines.add(creditLine1);
        
        Credit_Line__c creditLine2 = new Credit_Line__c();
        creditLine2.Credit_Limit__c = 121;
        creditLine2.Total_utilisation__c = 125;
        creditLine2.Client_Name__r = client1;
        creditLine2.Client_Name__c = client1.Id;
        creditLine2.Product__c = 'TestProd2';
        creditLines.add(creditLine2);

        insert creditLines;

        Probability_of_default__c pd  = new Probability_of_default__c( Name = 'SB01',
                                                                    Fitted_PD__c = '0.010'); //Positive test
        insert pd;

        List<Credit_Risk_Appetite__c> riskAppetites = new List<Credit_Risk_Appetite__c>();

        Credit_Risk_Appetite__c riskAppetite0 = new Credit_Risk_Appetite__c();
        riskAppetite0.Country_Credit_Appetite__c = 'Reduce';
        riskAppetite0.Country__c = 'South Africa';
        riskAppetites.add(riskAppetite0);

        insert riskAppetites;
    }

    public static testMethod void CreditUtilisationTest(){
        setupTestData(); 
        
        List<Account> client = [select id from Account where name ='Google Inc'];    
        CI_CardMapModel result = (CI_CardMapModel)CI_CreditController.getCreditUtilisation(client[0].id).Data;
        System.assertEquals('2', result.cardDataMap.get('facilitiesCount'));
        System.assertEquals('2', result.cardDataMap.get('inExcessCount'));
        System.assertEquals('100.0', result.cardDataMap.get('creditTotal'));
        System.assertEquals('200.0', result.cardDataMap.get('utilisationTotal'));
        System.assertEquals('200', result.cardDataMap.get('percentCreditUsed'));
        System.assertEquals('0', result.cardDataMap.get('percentCreditAvail'));
    } 

    public static testMethod void InternalCreditRatingTest(){
        setupTestData(); 
        
        List<Account> client = [select id from Account where name ='Google Inc'];    
        CI_CardMapModel result = (CI_CardMapModel)CI_CreditController.getInternalCreditRating(client[0].id).Data;
   
        System.assertEquals('SB01', result.cardDataMap.get('Rating'));
    }  

    public static testMethod void getCreditRiskRating(){
        setupTestData(); 
        
        List<Account> client = [select id from Account where name ='Google Inc'];    
        CI_CardMapModel result = (CI_CardMapModel)CI_CreditController.getCreditRiskRating(client[0].id).Data;
   
        System.assertEquals('0.010', result.cardDataMap.get('Rating'));
    } 

    public static testMethod void getCreditRiskRatingNone(){
        setupTestData(); 
        
        List<Account> client = [select id from Account where name ='Yahoo'];    
        CI_CardMapModel result = (CI_CardMapModel)CI_CreditController.getCreditRiskRating(client[0].id).Data;
   
        System.assertEquals('None', result.cardDataMap.get('Rating'));
    } 

    public static testMethod void GetCreditLinesTest(){
        setupTestData(); 
        
        List<Account> client = [select id from Account where name ='Yahoo'];    
        List<Credit_Line__c> result = (List<Credit_Line__c>)CI_CreditController.getCreditLines(client[0].id).Data;
        System.assert(result.size() > 0);
    }

    static testMethod void getRiskAppetiteTest() {
        setupTestData(); 

        List<Account> client = [select id, Parentid, Name from Account where name  = 'Google Inc'];
        CI_CardMapModel result = (CI_CardMapModel)CI_CreditController.getRiskAppetite(client[0].id).Data;
         
        System.assertEquals(null, result.cardDataMap.get('Country_Credit_Appetite__c'));              
    }
}