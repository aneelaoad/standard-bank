/***************************************
Created By: Abhishek V
Created on: 06/07/2016
Description: To test US - 1379: Class to redirect Event report based on Record type

Modified By: Abhishek V
Modified on: 02/12/2016
Description: Included test cases for US: 1695
********************************************/
@IsTest
public without sharing class EventReport_Navigate_Test{

    public static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
    public static Map<String, Schema.RecordTypeInfo> eventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
    public static Id nbacMeetingRtId = eventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getEnvironmentVariable()
        });
    }

    @IsTest
    static void newERscenario1(){
        ApexPages.StandardController stdController;
        EventReport_Navigate cont = new EventReport_Navigate(stdController);
        cont.navigateNew();
        ApexPages.CurrentPage().getParameters().put('RecordType', nbacMeetingRtId);
        cont.navigateNew();
        List<Recordtype> errtlst = [Select ID, Name, Description from RecordType where SobjectType = 'Call_Report__c'];
        System.assertEquals(cont.rtlstdetails.size(),errtlst.size());
        cont.continuemethod();
        cont.selectedRT = 'Meeting';
        cont.continuemethod();
    }

    @IsTest
    static void shouldGetOnlyOneRt(){
        User testUser = (User) new BLD_User('testNameShouldGetOnlyOneRt@test.com').useCib().commitWork().getRecord();
        System.runAs(testUser){
            Test.startTest();
            ApexPages.StandardController stdController;
            EventReport_Navigate cont = new EventReport_Navigate(stdController);
            cont.navigateNew();
            System.assertEquals(cont.rtlstdetails.size(),1);
            Test.stopTest();
        }
    }

    @IsTest
    static void newERscenario2(){

        ApexPages.StandardController stdController;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild();
        uow.commitWork();

        //Setting the ContactSequenceList page as a test page for the test class
        PageReference pageRef = Page.EventReport_New_Navigate;
        Test.setCurrentPage(pageRef);

        //passing parameters for the url
        String accId = String.valueOf(accBld.getRecordId()).substring(0,15);
        ApexPages.currentPage().getParameters().put('retUrl','/' + accId );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try{
            EventReport_Navigate cont = new EventReport_Navigate(stdController);
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void viewERscenario1(){

        Call_Report__c cr = new Call_Report__c();
        cr.Subject__c = 'TestRedirection';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = nbacMeetingRtId;
        insert cr;

        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ApexPages.StandardController stdController;
            EventReport_Navigate cont = new EventReport_Navigate(stdController);
            PageReference pageRef = Page.EventReport_View_Navigate;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getParameters().put('id', cr.Id);
            String url = cont.navigateViewURL;
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void viewERscenario2(){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Call_Report__c;
        String keyPrefix = d.getKeyPrefix();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld = new BLD_Account(uow).useChild();
        uow.commitWork();

        Call_Report__c cr = new Call_Report__c();
        cr.Subject__c = 'TestRedirection';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'Core Client Team Meeting';
        cr.Relate_to_Client__c = accBld.getRecordId();
        insert cr;

        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ApexPages.StandardController stdController;
            EventReport_Navigate cont = new EventReport_Navigate(stdController);
            PageReference pageRef = Page.EventReport_View_Navigate;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getParameters().put('id', cr.Id);
            ApexPages.CurrentPage().getParameters().put('retUrl','/'+keyPrefix);
            String url = cont.navigateViewURL;
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void editERscenario1(){

        Call_Report__c cr = new Call_Report__c();
        cr.Subject__c = 'TestRedirection';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = nbacMeetingRtId;
        insert cr;

        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ApexPages.StandardController stdController;
            EventReport_Navigate cont = new EventReport_Navigate(stdController);
            PageReference pageRef = Page.EventReport_Edit_Navigate;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getParameters().put('id', cr.Id);
            cont.navigateEdit();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void editERscenario2(){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Call_Report__c;
        String keyPrefix = d.getKeyPrefix();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld = new BLD_Account(uow).useChild();
        uow.commitWork();

        Call_Report__c cr = new Call_Report__c();
        cr.Subject__c = 'TestRedirection';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'Core Client Team Meeting';
        cr.Relate_to_Client__c = accBld.getRecordId();
        insert cr;

        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ApexPages.StandardController stdController;
            EventReport_Navigate cont = new EventReport_Navigate(stdController);
            PageReference pageRef = Page.EventReport_Edit_Navigate;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getParameters().put('id', cr.Id);
            ApexPages.CurrentPage().getParameters().put('retUrl','/'+keyPrefix);
            cont.navigateEdit();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown);
    }

}