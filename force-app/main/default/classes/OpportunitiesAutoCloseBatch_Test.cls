/**
 * A test class for the OpportunitiesAutoCloseBatch class.
 * <br/>US-4657 - SGPRT-827
 *
 * @author Youssef Ibrahim(yibrahim@deloittece.com)
 * @date November 2019
 */
@IsTest
class OpportunitiesAutoCloseBatch_Test {

    @TestSetup
    static void setup() {                        
        List<Opportunity> openOppsLessThan1MonthOld = new List<Opportunity>();
        List<Opportunity> openOppsMoreThan1MonthOld = new List<Opportunity>();
        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();        
        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User busUser = (User) new BLD_USER(uow).useBusinessAdmin().getRecord();        
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }
        uow.commitWork();
        
        system.runAs(busUser){
            for (Integer i = 0; i < 5; i++) {
                Opportunity testOpp = new Opportunity(Name = 'Test-Autoclosed-Opp ' + i, StageName = '1 - Lead', CloseDate = System.today() - 30);
                openOppsLessThan1MonthOld.add(testOpp);
            }
            for (Integer i = 0; i < 5; i++) {
                Opportunity testOpp = new Opportunity(Name = 'Test-Open-Opp ' + i, StageName = '1 - Lead', CloseDate = System.today() - 35);
                openOppsMoreThan1MonthOld.add(testOpp);
            }
            insert openOppsMoreThan1MonthOld;
            insert openOppsLessThan1MonthOld;
        }
    }

    @IsTest
    static void shouldBatchAutoCloseOldOpportunities() {
        Test.startTest();
        OpportunitiesAutoCloseBatch oppAutoCloseBatch = new OpportunitiesAutoCloseBatch();
        Database.executeBatch(oppAutoCloseBatch);
        Test.stopTest();
        List<Opportunity> autoClosedOpps= [SELECT Id, StageName, Reason_Won_Lost_Comments__c, ReasonForWinLossPickList__c, Actual_Close_Date__c
                                            FROM Opportunity
                                            WHERE Name LIKE 'Test-Autoclosed-Opp%'
                                            AND Reason_Won_Lost_Comments__c = 'Auto closed'
                                            AND StageName = 'Cancel'
                                            AND Actual_Close_Date__c = TODAY
                                            AND ReasonForWinLossPickList__c = 'Captured in Error / Duplicate / Expired'];

        List<Opportunity> stillOppenOpps = [SELECT Id, StageName, Reason_Won_Lost_Comments__c, ReasonForWinLossPickList__c, Actual_Close_Date__c
                                            FROM Opportunity
                                            WHERE Name LIKE 'Test-Open-Opp%'
                                            AND StageName = '1 - Lead'];
        System.assertEquals(5, autoClosedOpps.size());
    }
}