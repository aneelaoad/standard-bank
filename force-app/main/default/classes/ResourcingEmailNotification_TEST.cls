/**
 * @description Test class for ResourcingEmailNotification class
 */
@IsTest
public with sharing class ResourcingEmailNotification_TEST {

    @IsTest
    static void shouldScheduleJob() {
        Set<String> roleNames = new Set<String>{'CIB_Global_IB_Division'};
        List<SEL_Resourcing.AggregateResultWrapper> aggregateMock = new List<SEL_Resourcing.AggregateResultWrapper>{
          new SEL_Resourcing.AggregateResultWrapper(new Map<String, Object>{
                  'Resource__c' => fflib_IDGenerator.generate(User.SObjectType)
          })
        };
        ResourcingEmailNotification scheduleInstance = new ResourcingEmailNotification(roleNames, 16, 1);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Resourcing selResourcing = (SEL_Resourcing) mocks.mock(SEL_Resourcing.class);

        mocks.startStubbing();
        mocks.when(selResourcing.sObjectType()).thenReturn(Resourcing__c.SObjectType);
        mocks.when(selResourcing.selectByWeekEndDateAndRolesGroupByResource(UTL_Resourcing.getLastWeekFridayDate(), UTL_Role.getInternalSubordinateRolesIds(roleNames))).thenReturn(aggregateMock);
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selResourcing);

        Test.startTest();
        System.schedule(ResourcingEmailNotification.JOB_NAME + '_TEST', ResourcingEmailNotification.CRON_EXPR, scheduleInstance);
        Test.stopTest();
        System.assertEquals(1, [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE ApexClass.Name = :ResourcingEmailNotification.class.getName()
                AND Status = 'Queued'
        ]);
    }
}