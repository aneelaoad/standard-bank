/*  Copyright [2018] [salesforce.com]
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

/**
 * @description Creates dummy data for FSC bot flow.
 **/
public with sharing class IBot_DataUtils {

    /**
    * Creates Data for the FSC Bot
    */       
    public static void createFscBotData() {
		sObject[] cardLst = new List<sObject>();
        sObject[] finAccs = new List<sObject>();
        
        
        Account account = createAccountAndContact('Johnson Smith (FscBot)', UserInfo.getUserEmail(), '9999999999');
		
		finAccs.add( createFinancialAccount(account.Id, '896700909192', 'Credit Card',true));		
        
		insert finAccs;
											
        cardLst.add( createCard('Gold Card (FscBot)', account.Id,      finAccs[0].Id ,true ));		
											
        cardLst.add( createCard('Platinum Card (FscBot)', account.Id, finAccs[0].Id, '1111222233334444' ,true));				
      				
		insert cardLst;
    }

    /**
    * Creates Account and its contact
    * @param name - Name of the Account
    * @param email - Email of the Account
    * @param mobile - Phone Number of the Account
    * @return Account - Created Account
    */
    public static Account createAccountAndContact(String name, String email, String mobile) {
        if(isPersonAccountsEnabled()) {
            return createPersonAccountModalData(name, email, mobile);
        }else{
            return createIndividualModalData(name, email, mobile);
        }
    }

    /**
    * Creates Person Account
    * @param name - Name of the Account
    * @param email - Email of the Account
    * @param mobile - Phone Number of the Account
    * @return Account - Created Account
    */        
    public static Account createPersonAccountModalData(String name, String email, String mobile) {
        /*RecordType recordType = [Select Id from RecordType where DeveloperName = 'PersonAccount'  and SobjectType = 'Account'];
        Account account = new Account();
        account.put('LastName', name);
        account.put('PersonEmail', email);
        account.put('PersonMobilePhone', mobile);
        if(recordType != null){
            account.put('RecordTypeId', recordType.id);
        }
        Database.insert(account);

        String soql = 'Select PersonContactId from Account where Id =\'' + account.id + '\'';
        List<Account> accountList = Database.query(soql);
        Account acc = accountList.get(0);
        account.put('FinServ__PrimaryContact__c', acc.get('PersonContactId'));
        update account;

        return account;*/
        return null;
    }

    /**
    * Creates Individual Account
    * @param name - Name of the Account
    * @param email - Email of the Account
    * @param mobile - Phone Number of the Account
    * @return Account - Created Account
    */
    public static Account createIndividualModalData(String name, String email, String mobile) {
        if (Schema.sObjectType.Account.fields.Name.isCreateable() &&
                Schema.sObjectType.Account.fields.RecordTypeId.isCreateable() ){

            RecordType recordType = [Select Id from RecordType where DeveloperName = 'IndustriesIndividual'  and SobjectType = 'Account'];
            Account account = new Account();
            account.Name = name;
            account.Email_Address__c = email;
            account.Phone_Number__c = mobile;
            account.Phone = mobile;
            if(recordType != null){
                account.RecordTypeId = recordType.id;
            }

            insert account;

            if (Schema.sObjectType.Contact.fields.Email.isUpdateable() &&
                    Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable()){
                Contact contact = [Select Id from Contact where AccountId =: account.id];
                contact.Email = email;
                contact.MobilePhone = mobile;

                update contact;

                return account;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access'));
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access'));
            return null;
        }
    }

    /**
    * Creates Financial Account
    * @param accountId - Id of the Account
    * @param accountNumber - Number of the Account
    * @param accountType - Type of the Account
    * @return SObject - Created Account
    */
    public static sObject createFinancialAccount(String accountId, String accountNumber, String accountType) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__FinancialAccount__c');
        sObj.put('Name', 'Credit Card (FscBot)');
        sObj.put('FinServ__PrimaryOwner__c', accountId);
        sObj.put('FinServ__FinancialAccountNumber__c', accountNumber);
        sObj.put('FinServ__FinancialAccountType__c', accountType);

        Database.insert(sObj);

        return sObj;
    }
    /**
    * Creates Financial Account
    * @param accountId - Id of the Account
    * @param accountNumber - Number of the Account
    * @param accountType - Type of the Account
    * @param noInsert - No insert statement if value is true
    * @return SObject - Account Instance
    */
    public static sObject createFinancialAccount(String accountId, String accountNumber, String accountType, Boolean noInsert) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__FinancialAccount__c');
        sObj.put('Name', 'Credit Card (FscBot)');
        sObj.put('FinServ__PrimaryOwner__c', accountId);
        sObj.put('FinServ__FinancialAccountNumber__c', accountNumber);
        sObj.put('FinServ__FinancialAccountType__c', accountType);
        if(!noInsert){
            Database.insert(sObj);
        }
        return sObj;
    }

    /**
   * Creates FinServ__Card__c
   * @param cardName - Name of the Card
   * @param accountId - Email of the Account
   * @param financialAccountId - Phone Number of the Account
   * @param ccnumber - Bin Number
   * @return SObject - Created Card
   */
    public static sObject createCard(String cardName, String accountId, String financialAccountId, String ccnumber) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__Card__c');
        sObj.put('Name', cardName);
        sObj.put('FinServ__AccountHolder__c', accountId);
        sObj.put('FinServ__Active__c', true);
        sObj.put('FinServ__FinancialAccount__c', financialAccountId);
        sObj.put('FinServ__ValidUntil__c', Date.today().addDays(365));
        sObj.put('FinServ__BinNumber__c', Double.valueOf(ccnumber));

        Database.insert(sObj);

        return sObj;
    }
    
     /**
   * Creates FinServ__Card__c
   * @param cardName - Name of the Card
   * @param accountId - Email of the Account
   * @param financialAccountId - Phone Number of the Account
   * @param ccnumber - Bin Number
   * @param noInsert - No insert statement if value is true
   * @return SObject - Created Card
   */
    public static sObject createCard(String cardName, String accountId, String financialAccountId, String ccnumber, Boolean noInsert) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__Card__c');
        sObj.put('Name', cardName);
        sObj.put('FinServ__AccountHolder__c', accountId);
        sObj.put('FinServ__Active__c', true);
        sObj.put('FinServ__FinancialAccount__c', financialAccountId);
        sObj.put('FinServ__ValidUntil__c', Date.today().addDays(365));
        sObj.put('FinServ__BinNumber__c', Double.valueOf(ccnumber));
		if(!noInsert){
        	Database.insert(sObj);
        }

        return sObj;
    }

    /**
    * Creates FinServ__Card__c
    * @param cardName - Name of the Card
    * @param accountId - Email of the Account
    * @param financialAccountId - Phone Number of the Account
    * @return SObject - Created Card
    */
    public static sObject createCard(String cardName, String accountId, String financialAccountId) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__Card__c');
        sObj.put('Name', cardName);
        sObj.put('FinServ__AccountHolder__c', accountId);
        sObj.put('FinServ__Active__c', true);
        sObj.put('FinServ__FinancialAccount__c', financialAccountId);
        sObj.put('FinServ__ValidUntil__c', Date.today().addDays(365));
        sObj.put('FinServ__BinNumber__c', Double.valueOf('1111222233334444'));

        Database.insert(sObj);

        return sObj;
    }
    
    /**
    * Creates FinServ__Card__c
    * @param cardName - Name of the Card
    * @param accountId - Email of the Account
    * @param financialAccountId - Phone Number of the Account
    * @param noInsert - No insert statement if value is true
    * @return SObject - Created Card
    */
    public static sObject createCard(String cardName, String accountId, String financialAccountId, Boolean noInsert) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__Card__c');
        sObj.put('Name', cardName);
        sObj.put('FinServ__AccountHolder__c', accountId);
        sObj.put('FinServ__Active__c', true);
        sObj.put('FinServ__FinancialAccount__c', financialAccountId);
        sObj.put('FinServ__ValidUntil__c', Date.today().addDays(365));
        sObj.put('FinServ__BinNumber__c', Double.valueOf('1111222233334444'));
        if(!noInsert){
            Database.insert(sObj);
        }
        
        return sObj;
    }

    /**
    * Check is Person Account Enabled
    * @return Boolean
    */
    public static Boolean isPersonAccountsEnabled(){
        return Account.SObjectType.getDescribe().hasSubtypes;
    }
}