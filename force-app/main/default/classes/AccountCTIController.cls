/***
@ Func Area     	:  CTI Softphone Integration
@ Author        	:  Created by Nocks Mulae
@ Date          	:  06.11.2019
@ User Story        :  US-4459 Implementing Thinkconnect CTI softphone 
@ Description 	    :  Invokes account ID recieved in URL
***/

public with sharing class AccountCTIController
{  
    /*
@Decription : this class gets the ID parameter set from the URL and tries to find the account record
*@param :RecordID use for account ID 
*/
 

 /*
* Redirect to a contact related account. The parameters are sent by thinkConnect
*/
    public Class AccountCTIControllerException extends Exception{}
    public PageReference redirectToAccount()
    {
        
        String recordIdString = ApexPages.currentPage().getParameters().get('recordId');
        String[] recordIds = String.isNotEmpty(recordIdString)? 
            recordIdString.split(';')
            :new List<String>();
        try{
            // 1 - If there are no records, just show a blank page
            if(recordIds.isEmpty())
            {
                throw new AccountCTIControllerException('there are no records');
            }
            
            
            // 2 - There is no control of multiple results; redirect to the first found contact account returned by getAccount
            return new ApexPages.StandardController(
                new Account( 
                    Id = getAccount(recordIds[0])
                )
            ).view();
        }
        catch(Exception ex){
            //Eric requested to be a case created when account not found
            return new PageReference('/lightning/o/Case/new?nooverride=1&useRecordTypeCheck=1&navigationLocation=MRU_LIST&backgroundContext=%2Flightning%2Fo%2FCase%2Flist%3FfilterName%3DRecent');
        }
        
    }
    
    /**
* Find and return to contact related account. If multiple records are found, return the most recent
**/
    @AuraEnabled
    public static Id getAccount(Id recordId)
    {
        // 1 - Look for the related accounts
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id =:recordId ORDER BY CreatedDate DESC];
        
        if(contacts.isEmpty())
        {
            return null;
        }
        
        return contacts[0].AccountId;
    }
}