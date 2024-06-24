/**
 * A test class for the RedirectFromRelatedListToLex class.
 *
 * @author Dyllan Higgins
 * @date January 2021
 */
@IsTest
public class RedirectFromRelatedListToLex_Test {
    
    @IsTest
    static void shouldRedirect(){
        
        String partialExpectedUrl = '/one/one.app?source=aloha#';
        String expectedParamSource = 'aloha';
        
        Account obj = new Account(Name='RD_Test1');
        insert obj;
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);

        RedirectFromRelatedListToLex instance = new RedirectFromRelatedListToLex(sc);
		PageReference result;
        Test.startTest();
        result = instance.redirect();
        Test.setCurrentPage(result);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.getUrl());
        System.assert(result.getUrl().contains(partialExpectedUrl));
        System.assertNotEquals(null, result.getParameters().get('Source'));
        System.assertEquals(expectedParamSource, result.getParameters().get('Source'));
    }
    
    @IsTest
    static void shouldRedirectLightning(){
		
		String expectedComponentName = 'redirectLightningComponent';   
        
        Account accObj = new Account(Name='RD_Lightning_Test');
        insert accObj;
        accObj = [SELECT Id FROM Account WHERE Name =: accObj.Name];
        ApexPages.StandardController sc = new ApexPages.StandardController(accObj);
        
        RedirectFromRelatedListToLex rdInstance = new RedirectFromRelatedListToLex(sc);
        rdInstance.componentName = expectedComponentName;
        
        PageReference pageRef;	
        Test.startTest();
        
        PageReference originalPage = new PageReference('/lightning/cmp/');	
        
        Test.setCurrentPage(originalPage);
        ApexPages.currentPage().getParameters().put('parentId', accObj.Id);
        ApexPages.currentPage().getParameters().put('componentName',expectedComponentName);
        
        
        
        pageRef = rdInstance.redirectLightning();
        Test.stopTest();
        
        System.assertEquals(expectedComponentName, rdInstance.componentName);
        System.assertNotEquals(null, pageRef);
        System.assertNotEquals(null, pageRef.getUrl());
        System.assert(pageRef.getUrl().contains(expectedComponentName));
        System.assertNotEquals(null, pageRef.getParameters().get('c__id'));
        System.assertEquals(accObj.Id, pageRef.getParameters().get('c__id'));
        System.assert(pageRef.getRedirect());
        
    }
}