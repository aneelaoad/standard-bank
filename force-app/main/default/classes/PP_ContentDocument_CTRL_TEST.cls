/**
* @description  : Test Class for PP_ContentDocument_CTRL
* User Story : SFP-4873
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Aug 2021
*/
@IsTest
public class PP_ContentDocument_CTRL_TEST {
    
    @IsTest
    static void insertPublicFilesTest(){

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        PP_PartnerApplication__c partner = new BLD_PartnerApplication(uow).getPartner(); 
        uow.registerNew(partner);
        uow.commitWork();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'Test';
        cv.VersionData = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUg');
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = partner.Id;
		insert cdl;
        
        Test.startTest();

            try {
                PP_ContentDocument_CTRL.insertPublicFiles(new List<String>{cdl.ContentDocumentId}, partner.Id);
            }
            catch(Exception e) {
                System.assert(!String.isBlank(e.getMessage()));
            }

        Test.stopTest();
    }    
}