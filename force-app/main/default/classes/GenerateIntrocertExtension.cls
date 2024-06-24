/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : 13. 6. 2016
	@ TestClass		: GenerateIntrocertExtensionTest
	@ Description	: US-1375
****************************************************************************/

public without sharing class GenerateIntrocertExtension {
    
    private Account acc;
    private ApexPages.StandardController stdcont;
    
    public GenerateIntrocertExtension(ApexPages.StandardController stdCont) {
        this.stdCont = stdCont;
        this.acc = (Account) stdCont.getRecord();
    }
    
    public PageReference generateDoc() {
        PageReference doc = Page.IntrocertDocument;
        doc.getParameters().put('id', (String) acc.id); 
        doc.setRedirect(true);
        
        Blob b;
        
        if (Test.isRunningTest()) {
            b = Blob.valueOf('UNIT.TEST');
        } else{
            b = doc.getContent();
        }

        ContentVersion contentVersion = new ContentVersion(Title = 'Introcert.doc', PathOnClient = 'Introcert.doc', VersionData = b);
        insert contentVersion;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = this.acc.id, ContentDocumentId = contentDocumentId,
                ShareType = 'I');
        Database.SaveResult s = Database.insert(contentDocumentLink, false);


        return stdCont.view();
    }
}