/*************************************************************************\
    @ Author        : Nitish Kumar
    @ Date          : 14/01/2013
    @ Test File     : NA
    Function        : Contains all testing for the class AccountTriggerHandler_trgr
    
    @ Audit Trial   : Repeating block for each change to the code
    -----------------------------------------------------------------------------
    @ Last Modified By  : Nitish Kumar 
    @ Last Modified On  :  17/01/13
    @ Last Modified Reason  : Updated version to 27
    
    @ Last Modified By  : Nitish Kumar 
    @ Last Modified On  :  August , 2013
    @ Last Modified Reason  : Improved Code Coverage 
                                      Updated version to 28
    
    @ Last Modified By  :   Nitish Kumar        
    @ Last Modified On  :   January 2014
    @ Last Modified Reason  : EN-226 , Client Sector Update
                              Updated API Version to 29
                              
    @ Last Modified By  :   Abhishek Vaideeswaran        
    @ Last Modified On  : July 2015
    @ Modification Description : DEF-001368(EN - 0769) : To test whether Account owner is added to CCT only if the client record type equals Prospect,Potential (Goldtier), 
                                                         Potential (CIF) and also Onboarding alert mail should be sent for prospect and Potential (Goldtier), 
                                                         Potential (CIF) and Potential Client
                              
    @ Last Modified By  : Vishnu Vundavalli
    @ Last Modified On  : August 2015
    @ Modification Description : EN - 0791 : Renaming of New Personal and Business Banking Entity (Africa Only) to Potential Client and hence removing the reference
    
    @ Last Modified By  :   Abhishek Vaideeswaran        
    @ Last Modified On  : August 2015
    @ Modification Description: EN - 0792 : Renaming of New Corporate and Investment Banking Entity (Africa) to Potential (CIF) and 
                                            New Corporate and Investment Banking Entity (South Africa / International) to Potential (Goldtier)
                                            and hence removing the reference
                                            
    @ Last Modified By  : Manoj Gupta 
    @ Last Modified On  : Oct  2015
    @ Last Modified Reason  : EN-0772 Added Test data for Salesforce to Salesforce sharing method (Updated with Jorel Naidu code from ServCloud Org)  
    
    @ Last Modified By:     Abhishek Vaideeswaran
    @ Last Modified On:     February 2016
    @ Last Modified Reason: EN - 686 : Assigned CIF__c number to all clients for which GCR records are created and also modified 
                            testAccountTriggerFunctionality1, testAccountTriggerFunctionality2, testAccountTriggerFunctionality3 
                            by including separate updates on individual account records to a list and a single update so as to avoid 101 SOQL error
                            
    @ Last Modified By  : Manoj Gupta 
    @ Last Modified On  : July  2016
    @ Last Modified Reason  : US-1348 Adjusted testAccountTriggerFunctionality to fix SOQL 101 queries issue                            
                                          
******************************************************************************/

@isTest(SeeAllData=false)

private class AccountTriggerHandler_trgr_test {
    
//JN: Added to Test Salesforce to Saleforce sharing
    public static testMethod void testAccountS2SShare(){
        List <Account> testAccountList = new List<Account>();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        for (Integer i = 0; i < 5; i++) {
            testAccountList.add((Account) new BLD_Account(uow)
                .CIF('123456' + i)
                .getRecord());
        }
        uow.commitWork();
        
        List <PartnerNetworkRecordConnection> s2sSharerecords = [Select Id from PartnerNetworkRecordConnection where LocalRecordId IN :testAccountList];
      
        System.assert(s2sSharerecords.size()>0);
    }    
}