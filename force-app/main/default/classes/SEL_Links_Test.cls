/**
 * 
 * @description Test class for SEL_Links
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public with sharing class SEL_Links_Test {
    /**
     * 
     * @description testLinksSelector
     */
    @isTest
    public static void testLinksSelector() {
        Test.startTest();

        Link__c link  = new Link__c();
        link.Name = 'Example link';
        link.Desktop_Url__c = 'Example link url';
        link.Description__c = 'Example description';
        insert link;

    	List<Link__c> linksLst1 = SEL_Links.newInstance().selectByCustomFilterCondition('ID != NULL');
        List<Link__c> linksLst2 = SEL_Links.newInstance().selectById(new Set<Id>{(Id)link.Id});
        Assert.areEqual(1, linksLst1.size(),'1 link created');
        Assert.areEqual(1, linksLst2.size(),'1 link created');
        Test.stopTest();
	}
}