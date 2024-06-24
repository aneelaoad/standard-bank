/*************************************************************************\
@ Author        :     Shaveen Bageloo
@ Date          :     13 Apr 2011
@ Test File     :     N/A
@description   :     Test Class for Product Inserts / Updates.
@ Last Modified By  :   Caro Reinecke
@ Last Modified On  :   13 Jun 2011
@ Last Modified Reason  :   Renamed according to Standards
Regression - Globalise User Profiles: Tests modified to cater for Trading Product Maturity Date Reminer
functionality.

@ Last Modified By  :   Anand Nancharla
@ Last Modified On  :   17th Aug 2011
@ Modified Reason   :   Code comments whereever Domain_UserName__c is no longer used.
Case C-00000178

@ Last Modified By  : Nitish Kumar
@ Last Modified On  : Feb 2013
@ Modification Description : EN 31 - Used TestDataUtilityClass 
Added Best Practices
API Version moved from 20 to 27  

@Last Modified By   : Abhishek V
@Last Modified on   : 18/11/2015
@Last Modified Reason: Due to a validation inclusion for EN - 0916, it is not possible to add products for a closed opportunity. 

@Last Modified By  : Augustine Chirombo
@Last Modified On  : Sep 13, 2023
@Modification Description : Change the static reference of Record types to new labels 
****************************************************************************/
@isTest(SeeAllData=false)
private class SA_Create_MM_Reminder_Test{
    
    // Get Account Record type Map
    public static Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    // Get the record type id of from the Map based on the Name
    public static Id prospectRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();
    
    public static Map < String, Schema.RecordTypeInfo > mapProductRecordTypes = SB_Product__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    // Get the record type id of from the Map based on the Name
    public static Id singleRiskRecTypeId = mapProductRecordTypes.get('CIB GM Single-Risk').getRecordTypeId();
    
    //Static data Member
    public static list < SB_Product__c > olstSBProduct ;
    public static Integer testDataSize = 20;
    
    @isTest
    public static void testSaCreateMmReminder() {
        
        // Create test user
        User testUser1 = (User) new BLD_USER().useCib().getRecord();
        insert testUser1 ;
        
        System.runAs(testUser1) {
            try {
                Account oTestClient = new Account();
                oTestClient.RecordTypeId = prospectRecTypeId;
                oTestClient.Name = 'Test Client 1'  ;
                oTestClient.BillingStreet = 'Test street 1' ;
                oTestClient.Client_Sector__c = 'Unknown Sector';
                oTestClient.Client_Sub_Sector__c = 'Unknown Sub-Sector';
                oTestClient.Client_Segment__c = 'AB';
                oTestClient.Country_Risk__c = 'India';
                oTestClient.Correspondence_Addr_Line1__c = 'Test Street Line 1' ;
                oTestClient.Correspondence_City__c = 'City';
                oTestClient.Correspondence_Postal_Code__c = '123456';
                oTestClient.Correspondence_Country__c = 'India';
                oTestClient.BillingCountry = 'South Africa';
                oTestClient.BillingCity = 'Durban';
                oTestClient.Client_Co_ordinator__c = UserInfo.getUserID();
                insert oTestClient;
                
                List<Opportunity> opplst = new List<Opportunity>();
                for(Integer i=0; i<testDataSize ;i++){
                    Opportunity opp = new Opportunity();
                    opp.AccountId= oTestClient.Id;
                    opp.Name= 'Opportunity_'+ oTestClient.Name;
                    opp.CloseDate=System.today();
                    opp.StageName='2 - Develop';
                    opp.Reason_Won_Lost_Comments__c = 'Test Lost';
                    opp.Short_Summary__c = 'test opportunity';
                    opp.CurrencyIsoCode = 'ZAR';
                    opp.OwnerId = testUser1.Id;
                    opplst.add(opp);
                }
                insert opplst;
                opplst[0].AccountID = oTestClient.ID;
                update opplst[0];
                
                olstSBProduct = new List<SB_Product__c>();
                for (Integer i = 0; i < 3; i++) {
                    olstSBProduct.add(
                        (SB_Product__c) new BLD_Product()
                        .linkToOpp(opplst[i].Id)
                        .grandParentProduct('Advisory Fees')
                        .getRecord()
                    );
                }
                olstSBProduct[0].RecordTypeId =  singleRiskRecTypeId ;
                olstSBProduct[0].Maturity_Date_Reminder__c =  true ;
                olstSBProduct[0].SA_Maturity_Date__c =  DATE.TODAY().addDays(14) ;
                olstSBProduct[0].Term_Tenor__c = 1;
                olstSBProduct[1].RecordTypeId =  singleRiskRecTypeId ;
                olstSBProduct[1].Maturity_Date_Reminder__c =  true ;
                olstSBProduct[1].SA_Maturity_Date__c = DATE.TODAY().addDays(14) ;
                olstSBProduct[1].Term_Tenor__c = 1;
                olstSBProduct[2].RecordTypeId =  singleRiskRecTypeId ;
                olstSBProduct[2].Maturity_Date_Reminder__c =  true ;
                olstSBProduct[2].SA_Maturity_Date__c =  DATE.TODAY().addDays(14) ;
                olstSBProduct[2].Term_Tenor__c = 1;
                insert olstSBProduct;
            }
            catch (Exception ex) {
                Assert.isTrue(false, ex.getMessage());
            }
        }
    }
}