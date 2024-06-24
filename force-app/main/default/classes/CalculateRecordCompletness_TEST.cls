/**
 * @description       : 
 * @author            : Derek Hughes
 * @group             : 
 * @last modified on  : 20-09-2022
 * @last modified by  : Derek Hughes
**/
@isTest
public with sharing class CalculateRecordCompletness_TEST {
    
    public static final String 
        TEST_ACCOUNT_NAME = 'Test Account Name',
        COMMERCIAL_AFRICA_TYPE  = 'Commercial_Banking_Africa_Regions';

    public static List<Account> accounts;

    private static void getAccounts() {
        String query = 'Select RecordType.Name ';
        for(Schema.SObjectField fld: Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().values()){
            query = query + ', ' + fld.getDescribe().getName() + ' ';
        }
        query = query + 'from Account';
        accounts  = Database.query(query);
    }

    @testSetup
    private static void setup(){
    
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        ABS_ObjectBuilderBase accBld = new BLD_Account(uow)
            .name(TEST_ACCOUNT_NAME)
            .useCommB()
            .useGroupParent()
            .addContact(new BLD_Contact(uow)
                .useClientContact()
            )
            .commitWork();
    }

    @isTest
	public static void testAccountRecCompleteness() {
		getAccounts();

        Account testAccount = accounts.get(0);
        Map<Id, Account> accountMap =  new Map<Id,Account>(accounts);
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(COMMERCIAL_AFRICA_TYPE).getRecordTypeId();
        testAccount.Completeness_Score__c = 0.0;
        testAccount.Missing_Fields__c = '';
        testAccount.Missing_Sections__c = '';
        testAccount.Missing_Related_Records__c = '';

		Test.startTest();
            CalculateRecordCompleteness.updateRecordCompletenessScore(testAccount, Record_Completeness_RR_Helper.getRelatedRecord(accountMap.keySet(), accountMap).get(accounts.get(0)));
        Test.stopTest();

        System.assert(testAccount.Completeness_Score__c >0, 'Score not calculated');
    }
	

}