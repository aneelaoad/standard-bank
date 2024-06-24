/*************************************************************************\
@ Author        :     Anurag Jain
@ Date          :     21 June 2011
@ Test File     :     N/A
@description    :     Test Class for Case Inserts / Updates.

@ Last Modified By  :   Anand Nancharla
@ Last Modified On  :   17th Aug 2011
@ Modified Reason   :   Code comments whereever Domain_UserName__c is no longer used.
Case C-00000178

@ Last Modified By  : Nitish Kumar
@ Last Modified On  : 20 Feb 2013
@ Last Modified Reason  : EN 31 - Added best practices to the test class
Used TestdataUtility class
API version moved from 22 to 27  

@ Last Modified By  : Manoj Gupta
@ Last Modified On  : 24 Feb , 2016
@ Last Modified Reason  : EN-1123 CommB - updating support cases for Helpdesk.
Included testHandleICBCandCommBCase  method  

@ Last Modified By      :   Jana Cechova
@ Last Modified On      :   Oct 18, 2016
@ Last Modified Reason  :   US-1643: Duplicate Contact Rules      

@ Last Modified By      :   Raja Kumar
@ Last Modified On      :   April 08, 2022
@ Last Modified Reason  :   SFP-9714 Salesforce not maintaining a Contact record on a case.
	
************************************************************************************/
@IsTest(SeeAllData=false)
public class CaseClassAndTriggerTests{
    
    @IsTest
    static void testCaseTriggerUtility () {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser1 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser2 = (User) new BLD_USER(uow).useCib().getRecord();
        uow.commitWork();
        
        System.runAs(testUser1) {
            Boolean isExceptionThrown = false;
            try {
                Case caseRec = (Case) new BLD_Case().useChangeRequest().commitWork().getRecord();
                caseRec.OwnerId = testUser2.Id;
                update caseRec;
            }
            catch(Exception ex) {
                isExceptionThrown = true;
            }
            System.assert(!isExceptionThrown);
        }
        
    }
    
    @IsTest
    static void testHandleICBCandCommBCase() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        
        String userEmail = 'test123@testorg.com';
        User testUser2 = (User) new BLD_USER(uow).useSysAdmin()
            .cibGlobalArea(DMN_User.CIB_GA_COMMB)            
            .email(userEmail)
            .getRecord();
        
        uow.commitWork();
        
        System.runAs(testUser1) {
            
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .account(accBld)
                .icbcContact(true);
            BLD_Case caseBld = new BLD_Case(uow).useUserCase()
                .account(accBld)
                .contact(conBld)
                .suppliedEmail(userEmail);
            
            uow.commitWork();
            
            
            List<Case> caseRecords = [Select Id,ICBC_Case__c,CommB_Case__c from Case where Id = :caseBld.getRecordId()];
            Assert.isTrue(caseRecords[0].ICBC_Case__c);
            Assert.isFalse(caseRecords[0].CommB_Case__c);
            
            
        }
        
        System.runAs(testUser2) {
            
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .account(accBld)
                .email(userEmail)
                .cifNumber('Aacvb(()nb xs)0');
            
            BLD_Case caseBld = new BLD_Case(uow).useUserCase()
                .account(accBld)
                .contact(conBld)
                .suppliedEmail(userEmail);
            BLD_Case caseBld2 = new BLD_Case(uow).useUserCase()
                .account(accBld)
                .contact(conBld)
                .suppliedEmail('test@icbc.com');
            
            uow.commitWork();
            
            List <Case> caseRecords = [Select Id,CommB_Case__c from Case where Id = :caseBld.getRecordId()];
            System.assertEquals(true, caseRecords[0].CommB_Case__c);
            
            case casRec=[select id,parentId,status,isClosed from case where id = :caseBld2.getRecordId()];
            casRec.parentId=caseBld.getRecordId();
            casRec.Main_Category__c='Accounts';
            casRec.Sub_Category__c='Account New';
            casRec.Status='Closed';
            update casRec;
            Assert.isFalse(casRec.isClosed);
            
        }
        
        //newly added
        System.runAs(testUser1) {
            
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .account(accBld)
                .icbcContact(true);
            BLD_Contact conBld2 = new BLD_Contact(uow).useBankContact()
                .account(accBld)
                .icbcContact(true);
            
            uow.commitWork();
            case cas=new Case();
            RecordType recordType=[select id from Recordtype where sobjectType='Case' and DeveloperName='TPS_Client_Case'];
            
            cas.RecordTypeId=recordType.id;
            cas.Subject='test TPS';
            cas.hContactId__c=string.valueOf(conBld.getRecordId());
            cas.AccountId=accBld.getRecordId();
            cas.OwnerId=testUser2.id;
            cas.Custody_Category__c='Accounts';
            cas.Custody_Sub_Category__c='GC Account Closure';
            insert cas;
            case cas2=new Case();
            cas2.RecordTypeId=recordType.id;
            cas2.Subject='test TPS child';
            cas2.hContactId__c=string.valueOf(conBld.getRecordId());
            cas2.AccountId=accBld.getRecordId();
            cas2.Main_Category__c='Accounts';
            cas2.Sub_Category__c='Account New';
            cas2.Status='Closed';
            cas2.ParentId=cas.id;
            insert cas2;
            cas.subject='New Test Update';
            cas.Main_Category__c='Accounts';
            cas.Sub_Category__c='Account New';
            cas.Status='closed';
            cas.hContactId__c=string.valueOf(conBld2.getRecordId());
            cas.Resolution_Comment__c='Case closed';
            cas.Custody_Category__c='Accounts';
            cas.Custody_Sub_Category__c='GC Account Opening';
            update cas;
            Assert.areEqual(cas.id!=null,true);
        }
        
        
        
    }
    
    @IsTest
    static void testCaseTriggerUtilityAll () {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser2 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();
        
        
        
        System.runAs(testUser1) {
            
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .account(accBld)
                .icbcContact(true);
            BLD_ServiceType serviceTypeBld=new BLD_ServiceType(uow).serviceType('TestServiceTypeName')
                .setRequiredFields();
            BLD_ServiceType serviceTypeBld2=new BLD_ServiceType(uow).serviceType('TestServiceTypeName2')
                .setRequiredFields();
            
            uow.commitWork();
            case cas=new Case();
            RecordType recordType=[select id from Recordtype where sobjectType='Case' and DeveloperName='TPS_Client_Case'];
            
            cas.RecordTypeId=recordType.id;
            cas.Subject='test TPS';
            cas.hContactId__c=string.valueOf(conBld.getRecordId());
            cas.AccountId=accBld.getRecordId();
            cas.OwnerId=testUser2.id;
            cas.Service_Type_Name__c=serviceTypeBld.getRecordId();
            
            insert cas;
            cas.Service_Type_Name__c=serviceTypeBld2.getRecordId();
            try{
                update cas;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('The selected service type does not belong to the support team linked to this case. Please use the manual classification option to classify the case appropriately or search for the correct service type associated to the support team.') ? true : false;
                Assert.isTrue(expectedExceptionThrown);
            }
            
            Assert.areEqual(cas.id!=null,true);
            
        }
        System.runAs(testUser2) {
            
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .account(accBld)
                .icbcContact(true);
            BLD_Contact conBld2 = new BLD_Contact(uow).useBankContact()
                .account(accBld)
                .icbcContact(true);
            
            uow.commitWork();
            case cas=new Case();
            RecordType recordType=[select id from Recordtype where sobjectType='Case' and DeveloperName='TPS_Client_Case'];
            
            cas.RecordTypeId=recordType.id;
            cas.Subject='test TPS';
            cas.hContactId__c=string.valueOf(conBld.getRecordId());
            cas.AccountId=accBld.getRecordId();
            cas.OwnerId=testUser2.id;
            insert cas;
            case cas2=new Case();
            cas2.RecordTypeId=recordType.id;
            cas2.Subject='test TPS child';
            cas2.hContactId__c=string.valueOf(conBld.getRecordId());
            cas2.AccountId=accBld.getRecordId();
            cas2.Main_Category__c='Accounts';
            cas2.Sub_Category__c='Account New';
            cas2.Status='New';
            cas2.ParentId=cas.id;
            insert cas2;
            cas.subject='New Test Update';
            cas.Main_Category__c='Accounts';
            cas.Sub_Category__c='Account New';
            cas.Status='closed';
            cas.hContactId__c=string.valueOf(conBld2.getRecordId());
            cas.Resolution_Comment__c='Case closed';
            try{
                update cas;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot close this case at this stage. Please close all related child cases first') ? true : false;
                Assert.isTrue(expectedExceptionThrown);
            }
        }
    }
}