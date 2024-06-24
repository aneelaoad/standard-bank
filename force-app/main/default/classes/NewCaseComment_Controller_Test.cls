@isTest
private Class NewCaseComment_Controller_Test{

    @IsTest
    static void myUnitTest() {
        
        string comment = 'Test Comment';
        
        Case cs = new Case();
        cs.Status ='New';
        cs.Priority = 'Medium';
        cs.Origin = 'Email';
        cs.Main_Category__c = 'General Management';
        cs.Sub_Category__c = 'Activities Management';
        cs.Subject = 'Test Case';
        cs.Description = 'Test Description';
        insert cs;

        Test.startTest();
        NewCaseComment_Controller.saveCaseComment(cs.id,comment);
        Test.stopTest();

        List<CaseComment> comments = [SELECT Id FROM CaseComment];
        System.assert(!comments.isEmpty());
    }
}