/***************************************************************************************
@Author            : Devi Ravuri
@Date              : 02-10-2023
@Name of the Class : AOB_FLOW_LinkAccountToApplicationMall
@description       : Class for Linking Application and Account
***************************************************************************************/
public without sharing class AOB_FLOW_LinkAccountToApplicationMall{
    private static final String CHANNEL_NAME='Mall';
     /**
    * @description	used to linkAppWithAccount 
    * @param appIds
    * @return List<String>
    */
    @AuraEnabled
    public static List<String> linkAppWithAccount(String appIds){
        try{
            List<String> result = new List<String>();
            Map<String, Object> preAppResponse;
            Map<String, Object> preAppData;
            Map<String, Object> inflight;
            AOB_OnboardingSetting__mdt setting = AOB_Utils.getOnboardingSettings(AOB_Constants.SB_COZA);
            Id applicationId = appIds;
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            User userRec = [Select Id, AccountId,contactId from User Where Id=:UserInfo.getUserId()];
            
            Contact userContact = [Select Id, FirstName,LastName,ExternalIdentifier__c,ExternalCIFId__c, ExternalCIFUUID__c,  Email,Identity_Number__c
                                            from Contact where Id=:userRec.contactId];
          
            Account userAccount =[Select Id,ExternalCIFCountry__c,ExternalSystemId__c,ExternalIdentifier__c,ExternalCIFUUID__c,
                                    Registration_Number__c, Name from Account Where Id=:userRec.AccountId];
            
            inflight = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
            
            if(inflight.containsKey(AOB_Constants.PRE_APPLICATION)){
                preAppData = (Map<String, Object>)inflight.get(AOB_Constants.PRE_APPLICATION);
            }
            if(inflight.containsKey(AOB_Constants.PRE_APP_RESPONSE)){
                    preAppResponse = (Map<String, Object>)inflight.get(AOB_Constants.PRE_APP_RESPONSE);
            }
            if(!apps.isEmpty()){ 
                String contExtIdentifier = setting.AOB_CountryCode__c + setting.AOB_SystemId__c +
                                                (String)preAppResponse.get(AOB_Constants.INITIATOR_BPID);
                        if(contExtIdentifier != null){
                            List<Contact> conts = [SELECT Id,ExternalSystemId__c,ExternalIdentifier__c, RecordType.Name 
                                                        FROM Contact WHERE ExternalIdentifier__c =:contExtIdentifier 
                                                            AND RecordType.Name='Client Contact Record Type'];
                            if(conts.isEmpty()){
                              
                                userContact.ExternalIdentifier__c = contExtIdentifier;
                                userContact.ExternalCIFId__c =(String) preAppResponse.get(AOB_Constants.INITIATOR_BPID);
                                userContact.ExternalCIFUUID__c = (String) preAppResponse.get(AOB_Constants.INITIATOR_BPGUID);
                                userContact.LastName = (String) preAppData.get(AOB_Constants.SURNAME);
                                userContact.FirstName =(String)  preAppData.get(AOB_Constants.NAME);
                                userContact.Email =(String)  preAppData.get(AOB_Constants.EMAIL);
                                userContact.Identity_Number__c = (String) preAppData.get(AOB_Constants.IDNUM);
                                update  userContact;                            
                            }
                            else{
                                userContact.ExternalCIFId__c =(String) preAppResponse.get(AOB_Constants.INITIATOR_BPID);
                                userContact.ExternalCIFUUID__c = (String) preAppResponse.get(AOB_Constants.INITIATOR_BPGUID);
                                userContact.LastName = (String) preAppData.get(AOB_Constants.SURNAME);
                                userContact.FirstName =(String)  preAppData.get(AOB_Constants.NAME);
                                userContact.Email =(String)  preAppData.get(AOB_Constants.EMAIL);
                                userContact.Identity_Number__c = (String) preAppData.get(AOB_Constants.IDNUM);
                                update  userContact;   
                            }
                        }
               
                    String acctExtIdentifier = setting.AOB_CountryCode__c + setting.AOB_SystemId__c + (String)preAppResponse.get(AOB_Constants.BUSINESS_BPID);
               
                        List<Account> accs = [SELECT Id,ExternalCIFCountry__c ,ExternalSystemId__c,ExternalIdentifier__c ,RecordType.Name
                                                FROM Account WHERE ExternalIdentifier__c =:acctExtIdentifier];
                        if(accs.isEmpty()){
                          
                            userAccount.ExternalIdentifier__c = acctExtIdentifier;
                            userAccount.ExternalCIF_Id__c = (String) preAppResponse.get(AOB_Constants.BUSINESS_BPID);
                            userAccount.ExternalCIFUUID__c =(String)  preAppResponse.get(AOB_Constants.BUSINESS_BPGUID);
                            userAccount.Name = (String) preAppData.get(AOB_Constants.BUSINESS_NAME);
                            userAccount.Registration_Number__c = String.isEmpty((String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM))?
                                                                        (String)preAppData.get(AOB_Constants.IDNUM) : 
                                                                        (String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM);
                            
                            update userAccount;
                            apps[0].AOB_Client__c = userAccount.Id;
                            update apps;
                        
                        }else{
                            userAccount.ExternalCIF_Id__c = (String) preAppResponse.get(AOB_Constants.BUSINESS_BPID);
                            userAccount.ExternalCIFUUID__c =(String)  preAppResponse.get(AOB_Constants.BUSINESS_BPGUID);
                            userAccount.Name = (String) preAppData.get(AOB_Constants.BUSINESS_NAME);
                            userAccount.Registration_Number__c = String.isEmpty((String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM))?
                                                                        (String)preAppData.get(AOB_Constants.IDNUM) : 
                                                                        (String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM);
                            
                            update userAccount;
                            apps[0].AOB_Client__c = userAccount.Id;
                            update apps;
                        }
            }
            return result;
        }   	
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());  
        }

    }

    /**
    * @description	used to checkForOpenApplication 
    * @param pricingOption
    * @return String
    */
    @AuraEnabled
    public static String checkForOpenApplication(String pricingOption){
        String applicationId;
        User userRec = [Select Id, AccountId,contactId from User Where Id=:UserInfo.getUserId()];
        List<AOB_ApplicationLineItem__c> appLineItems = [select id, AOB_Application__c from AOB_ApplicationLineItem__c where AOB_Product__r.name=:AOB_Constants.PRODUCTNAME and AOB_Pricing_Option__c=:pricingOption and AOB_Application__c in (select Id from AOB_Application__c where AOB_Client__c=:userRec.AccountId and SBG_Channel__c =:CHANNEL_NAME and AOB_Status__c =:AOB_Constants.IN_PROGRESS)];        
        if(appLineItems.size()>0){
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appLineItems[0].AOB_Application__c);
            Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c); 
            if(jsonData.containsKey(AOB_Constants.PRE_APP_RESPONSE)){
                applicationId=appLineItems[0].AOB_Application__c;
            }
        } 
        return applicationId;
    }

    /**
    * @description	used to fetchUserData 
    * @return String
    */
    @AuraEnabled
    public static String fetchUserData(){
        String userData;
        Map<String,Object> userDataMap = new Map<String,Object>();
        User userRec = [Select Id, FirstName,LastName,Email from User Where Id=:UserInfo.getUserId()];
        userDataMap.put('Name',userRec.FirstName);
        userDataMap.put('Surname',userRec.LastName);
        userDataMap.put('EmailAddress',userRec.Email);
        userData =  System.JSON.serialize(userDataMap);
        return userData;
    }

}