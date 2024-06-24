/**
 * @description       : Class for generic form creation based on database records
 * @author            : Salesforce
 * @group             : Staff-Assisted
 * @last modified on  : 07-19-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver      Date            Author              Modification Description: SFP-25088
 * 1.0                                          Initial Version
 * 1.0.1    06-29-2023      Tukelo Moseamo      getDirectorDetails
**/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
public with sharing class AOB_Internal_CTRL_FormCreator {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Internal_CTRL_FormCreator');
    
    /**
    * @description gets a list of fields to be displayed based on screen and product
    * @param applicationId  - Id of the Community
    * @param screenName - Auth Provider user data describing the User to create
    * @return AOB_DTO_Form 
    */
    @AuraEnabled
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.NcssMethodCount')
    public static AOB_DTO_Form getFields(Id applicationId,String screenName) {
        String language=AOB_UTILS.getUserLanguage();
        List<AOB_FlowScreen__c> screens = new SEL_AOBScreen().selectFieldsByName(screenName,language);
        AOB_DTO_Form form = new AOB_DTO_Form();
        List<AOB_Application__c> apps;
        if(!screens.isEmpty()){
            apps = getApps(screens,applicationId);
        }
        else{
            LOGGER.error('Unable to find selected screen');
            throw new AuraHandledException('Unable to find selected screen'+screenName);
        }
        form.subTitle = getFormSubtitle(screens, apps);
        form.title=screens[0].AOB_title__c;
        List<AOB_DTO_Field> fields=new List<AOB_DTO_Field>();
        List<AOB_DTO_Section> sections=new List<AOB_DTO_Section>();
        Set<Id> sectionIds=new Set<Id>();
        AOB_DTO_Section jsSection;
        
        for(AOB_ScreenSection__c  section : new SEL_AOBSection().selectSectionsByScreenName(screenName,language)){
            jsSection = setSectionInfo(section);
            sections.add(jsSection); 
            sectionIds.add(section.id);                             
        }
        
        if(sectionIds.isEmpty()){
            LOGGER.error('Unable to find any sections');
            throw new AuraHandledException('Unable to find any sections');
        }
        
        Map<id,List<AOB_DTO_Field>> sectionFields=new Map<id,List<AOB_DTO_Field>>();
        List<String> mriTables=new List<String>();
        for(AOB_Field__c  field: new SEL_AOBField().selectMRITablesByLanguage(sectionIds,language)){
            mriTables.add(field.AOB_MRITable__c );
        }   
        
        Map<String, List<AOB_DTO_SelectOption>> refData = AOB_Utils.getAllPicklistEntriesCodes(mriTables);
        if(refData.isEmpty()){
            LOGGER.error('Unable to find any referenced data');
            throw new AuraHandledException('Unable to find any referenced data');
        }
        
        for(AOB_Field__c  field : new SEL_AOBField().selectFieldsBySection(sectionIds)){
            AOB_DTO_Field jsField = new AOB_DTO_Field(field,apps);
            jsField.options=refData.get(field.AOB_MRITable__c);
            if(sectionFields.containsKey(field.AOB_Section__c)){
                sectionFields.get(field.AOB_Section__c).add(jsField);
            }
            else{
                sectionFields.put(field.AOB_Section__c,new List<AOB_DTO_Field>{jsField});
            }
        }
        if(sectionFields.isEmpty()){
            LOGGER.error('Unable to find any fields');
            throw new AuraHandledException('Unable to find any fields');
        }
        for(AOB_DTO_Section section:sections){
            List<AOB_DTO_Field> sortedFields=sectionFields.get(section.identifier);
            if(sortedFields!=null){
                sortedFields.sort();
            }
            section.fields=sortedFields;
        }
        form.sections=sections;
        return form;
    }
    
    /**
    * @description gets a list of apps
    * @param screens - all flow screens
    * @param applicationId
    * @return List<AOB_Application__c> 
    */
    private static List<AOB_Application__c> getApps(List<AOB_FlowScreen__c> screens,Id applicationId){
        List<AOB_Application__c> apps;
        if(applicationId!=null){
            if(String.isNotBlank(screens[0].AOB_TitleApplicationField__c) && screens[0].AOB_TitleApplicationField__c.toLowerCase()!='name'){
                apps=database.query('select id,name,AOB_TECH_ResidentialAddress__c,AOB_TECH_Company_Address__c,'+screens[0].AOB_TitleApplicationField__c+' from AOB_Application__c where id=\''+applicationId+'\'');
            }else{
                apps=database.query('select id,name,AOB_TECH_ResidentialAddress__c,AOB_TECH_Company_Address__c from AOB_Application__c where id=\''+applicationId+'\'');
            }
        }
        return apps;
    }
    
    /**
    * @description gets form subtitle
    * @param screens - all flow screens
    * @param apps - all flow apps
    * @return String
    */
    private static String getFormSubtitle(List<AOB_FlowScreen__c> screens, List<AOB_Application__c> apps){
        String formSub;
        if(String.isNotBlank(screens[0].AOB_subTitle__c) && screens[0].AOB_subTitle__c.contains('{####}') &&!apps.isEmpty()){
            formSub=screens[0].AOB_subTitle__c.replace('{####}',String.valueOf(apps[0].get(screens[0].AOB_TitleApplicationField__c)));
        }
        else if(String.isNotBlank(screens[0].AOB_subTitle__c) && screens[0].AOB_subTitle__c.contains('{##firstName##}') &&!apps.isEmpty()){
            String preAppData = getInflight(apps[0].Id, AOB_Constants.PRE_APPLICATION); 
            Map<String, Object> preappfields = (Map<String, object>) JSON.deserializeUntyped(preAppData);
            formSub=screens[0].AOB_subTitle__c.replace('{##firstName##}',(String)preappfields.get(AOB_Constants.NAME));        
        }
        else{
            formSub=screens[0].AOB_subTitle__c;
        }
        return formSub;
    }
    
    /**
    * @description gets sections info
    * @param section - section info
    * @return String
    */
    private static AOB_DTO_Section setSectionInfo(AOB_ScreenSection__c section){
        AOB_DTO_Section sectionInfo;
        sectionInfo = new AOB_DTO_Section();
        sectionInfo.identifier=section.id;                               
        sectionInfo.title=section.AOB_Title__c;  
        sectionInfo.sectionName=section.Name;  
        sectionInfo.smallDeviceColumns=section.AOB_smallDeviceColumns__c;
        sectionInfo.mediumDeviceColumns=section.AOB_mediumDeviceColumns__c;
        sectionInfo.largeDeviceColumns=section.AOB_largeDeviceColumns__c;
        sectionInfo.rank=section.AOB_Rank__c;
        sectionInfo.gridClass='aob_form_input slds-col slds-m-top_small slds-small-size_1-of-'+sectionInfo.smallDeviceColumns+' slds-medium-size_1-of-'+sectionInfo.mediumDeviceColumns+' slds-large-size_1-of-'+sectionInfo.largeDeviceColumns;
        return sectionInfo;
    }
    
    /**
    * @description sets application's inflight data
    * @param applicationId Id
    * @param appData String
    */
    @AuraEnabled
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.NcssMethodCount, PMD.CognitiveComplexity')
    public static void setApplicationData(Id applicationId,String appData){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            if(apps[0].AOB_CurrentScreen__c != AOB_Constants.AVALIBLE_BUNDLES && apps[0].AOB_CurrentScreen__c != AOB_Constants.POCKETBIZ && apps[0].AOB_CurrentScreen__c != AOB_Constants.SNAPSCAN){
                if(!apps.isEmpty()){
                    Map<String, Object> jsonMAp ;
                    if(apps[0].AOB_CurrentScreen__c==AOB_Constants.RESIDENTIAL_ADDRESS){
                        Map<String, Object> data = (Map<String, Object>)System.JSON.deserializeUntyped(appData);
                        apps[0].AOB_TECH_ResidentialAddress__c='';
                        String complex = String.isNotBlank((String)data.get('Complexe'))? data.get('Complexe')+', ' : '';
                        String unitNumber = String.isNotBlank((String)data.get('UnitNumber'))? data.get('UnitNumber')+', ' : '';
                        apps[0].AOB_TECH_ResidentialAddress__c =data.get('Street')+', '+unitNumber+complex+data.get('suburb')+', '+data.get('city')+', '+data.get('PostalCode');
                    }
                    if(apps[0].AOB_CurrentScreen__c== AOB_Constants.COMPANY_TRADING_ADDRESS){
                        Map<String, Object> data = (Map<String, Object>)System.JSON.deserializeUntyped(appData);
                        apps[0].AOB_TECH_Company_Address__c='';
                        if(data.get('AddressType') == 'Different'){
                            data.remove('AddressValue');
                            appData=System.JSON.serialize(data);
                            Map<String, Object> inflightToUpdate=(Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                            if(inflightToUpdate.containsKey('Company Trading Address')){
                                Map<String, Object> updateInflight=(Map<String, Object>)inflightToUpdate.get('Company Trading Address');
                                updateInflight.remove('AddressValue');
                                inflightToUpdate.put('Company Trading Address', updateInflight);
                            }
                            apps[0].AOB_inflightData__c=System.JSON.serialize(inflightToUpdate);
                            String complex = String.isNotBlank((String)data.get('Complex'))? data.get('Complex')+', ' : '';
                            String unitNumber = String.isNotBlank((String)data.get('UnitNumber'))? data.get('UnitNumber')+', ' : '';
                            apps[0].AOB_TECH_Company_Address__c =data.get('StreetName')+', '+unitNumber+complex+data.get('SUBURB')+', '+data.get('city')+', '+data.get('PostalCode');
                        }
                        else if(data.get('AddressType') == 'Same'){
                            Map<String, Object> residentialData = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                            if(residentialData.containsKey('Residential Address')){
                                Map<String,Object> addData=(Map<String,Object>)residentialData.get('Residential Address');
                                data.put('AddressValue', addData);
                                appData=System.JSON.serialize(data);
                            }
                            apps[0].AOB_TECH_Company_Address__c = apps[0].AOB_TECH_ResidentialAddress__c;
                        }
                    }
                    if(String.isBlank(apps[0].AOB_inflightData__c)){
                        jsonMAp = new Map<String, Object>();
                        jsonMap.put(apps[0].AOB_CurrentScreen__c,appData);
                        apps[0].AOB_inflightData__c='{"'+apps[0].AOB_CurrentScreen__c+'":'+appData+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                        jsonMap.put(apps[0].AOB_CurrentScreen__c,System.JSON.deserializeUntyped(appData));
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
                } 
                update apps;
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('update exception msg'+ex.getMessage());  
        }
    }

     /**
    * @description sets application's current and previous step
    * @param applicationId Id
    * @param appData String
    */ 
    @AuraEnabled
    public static void updateAvailableBundles(Id applicationId, String appData) {
        try {
             List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            Map<String, Object> jsonMAp ;
            if(String.isBlank(apps[0].AOB_inflightData__c)){
                jsonMAp = new Map<String, Object>();
                jsonMap.put(AOB_Constants.AVALIBLE_BUNDLES,appData);
                apps[0].AOB_inflightData__c='{"'+apps[0].AOB_CurrentScreen__c+'":'+appData+'}';
            }
            else{ 
                jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                jsonMap.put(AOB_Constants.AVALIBLE_BUNDLES,System.JSON.deserializeUntyped(appData));
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
        } catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('update exception msg'+ex.getMessage());  
        }
    }
    
    /**
    * @description sets application's current and previous step
    * @param applicationId Id
    * @param currentScreen String
    * @param previousScreen String
    */
    @AuraEnabled
    public static void setApplicationStep(Id applicationId,String currentScreen,String previousScreen){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            if(apps.isEmpty()){
                throw new AuraHandledException('Unable to find application '+applicationId);
            }
            if(!apps.isEmpty()){
                if(String.isNotBlank(apps[0].AOB_PreviousScreens__c)){
                    if(String.isNotBlank(previousScreen)){
                        if (!apps[0].AOB_PreviousScreens__c.contains(previousScreen)){
                            apps[0].AOB_PreviousScreens__c=apps[0].AOB_PreviousScreens__c+';'+previousScreen;
                        }
                    }
                }
                else {
                    apps[0].AOB_PreviousScreens__c=previousScreen;
                }
                apps[0].AOB_CurrentScreen__c = currentScreen;
                apps[0].AOB_PreviousScreen__c = previousScreen; 
            }
            update apps;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
    * @description sets application's current and previous step based on the information stored in previous steps
    * @param applicationId Id
    */
    @AuraEnabled
    public static void goBacktoPreviousStep(Id applicationId){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            if(apps.isEmpty()){
                throw new AuraHandledException('Unable to find application '+applicationId);
            }
            if(!apps.isEmpty()){
                if(String.isNotBlank(apps[0].AOB_PreviousScreens__c)){
                    List<String> screens=apps[0].AOB_PreviousScreens__c.split(';');
                    if (screens.size() > 0) {
                        apps[0].AOB_CurrentScreen__c = screens[screens.size()-1];  
                        apps[0].AOB_PreviousScreens__c = apps[0].AOB_PreviousScreens__c.replace(';'+apps[0].AOB_CurrentScreen__c,'').replace(apps[0].AOB_CurrentScreen__c,'');
                }
                    if (screens.size() > 1) {
                        apps[0].AOB_PreviousScreen__c = screens[screens.size()-2];  
                    } else {
                        apps[0].AOB_PreviousScreen__c = ''; 
            }
                }
            }
            update apps;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    /**
    * @description create ApplicationLineItems 
    * @param applicationId Id
    * @param items String
    */
    @AuraEnabled
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity,PMD.NcssMethodCount')
    public static void createApplicationLineItems(Id applicationId, String items) { 
        try {
            if (!String.isEmpty(items)) {
                Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(items);
                Set<String> productCodes = new Set<String>();
                for (String pdc : appData.keySet()) {
                    if (Boolean.valueOf(appData.get(pdc)) == true || Boolean.valueOf(appData.get(pdc)) == false) {
                        productCodes.add(pdc);
                    }
                }
                if (!productCodes.isEmpty()) {
                    List<Product2> products = SEL_Products2.newInstance().selectByProductCodes(productCodes);
                    Map<String, Product2> productMap = new Map<String, Product2>();
                    for (Product2 prod : products) {
                        productMap.put(prod.ProductCode, prod);
                    }
    
                    List<AOB_ApplicationLineItem__c> appLinesToInsert = new List<AOB_ApplicationLineItem__c>();
                    List<AOB_ApplicationLineItem__c> appLinesToUpdate = new List<AOB_ApplicationLineItem__c>();
    
                    // Query existing Application Line Items by applicationId and product Ids
                    List<AOB_ApplicationLineItem__c> existingAppLines = [SELECT Id, AOB_Product__c, AOB_Application__c FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c = :applicationId AND AOB_Product__c IN :productMap.values()];
                    // Create a Map of existing Application Line Items with Product Ids as keys
                    Map<Id, AOB_ApplicationLineItem__c> existingAppLineMap = new Map<Id, AOB_ApplicationLineItem__c>();
                    for (AOB_ApplicationLineItem__c appLine : existingAppLines) {
                        existingAppLineMap.put(appLine.AOB_Product__c, appLine);
                    }
    
                    for (String code : productCodes) {
                        if (productMap.containsKey(code)) {
                            Product2 prod = productMap.get(code);
    
                            if (existingAppLineMap.containsKey(prod.Id)) {
                                // Update existing Application Line Item
                                AOB_ApplicationLineItem__c appLine = existingAppLineMap.get(prod.Id);
                                if (Boolean.valueOf(appData.get(code))) {
                                    appLine.AOB_Status__c = 'Accepted';
                                } else {
                                    appLine.AOB_Status__c = 'Not Taken Up';
                                }
                                appLinesToUpdate.add(appLine);
                            } else {
                                // Create new Application Line Item
                                AOB_ApplicationLineItem__c appLine = new AOB_ApplicationLineItem__c();
                                appLine.Name = prod.Name;
                                appLine.AOB_Product__c = prod.Id;
                                if (Boolean.valueOf(appData.get(code))) {
                                    appLine.AOB_Status__c = 'Accepted';
                                } else {
                                    appLine.AOB_Status__c = 'Not Taken Up';
                                }
                                List<AOB_Application__c> salesObjectId = new SEL_AOBApplication().selectAppsById(applicationId);
                                appLine.SalesObjectItemId__c=salesObjectId[0].AOB_SalesObjectId__c;
                                appLine.AOB_Application__c = applicationId;
                                appLinesToInsert.add(appLine);
                            }
                        }
                    }
    
                    if (!appLinesToInsert.isEmpty()) {
                        insert appLinesToInsert;
                    }
                    if (!appLinesToUpdate.isEmpty()) {
                        update appLinesToUpdate;
                    }
                }
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator', ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
    
    
    /**
    * @description method to call Update Personal Details API
    * @param applicationId Id
    * @return  String
    */
    @AuraEnabled
    @SuppressWarnings('PMD.NcssMethodCount')
    public static String updatePersonalDetails(String applicationId){
        try{
            
            AOB_Internal_API_UpdatePersonalDetails customerServiceCall = new AOB_Internal_API_UpdatePersonalDetails(applicationId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_UpdatePersonalDetails.SERVICE_NAME);
            obj.CMN_TriggeringObjectId__c = applicationId;
            customerServiceCall.process(obj);
            insert obj;
            
            List<responsebody> responseList= new List<responsebody>();
            if(customerServiceCall.getResponseStatusCode()==200){
                List<AOB_Application__c> aobapplication=SEL_AOBApplication.newInstance().selectAppsById(applicationId);
                aobapplication[0].AOB_Retry_Count__c=0;
                update aobapplication;
                Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                String personalout=Json.serialize(jsonData.get('personalDetOut'));   
                Map<String, Object> personalDetOut = (Map<String, Object>)system.JSON.deserializeUntyped(personalout);
                String  personalDetailsstring= Json.serialize(personalDetOut.get('personalDetails')); 
                personalDetailsstring=personalDetailsstring.removeStart('[');
                personalDetailsstring=personalDetailsstring.removeEnd(']');   
                Map<String, Object> personalDetails = (Map<String, Object>)system.JSON.deserializeUntyped(personalDetailsstring);
                List<Object>  validationErrorsList=(List<Object>)personalDetails.get('validationErrors');
                if(validationErrorsList!=null){
                    for(Object error:validationErrorsList){
                        Map<String, Object> m = (Map<String, Object>)error;
                        responsebody resmessage= new responsebody();
                        resmessage.responseCode=customerServiceCall.getResponseStatusCode();
                        resmessage.message=(String)m.get('message');
                        responseList.add(resmessage);           
                    } 
                }else{
                    responsebody resmessageelse= new responsebody();
                    resmessageelse.responseCode=customerServiceCall.getResponseStatusCode();
                    resmessageelse.message = AOB_Internal_Constants.SUCCESSFUL;
                    responseList.add(resmessageelse);
                    
                }           
            }
            if (customerServiceCall.getResponseStatusCode() != 200) {                
                responsebody resmessage3= new responsebody();
                resmessage3.responseCode=customerServiceCall.getResponseStatusCode();
                resmessage3.message=null;
                responseList.add(resmessage3);
            }
            return Json.serialize(responseList);
        }Catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_API_UpdatePersonalDetails',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    /**
    * @description method to call Update company Details API
    * @param applicationId Id
    * @return  responseCode String
    */
    @AuraEnabled
    @SuppressWarnings('PMD.NcssMethodCount')
    public static String updateCompanyDetails(String applicationId){
        try{
        String companydetails;
        String companytradingdetails;
        String companyfinancialdetails;
        String marketingconsents;
        String preApplication;
        String resdentialData;
        String preappResponse;
        companydetails = getInflight(applicationId, AOB_Constants.COMPANY_DETAILS);  
        preappResponse=getInflight(applicationId, 'PreApplicationResponse');  
        companytradingdetails = getInflight(applicationId, AOB_Constants.COMPANY_TRADING_ADDRESS); 
        companyfinancialdetails = getInflight(applicationId, AOB_Constants.COMPANY_FINANCIAL_ADDRESS);
        resdentialData = getInflight(applicationId, AOB_Constants.RESIDENTIAL_ADDRESS); 
        marketingconsents=getInflight(applicationId,  AOB_Internal_Constants.MARKETING_CONSENT);
        preApplication=getInflight(applicationId, AOB_Constants.PRE_APPLICATION);
        AOB_API_CompanyDetails customerServiceCall = new AOB_API_CompanyDetails(applicationId,companydetails,companytradingdetails,companyfinancialdetails,marketingconsents,preApplication,resdentialData,preappResponse);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CompanyDetails.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        List<responsebody> responseList= new List<responsebody>();
        if(customerServiceCall.getResponseStatusCode()==200){
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
                    responsebody resmessage= new responsebody();
                    resmessage.responseCode=customerServiceCall.getResponseStatusCode();
                    resmessage.message=(String)m.get('message');
                    responseList.add(resmessage);           
                } 
            }else{
                responsebody resmessageelse= new responsebody();
                resmessageelse.responseCode=customerServiceCall.getResponseStatusCode();
                resmessageelse.message=null;
                responseList.add(resmessageelse);
                
            }    
            
        }
        if (customerServiceCall.getResponseStatusCode() != 200) {
            AOB_CTRL_CaseController.createCase(AOB_API_CompanyDetails.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationId);
            responsebody resmessage3= new responsebody();
            resmessage3.responseCode=customerServiceCall.getResponseStatusCode();
            resmessage3.message=null;
            responseList.add(resmessage3);
        }
        return Json.serialize(responseList);
        }Catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_API_CompanyDetails',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    /**
    * @description method to get data from application record and set default data for data prepopulation
    * @param appId string
    * @param screenName string
    * @return   String
    */  
    @AuraEnabled
    public static String setExistingData(String appId, String screenName){
        String inflightData;
        try{
            if(screenName != 'SnapScan'){
                inflightData = getInflight(appId,screenName);    
            }
            if(screenName == 'SnapScan'){
                inflightData = getInflightFromLineItem('ZPSS',appId);    
            }
            if(screenName == 'Company Details' && String.isEmpty(inflightData)){
                Map<String,Object> companyDetailsMap = new Map<String,Object>();
                String preAppData = getInflight(appId, 'PreApplication');
                Map<String,Object> preAppMap = (Map<String, object>) JSON.deserializeUntyped(preAppData);
                companyDetailsMap.put('EMAIL ADDRESS',(String)preAppMap.get('EmailAddress'));
                companyDetailsMap.put('CELLPHONE',(String)preAppMap.get('PhoneNumber'));
                inflightData = System.JSON.serialize(companyDetailsMap);
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return inflightData;
    }
    
    /**
    * @description method to get Inflight data from application line item record
    * @param prodCode 
    * @param appId 
    * @return   String
    */   
    @AuraEnabled
    public static String getInflightFromLineItem(String prodCode, String appId){
        String inflightData;
        try{
            List<AOB_ApplicationLineItem__c> apps = [SELECT Id,Details__c,AOB_ProductCode__c,AOB_Application__c 
                                                 FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c=:appId
                                                 AND AOB_ProductCode__c=:prodCode];
        if(!apps.isEmpty()){
            inflightData = apps[0].Details__c;
        }
        }
         catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return inflightData;
    }
    
    /**
    * @description method to get Inflight data from application record
    * @param appId Id
    * @param screenName
    * @return   String
    */   
    @AuraEnabled
    public static String getInflight(string appId, string screenName){
        String inflightData;
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
            if(String.isNotEmpty(apps[0].AOB_inflightData__c)){
                Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                
                for(string screen : jsonData.keyset()){
                    if(screen == screenName){
                        inflightData = System.JSON.serialize(jsonData.get(screen));
                    }
               }
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
        return inflightData;
    }
    
    /**
    * @description method to get Inflight data from application record
    * @param appId Id
    * @return  Boolean 
    */    
    @AuraEnabled(cacheable=true)
    public static Boolean isSACitizen(String appId){
        Boolean saCiziten = false;
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
            Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            if(jsonData.containsKey(AOB_Constants.PRE_APPLICATION)){
                String inflightData = System.JSON.serialize(jsonData.get(AOB_Constants.PRE_APPLICATION));
                Map<String, Object> preAppData = (Map<String, Object>)system.JSON.deserializeUntyped(inflightData);
                String idNum = (String)preAppData.get(AOB_Constants.IDNUM);
                if(idNum.substring(10,11) == '0'){
                    return true;
                }
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator: isSACitizen',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return saCiziten;
    }
    
    /**
    * @description method searching for specific key in application inflight 
    * @param appliId Id
    * @return  value of the key String
    * author Lokesh Bothsa
    */  
    @AuraEnabled
    public static String fetchApplicationInflightData(Id appliId){
        Map<String, Object> jsonMAp = new Map<String, Object>();
        Object obj;
        String cardString;
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appliId);
            jsonMAp= (map<String,Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            for(String eachstring : jsonMAp.keyset()){
                if(eachstring == AOB_Constants.CARDSELECTION){
                    obj =  jsonMAp.get(eachstring);
                    cardString = json.serialize(obj);
                }
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return cardString;
    }
    
    /**
    * @description method searching for prefered branch data 
    * @param appliId Id
    * @return  value String
    * author Lokesh Bothsa
    */
    @AuraEnabled
    public static String fetchPrefferedData(Id appliId){
        String prefBranch;
        try{
            if(appliId !=null){
                Object obj;
                Map<String, Object> jsonMAp = new Map<String, Object>();
                List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appliId);
                jsonMAp= (map<String,Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                for(String eachstring : jsonMAp.keySet()){
                    if(eachstring == AOB_Constants.COMPANY_DETAILS){
                        obj =  jsonMAp.get(eachstring);
                        prefBranch = json.serialize(obj);
                    }
                }
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        } 
        return PrefBranch;
    }
    
    /**
    * @description method searching for prefered email data 
    * @param appliId
    * @return  String
    * author Lokesh Bothsa
    */
    @AuraEnabled
    public static String fetchEmailAddressInflightData(Id appliId){
        String emailAddressOnCompanyAddr;
        try{
            Object obj;
            Map<String, Object> jsonMAp = new Map<String, Object>();
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appliId);
            jsonMAp= (map<String,Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            for(String eachstring : jsonMAp.keySet()){
                if(eachstring == AOB_Constants.COMPANY_DETAILS){
                    obj =  jsonMAp.get(eachstring);
                    emailAddressOnCompanyAddr = json.serialize(obj);
                }
            }
        }
         catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('exception '+ex.getMessage());  
        }    
        return emailAddressOnCompanyAddr;
    }
    
    /**
    * @description method searching for selectedAvaialbleBundles
    * @param appliId
    * @return  value String
    * author Lokesh Bothsa
    */
    @AuraEnabled
    public static String selectedAvailableBundles(Id appliId) {
    String availableBundleRecs = '';
    try {
        Map<String, Object> jsonMAp = new Map<String, Object>();
        List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appliId);
        jsonMAp = (Map<String, Object>) system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);

        if (jsonMAp.containsKey(AOB_Constants.AVALIBLE_BUNDLES)) {
            availableBundleRecs = json.serialize(jsonMAp.get(AOB_Constants.AVALIBLE_BUNDLES));
        }
    }
    catch (Exception ex) {
        LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator', ex.getMessage()}, ex);
        return '{"error": "There were no available bundles found, Contact your admnistrator: ' + ex.getMessage() + '"}';
    }
    return availableBundleRecs;
}
    /**
    * @description method searching for updateDeletedBundles
    * @param applicationId
    * @param itemToDelete
    */
    @AuraEnabled
    public static void updateDeletedBundles(Id applicationId, String itemToDelete) {
        String updatedBundles='';
        Map<String, Object> jsonMAp = new Map<String, Object>();
        try {
            String selectedBundles = AOB_Internal_CTRL_FormCreator.selectedAvailableBundles(applicationId);
            jsonMAp = (Map<String, Object>) system.JSON.deserializeUntyped(selectedBundles);
            if (jsonMAp.containsKey(itemToDelete)) {
                jsonMAp.remove(itemToDelete); // Remove the key-value pair from the map
            }
            updatedBundles=JSON.serialize(jsonMAp);
            AOB_Internal_CTRL_FormCreator.updateAvailableBundles(applicationId,updatedBundles);
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator', ex.getMessage()}, ex);
        }
    }



    
    /**
    * @description method fetching phone number inflight data of application
    * @param appId
    * @return  value String
    * author Lokesh Bothsa
    */
    @AuraEnabled
    public static String fetchPhoneNumber(Id appId){
        String mobileNumber;
        try{
            Object obj;
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
            Map<String, Object> jsonMAp= (map<String,Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            for(String eachstring : jsonMAp.keySet()){
                if(eachstring == AOB_Constants.PRE_APPLICATION){
                    obj =  jsonMAp.get(eachstring);
                    mobileNumber = json.serialize(obj);                  
                }
            }
        }catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return mobileNumber; 
    }
    
    /**
    * @description method fetching pocktbiz data from application's line item
    * @param applicationId 
    * @return  String 
    * author Lokesh Bothsa
    *Modification Lof
    *Tukelo - updated method to used product Code instead of Name
    */
    @AuraEnabled
    public static String fetchPocketBizDetails(String applicationId){
        try{
            List<AOB_ApplicationLineItem__c> lineItemPocketbiz = new SEL_AOBApplicationLineItem().selectAppLineItemsByAppIdAndProductCodes(applicationId, new List<String>{AOB_Internal_Constants.POCKETBIZ_CODE});
            if(lineItemPocketbiz.size() > 0){
                return lineItemPocketbiz[0].Details__c;
            }
        }catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator: fetchPocketBizDetails',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    } 
    /**
    * @description method fetching pocktbiz data from application's line item
    * @param merchantCode 
    * @return string 
    */
    @AuraEnabled
    public static string fetchPocketBizMerchant(String merchantCode){

        List<AOB_ReferencedData__c> referenceDataList;
        
        String language=AOB_UTILS.getUserLanguage();

        try{
            referenceDataList = [SELECT Name
                                 FROM AOB_ReferencedData__c
                                 WHERE (AOB_Code__c =:merchantCode AND AOB_Language__c=:language)
                                 WITH SECURITY_ENFORCED
                                 ORDER BY Name];
        }
        catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return referenceDataList[0].Name;
    }

    /**
    * @description method fetching main line item from application
    * @param applicationId 
    * @return  AOB_ApplicationLineItem__c Object
    * author Lokesh Bothsa
    */
    @AuraEnabled
    public static AOB_ApplicationLineItem__c getMainLineItem(Id applicationId){
        AOB_ApplicationLineItem__c result = null;
        try {
            for (AOB_ApplicationLineItem__c appLI : new SEL_AOBApplicationLineItem().selectAppLineItemsById(applicationId)) {
                if(appLI.AOB_Main__c == true){
                    result = appLI;
                    break;
                }
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return result;
    }
    
    /**
    * @description method to deselect cross sell items based on summary screen
    * @param appId 
    * @param prodToDelete List
    */
    @AuraEnabled    
    public static void removeSummaryProduct(String appId,List<String> prodToDelete){
        try{
            if(prodToDelete.size()>0){
                List<AOB_ApplicationLineItem__c> appLineItems = [SELECT Id,AOB_Status__c,AOB_ProductCode__c, AOB_ExpiryDate__c,AOB_Application__c 
                                                                 FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c=:appId
                                                                 AND AOB_ProductCode__c IN:prodToDelete];
                for(AOB_ApplicationLineItem__c appItem :appLineItems){
                    appItem.AOB_Status__c = 'Not Taken Up';
                    appItem.Details__c = '';
                }
                update appLineItems;
            }
        }catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
    * @description method to update the infligh data of the application
    * @param code of the change
    * @param json string to merged on the inflight data
    * @param applicationId
    */
    @AuraEnabled
    public static void updateinflight(String code,String json,String applicationId){
        try{
            List<AOB_ApplicationLineItem__c> appLineItem = new SEL_AOBApplicationLineItem().selectAppLineItemsByIdAndProductCode(applicationId,code);
        if(appLineItem[0].AOB_ProductCode__c != 'ZBCH'){
            Map<String, Object> jsonMApping = new Map<String, Object>();
            jsonMApping.put(appLineItem[0].Name,json);
            appLineItem[0].Details__c='{"'+appLineItem[0].Name+'":'+json+'}';
                    appLineItem[0].Details__c=json;
        }

        if(appLineItem[0].AOB_ProductCode__c == 'ZBCH'){
            Map<String, Object> jsonMap=(Map<String, Object>)System.JSON.deserializeUntyped(json);
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            Map<String, Object> inflightData=(Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            jsonMap.remove('addressValue');
            if(jsonMap.containsKey('Deliver Address')){
                if((String)jsonMap.get('Deliver Address') == 'Residential'){ 
                    jsonMap.put('addressValue',inflightData.get('Residential Address'));
                }
                else if((String)jsonMap.get('Deliver Address') == 'Company'){
                    Map<String,Object> compTradingMap = (Map<String, Object>)inflightData.get('Company Trading Address');
                    if(compTradingMap.get('addressType') == 'Same'){
                        jsonMap.put('addressValue',inflightData.get('Residential Address'));
                    }
                    else{
                        compTradingMap.remove('AddressType');
                        compTradingMap.remove('AddressValue');
                        jsonMap.put('addressValue',compTradingMap);
                    }
                }
           }   
            appLineItem[0].Details__c=System.JSON.serialize(jsonMap);
            appLineItem[0].AOB_Status__c = 'Accepted';
        }
        update appLineItem;
        }catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('Exception occured '+ex.getMessage());  
        }
    }   
    
    /**
    * @description used to populate jsonMap with address - helps with AvoidDeeplyNestedIfStmts
    * @author Tukelo Moseamo | 04-12-2023 
    * @param jsonMap 
    * @param inflightData 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> populateAddress(Map<String, Object> jsonMap,Map<String, Object> inflightData) {
        if((String)jsonMap.get('Deliver Address') == 'Residential'){ 
            jsonMap.put('addressValue',inflightData.get('Residential Address'));
        }
        else if((String)jsonMap.get('Deliver Address') == 'Company'){
            Map<String,Object> compTradingMap = (Map<String, Object>)inflightData.get('Company Trading Address');
            if(compTradingMap.get('addressType') == 'Same'){
                jsonMap.put('addressValue',inflightData.get('Residential Address'));
            }
            else{
                compTradingMap.remove('AddressType');
                compTradingMap.remove('AddressValue');
                jsonMap.put('addressValue',compTradingMap);
            }
        }
        return jsonMap;
    }
    
    /**
    * @description response class wrapper
    */
    public class Responsebody{
        Integer responseCode;
        String message;
    }
     
    /**
 * @description Retrieves a list of open AOB_Application__c objects associated with the given registration number.
 * @param registration The registration number associated with the applications.
 * @return List<AOB_Application__c> A list of open AOB_Application__c objects associated with the registration number.
 * @throws AuraHandledException if no open applications are found for the given registration number.
 */
    @AuraEnabled
    public static List<AOB_Application__c> getOpenApplications(String registration){
    	Set<String> reg=new Set<String>();
    	reg.add(registration);
    	List<Account> account= new SEL_Accounts().selectByRegistrationNumber(reg);
        List<AOB_Application__c> applications=new List<AOB_Application__c>();
        List<AOB_Application__c> applicationssInprogress=new List<AOB_Application__c>();
        List<AOB_Application__c> applicationssNew=new List<AOB_Application__c>();
			for(Account acc:account){
                applicationssInprogress= new SEL_AOBApplication().selectAppsByClientStatus(acc.Id,'In Progress');
                applicationssNew= new SEL_AOBApplication().selectAppsByClientStatus(acc.Id,'New');
                applications.addAll(applicationssInprogress);
                applications.addAll(applicationssNew);
        	}
	
        if(applications.isEmpty()){
            throw new AuraHandledException('No Records Found..');
        }
    return applications;
    }
    
    /**
    * @description method to update the the current screen of the application
    * @param applicationId
    * @param currentScreen
    * @param previousScreen
    */
    @AuraEnabled
    public static void updateScreen(String applicationId,String currentScreen,String previousScreen){
         List<AOB_Application__c> app = new SEL_AOBApplication().selectAppsById(applicationId);
            if(!app.isempty()){
            app[0].AOB_CurrentScreen__c=currentScreen;
            update app;
            }       
    }
    
    /**
    * @description method to update the the previous screen of the application
    * @param applicationId
    * @param currentScreen
    * @param previousScreen
    */
    @AuraEnabled
    public static void updatePreviousScreen(String applicationId,String currentScreen,String previousScreen){
        List<AOB_Application__c> app = SEL_AOBApplication.newInstance().selectAppsById(applicationId);
            if(!app.isempty()){
            app[0].AOB_CurrentScreen__c=previousScreen;
            update app;
            }             
    }
    
    /**
    * @description method to get the application line item name and status
    * @param recordId of the application line item
    * @return Map<String,String> a map of name and status of the application line item
    */
    @AuraEnabled
    public static Map<String,String> getApplicationLineItem(String recordId){
        List<AOB_ApplicationLineItem__c> applines = new SEL_AOBApplicationLineItem().selectAppLineItemsById(recordId);

        Map<String, String> nameStatusMap = new Map<String, String>();
        
        for (AOB_ApplicationLineItem__c appLine : applines) {
            nameStatusMap.put(appLine.Name, appLine.AOB_Status__c);
        }
        
        return nameStatusMap;
    }
	/**
 	* @description Updates the details and status of an AOB_ApplicationLineItem__c object based on the provided code, JSON data, and application ID.
 	* @param code          The product code associated with the application line item.
 	* @param json          The JSON data to update the application line item details.
 	* @param applicationId The ID of the application associated with the application line item.
 	* @throws AuraHandledException if an exception occurs during the update process.
 	*/
    @AuraEnabled
    public static void updateinfilght(String code,String json,String applicationId){
        try{
            List<AOB_ApplicationLineItem__c> appLineItem= new SEL_AOBApplicationLineItem().selectAppLineItemsByIdAndProductCode(applicationId,code);
         
        if(appLineItem[0].AOB_ProductCode__c != 'ZBCH'){
            appLineItem[0].Details__c=json;
        }
        if(appLineItem[0].AOB_ProductCode__c == 'ZBCH'){
            Map<String, Object> jsonMap=(Map<String, Object>)System.JSON.deserializeUntyped(json);
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            Map<String, Object> inflightData=(Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            jsonMap.remove('addressValue');
            if(jsonMap.containsKey('Deliver Address')){
                if((String)jsonMap.get('Deliver Address') == 'Residential'){ 
                    jsonMap.put('addressValue',inflightData.get('Residential Address'));
                }
                else if((String)jsonMap.get('Deliver Address') == 'Company'){
                    Map<String,Object> compTradingMap = (Map<String, Object>)inflightData.get('Company Trading Address');
                    if(compTradingMap.get('AddressType') == 'Same'){
                        jsonMap.put('addressValue',inflightData.get('Residential Address'));
                    }
                    else{
                        compTradingMap.remove('AddressType');
                        compTradingMap.remove('AddressValue');
                        jsonMap.put('addressValue',compTradingMap);
                    }
                }
            }   
            appLineItem[0].Details__c=System.JSON.serialize(jsonMap);
            appLineItem[0].AOB_Status__c = 'Accepted';
        }
        update appLineItem;
        }catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('Exception occured '+ex.getMessage());  
        }
    }

    /**
    * @description updates the company Details Ran node when company details API gets called 
    * @author Tukelo Moseamo | 06-29-2023 
    * @param  applicationId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean isNewCompanyRan(String applicationId) { 
        try
		{
            Boolean isNew = true;

            String companyDetailRan = getInflight(applicationId, AOB_Internal_Constants.COMPANYDETAILRAN); 

            if (String.isBlank(companyDetailRan)) {
                AOB_Application__c applicationRec = new SEL_AOBApplication().selectAppsById(applicationId).iterator().next();
                // String inflight = applicationRec?.AOB_inflightData__c;
                CompanyDetailRan compDetail = new CompanyDetailRan();
                compDetail.ran = true;

                String tempInflight = applicationRec.AOB_inflightData__c.substringAfter('{');
                applicationRec.AOB_inflightData__c = '{"' + AOB_Internal_Constants.COMPANYDETAILRAN + '":' + JSON.serialize(compDetail) + ',' + tempInflight;

                update applicationRec;
            }
            else {
                isNew = false;
            }

            return isNew;
        }
        catch(Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('Exception occured '+ex.getMessage());  
        }
    }

    /**
    * @description gets a list of directors from inflight number
    * @author Tukelo Moseamo | 06-29-2023 
    * @param  applicationId 
    * @return List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail>
    **/
    @AuraEnabled
    public static List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> getDirectorDetails(String applicationId) {
        AOB_Application__c application = new SEL_AOBApplication().selectAppsById(applicationId).iterator()?.next();

        if (application != null) {
        String inflightData = application.AOB_inflightData__c.contains(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE) ? application.AOB_inflightData__c.replace(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE, CMN_UTIL_String.EMPTY)
					: application.AOB_inflightData__c;

        Map<String, Object> inflightDataMap = (Map<String, Object>)JSON.deserializeUntyped(inflightData);

        AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

            List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetailsList = preApplicationResponse?.cipcRegisteredDetails?.directorDetails;
            
            if (directorDetailsList != null) {
                
                return directorDetailsList;
            }
        } 
        
        return new List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail>(); 
    }
    
    /**
    * @description updates the company Details Ran node when company details API gets called 
    * @author Tukelo Moseamo | 06-29-2023 
    */
    public class CompanyDetailRan{
        public Boolean ran;
        public Boolean isSuccessful; 
    }
}