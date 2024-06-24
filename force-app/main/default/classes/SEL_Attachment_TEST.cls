/*****************************************************************************************
 *@Name of the Class: SEL_Attachment_TEST
 *@Description      : SFP-30097 Test Class for SEL_Attachment
 *@Author           : Likhitha Karusala
 *@Created Date     : Feb 2024
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
@IsTest
public class SEL_Attachment_TEST {
    /**
    * @description shouldSelectById queried by Record Id
    */
	@IsTest
    static void shouldSelectById() {
        
        Account testacc=new Account();
        testacc.name='Test Client';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        
        zafin_rrp__Negotiated_Pricing__c zrnp= new zafin_rrp__Negotiated_Pricing__c();	
        zrnp.zafin_rrp__Agreement_Name__c='testing';
        zrnp.zafin_rrp__Arrangement_Type__c='Fee Arrangement';
        zrnp.zafin_rrp__Reporting_Customer__c=acc.id;
        zrnp.zafin_rrp__Start_Date__c= system.today();
        zrnp.zafin_rrp__End_Date__c= system.today()+30;
        insert zrnp;
        Blob pdfBlob = blob.valueOf('Unit.Test');
        Attachment att = new Attachment(parentId = zrnp.id, name='Client Pricing Letter-V.pdf', Body = pdfBlob);
        insert att;
                
        Test.startTest();
        SEL_Attachment selectorAttachement= new SEL_Attachment();
        selectorAttachement.selectByAttachmentRecordId(att.id ,1);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Id =: attachmentId'),true, 'Query contains Id =: attachmentId');
        
    }
}