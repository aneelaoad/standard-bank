/***************************************************************************************
@Author            : Dayakar
@Date              : 11-12-2022
@Name of the Class : AOB_SRV_CreateContract
@description       : Class for Calling Create Contract API and getDocument API	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_SRV_CreateContract{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_CreateContract');
    private static final String CONTENTTYPE = 'application/pdf';
	private static final String LINK = '/servlet/servlet.FileDownload?file=';
	private static final String NAME = 'Document.pdf';

    /**
    * @description	used to Call the Contract API 
    * @param applicationId
    * @return Integer
    */
    @AuraEnabled
    public static Integer callContractAPI(String applicationId){
        try{
        String totalResponse;
        AOB_Application__c applicationRec = [select id,name,AOB_inflightData__c,AOB_SalesObjectId__c from AOB_Application__c where id=:applicationId];
        AOB_API_CreateContract customerServiceCall = new AOB_API_CreateContract(applicationRec.AOB_SalesObjectId__c);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CreateContract.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        if(customerServiceCall.getResponseStatusCode()==200){
            Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
            String appData=JSON.serialize(responseData.get(AOB_Constants.CONTRACTS));
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            Map<String, Object> jsonMAp ;
            if(String.isBlank(apps[0].AOB_inflightData__c)){
                jsonMAp = new Map<String, Object>();
                jsonMap.put(AOB_Constants.CONTRACT_DOCUMENT,appData);
                apps[0].AOB_inflightData__c='{"'+apps[0].AOB_CurrentScreen__c+'":'+appData+'}';
            }
            else{ 
                jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                jsonMap.put(AOB_Constants.CONTRACT_DOCUMENT,System.JSON.deserializeUntyped(appData));
                apps[0].AOB_inflightData__c='';
                for(String screen:jsonMAp.keyset()){
                    if(String.isblank(apps[0].AOB_inflightData__c)){
                        apps[0].AOB_inflightData__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+'}';
                    }
                    else {
                        String str=apps[0].AOB_inflightData__c.SubStringAfter('{');
                        apps[0].AOB_inflightData__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+','+str;
                    }
                }
            } 
            update apps;
            List<AOB_Application__c> aobapplication=[select id, AOB_inflightData__c,AOB_Retry_Count__c,AOB_Client__r.Name,AOB_ProcessId__c,AOB_SalesObjectId__c,AOB_InflightDataID__c from AOB_Application__c where id =:applicationId];
            aobapplication[0].AOB_Retry_Count__c=0;
            update aobapplication;   
            
        }
         if (customerServiceCall.getResponseStatusCode() != 200) {
            AOB_CTRL_CaseController.createCase(AOB_API_CompanyDetails.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationId);
         }
        return customerServiceCall.getResponseStatusCode();
        }Catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_CreateContract',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
       
    }
   /**
    * @description	used to Call the get Document
    * @param applicationId
    * @param docName
    * @return String
    */
    @AuraEnabled
    public static String callGetDocumentAPI(String applicationId,String docName){
   
        try{
            String totalResponse;
            AOB_API_GetDocument customerServiceCall = new AOB_API_GetDocument(applicationId,docName);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetDocument.SERVICE_NAME);
            customerServiceCall.process(obj);
            if(docName!='600'){
                insert obj;
                totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
                AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
            }
            Blob document = customerServiceCall.getResponseBlobBody();
            String base64Pdf='';
            if (document != null){
                base64Pdf= EncodingUtil.Base64Encode(document);
            }
            return base64Pdf;
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_CreateContract',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
       
    }
}