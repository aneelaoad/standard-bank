@isTest
public class MallProductRangeItemControllerTest {
    
    @IsTest
    static void setPingSessionVariableTest(){
        
        Test.startTest();
        MallProductRangeItemController.setPingSessionVariable();
        // Assertions
        Assert.areEqual(true, Cache.Session.get('pingSessionChecked'));
        Test.stopTest();
        
    }

    @IsTest
    static void setSessionVariablesTest(){
        
        
        MallProductRangeItemController.setSessionVariables(URL.getSalesforceBaseUrl().toExternalForm());
        // Assertions
        Assert.areEqual(URL.getSalesforceBaseUrl().toExternalForm(), Cache.Session.get('lastVisitedPage'));
        Assert.areEqual(true, Cache.Session.get('redirectTolastVisitedPage'));
        MallProductRangeItemController.setSessionVariables(null);
       
        
    }
}