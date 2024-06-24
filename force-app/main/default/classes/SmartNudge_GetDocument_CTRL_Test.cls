/********************************************
* @author  		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
* @date    		: 5 Sept 2023
* @description 	: SFP-28741 - Test class for SmartNudge_GetDocument_CTRL
* *****************************************/
@isTest
public class SmartNudge_GetDocument_CTRL_Test {
        
    @IsTest
    static void shouldGetDocumentUrl() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Documents docSelector = (SEL_Documents) mocks.mock(
            SEL_Documents.class
        );
        Document sampleDocument = (Document) new BLD_Document().mock();
        
        mocks.startStubbing();
        mocks.when(docSelector.sObjectType()).thenReturn(Document.SObjectType);
        mocks.when(
            docSelector.selectByDeveloperName(
                (Set<String>) fflib_Match.anyObject()
            )
        )
            .thenReturn(new List<Document>{ sampleDocument });
        mocks.stopStubbing();
        ORG_Application.selector.setMock(docSelector);
        
        Test.startTest();
        SmartNudge_GetDocument_CTRL  getDocCls = new SmartNudge_GetDocument_CTRL();
        getDocCls.documentName =  sampleDocument.Name;
        String url = getDocCls.documentURL;
        Test.stopTest();
        Assert.areEqual(true, url.contains(sampleDocument.Id),'The shouldGetDocumentLink method did identify the url.');
        
    }
    
    @IsTest
    static void errorWhileGetDocumentURL() {
        Test.startTest();
        SmartNudge_GetDocument_CTRL  getDocCls = new SmartNudge_GetDocument_CTRL();
        getDocCls.documentName = null;
        String url = getDocCls.documentURL;
        Test.stopTest();
        Assert.areEqual(null, url,'return no url');
        
    }
    
    
}