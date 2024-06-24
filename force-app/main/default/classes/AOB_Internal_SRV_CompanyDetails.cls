/**
* @description : SFP-25090 - Class for generic form creation based on database records
*
* <p></p>
*
* @author Salesforce
*
* @date May h 2021
*/
public with sharing class AOB_Internal_SRV_CompanyDetails {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_FormCreator');
    
    /**
* @description method to call Update company Details API
* @param  applicationId
* @return String
*/
    @AuraEnabled
    public static String updateCompanyDetails(String applicationId){
        try{
            String companydetails;
            String companytradingdetails;
            String companyfinancialdetails;
            String marketingconsents;
            String preApplication;
            String resdentialData;
            String preappResponse;
            String getApplicationProcessDataResponse;
            String businessRegistrationNumber;
            String businessRegistrationType;
            
            getApplicationProcessDataResponse=AOB_CTRL_FormCreator.getInflight(applicationId,'getApplicationProcessDataResponse'); 
            if(getApplicationProcessDataResponse != null){
            Map < String, Object > cdfields = (Map < String, object > ) JSON.deserializeUntyped(getApplicationProcessDataResponse);
            String  businessDetails=Json.serialize(cdfields.get('businessDetails'));   
            Map < String, Object > businessDetailsMap = (Map < String, object > ) JSON.deserializeUntyped(businessDetails);
                businessRegistrationNumber=(String)businessDetailsMap.get('businessRegistrationNumber');
                businessRegistrationType=(String)businessDetailsMap.get('businessType');
            }   
            
            companydetails = AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.COMPANY_DETAILS);  
            preappResponse=AOB_CTRL_FormCreator.getInflight(applicationId, 'PreApplicationResponse');  
            companytradingdetails = AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.COMPANY_TRADING_ADDRESS); 
            companyfinancialdetails = AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.COMPANY_FINANCIAL_ADDRESS);
            resdentialData = AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.RESIDENTIAL_ADDRESS); 
            marketingconsents=AOB_CTRL_FormCreator.getInflight(applicationId,  AOB_Internal_Constants.MARKETING_CONSENT);
            preApplication=AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.PRE_APPLICATION);
            AOB_Internal_API_CompanyDetails customerServiceCall = new AOB_Internal_API_CompanyDetails(applicationId,companydetails,companytradingdetails,companyfinancialdetails,marketingconsents,preApplication,resdentialData,preappResponse,businessRegistrationNumber,businessRegistrationType);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_CompanyDetails.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            List<ResponseBody> responseList= new List<ResponseBody>(); 
            if(customerServiceCall.getResponseStatusCode()==200 && !String.isEmpty(customerServiceCall.getResponseBody()) ){
                List<AOB_Application__c> aobapplication=[select id, AOB_inflightData__c,AOB_Retry_Count__c,AOB_Client__r.Name,AOB_ProcessId__c,AOB_SalesObjectId__c,AOB_InflightDataID__c from AOB_Application__c where id =:applicationId];
                aobapplication[0].AOB_Retry_Count__c=0;
                update aobapplication;
                Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                String businessDetOut=Json.serialize(jsonData.get('businessDetOut'));
                Map<String, Object> businessDetOutMap;
                if(!String.isEmpty(businessDetOut)){
                    businessDetOutMap=(Map<String, Object>)system.JSON.deserializeUntyped(businessDetOut); 
                }
                List<Object>  validationErrorsList=(List<Object>)businessDetOutMap.get('validationErrors'); 
                if(validationErrorsList!=null){
                    for(Object error:validationErrorsList){
                        Map<String, Object> m = (Map<String, Object>)error;
                        ResponseBody resmessage= new ResponseBody();
                        resmessage.responseCode=customerServiceCall.getResponseStatusCode();
                        resmessage.message=(String)m.get('message');
                        responseList.add(resmessage);           
                    } 
                }else{
                    ResponseBody resmessageelse= new ResponseBody();
                    resmessageelse.responseCode=customerServiceCall.getResponseStatusCode();
                    resmessageelse.message=null;
                    responseList.add(resmessageelse);
                    
                }    
                
            }
            if (customerServiceCall.getResponseStatusCode() != 200) {
                ResponseBody resmessage3= new ResponseBody();
                resmessage3.responseCode=customerServiceCall.getResponseStatusCode();
                resmessage3.message=null;
                responseList.add(resmessage3);
            }
            return Json.serialize(responseList);
        }Catch(Exception ex){
          LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_API_CompanyDetails',ex.getMessage()}, ex);
           throw new AuraHandledException(ex.getMessage());
       }
        
    }
    
    /**
    * @description wrapper class for response body
    */
    public class ResponseBody{
        Integer responseCode;
        String message;
    }
}