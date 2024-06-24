/*************************************************************************
@ Author        : Rinkita Patil
@ Date          : May 2019
@ Description   : US-3886:Angola - Phase 4A | Adding "Search" within the Case Record
Test Class for MergeCaseController
*************************************************************************/
@isTest
public class MergeCaseControllerTest {
    
    @testSetup static void setupData() {
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            List<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().useChild().name(DMN_Account.STANDARD_BANK_EMPLOYEES).getRecord()};
            insert olstTestAccount;
            
            List<case> caseList=new List<case>();
            RecordType recordType=[select id from Recordtype where sobjectType='Case' and DeveloperName='CCC_Angola'];
            for(Integer i=0;i<10;i++) {
                Case caseRecord=new Case();
                caseRecord.RecordTypeId=recordType.Id;
                caseRecord.Resolution_Comment__c='Test Resolution Comments'+i;
                caseRecord.Next_Steps__c='Test Next Step'+i;
                caseRecord.Status='New' ;
                caseRecord.origin='Phone';
                caseRecord.CCC_Angola_Category__c='Car Loan';
                caseRecord.CCC_Angola_Sub_Category__c='Balance, Statements and Complementary Information';
                caseRecord.Type='Query';
                caseRecord.Subject='Test Multiple Contact';
                caseRecord.Description='Test Multiple Contact';
                caseRecord.SuppliedEmail='mergecase@gm.com';
                caseList.add(caseRecord);
            }
            insert caseList; 
            Account accRecord=olstTestAccount[0];
            Contact conRecord=new Contact();
            RecordType recordTypeContact=[select id from Recordtype where sobjectType='Contact' and Name='Bank Contact Record Type'];
            conRecord.FirstName='Contact';
            conRecord.LastName='Test Record';
            conRecord.Phone='12432524';
            conRecord.Email='test@gm.com';
            conRecord.RecordTypeId=recordTypeContact.id;
            conRecord.AccountId=accRecord.id;
            insert conRecord;
        } 
    } 
    @isTest static void fetchLookUpValuesTest(){
        String searchKeyword='Test Multiple Contact'; 
        List<Case> caseList = [SELECT Id,Status,Resolution_Comment__c,Next_Steps__c FROM Case WHERE SuppliedEmail='mergecase@gm.com'];
        String caseId=caseList[0].id;
        //Convert the String value to Id.
        Id currentRecordId=Id.valueOf(caseList[0].id);
        //Get the Object Name.
        String sObjName=currentRecordId.getSObjectType().getDescribe().getName();
        MergeCaseController.fetchLookUpValues(searchKeyword,sObjName,caseList,caseId);
        system.assertEquals(sObjName,'Case');
        system.assertEquals(caseList.size()>0,true);
    }
    @isTest static void getRelatedCase(){
        List<Case> caseList = [SELECT Id,Status,Resolution_Comment__c,Next_Steps__c,suppliedEmail FROM Case WHERE SuppliedEmail='mergecase@gm.com'];
        String caseId=caseList[0].id;
        MergeCaseController.getRelatedCase(caseId);
        system.assertEquals(caseList[0].SuppliedEmail, 'mergecase@gm.com');
    }
    @isTest static void mergeCase(){
        User testUser = (User) new BLD_USER().useSysAdmin()
            .businessUnit(DMN_User.BU_BRANCH)
            .userTeam(DMN_User.TEAM_BELAS)
            .commitWork()
            .getRecord();
        System.runAs(testUser) {
            List<Case> caseList = [SELECT Id,Status,Resolution_Comment__c,Next_Steps__c,SuppliedEmail,ParentId FROM Case WHERE SuppliedEmail='mergecase@gm.com' limit 5];
            List<case> updateCaseList=new List<Case>();
            for(Case caseRecord:caseList){
                caseRecord.Resolution_Comment__c='Test Resolution Comments';
                caseRecord.Next_Steps__c='Test Next Step';
                caseRecord.origin='Branch';
                caseRecord.CCC_Angola_Branch_Name__c='Belas';
                updateCaseList.add(caseRecord);
            }    
            update updateCaseList;
            String parentCaseId=updateCaseList[0].id;
            String childCaseId=caseList[1].id;
            MergeCaseController.mergeCase(parentCaseId,childCaseId);
            system.assertEquals(updateCaseList[0].SuppliedEmail, 'mergecase@gm.com');
            Case caseAssertRec=[select id,status,parentid from case where id=:caseList[1].id];
            system.assertEquals(caseAssertRec.Status, 'Duplicate');
            system.assertEquals(caseAssertRec.ParentID, parentCaseId);
        }
    }
    @isTest static void mergeMultipleCase(){
        User testUser = (User) new BLD_USER().useSysAdmin()
            .businessUnit(DMN_User.BU_BRANCH)
            .userTeam(DMN_User.TEAM_BELAS)
            .commitWork()
            .getRecord();
        System.runAs(testUser) {
            List<Case> caseList = [SELECT Id,Status,Resolution_Comment__c,Next_Steps__c,SuppliedEmail,ParentID FROM Case WHERE SuppliedEmail='mergecase@gm.com' limit 5];
            caseList[0].Resolution_Comment__c='Test Resolution Comments';
            caseList[0].Next_Steps__c='Test Next Step';
            caseList[0].origin='Branch';
            caseList[0].CCC_Angola_Branch_Name__c='Belas';
            update caseList[0];
            String parentCaseId=caseList[0].id;
            List<case> updateCaseList=new List<Case>();
            for(Case caseRecord:caseList){
                caseRecord.Resolution_Comment__c='Test Resolution Comments';
                caseRecord.Next_Steps__c='Test Next Step';
                caseRecord.origin='Branch';
                caseRecord.CCC_Angola_Branch_Name__c='Belas';
                updateCaseList.add(caseRecord);
            }    
            update updateCaseList;
            List<case> childCaseList=new List<Case>();
            For(Integer i=1;i<updateCaseList.size();i++){
                childCaseList.add(updateCaseList[i]);
            }
            MergeCaseController.mergeMultipleCase(parentCaseId,childCaseList);
            system.assertEquals(updateCaseList[0].SuppliedEmail, 'mergecase@gm.com');
            Case caseAssertRec=[select id,status,parentid from case where id in: childCaseList limit 1];
            system.assertEquals(caseAssertRec.Status, 'Duplicate');
            system.assertEquals(caseAssertRec.ParentID, parentCaseId);
        }
    }
}