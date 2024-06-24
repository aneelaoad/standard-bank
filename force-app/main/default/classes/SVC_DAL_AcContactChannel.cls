/**
 * @description Data access layer for the amazonconnect__AC_ContactChannels__c SObject
 * 
 * @author Accenture
 * @date March 2022
 * 
 **/
public inherited sharing class SVC_DAL_AcContactChannel
{
    /**
      * @description Find the amazonconnect__AC_ContactChannels__c record based on the amazonconnect__ContactId__c
      *
      * @author Accenture
      * @date March 2022
      *
      **/
    @TestVisible
    public static amazonconnect__AC_ContactChannels__c findByContactId(String contactId)
    {
        return [SELECT 
            Id, 
            OwnerId 
          FROM 
            amazonconnect__AC_ContactChannels__c 
          WHERE 
            amazonconnect__ContactId__c = :contactId
        ];    
    }

}