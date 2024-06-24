/* @Class Name   : NewEventRedirectPageExtTest
 * @Description  : Test class for the NewEventRedirectPageExt class
 * @Created By   : Vishnu Teja V
 * @Created On   : 27 May 2015
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * @Vishnu Teja V         27 May 2015               Created
 * ---------------------------------------------------------------------------------------------------
*/
@isTest
private class NewEventRedirectPageExtTest {
    
    @IsTest
    static void scenario1(){
        try {
            ApexPages.StandardController stdController;
            NewEventRedirectPageExt cont = new NewEventRedirectPageExt(stdController);
            PageReference p = cont.redirect();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void scenario2(){
        try {
            ApexPages.StandardController stdController;
            NewEventRedirectPageExt cont = new NewEventRedirectPageExt(stdController);
            PageReference pageRef = Page.NewEventRedirectPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getParameters().put('retUrl','/something');
            pageRef = cont.redirect();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void scenario3(){
        try {
            ApexPages.StandardController stdController;
            NewEventRedirectPageExt cont = new NewEventRedirectPageExt(stdController);
            Account accRec = (Account) new BLD_Account().useChild().commitWork().getRecord();
            PageReference pageRef = Page.NewEventRedirectPage;
            Test.setCurrentPage(pageRef);
            String accId = String.valueOf(accRec.Id).substring(0, 15);
            ApexPages.CurrentPage().getParameters().put('retUrl','/' + accId );
            pageRef = cont.redirect();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void scenario4(){
        try {
            ApexPages.StandardController stdController;
            NewEventRedirectPageExt cont = new NewEventRedirectPageExt(stdController);
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            Opportunity oppRec = (Opportunity) new BLD_Opportunity(uow)
                    .client(new BLD_Account(uow).useChild())
                    .getRecord();
            uow.commitWork();
            PageReference pageRef = Page.NewEventRedirectPage;
            Test.setCurrentPage(pageRef);
            String oppId = String.valueOf(oppRec.Id).substring(0, 15);
            ApexPages.CurrentPage().getParameters().put('retUrl','/' + oppId );
            pageRef = cont.redirect();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void scenario5(){
        try {
            ApexPages.StandardController stdController;
            NewEventRedirectPageExt cont = new NewEventRedirectPageExt(stdController);
            Campaign camp = (Campaign) new BLD_Campaign().commitWork().getRecord();
            PageReference pageRef = Page.NewEventRedirectPage;
            Test.setCurrentPage(pageRef);
            String campId = String.valueOf(camp.Id).substring(0, 15);
            ApexPages.CurrentPage().getParameters().put('retUrl','/' + campId );
            pageRef = cont.redirect();
        }
        catch(Exception ex)  {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void scenario6(){
        try {
            ApexPages.StandardController stdController;
            NewEventRedirectPageExt cont = new NewEventRedirectPageExt(stdController);
            Case caseRec = (Case) new BLD_Case().useChangeRequest().commitWork().getRecord();
            PageReference pageRef = Page.NewEventRedirectPage;
            Test.setCurrentPage(pageRef);
            String caseId = String.valueOf(caseRec.Id).substring(0, 15);
            ApexPages.CurrentPage().getParameters().put('retUrl','/' + caseId);
            pageRef = cont.redirect();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void scenario7(){
        try {
            ApexPages.StandardController stdController;
            NewEventRedirectPageExt cont = new NewEventRedirectPageExt(stdController);
            Contact conRec = (Contact) new BLD_Contact().useClientContact().commitWork().getRecord();
            PageReference pageRef = Page.NewEventRedirectPage;
            Test.setCurrentPage(pageRef);
            String conId = String.valueOf(conRec.Id).substring(0, 15);
            ApexPages.CurrentPage().getParameters().put('retUrl','/' + conId + '?nooverride=1');
            pageRef = cont.redirect();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}