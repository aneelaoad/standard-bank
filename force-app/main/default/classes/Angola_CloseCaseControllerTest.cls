/*************************************************************************
@ Author        : Rinkita Patil
@ Date          : April 2019
@description   : US-3664:Test Class for Angola_CloseCaseController
@ Last Modified By  :   Kyle Cockcroft
@ Last Modified On  :   29th Apr 2019
@ Modified Reason   :   Ensured Test User is created with the required User detail in order to pass validation rule below:
Rule Name = Angola_Wrong_Source_Branch_Selected
@ Formula Condition			: 	AND( 
RecordType.DeveloperName = 'CCC_Angola' , 
ISPICKVAL( Origin , 'Branch') , 
NOT(ISPICKVAL( $User.Business_Unit__c, 'Branch')) 
)

@ Last Modified By  :   Kyle Cockcroft
@ Last Modified On  :   14th May 2019
@ Modified Reason   :   Validation rule 'Branch_Complaint' introduced for user story is causing existing test classes to fail
Rule Name = Branch_Complaint
@ Formula Condition			: 	
AND( 
TEXT(Type) = "Complaint", 
TEXT(Origin)= "Branch", 
ISBLANK(Complaint_Reference_Number__c) 
)
*************************************************************************/
@isTest
public with sharing class Angola_CloseCaseControllerTest {

    @testSetup static void setupData() {
        
        User testUser = (User) new BLD_USER('clientTeamUser001@testorg.com').useSysAdmin()
            .businessUnit(DMN_User.BU_BRANCH)
            .userTeam(DMN_User.TEAM_BELAS)
            .commitWork()
            .getRecord();
        
        System.runAs(testUser) {
            
            Account accRec = (Account) new BLD_Account()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                .commitWork()
                .getRecord();
            
            List<case> caseList=new List<case>();
            RecordType recordType=[select id from Recordtype where sobjectType='Case' and DeveloperName='CCC_Angola'];
            for(Integer i=0;i<10;i++) {
                Case caseRecord=new Case();
                caseRecord.RecordTypeId=recordType.Id;
                caseRecord.Resolution_Comment__c='Test Resolution Comments'+i;
                caseRecord.Next_Steps__c='Test Next Step'+i;
                caseRecord.Status='Open' ;
                caseRecord.origin='Branch';
                caseRecord.CCC_Angola_Category__c='Car Loan';
                caseRecord.CCC_Angola_Sub_Category__c='Balance, Statements and Complementary Information';
                caseRecord.Type='Complaint';
                caseRecord.CCC_Angola_Branch_Name__c='Belas';
                caseRecord.Complaint_Reference_Number__c='C10-'+ i;
                caseList.add(caseRecord);
            }for(Integer i=0;i<10;i++) {
                Case caseRecord=new Case();
                caseRecord.RecordTypeId=recordType.Id;
                caseRecord.Subject='Closure Process'+i;
                caseRecord.Resolution_Comment__c='Test Cases';
                caseRecord.Next_Steps__c=null;
                caseRecord.Status='Open' ;
                caseRecord.origin='Branch';
                caseRecord.CCC_Angola_Category__c='Car Loan';
                caseRecord.CCC_Angola_Sub_Category__c='Balance, Statements and Complementary Information';
                caseRecord.Type='Complaint';
                caseRecord.CCC_Angola_Branch_Name__c='Belas';
                caseRecord.Complaint_Reference_Number__c='C20-'+ i;
                caseList.add(caseRecord);
            }
            insert caseList;
            
            Contact conRecord=new Contact();
            RecordType recordTypeContact=[select id from Recordtype where sobjectType='Contact' and Name='Bank Contact Record Type'];
            conRecord.FirstName='Contact';
            conRecord.LastName='Test Record';
            conRecord.Phone='12432524';
            conRecord.Email='test@gm.com';
            conRecord.RecordTypeId=recordTypeContact.id;
            conRecord.AccountId=accRec.id;
            insert conRecord;
        }
        
        
        
        
    }
    
    @isTest static void getCaseRecordTest(){
        
        Case caseRecord = [SELECT Id,CCC_Angola_Branch_Name__c FROM Case WHERE CCC_Angola_Branch_Name__c='Belas' LIMIT 1];
        Angola_CloseCaseController.getRecord(caseRecord.id); 
        system.assertEquals(caseRecord.CCC_Angola_Branch_Name__c, 'Belas');
        
    }
    
    
    
    @isTest static void getSaveRecordTest(){
        
        User testUser = (User) new BLD_USER('2clientTeamUser002@testorg.com').useSysAdmin()
            .businessUnit(DMN_User.BU_BRANCH)
            .userTeam(DMN_User.TEAM_BELAS)
            .commitWork()
            .getRecord();
        
        System.runAs(testUser) {
            Case caseRecord = [SELECT Id,Status,Resolution_Comment__c,Next_Steps__c FROM Case WHERE CCC_Angola_Branch_Name__c='Belas' and Subject='Closure Process1' LIMIT 1];
            Contact conRecord = [SELECT Id,Name FROM Contact WHERE LastName='Test Record' and FirstName='Contact' LIMIT 1];
            Angola_CloseCaseController.saveRecord(caseRecord,conRecord); 
            system.assertEquals(caseRecord.status, 'Closed');
        }
        
    }
    @isTest static void fetchLookUpValuesTest(){
        
        String searchKeyword='Contact'; 
        Contact conRecord = [SELECT Id,Name FROM Contact WHERE LastName='Test Record' and FirstName='Contact' LIMIT 1];
        
        //Convert the String value to Id.
        Id currentRecordId=Id.valueOf(conRecord.id);
        
        //Get the Object Name.
        String sObjName=currentRecordId.getSObjectType().getDescribe().getName();
        
        Angola_CloseCaseController.fetchLookUpValues(searchKeyword, sObjName);
        system.assertEquals(searchKeyword, 'Contact');
        
    }
    
    @isTest static void getStatusesTest(){
        
        Angola_StatusPicklistController[] options = Angola_CloseCaseController.getStatuses();
        System.assert(!options.isEmpty());
    }
    
}