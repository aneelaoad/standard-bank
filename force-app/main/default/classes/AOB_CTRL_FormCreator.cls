/***************************************************************************************
@Author            : Salesforce
@Date              : Oct 7th 2021
@Name of the Class : AOB_CTRL_FormCreator
@description       : Class for generic form creation based on database records	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public with sharing class AOB_CTRL_FormCreator {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_FormCreator');
    private static final String AO_STAGE ='AO Journey Initiated';
    
    /**
    * @description gets a list of fields to be displayed based on screen and product
    * @param applicationId  - Id of the Community
    * @param screenName - Auth Provider user data describing the User to create
    * @return AOB_DTO_Form 
    */
    @AuraEnabled
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
    * @param screens - List<AOB_FlowScreen__c>
    * @param applicationId - Id
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
    * @param screens - List<AOB_FlowScreen__c>
    * @param apps - List<AOB_Application__c>
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
    * @return AOB_DTO_Section
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
    public static void setApplicationData(Id applicationId,String appData){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            if(apps[0].AOB_CurrentScreen__c != AOB_Constants.POCKETBIZ && apps[0].AOB_CurrentScreen__c != AOB_Constants.SNAPSCAN){
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
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
                apps[0].PreApp_Stages__c = AO_STAGE;
                List<Lead> lobj = [SELECT Id, Status FROM Lead  WHERE Id=:apps[0].Lead__c];
                if(lobj[0].Status != 'Closed'){ 
                    lobj[0].Status = 'Closed';
                    update  lobj;
                }
                
            }
            update apps;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    } 
    
    /**
    * @description to clear  ChequeCardInflight
    * @param applicationId Id
    */
    @AuraEnabled
    public static void clearChequeCardInflight(Id applicationId){
        try{
            List<AOB_ApplicationLineItem__c> applineItem=[select Id,AOB_Status__c,Details__c,AOB_ProductCode__c, AOB_ExpiryDate__c,AOB_Application__c from AOB_ApplicationLineItem__c where AOB_Application__c=:applicationId and AOB_ProductCode__c='ZBCH'];
            if(!applineItem.isEmpty()){  
                if(applineItem[0].AOB_Status__c != 'Not Taken Up'){
                    applineItem[0].AOB_Status__c = 'Not Taken Up';
                    applineItem[0].Details__c = '';
                }
                update applineItem;
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description create ApplicationLineItems 
    * @param applicationId Id
    * @param items String
    */
    @AuraEnabled
    public static void createApplicationLineItems(Id applicationId, String items){
        try{
            if(!String.isEmpty(items)){
                Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(items);
                List<String> productCode=new List<String>();
                for(String pdc:appData.keySet()){
                    if(Boolean.ValueOf(appData.get(pdc))==true){
                        productCode.add(pdc);
                    }
                }
                Set<String> prodCodes = new Set<String>();
                prodCodes.add('4488');
                prodCodes.add('ZPOB');
                prodCodes.add('ZPSS');   
                List<AOB_ApplicationLineItem__c> updateLineItems= new List<AOB_ApplicationLineItem__c>();
                List<AOB_ApplicationLineItem__c> applineItem=[select Id,AOB_Status__c,AOB_ProductCode__c, AOB_ExpiryDate__c,AOB_Application__c from AOB_ApplicationLineItem__c where AOB_Application__c=:Applicationid and AOB_ProductCode__c IN:prodCodes];
                for(AOB_ApplicationLineItem__c app:applineItem){
                    if(productCode.Contains(app.AOB_ProductCode__c)){
                        app.AOB_Status__c='Accepted';
                    }else{
                        app.AOB_Status__c='Not Taken Up';
                        app.Details__c='';
                    }
                    
                    updateLineItems.add(app);
                }
                
                Update updateLineItems;
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description method to call Update Personal Details API
    * @param applicationId String
    * @return  String
    */
    @AuraEnabled
    public static String updatePersonalDetails(String applicationId){
        try{
            String personalData;
            String resdentialData;
            String employementData;
            String preapplication;
            String requestBody;
            String preappResponse;
            String totalResponse;
            personalData = getInflight(applicationId, AOB_Constants.PERSONAL_DETAILS);
            preappResponse=getInflight(applicationId, 'PreApplicationResponse');     
            resdentialData = getInflight(applicationId, AOB_Constants.RESIDENTIAL_ADDRESS); 
            employementData = getInflight(applicationId, AOB_Constants.EMPLOYMENT_DETAILS); 
            preapplication = getInflight(applicationId, AOB_Constants.PRE_APPLICATION); 
            AOB_DTO_UpdatePersonalDetails rp = new AOB_DTO_UpdatePersonalDetails(personalData,resdentialData,employementData, preapplication, applicationId,preappResponse);
            requestBody = JSON.serialize(rp);
            AOB_API_UpdatePersonalDetails customerServiceCall = new AOB_API_UpdatePersonalDetails(requestBody);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_UpdatePersonalDetails.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            List<ResponseBody> responseList= new List<ResponseBody>();
            if(customerServiceCall.getResponseStatusCode()==200){
                List<AOB_Application__c> aobapplication=[select id, AOB_inflightData__c,AOB_Retry_Count__c,AOB_Client__r.Name,AOB_ProcessId__c,AOB_SalesObjectId__c,AOB_InflightDataID__c from AOB_Application__c where id =:applicationId];
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
                AOB_CTRL_CaseController.createCase(AOB_API_UpdatePersonalDetails.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationId);
                
                ResponseBody resmessage3= new ResponseBody();
                resmessage3.responseCode=customerServiceCall.getResponseStatusCode();
                resmessage3.message=null;
                responseList.add(resmessage3);
            }
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c+ ' \n Validations :'+ Json.serialize(responseList);
            AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
            return Json.serialize(responseList);
        }Catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_API_UpdatePersonalDetails',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    /**
    * @description method to call Update company Details API
    * @param applicationId String
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
        String totalResponse;
        companydetails = getInflight(applicationId, AOB_Constants.COMPANY_DETAILS);  
        preappResponse=getInflight(applicationId, 'PreApplicationResponse');  
        companytradingdetails = getInflight(applicationId, AOB_Constants.COMPANY_TRADING_ADDRESS); 
        companyfinancialdetails = getInflight(applicationId, AOB_Constants.COMPANY_FINANCIAL_ADDRESS);
        resdentialData = getInflight(applicationId, AOB_Constants.RESIDENTIAL_ADDRESS); 
        marketingconsents=getInflight(applicationId,  AOB_Constants.MARKETING_CONSENT);
        preApplication=getInflight(applicationId, AOB_Constants.PRE_APPLICATION);
        AOB_API_CompanyDetails customerServiceCall = new AOB_API_CompanyDetails(applicationId,companydetails,companytradingdetails,companyfinancialdetails,marketingconsents,preApplication,resdentialData,preappResponse);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CompanyDetails.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        List<ResponseBody> responseList= new List<ResponseBody>();
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
            AOB_CTRL_CaseController.createCase(AOB_API_CompanyDetails.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationId);
            ResponseBody resmessage3= new ResponseBody();
            resmessage3.responseCode=customerServiceCall.getResponseStatusCode();
            resmessage3.message=null;
            responseList.add(resmessage3);
        }
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c+ ' \n Validations :'+ Json.serialize(responseList);
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        return Json.serialize(responseList);
        }Catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_API_CompanyDetails',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    /**
    * @description get Applicant data required for adobe tagging
    * @param applicationId String
    * @return String
    */
    @AuraEnabled
    public static String getApplicantDataForAdobe(String applicationId){
        String adobeData;
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            Map<String, Object> adobeTaggingData = new Map<String, Object>();
            if(!apps.isEmpty()){
                Map<String, Object> inflightData =(Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                if(inflightData.containsKey('PreApplicationResponse')){
                    Map<String, Object> preAppRespone =(Map<String, Object>)inflightData.get('PreApplicationResponse');
                    Map<String, Object> preAppData =(Map<String, Object>)inflightData.get('PreApplication');

                    Blob verifierCode = Blob.valueOf((string)preAppData.get('EmailAddress'));

                    Blob hash = Crypto.generateDigest('SHA-256', verifierCode);
                
                    String challenge = EncodingUtil.base64Encode(hash);

                   
                    adobeTaggingData.put('customerGUID',preAppRespone.get('initiatorBPGUID'));
                    adobeTaggingData.put('customerEmail',challenge);
                    adobeData = System.JSON.serialize(adobeTaggingData);
                }
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('update exception msg'+ex.getMessage());  
        }
        return adobeData;
    }
    
    /**
    * @description method to get data from application record and set default data for data prepopulation
    * @param appId String
    * @param screenName string
    * @return String
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
                if(String.isEmpty(inflightData)){
                    Map<String,Object> snapScanDetailsMap = new Map<String,Object>();
                    String preAppData = getInflight(appId, 'PreApplication');
                    Map<String,Object> preAppMap = (Map<String, object>) JSON.deserializeUntyped(preAppData);
                    snapScanDetailsMap.put('COMPANY TRADING NAME',(String)preAppMap.get('businessName'));
                    snapScanDetailsMap.put('EMAIL ADDRESS',(String)preAppMap.get('EmailAddress'));
                    inflightData = System.JSON.serialize(snapScanDetailsMap);
                }
            }
            if(screenName == 'Company Details' && String.isEmpty(inflightData)){
                Map<String,Object> companyDetailsMap = new Map<String,Object>();
                String preAppData = getInflight(appId, 'PreApplication');
                Map<String,Object> preAppMap = (Map<String, object>) JSON.deserializeUntyped(preAppData);
                companyDetailsMap.put('EMAIL ADDRESS',(String)preAppMap.get('EmailAddress'));
                companyDetailsMap.put('CELLPHONE',(String)preAppMap.get('PhoneNumber'));
                companyDetailsMap.put('COUNTRY OF REGISTRATION','ZA');
                inflightData = System.JSON.serialize(companyDetailsMap);
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return inflightData;
    }
    
    /**
    * @description method to get Inflight data from application line item record
    * @param prodCode String
    * @param appId String
    * @return String
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return inflightData;
    }
    
    /**
    * @description method to get AcceptedLineItems from application record
    * @param appId Id
    * @return List<AOB_ApplicationLineItem__c>
    */ 
    @AuraEnabled
    public static List<AOB_ApplicationLineItem__c> getAcceptedLineItems(String appId){
        try{
            List<AOB_ApplicationLineItem__c> apps = [SELECT Id,SalesObjectItemId__c,AOB_Status__c,AOB_ProductCode__c,AOB_Application__c 
                                                 FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c=:appId
                                                 AND AOB_Status__c='Accepted'];
        if(!apps.isEmpty()){
            return apps;
        }
        }
         catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return null;
    }
    
    /**
    * @description method to get Inflight data from application record
    * @param appId Id
    * @param screenName String
    * @return String
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator: goBacktoPreviousStep',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
        return inflightData;
    }
    
    /**
    * @description method to get Inflight data from application record
    * @param appId Id
    * @return Boolean 
    */   
    @AuraEnabled
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator: isSACitizen',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return saCiziten;
    }
    
    /**
    * @description method searching for specific key in application inflight 
    * @param appliId Id
    * @return String
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return cardString;
    }
    
    /**
    * @description method searching for prefered branch data 
    * @param appliId Id
    * @return String
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return PrefBranch;
    }
    
    /**
    * @description method searching for prefered email data 
    * @param appliId Id
    * @return String
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('exception '+ex.getMessage());  
        }    
        return emailAddressOnCompanyAddr;
    }
    
    /**
    * @description method searching for selectedAvaialbleBundles
    * @param appliId Id
    * @return String
    */
    @AuraEnabled
    public static String selectedAvaialbleBundles(Id appliId){
        String  availableBundleRecs;
        try{
            Object obj;
            Map<String, Object> jsonMAp = new Map<String, Object>();
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appliId);
            jsonMAp= (map<String,Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            for(String eachstring : jsonMAp.keySet()){
                if(eachstring == AOB_Constants.AVALIBLE_BUNDLES){
                    obj = jsonMAp.get(eachstring);
                    availableBundleRecs = json.serialize(obj);
                }
            }
            String getselectcard=getselectcard(appliId);
            if(getselectcard !=null){
                getselectcard=getselectcard.removeStart('{');
                availableBundleRecs=availableBundleRecs.removeEnd('}');
                if(availableBundleRecs != '{'){
                availableBundleRecs=availableBundleRecs+','+getselectcard;
                }else{
                    availableBundleRecs = availableBundleRecs+getselectcard;
                }
            }
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('exception '+ex.getMessage());  
        } 
        return availableBundleRecs;
    }
    
    /**
    * @description method fetching phone number inflight data of application
    * @param appId Id
    * @return String
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return mobileNumber; 
    }
    
    /**
    * @description method fetching pocktbiz data from application's line item
    * @param appplicationId Id
    * @return String
    */
    @AuraEnabled
    public static String fetchPocketBizDetails(String appplicationId){
        try{
            AOB_ApplicationLineItem__c lineItemPocketbiz = [SELECT Id,Name,Details__c,AOB_Application__c FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c=:appplicationId AND Name='PocketBiz'];
            if(lineItemPocketbiz != null){
                return lineItemPocketbiz.Details__c;
            }
        }catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    } 
    
    /**
    * @description method fetching main line item from application
    * @param applicationId Id
    * @return  AOB_ApplicationLineItem__c Object
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return result;
    }
    
    /**
    * @description method to deselect cross sell items based on summary screen
    * @param appId Id
    * @param prodToDelete List<String>
    */
    @AuraEnabled    
    public static void removeSummaryProduct(String appId,List<String> prodToDelete){
        try{
            if(prodToDelete.size()>0){
                List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
                Map<String, Object> jsonMAp= (map<String,Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                if(jsonMAp.containsKey('Available Bundles')){
                    Map<String, Object> bundlesData = (Map<String, Object>)jsonMAp.get('Available Bundles');
                    for(String key : bundlesData.keySet()){
                        if(prodToDelete.Contains(key)){
                            bundlesData.put(key,false);
                        }
                        
                    }
                    jsonMAp.put('Available Bundles',bundlesData);
                    if(prodToDelete.contains('ZPOB')){
                        String screen = 'PocketBiz';
                        apps[0].AOB_PreviousScreens__c = apps[0].AOB_PreviousScreens__c.replace(';'+screen,'').replace(screen,'');
                    }
                    if(prodToDelete.contains('ZPSS')){
                        String screen = 'SnapScan';
                        apps[0].AOB_PreviousScreens__c = apps[0].AOB_PreviousScreens__c.replace(';'+screen,'').replace(screen,'');
                    }
                }
                apps[0].AOB_inflightData__c = System.JSON.serialize(jsonMAp);
                update apps;
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
    * @description method to update application status to 'Approved'
    * @param appId Id
    * @param screenName String
    * @param previousScreen String
    */
    @AuraEnabled    
    public static void updateApplicationStatus(String appId, String screenName, String previousScreen){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
            apps[0].AOB_Status__c = 'Approved';
            apps[0].AOB_CurrentScreen__c=screenName;
            apps[0].AOB_PreviousScreen__c=previousScreen;
            update apps;
        }catch(Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
    * @description method searching for prefered branch data
    * @param code String
    * @param json String
    * @param applicationId String
    */
    @AuraEnabled
    public static void updateinfilght(String code,String json,String applicationId){
        try{
            List<AOB_ApplicationLineItem__c> appLineItem = [select Id,AOB_Status__c,SalesObjectItemId__c,AOB_ExpiryDate__c,
                                                        AOB_Product__c,AOB_Application__c,name,Details__c,
                                                        AOB_ProductCode__c,AOB_Product__r.Name 
                                                        from AOB_ApplicationLineItem__c  where AOB_Application__c=:applicationId
                                                        AND AOB_ProductCode__c=:code];
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
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException('Exception occured '+ex.getMessage());  
        }
    }         
    
    /**
    * @description method searching for prefered branch data
    * @param applicationId is the application record
    * @return  value String
    */
    @AuraEnabled
    public static String getselectcard(String applicationId){
        String selectedCard;
        try{
            String cardselection=getInflight(applicationId,'Card Selection');
            selectedCard=cardselection;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        return selectedCard;
    }
    /**
    * @description method to update the API service and response code in application
    * @param applicationId id
    * @param totalResponse API_Response
    */
     public static void updateApiService(String applicationId, String  totalResponse){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            apps[0].Recent_API_Service__c = totalResponse;
            update apps;
        }catch(Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_FormCreator.updateApiService',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
    * @description wrapper class to hold response
    */
    public class ResponseBody{
        Integer responseCode;
        String message;
    }
}