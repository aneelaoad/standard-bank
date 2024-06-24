/**
 * @description Pre Application controller class
 *
 * @see AOB_CTRL_Internal_CTRL_FindApplication
 *
 * @author Sibonelo Ngcobo
 *
 * @date March 2023
 */
public without sharing class AOB_Internal_CTRL_FindApplications {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_FindApplications');
  
    public static String applicationId;
    public static String productCode;
    /**
    * @description	finds an application based on Customer ID and data that has been captured in preapplication screen
    * @param customerId
    * @param preAppData
    * @param productCode
    * @param accountId
    * @return application Id and custom status(EXISTING  - if application found, NEW - If application created from here)
    */
    @AuraEnabled
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static String findApplication(String customerId, String preAppData,String productCode,Id accountId){
             String result;
             try{
            AppWrapper data = new AppWrapper();
            data.appFound= AOB_Constants.NEW_APP;
            Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
            String pricingOpt = (String)appData.get(AOB_Constants.PRICING_OPTION);
            String regNum = String.isEmpty((String)appData.get(AOB_Constants.BUSINESS_REG_NUM))? (String)appData.get(AOB_Constants.IDNUM) : (String)appData.get(AOB_Constants.BUSINESS_REG_NUM);
            //Query uses a subquery and cant be placed in SELECTOR class    
            List<AOB_ApplicationLineItem__c> appLineItems = [select id, AOB_Application__c from AOB_ApplicationLineItem__c where AOB_Product__r.name=:AOB_Constants.PRODUCTNAME and AOB_Pricing_Option__c=:pricingOpt and AOB_Application__c in (select Id from AOB_Application__c where AOB_Registration_Number__c=:regNum and Lead__r.Customer_ID__c =: customerId and AOB_Status__c =:AOB_Constants.IN_PROGRESS)];
            if(appLineItems.isEmpty()){
                createApplication(preAppData,productCode,accountId);
                data.appId = applicationId;
            }
            else{
                String applicantId =appLineItems[0].AOB_Application__c;
                List<AOB_Application__c> apps = SEL_AOBApplication.newInstance().selectAppsById(applicantId);
                Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c); 
                if(jsonData.containsKey(AOB_Constants.PRE_APP_RESPONSE)){
                    data.appFound=AOB_Constants.EXISTING_APP;
                    data.appId = appLineItems[0].AOB_Application__c;
                    data.initiateAPI = false;
                }
                else{
                    data.appFound=AOB_Constants.EXISTING_APP;
                    data.appId = appLineItems[0].AOB_Application__c;
                    data.initiateAPI = true;
                }
            }
            result = System.JSON.serialize(data);
            return result;   
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FindApplications.findApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description	creates lead with the data that has been captured in preapplication screen
    * @param preAppData
    * @param productCode
    * @param accountId
    */
    @AuraEnabled
    public static void createLead(String preAppData, String productCode,Id accountId) {
        try{
            Lead leadObj = new Lead();
            Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
            leadObj.FirstName = (String)appData.get(AOB_Constants.NAME);
            leadObj.LastName = (String)appData.get(AOB_Constants.SURNAME);
            leadObj.Customer_ID__c = (String)appData.get(AOB_Constants.IDNUM);
            leadObj.MobilePhone = (String)appData.get(AOB_Constants.PHONENUM);
            leadObj.Email = (String)appData.get(AOB_Constants.EMAIL);
            leadObj.Company = (String)appData.get(AOB_Constants.BUSINESS_NAME);
            leadObj.AnnualRevenue = Integer.valueOf(appData.get(AOB_Constants.BUSINESS_TURN_OVER));
            leadObj.Registration_Number__c = (String)appData.get(AOB_Constants.BUSINESS_REG_NUM);
            leadObj.State = (String)appData.get(AOB_Constants.BUSINESS_PROVINCE);
            leadObj.City = (String)appData.get(AOB_Constants.BUSINESS_CITY);

            insert leadObj;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FindApplications.createLead',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description	creates application with the data that has been captured in preapplication screen
    * @param preAppData
    * @param productCode
    * @param accountId
    */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void createApplication(String preAppData,String productCode,Id accountId){
        try{
             AOB_Application__c application = new AOB_Application__c();
            Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(preAppData);
            if(!String.isEmpty(accountId)){
            application.AOB_Client__c=accountId;
            }
            String prodNum = (String)appData.get(AOB_Constants.PRODUCT_NUMBER);
            String pricingOpt = (String)appData.get(AOB_Constants.PRICING_OPTION);
            application.Name = (String)appData.get(AOB_Constants.APP_NAME);
            application.AOB_CurrentScreen__c='Personal Details';
            application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
            application.AOB_Registration_Number__c = String.isEmpty((String)appData.get(AOB_Constants.BUSINESS_REG_NUM))? (String)appData.get(AOB_Constants.IDNUM) : (String)appData.get(AOB_Constants.BUSINESS_REG_NUM);
            application.AOB_inflightData__c =AOB_Constants.PRE_APP_RES +preAppData+ '}';
        
            insert application;
            applicationId = application.id;
            String appName = (String)appData.get(AOB_Constants.APP_NAME);
            createAppLineItem(application, prodNum, pricingOpt,appName,productCode);
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FindApplications.createApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }   
    }
    /**
    * @description returns product2 list
    * @param productId
    * @return List<Product2>
    */
    	@auraenabled
        public static List<Product2> getProduct(Id productId){
            List<Product2> prod= SEL_Products2.newInstance().selectByIds(new Set<Id>{productId});
            return prod;
        }

    /**
    * @description	creates ApplicationLineItem for application
    * @param app
    * @param productNum
    * @param pricingOption
    * @param appName
    * @param productCode
    */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void createAppLineItem(AOB_Application__c app, String productNum, String pricingOption, String appName,String productCode){
        try{
            AOB_ApplicationLineItem__c appLineItem = new AOB_ApplicationLineItem__c();
            List<Product2> prod = SEL_Products2.newInstance().selectByProductCodes(new Set<String>{productCode});
            if (prod.isEmpty()) {
                throw new AuraHandledException('Can not create applicatoin line item. No product found for product code: '+productNum);
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FindApplications.createAppLineItem',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }      
    }
     /**
     * @description ApWrapper Inner class.
     */
    public class AppWrapper{    
        String appId;
        String appFound;
        Boolean initiateAPI;
    }
    /**
     * @description PreApplicationData Inner class.
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
}