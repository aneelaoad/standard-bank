/**
 * 
 * @description MallEmailTemplateContentTest
 * @author Ankit Kumar
 * @since
 */
@isTest
public with sharing class MallEmailTemplateContentTest {
    
    @IsTest
    static void testMallEmailTemplateContent(){
        Test.startTest();
        MallEmailTemplateContent mallEmailTemplateContentRec = new MallEmailTemplateContent();
        mallEmailTemplateContentRec.rowNumber = 1;
        mallEmailTemplateContentRec.newContents = new List<mallEmailTemplateContent.MallNewContent>();
        MallEmailTemplateContent.MallNewContent m = new mallEmailTemplateContent.MallNewContent();
        m.imageUrl = 'test';
        m.name = 'test';
        m.navUrl = 'test';
        mallEmailTemplateContentRec.newContents.add(m);
        MallEmailTemplateContent content = MallEmailTemplateContent.parse(System.JSON.serialize(mallEmailTemplateContentRec));
        Assert.areNotEqual(null, mallEmailTemplateContentRec, 'should not be null');
        Assert.areNotEqual(null, content, 'should not be null');
        Test.stopTest();
    }
}