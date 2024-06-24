/************************************************************************
* @author       Manoj Gupta 
* @date         Apr -2017
* @description  Test class for ComplaintCase_LDS_ctrl-US-1794
 
************************************************************************/


@IsTest
public class ComplaintCase_LDS_ctrl_Test{

    @TestSetup
    static void prepareData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
            .name('TestAccountLookup')
            .addContact(
                new BLD_Contact(uow)
                    .name('Test ', 'Case Contact')
            );

        new BLD_Case(uow)
            .useClientCase();

        new BLD_ServiceType(uow)
                .setRequiredFields()
                .serviceType('Complaint');

        uow.commitWork();
    }
    
     @IsTest
    static void testinsertcase() {
    
    Test.startTest(); 
        Account foundAccount = [Select Id from Account where Name = 'TestAccountLookup' limit 1];
        Contact foundContact = [Select Id from Contact where LastName = 'Case Contact' limit 1];
        Service_Type__c foundServiceType = [Select Id from Service_Type__c LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        
        ApexPages.currentPage().getParameters().put('accId', foundAccount.Id);
        ApexPages.currentPage().getParameters().put('contId',foundContact.Id );
        ComplaintCase_LDS_ctrl ctrl = new ComplaintCase_LDS_ctrl (sc);
        
        Pagereference pref = ctrl.cancelcase();
       
        ctrl.caserec.AccountId = foundAccount.Id;
        ctrl.caserec.ContactId = foundContact.Id;
        ctrl.caserec.Priority = 'High';
        ctrl.caserec.Subject = 'Client Complaint';
        ctrl.caserec.Origin = 'General Interaction / Face to Face';
        ctrl.caserec.Type= 'Complaint';
        ctrl.caserec.Status= 'New';
        ctrl.caserec.Service_Type_Name__c = foundServiceType.Id;
        ctrl.savecase();
        System.assertEquals(ctrl.errorMsginsert, '');
        System.assertnotEquals(ctrl.navigateurl, '');              
        Pagereference pref1 = ctrl.cancelcase();

    
      
      Test.StopTest();   
    } 

    

        
}