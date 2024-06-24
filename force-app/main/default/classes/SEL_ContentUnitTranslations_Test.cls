/**
 * 
 * @description Test class for SEL_ContentUnitTranslations
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public with sharing class SEL_ContentUnitTranslations_Test {
    /**
     * 
     * @description testContentUnitTranslationsSelector
     */
    @isTest
    public static void testContentUnitTranslationsSelector() {
        Test.startTest();

        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
        cut.Text__c = 'Example cut text';
        cut.RichText__c = 'Example cut rich text';
        cut.Title__c = 'Example cut title';
        cut.Image_Url__c = 'Example cut image url';

        insert cut;

    	List<Content_Unit_Translation__c> cutLst1 = SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition('ID != NULL');
        List<Content_Unit_Translation__c> cutLst2 = SEL_ContentUnitTranslations.newInstance().selectByIds(new Set<Id>{(Id)cut.Id});
        Assert.areEqual(1, cutLst1.size(),'1 ContentUnitTranslations created');
        Assert.areEqual(1, cutLst2.size(),'1 ContentUnitTranslations created');
        Test.stopTest();
	}
}