@isTest
private class SEL_CallReportAttendees_Test {

    @IsTest
    static void selectByIdTest() {        
        SEL_CallReportAttendees.newInstance().selectById(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Passed');
    }

    @IsTest
    static void selectByContactIdTest() {
        SEL_CallReportAttendees.newInstance().selectByContactId(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Contact_id__c IN :contactIds'), 'Passed');
    } 

    @IsTest
    static void selectByEventIds() {
        SEL_CallReportAttendees.newInstance().selectByEventIds(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Call_Report__c IN :eventIds'), 'Passed');
    }
    
    @IsTest
    static void selectByContactIdAndStatusTest() {
        SEL_CallReportAttendees.newInstance().selectByContactIdAndStatus(new Set<Id>(), null, null);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Contact_id__c IN :contactIds AND (Status__c = :invited OR Status__c = :attended)'), 'Passed');
    }

    @IsTest
    static void shouldGetSObjectFieldList() {
        SEL_CallReportAttendees selector = new SEL_CallReportAttendees();
        List<SObjectField> result = selector.getSObjectFieldList();
        Assert.areNotEqual(null, result, 'Passed');
    }
}