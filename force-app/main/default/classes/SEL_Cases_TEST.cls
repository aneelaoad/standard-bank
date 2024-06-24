/**
 * SEL_Cases test class
 *
 * @author Kyle Cockcroft (kcockcroft@deloitte.co.za)
 * @date 2019-04-24
 * @description Test Class for SEL_Cases
 * 
 *****************************************************************************************
 *   @ Last Modified By  :   Maham Hassan
 *   @ Last Modified On  :   08/04/2022
 *   @ Last Modified Reason  : Updated this class to update the coverage required for 
 *                              deployment
 *
 *****************************************************************************************
 */
@isTest
private class SEL_Cases_TEST {

    private static final Integer RECORD_COUNT = 10;

    @TestSetup
    static void setupData() {

        System.runAs((User) new BLD_USER('asddaw@exampe.com').useSysAdmin().getRecord()) {

            List<case> caseList=new List<case>();
            RecordType recordType=[select id from Recordtype where sobjectType='Case' and DeveloperName='CCC_Angola'];
            for(Integer i=0;i<RECORD_COUNT;i++) {
                Case caseRecord=new Case();
                caseRecord.RecordTypeId=recordType.Id;
                caseRecord.Resolution_Comment__c='Test Resolution Comments'+i;
                caseRecord.Next_Steps__c='Test Next Step'+i;
                caseRecord.Status='New' ;
                caseRecord.origin='Phone';
                caseRecord.Notification__c = 'Unread Email';
                caseRecord.CCC_Angola_Category__c='Car Loan';
                caseRecord.CCC_Angola_Sub_Category__c='Balance, Statements and Complementary Information';
                caseRecord.Type='Query';
                caseRecord.Subject='Test Multiple Contact';
                caseRecord.Description='Test Multiple Contact';
                caseRecord.SuppliedEmail='test@gm.com';
                caseList.add(caseRecord);
            }
            insert caseList; 
        }
    }

    @IsTest
    private static void testSelectByNotification() {
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Angola').getRecordTypeId();
        Test.startTest();
        List<Case> cases  = new SEL_Cases().selectByNotification(false, 'Unread Email', recTypeId);
        Test.stopTest();
        System.assertEquals(RECORD_COUNT, cases.size(), 'Number of Cases should be 10');
    }
    
    @IsTest
    private static void testSelectorMethods() {
        User testUser = (User) new BLD_USER().useSysAdmin()
            .businessUnit(DMN_User.BU_BRANCH)
            .userTeam(DMN_User.TEAM_BELAS)
            .commitWork()
            .getRecord();
        System.runAs(testUser) {
            List<Case> allCases = new List<Case>();
            Set<Id> allIds = new Set<Id>();
            List<Case> caseRecord = [SELECT Id, AccountId, Subject, CCC_Angola_Branch_Name__c FROM Case WHERE SuppliedEmail='test@gm.com' LIMIT 1];
            caseRecord[0].Resolution_Comment__c='Test Resolution Comments';
            caseRecord[0].Next_Steps__c='Test Next Step';
            caseRecord[0].origin='Branch';
            caseRecord[0].CCC_Angola_Branch_Name__c='Belas';
            update caseRecord[0];
            allIds.add(caseRecord[0].Id);
            Test.startTest();
            SEL_Cases selector = new SEL_Cases();
            allCases = selector.selectById(allIds);
            selector.selectByParentCaseId( caseRecord[0].Id);
            selector.selectByCaseId(caseRecord[0].Id);
            selector.selectTheCaseById(caseRecord[0].Id);
            selector.mergeCase( caseRecord[0].Id);
            selector.mergeMultipleCase(caseRecord);
            selector.selectCasesByids(new Set<Id> {caseRecord[0].Id});
            selector.selectCasesByAccountIds(new Set<Id> {caseRecord[0].AccountId});
            selector.selectCasesByCondition(String.valueOf(caseRecord[0].AccountId), caseRecord[0].Subject, caseRecord[0].Id );
            Test.stopTest();
            System.assertEquals(1, allCases.size(), 'Number of Cases should be 1');
        }
    } 

    @IsTest
    private static void shouldReturnCaseByEmailSubject(){
        SEL_Cases.newInstance().selectBySuppliedEmailAndSubject(new Set<String>(),new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(true, result.getCondition().containsIgnoreCase('SuppliedEmail in :emailsSet AND Subject =: SubjectSet'));
    }
    
/**
* @description  : OneHub - MySupport Tab related component
* User Story : SFP-4835
*/
    @isTest
    private static void shouldReturnCaseBySubject(){
        SEL_Cases.newInstance().selectBySubject(new Set<String>());
        SEL_Cases.newInstance().selectCasesBySubject(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(true, result.getCondition().containsIgnoreCase('Subject =: SubjectSet'));
    }

    
}