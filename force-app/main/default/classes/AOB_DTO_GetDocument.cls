/**
* @description  Wrapper Class for get Document API request Body
* @author Dayakar 
* @date Jan 5th 2021
*/
public class AOB_DTO_GetDocument{
    
    /**
    * @description	used to set information related to the get API
    * @param applicationId
    * @param docName
    * @return get document API request Body
    */
    public static AOB_DTO_Document createDocumentResponseBody(String applicationId, String docName){
        AOB_DTO_Document doc= new AOB_DTO_Document();
        String preAppData=getInflight(applicationId,AOB_Constants.PRE_APP_RESPONSE);
        String Docdetails=getInflight(applicationId,AOB_Constants.CONTRACTDOUCUMENT);
        Map<String, Object> PreApplicationResponse = (Map<String, object>) JSON.deserializeUntyped(preAppData);
        List<object> objects = (List<object>)System.JSON.deserializeUntyped(Docdetails);
        doc.guId=(String)PreApplicationResponse.get(AOB_Constants.BUSINESS_BPGUID);
        doc.documentId='0';
        doc.filename='';
        doc.businessFlag='P';
        for(Object o:objects){
            Map<String, Object> m = (Map<String, Object>)o; 
            if((String)m.get('itemId')==docName){    
                doc.contentId=(String)m.get(AOB_Constants.DOCUMENTID);
            }
        }
        return doc;
    }
    
   /**
    * @description	used to set information related to the get API
    * @param appId
    * @param screenName
    * @return inflight data
    */
    public static String getInflight(string appId, string screenName){
        String inflightData;
        List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
        Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
        for(string screen : jsonData.keyset()){
            if(screen == screenName){
                inflightData = System.JSON.serialize(jsonData.get(screen));
            }
        }
        return inflightData;
    }
    
}