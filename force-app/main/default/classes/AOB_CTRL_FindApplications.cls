/***************************************************************************************
@Author            : Dayakar
@Date              : 19-09-2022
@Name of the Class : AOB_CTRL_FindApplications
@description       : Finding Applications and creating one if there is no application found
@Last Modified By  : Ramadevi 
@Last Modified On  : 22 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_CTRL_FindApplications {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_FindApplications');
    private static final String RESPONSESTATUSDESC='responseStatusDesc';
    private static final String PREAPP_SUBMITTED='PreApplication Submitted';
    private static final String VERIFICATION_SUCCESSFUL='Verification Successful';
    private static final String OPEN_APPLICATION ='OpenApplication';
    private static final String SIGN_IN_CLICKED='SignI In Clicked';
    private static final String REGISTER_CLICKED='Register Clicked';
    private static final String CHANNEL_NAME='channelName';
    private static final Integer RETRYVALUE=1;
  
    public static String applicationId;
    /**
    * @description	finds an application based on Customer ID and data that has been captured in preapplication screen
    * @param customerId
    * @param preAppData
    * @return application Id and custom status(EXISTING  - if application found, NEW - If application created from here)
    */
    @AuraEnabled
    public static String findApplication(string customerId, string preAppData){
        try{
            String result;
            AppWrapper data = new AppWrapper();
            data.appFound= AOB_Constants.NEW_APP;
            Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
            String pricingOpt = (String)appData.get(AOB_Constants.PRICING_OPTION);
            String regNum = String.isEmpty((String)appData.get(AOB_Constants.BUSINESS_REG_NUM))? (String)appData.get(AOB_Constants.IDNUM) : (String)appData.get(AOB_Constants.BUSINESS_REG_NUM);
            List<AOB_ApplicationLineItem__c> appLineItems = new SEL_AOBApplicationLineItem().selectAppsByAppLineItem(pricingOpt,customerId,regNum,AOB_Constants.IN_PROGRESS);
            if(appLineItems.isEmpty()){
                createLead(preAppData);
                data.appId = applicationId;
                data.mallApplicationId=applicationId;
            }
            else{
                String applicantId =appLineItems[0].AOB_Application__c;
                List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicantId);
                data.mallApplicationId=applicantId;
                Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c); 
                if(jsonData.containsKey(AOB_Constants.PRE_APP_RESPONSE)){
                    data.appFound=AOB_Constants.EXISTING_APP;
                    data.appId = appLineItems[0].AOB_Application__c;
                    data.initiateAPI = false;
                    apps[0].PreApp_Stages__c = OPEN_APPLICATION;
                    update apps;
                }
                else{
                    data.appFound=AOB_Constants.NEW_APP;
                    data.appId = appLineItems[0].AOB_Application__c;
                    data.initiateAPI = true;
                }
            }
            result = System.JSON.serialize(data);
            return result;   
        }
        catch(Exception ex){
            LOGGER.error('AOB_CTRL_FindApplications.findApplication', ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description	creates lead with the data that has been captured in preapplication screen
    * @param preAppData
    */
    @AuraEnabled
    public static void createLead(String preAppData) {
        try{
            Lead lobj = new Lead();
            Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
            lobj.FirstName = (String)appData.get(AOB_Constants.NAME);
            lobj.LastName = (String)appData.get(AOB_Constants.SURNAME);
            lobj.Customer_ID__c = (String)appData.get(AOB_Constants.IDNUM);
            lobj.MobilePhone = (String)appData.get(AOB_Constants.PHONENUM);
            lobj.Email = (String)appData.get(AOB_Constants.EMAIL);
            lobj.Company = (String)appData.get(AOB_Constants.BUSINESS_NAME);
            lobj.AnnualRevenue = Integer.valueOf(appData.get(AOB_Constants.BUSINESS_TURN_OVER));
            lobj.Registration_Number__c = (String)appData.get(AOB_Constants.BUSINESS_REG_NUM);
            lobj.State = (String)appData.get(AOB_Constants.BUSINESS_PROVINCE);
            lobj.City = (String)appData.get(AOB_Constants.BUSINESS_CITY);
            insert lobj;
            createApplication(lobj,preAppData);
        }
        catch(Exception ex){
            LOGGER.error('AOB_CTRL_FindApplications.createLead', ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description	creates application with the data that has been captured in preapplication screen
    * @param lobj
    * @param preAppData
    */
    public static void createApplication(Lead lobj, String preAppData){
        try{
            AOB_Application__c application = new AOB_Application__c();
            Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
            String prodNum = (String)appData.get(AOB_Constants.PRODUCT_NUMBER);
            String pricingOpt = (String)appData.get(AOB_Constants.PRICING_OPTION);
            application.Name = (String)appData.get(AOB_Constants.APP_NAME);
            application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
            application.AOB_Registration_Number__c = String.isEmpty((String)appData.get(AOB_Constants.BUSINESS_REG_NUM))? (String)appData.get(AOB_Constants.IDNUM) : (String)appData.get(AOB_Constants.BUSINESS_REG_NUM);
            application.AOB_inflightData__c =AOB_Constants.PRE_APP_RES +preAppData+ '}';
            application.Lead__c = lobj.Id;  
            application.PreApp_Stages__c = PREAPP_SUBMITTED; 
            application.AOB_Entity_Type__c = (String)appData.get(AOB_Constants.BUSINESS_TYPE);
            application.SBG_Channel__c = (String)appData.get(CHANNEL_NAME);
            
            insert application;
            applicationId=application.id;
            String appName = (String)appData.get(AOB_Constants.APP_NAME);
            createAppLineItem(application, prodNum, pricingOpt,appName);
        }
        catch(Exception ex){
            LOGGER.error('AOB_CTRL_FindApplications.createApplication', ex);
            throw new AuraHandledException(ex.getMessage());  
        }   
    }
    /**
    * @description	creates ApplicationLineItem for application
    * @param app
    * @param productNum
    * @param pricingOption
    * @param appName
    */
    public static void createAppLineItem(AOB_Application__c app, String productNum, String pricingOption, String appName){
        try{
            AOB_ApplicationLineItem__c appLineItem = new AOB_ApplicationLineItem__c();
            List<Product2> prod = new SEL_Products2().selectByProductCodeslist('4648');
            if (prod.isEmpty()) {
                throw new AuraHandledException(AOB_Constants.PRODUCTCODENOTFOUND+productNum);
            }
            appLineItem.AOB_Application__c =app.Id;
            appLineItem.AOB_Product__c =prod[0].Id;
            appLineItem.AOB_Main__c = TRUE;
            appLineItem.AOB_Pricing_Option__c = pricingOption;
            appLineItem.AOB_Status__c='Accepted';
            appLineItem.Name = appName;
        
            insert appLineItem;
        }
        catch(Exception ex){
            LOGGER.error('AOB_CTRL_FindApplications.createAppLineItem', ex);
            throw new AuraHandledException(ex.getMessage());  
        }      
    }
    
    /**
    * @description	finds PreApplicationResponse key in inflight data and returns the data
    * @param appId
    * @return String
    */
    @AuraEnabled
    public static String isDILinkedToBPID(String appId){
        String inflightData='';
        List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
        if(!apps.isEmpty()){
            Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c); 
            for(string key : jsonData.keyset()){
                if(key == AOB_Constants.PRE_APP_RESPONSE){
                    inflightData = System.JSON.serialize(jsonData.get(AOB_Constants.PRE_APP_RESPONSE));
                }
            }
            if(String.isBlank(inflightData)){
                throw new AuraHandledException(AOB_Constants.PREAPPRESPONSENOTFOUND);
            }
        }
        return inflightData;
    }
    /**
    * @description	makes PreApplication API Call and handling response logic
    * @param preappData
    * @param applicationId
    * @return String
    */
    @AuraEnabled
    public static String callPreApplication(String preappData, String applicationId){
        try{
            AOB_API_PreApplication customerServiceCall = new AOB_API_PreApplication(preappData,applicationId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_PreApplication.SERVICE_NAME);
            customerServiceCall.process(obj); 
            Insert obj;
            Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            String updateServiceInfo='Service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c+'\n' ;
            updateServiceInfo = updateServiceInfo+'responseStatusCode : '+(String)responseData.get(AOB_Constants.BUSINESS_STATUS) +'\n ';
            updateServiceInfo = updateServiceInfo+'responseStatusDesc : '+(String)responseData.get(RESPONSESTATUSDESC);

            apps[0].Recent_API_Service__c=updateServiceInfo;
            Update apps;
            
            if(customerServiceCall.getResponseStatusCode()==200 && (String)responseData.get(AOB_Constants.BUSINESS_STATUS)=='52000'){
                Object listofobjs =responseData.get(AOB_Constants.INITIATORS);
                String intiateData=Json.serialize(listofobjs);
                List<object> objects = (List<object>)System.JSON.deserializeUntyped(intiateData);
                PreApplicationData preappjson=new PreApplicationData();
                for(object o:objects){
                    Map<String, Object> m = (Map<String, Object>)o;
                    preappjson.initiatorBPID=(String)m.get(AOB_Constants.INITIATOR_BPID);
                    preappjson.initiatorBPGUID=(String)m.get(AOB_Constants.INITIATOR_BPGUID);
                    preappjson.initiatorDigitalID=(String)m.get(AOB_Constants.INITIATOR_DIGID);
                }
                preappjson.businessRegisteredName=(String)responseData.get(AOB_Constants.BUSINESS_REG_NAME);
                preappjson.businessBPID=(String)responseData.get(AOB_Constants.BUSINESS_BPID);
                preappjson.businessBPGUID=(String)responseData.get(AOB_Constants.BUSINESS_BPGUID);
                preappjson.processId=(String)responseData.get(AOB_Constants.PROCESSID);
                preappjson.digitalOfferId=(String)responseData.get(AOB_Constants.DIGITALOFFERID);
                preappjson.inflightCustomerDataId=(String)responseData.get(AOB_Constants.INFLIGHT_CUSTID);
                String json=System.JSON.serialize(preappjson);
                string preapplicationresponsestrng  = AOB_Constants.PRE_APP_RESPONSEBODY+json;
                List<AOB_Application__c> aobapplication = new SEL_AOBApplication().selectAppsById(applicationId);
                List<AOB_Application__c> aobUpdate= new List<AOB_Application__c>();
                String str=aobapplication[0].AOB_inflightData__c.SubStringAfter('{');
                for(AOB_Application__c aob:aobapplication){   
                    aob.AOB_inflightData__c=preapplicationresponsestrng+','+str;
                    aob.AOB_ProcessId__c=(String)responseData.get(AOB_Constants.PROCESSID);
                    aob.AOB_SalesObjectId__c=(String)responseData.get(AOB_Constants.DIGITALOFFERID);
                    aob.AOB_InflightDataID__c=(String)responseData.get(AOB_Constants.INFLIGHT_CUSTID);
                    aob.AOB_ExpiryDate__c=Date.valueOf(String.valueOf(responseData.get('expiryDate'))); 
                    aob.AOB_Retry_Count__c=0;
                    aob.PreApp_Stages__c=VERIFICATION_SUCCESSFUL;
                    aobUpdate.add(aob);    
                }
                Update aobUpdate;
            }
            String responseCode=(String)responseData.get(AOB_Constants.BUSINESS_STATUS);
            if(responseCode=='52103' || responseCode=='52002' || responseCode=='52003' || responseCode=='52004' || responseCode=='52111'){
             List<AOB_Application__c> aobapplicationupdate = new SEL_AOBApplication().selectAppsById(applicationId);
             aobapplicationupdate[0].Lead_Created__c=true;  
             update aobapplicationupdate;   
            }
            if(responseCode=='52000'){
                List<AOB_ApplicationLineItem__c> applineItem=new SEL_AOBApplicationLineItem().selectAppLineItemsByIdAndProductCode(applicationId, '4648');
                applineItem[0].AOB_ExpiryDate__c=Date.valueOf(String.valueOf(responseData.get('expiryDate')));
                update applineItem;
            }
            PreApp_Response preApp= new PreApp_Response();
            preApp.responseCode=(String)responseData.get(AOB_Constants.BUSINESS_STATUS);
            preApp.responseDesc=(String)responseData.get(RESPONSESTATUSDESC);
            return System.JSON.serialize(preApp);
        }
        catch(Exception ex){
            LOGGER.error('AOB_CTRL_FindApplications.callPreApplication', ex);
            throw new AuraHandledException(ex.getMessage());  
        }   
    }
    /**
    * @description method to update application PreApp Stage
    * @param appId Id
    * @param stageToUpdate String
    */
    @AuraEnabled    
    public static void updatePreAppStage(String appId, String stageToUpdate){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
            apps[0].PreApp_Stages__c = stageToUpdate;
            update apps;
        }catch(Exception ex) {
            LOGGER.error('AOB_CTRL_FindApplications.updatePreAppStage', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @description	makes track of PreApplication API Call retries
    * @param applicationId
    * @return decimal
    */
    @auraEnabled
    public static decimal incrementRetryApplication(id applicationId) {
        try {
            List<AOB_Application__c> appRec = new SEL_AOBApplication().selectAppsById(applicationId);
            if (appRec[0].AOB_Retry_Count__c == null) {
                appRec[0].AOB_Retry_Count__c = 0;
            }
            appRec[0].AOB_Retry_Count__c++;
            decimal returnNumber = appRec[0].AOB_Retry_Count__c;
            if(appRec[0].AOB_Retry_Count__c==RETRYVALUE){
                
                appRec[0].AOB_Retry_Count__c=0;
                
            }
            update appRec;
            return returnNumber;
        } catch (Exception ex) {
            LOGGER.error('AOB_CTRL_FindApplications.incrementRetryApplication', ex);
            throw new AuraHandledException(ex.getMessage());  
        }     
    }
    
    
    /**
    * @description	makes track of PreApplication API Call retries
    * @param applicationId
    */
    @AuraEnabled
    public static void resetRetryCount(String applicationId){
        List<AOB_Application__c> appRec = new SEL_AOBApplication().selectAppsById(applicationId);
        if(appRec.size()>0){
            appRec[0].AOB_Retry_Count__c=0;
        }
        update appRec;
    }
    
    /**
    * @description	wrapper class for findapplication response
    */
    public class AppWrapper{    
        String appId;
        String appFound;
        Boolean initiateAPI;
        String mallApplicationId;
    }
     /**
    * @description	wrapper class for PreApplicationData
    */
    public class PreApplicationData{
        String initiatorBPID;
        String initiatorBPGUID;
        String initiatorDigitalID;
        String businessRegisteredName;
        String businessBPID;
        String businessBPGUID;
        String processId;
        String digitalOfferId;
        String inflightCustomerDataId;
    }
     /**
    * @description	wrapper class for preapp response
    */
    public Class PreApp_Response{
        
        public String responseCode;
        public String responseDesc;
        
    }
}