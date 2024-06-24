/**
 * @description Test class for CI_ClientOverviewController
 */
@isTest
public class CI_ClientOverviewControllerTest{

    @TestSetup
    private static void setupTestData() {
        List<CsiProjectCountry__c> csiProjCtrs = new List<CsiProjectCountry__c>();
         
        for (String ctry: new String[]{'Kenya'}) {
            csiProjCtrs.add(new CsiProjectCountry__c(name = ctry));
        }
        insert csiProjCtrs;       
        
        List<Account> client = new List<Account>();        
        client.add(new Account( Name = 'Google Inc',
                                Client_Strategy__c = 'Strategy for the client', 
                                Long_Term_Strategy__c = 'Long term goal', 
                                Short_Term_Objectives__c = 'Short term goal', 
                                Nature_of_Relationship__c ='Trusted Advisor',
                                Overall_CIB_CSI_Rating_Number__c =3,
                              	Survey_Year__c = '2017',
                                CSI_Client_at_Risk__c='No',
                              	Country_Risk__c='Angola',
                                Client_Sector__c = 'Consumer',
                                Client_Sub_Sector__c ='Sugar')); //Positive test
        client.add(new Account( Name = 'Yahoo',
                                Client_Strategy__c = '', 
                                Long_Term_Strategy__c = '',
                                Nature_of_Relationship__c ='',
                                Overall_CIB_CSI_Rating_Number__c = null)); //Negative test
        client.add(new Account( Name = 'Google Asia',        //for CSI Rating                        
                                Overall_CIB_CSI_Rating_Number__c = 6,
                              	Survey_Year__c = '2017',
                                CSI_Client_at_Risk__c='No'));
        client.add(new Account( Name = 'Google Latin America',                                
                                Overall_CIB_CSI_Rating_Number__c = 7));
        client.add(new Account( Name = 'Google Europe',                                
                                Overall_CIB_CSI_Rating_Number__c = 9));
        
        insert client;

        RecordType rt = [select Id from RecordType where Name = 'Client Contact Record Type' and SobjectType = 'Contact' limit 1];         
            
  		Contact surveyContact = new Contact(AccountId= client[0].id, firstName = 'Thandi', lastname='Newton', email='thandi@abinbev.com', Contact_Category__c ='CEO', Phone='0119284734', recordTypeId= rt.id);
        insert surveyContact;
        
        Client_Satisfaction_Index__c csiObj = new Client_Satisfaction_Index__c();
        csiObj.Overall_CIB_CSI_Rating_Number__c = 3;
        csiObj.Client__c =client[0].id;
        csiObj.Survey_Year__c = '2014';
        csiObj.CSI_Case_Subject__c = 'CSI Case Created';
        csiObj.CSI_Case_Description__c= 'CSI Case Description';
        csiObj.CSI_Survey_Contact__c = surveyContact.Id;
        csiObj.CSI_Project_Country__c = 'Kenya';
        csiObj.CSI_Client_at_Risk__c= 'No';
        csiObj.Related_To__c = 'Client Coverage';
        csiObj.TPS_CSI_Rating_Number__c=1;
        csiObj.GM_CSI_Rating_Number__c=7;
        csiObj.IB_CSI_Rating_Number__c=8;
        csiObj.CSI_TPS_Comment__c ='TPS Comment';
        csiObj.CSI_GM_Comment__c='GM Comment'; 
        csiObj.CSI_IB_Comment__c='IB Comment';
         
        insert csiObj;                                         
     }

    @IsTest
    public static void bankStrategyPositiveTest(){
        List<Account> client = [select id from Account where name ='Google Inc'];    

        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getBankStrategy(client[0].id).Data;

        system.assertEquals('Strategy for the client', result.cardDataMap.get('Text'));
        system.assertEquals('Bank Strategy', result.cardDataMap.get('Description'));
    } 
            
    @IsTest
    public static void clientStrategyPositiveTest(){
        List<Account> client = [select id from Account where name ='Google Inc'];    
        
        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getClientStrategy(client[0].id).Data;

        system.assertEquals('Short term goal', result.cardDataMap.get('ShortTermGoal'));
        system.assertEquals('Long term goal', result.cardDataMap.get('LongTermGoal'));
        system.assertEquals('Client Strategy', result.cardDataMap.get('Description'));
    } 

    @IsTest
    public static void csiRatingPositiveTest(){
        List<Account> client = [select id from Account where name ='Google Inc']; 
        
        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getCSIRating(client[0].id).Data;
        
        system.assertEquals('3', result.cardDataMap.get('Rating'));
        system.assertEquals('At Risk', result.cardDataMap.get('Description'));
                
        //CSI Ratings Per Division
		system.assertEquals('1', result.cardDataMap.get('TPSRating'));
        system.assertEquals('TPS Comment', result.cardDataMap.get('TPSComment'));             
        system.assertEquals('At Risk', result.cardDataMap.get('TPSDescription'));     
        
		system.assertEquals('7', result.cardDataMap.get('GMRating'));
        system.assertEquals('GM Comment', result.cardDataMap.get('GMComment'));             
        system.assertEquals('Indifferent', result.cardDataMap.get('GMDescription')); 
        
		system.assertEquals('8', result.cardDataMap.get('IBRating'));
        system.assertEquals('IB Comment', result.cardDataMap.get('IBComment'));             
        system.assertEquals('Satisfied', result.cardDataMap.get('IBDescription'));                   
    } 
 
    @IsTest
    public static void getCSIRatingAtRisk(){
        List<Account> client = [select id from Account where name ='Google Asia'];    

        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getCSIRating(client[0].id).Data;
	    system.assertEquals('At Risk', result.cardDataMap.get('Description')); 
    }      

    @IsTest
    public static void getCSIRatingIndifferent(){
        List<Account> client = [select id from Account where name ='Google Latin America'];    

        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getCSIRating(client[0].id).Data;
		system.assertEquals('Indifferent', result.cardDataMap.get('Description')); 
    }   
    
    @IsTest
    public static void getCSIRatingSatisfied(){
        List<Account> client = [select id from Account where name ='Google Europe'];    

        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getCSIRating(client[0].id).Data;
		system.assertEquals('Satisfied', result.cardDataMap.get('Description')); 
    } 
    
    @IsTest
    public static void relationshipStatusPositiveTest(){
        List<Account> client = [select id from Account where name ='Google Inc'];   
        
        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getRelationshipStatus(client[0].id).Data;
        system.assertEquals('Trusted Advisor', result.cardDataMap.get('Status'));
	} 

    @IsTest
    public static void relationshipStatusNegativeTest(){
        List<Account> client = [select id from Account where name ='Yahoo'];    

        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getRelationshipStatus(client[0].id).Data;
		system.assertEquals('None', result.cardDataMap.get('Status')); 
        system.assertEquals('None', result.cardDataMap.get('Description'));
    }   

 	@IsTest
    public static void getSectorAndSubSubsectorTest(){
        List<Account> client = [select id from Account where name ='Google Inc'];   
        
        CI_CardMapModel result = (CI_CardMapModel)CI_ClientOverviewController.getSectorAndSubSubsector(client[0].id).Data;
        system.assertEquals('Consumer', result.cardDataMap.get('Sector'));
     	system.assertEquals('Sugar', result.cardDataMap.get('Subsector'));         
	}     
}