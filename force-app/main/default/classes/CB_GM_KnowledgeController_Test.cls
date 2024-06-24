/**
* Test class for CB_GM_KnowledgeController class
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/
@isTest
public with sharing class CB_GM_KnowledgeController_Test {
    public static final String OBJ_NAME = 'Knowledge__kav';
    public static final String RT_SA_ARTICLE = 'FAQ';
    
    @TestSetup
    static void testSetup(){
        knowledge__kav know = new knowledge__kav();
        know.Title = 'test title';
        know.Info__c = 'test info';
        know.OSB_Country__c = 'South Africa';
        know.url__c = 'test url';
        know.UrlName = 'testUrlName';
        know.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SA_ARTICLE);
        
        Insert Know;
    }
    @IsTest
    static void testMethod1() {
        test.startTest();
        list<Knowledge__kav> knowledgeList = CB_GM_KnowledgeController.getArticles('', 'FAQ');
        system.assert(knowledgeList.size() > 0 );
        test.stopTest();
    }
}