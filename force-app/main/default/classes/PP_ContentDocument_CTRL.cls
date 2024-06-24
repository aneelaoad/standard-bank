/**
* @description  : Partner Portal Content Document Controller
* User Story : SFP-4873
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Aug 2021
*/
public without sharing class PP_ContentDocument_CTRL {

    /**
    * @description | Used to Insert Public Files.
    * User Story : SFP-4873
    * @param contentDocumentIds content document ids
    * @param linkedEntityId linked entity ids
    **/
    @AuraEnabled
    public static void insertPublicFiles(String[] contentDocumentIds, String linkedEntityId) {

        List<ContentDocumentLink> updatedCdlList = new List<ContentDocumentLink>(); 

        try {
            List<ContentDocumentLink> cdlList = [
                SELECT 
                    Id,
                    Visibility,
                    ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE 
                    ContentDocumentId IN :contentDocumentIds
                    AND LinkedEntityId =: linkedEntityId
            ];

            for(ContentDocumentLink cdl : cdlList) {
                cdl.Visibility = 'AllUsers';
                updatedCdlList.add(cdl);  
            }


            if(!updatedCdlList.isEmpty()) {
                update updatedCdlList;
            }
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage());
        }
    }

    public class CustomException extends Exception { }
}