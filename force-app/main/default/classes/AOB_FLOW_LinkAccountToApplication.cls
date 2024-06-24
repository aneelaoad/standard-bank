/**
* ACTION   DATE        OWNER         COMMENT
* Created  09-01-2023  Devi Ravuri   SFP-20549 , SFP-8988 Linking Account to Application -- Do not remove comments
*/
public without sharing class AOB_FLOW_LinkAccountToApplication {
    @InvocableMethod(label='Link Account to Application')
    public static List<String> linkAppWithAccount(List<Id> appIds){
        try{
            List<String> result = new List<String>();
            Map<String, Object> preAppResponse;
            Map<String, Object> preAppData;
            Map<String, Object> inflight;
            AOB_OnboardingSetting__mdt setting = AOB_Utils.getOnboardingSettings(AOB_Constants.SB_COZA);
            Id applicationId = appIds[0];
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            List<User> userRec = new SEL_Users().selectById(new Set<Id> {UserInfo.getUserId()});
        
            List<Contact> userContact = new SEL_Contacts().selectByIdWoSharing(new Set<Id> {userRec[0].contactId});
            List<Account> userAccount = new SEL_Accounts().selectByIdWoSharing(new Set<Id> {userRec[0].AccountId});

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
                            List<Contact> conts = new SEL_Contacts().selectByExternalIdentifiersWoSharing(new Set<String> {contExtIdentifier});
                            if(conts.isEmpty()){
                                //contact is not found, update the dummy contact with the director details
                                userContact[0].ExternalIdentifier__c = contExtIdentifier;
                                userContact[0].ExternalCIFId__c =(String) preAppResponse.get(AOB_Constants.INITIATOR_BPID);
                                userContact[0].ExternalCIFUUID__c = (String) preAppResponse.get(AOB_Constants.INITIATOR_BPGUID);
                                userContact[0].LastName = (String) preAppData.get(AOB_Constants.SURNAME);
                                userContact[0].FirstName =(String)  preAppData.get(AOB_Constants.NAME);
                                userContact[0].Email =(String)  preAppData.get(AOB_Constants.EMAIL);
                                userContact[0].Identity_Number__c = (String) preAppData.get(AOB_Constants.IDNUM);
                                update  userContact;                            
                            }
                            else{
                                userContact[0].ExternalCIFId__c =(String) preAppResponse.get(AOB_Constants.INITIATOR_BPID);
                                userContact[0].ExternalCIFUUID__c = (String) preAppResponse.get(AOB_Constants.INITIATOR_BPGUID);
                                userContact[0].LastName = (String) preAppData.get(AOB_Constants.SURNAME);
                                userContact[0].FirstName =(String)  preAppData.get(AOB_Constants.NAME);
                                userContact[0].Email =(String)  preAppData.get(AOB_Constants.EMAIL);
                                userContact[0].Identity_Number__c = (String) preAppData.get(AOB_Constants.IDNUM);
                                update  userContact;   
                            }
                        }
                    
                
                    String acctExtIdentifier = setting.AOB_CountryCode__c + setting.AOB_SystemId__c + (String)preAppResponse.get(AOB_Constants.BUSINESS_BPID);
                        //Logged in user is linked to a contact, the contact is linked to a dummy account
                        List<Account> accs = new SEL_Accounts().selectByExternalIdentifiersWoSharing(acctExtIdentifier);
                        if(accs.isEmpty()){
                            //account is not found, update the dummy account with the company details and link to application
                            userAccount[0].ExternalIdentifier__c = acctExtIdentifier;
                            userAccount[0].ExternalCIF_Id__c = (String) preAppResponse.get(AOB_Constants.BUSINESS_BPID);
                            userAccount[0].ExternalCIFUUID__c =(String)  preAppResponse.get(AOB_Constants.BUSINESS_BPGUID);
                            userAccount[0].Name = (String) preAppData.get(AOB_Constants.BUSINESS_NAME);
                            userAccount[0].Registration_Number__c = String.isEmpty((String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM))?
                                                                        (String)preAppData.get(AOB_Constants.IDNUM) : 
                                                                        (String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM);
                            
                            update userAccount;
                            apps[0].AOB_Client__c = userAccount[0].Id;
                            update apps;
                        
                        }else{
                            userAccount[0].ExternalCIF_Id__c = (String) preAppResponse.get(AOB_Constants.BUSINESS_BPID);
                            userAccount[0].ExternalCIFUUID__c =(String)  preAppResponse.get(AOB_Constants.BUSINESS_BPGUID);
                            userAccount[0].Name = (String) preAppData.get(AOB_Constants.BUSINESS_NAME);
                            userAccount[0].Registration_Number__c = String.isEmpty((String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM))?
                                                                        (String)preAppData.get(AOB_Constants.IDNUM) : 
                                                                        (String)preAppData.get(AOB_Constants.BUSINESS_REG_NUM);
                            
                            update userAccount;
                            apps[0].AOB_Client__c = userAccount[0].Id;
                            update apps;
                        }
            }
            return result;
        }   	
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());  
        }

    }
}