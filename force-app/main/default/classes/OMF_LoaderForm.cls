/**
* @description  Share the record details related to loader form,send the loader for field via email
* @author Naveen
* @company Absyz
* @test Class OMF_LoaderFormTest
*/
public without sharing class OMF_LoaderForm {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_LoaderForm');

    @AuraEnabled

    /**
     * @description Get the Record details i.e contract, fund details
     * @param strRecordId The ID of the managed fund record
     * @return Wrapper containing fund details and master agreement (high-level asset class)
     */
    public static RecordDetails getRecordDetails(String strRecordId){

        List<String>lstContractIds = new list <String>();
        List<String> lstHighLevelAssetClass = new list <String>();
        RecordDetails objRecordDetails = new RecordDetails();

        for(OMF_FundToAgreement__c objFundToAgreement : new SEL_OMFFundToAgreement().selectFundToAgreementByMasterAgreementId(strRecordId)){
                 lstContractIds.add(objFundToAgreement.MasterAgreementID__c);
        }

        for(Contract objContract : new SEL_Contracts().selectContractRecordByRecordId(lstContractIds)){
            if(String.isBlank(objContract.HighLevelAssetClass__c)){
                lstHighLevelAssetClass.add('Fixed Income');
            }
            else{
                lstHighLevelAssetClass.add(objContract.HighLevelAssetClass__c);    
            }            
        }

        if(lstHighLevelAssetClass.isEmpty()){
            lstHighLevelAssetClass.add('Fixed Income');
        }

        for(OMF_ManagedFund__c objManagedFund : new SEL_OMF_ManagedFunds().selectByManagedFundRecordWithId(strRecordId)){
                                                    objRecordDetails.strName = objManagedFund.Fund__r.Name;
                                                    objRecordDetails.strShortName = objManagedFund.ShortName__c;
                                                    objRecordDetails.strCIF =  objManagedFund.GlobalCIFNumber__c;
                                                    objRecordDetails.strRegisteredSuburb =objManagedFund.Fund__r.Registered_Suburb__c;
                                                    objRecordDetails.strBillingCity=objManagedFund.Fund__r.BillingCity;
                                                    objRecordDetails.strBillingState=objManagedFund.Fund__r.BillingState;
                                                    objRecordDetails.strBillingCountry=objManagedFund.Fund__r.BillingCountry;
                                                    objRecordDetails.strBillingStreet=objManagedFund.Fund__r.BillingStreet;
                                                    objRecordDetails.strBillingPostalCode=objManagedFund.Fund__r.BillingPostalCode;
                                                    objRecordDetails.strOSDID = objManagedFund.OSD_ID__c;

                                                }

        objRecordDetails.lstHighLevelAssetClass = lstHighLevelAssetClass;
        return objRecordDetails;

    }

    /**
     * @description wrapper class to store all related details of the loader form
     */

    public class RecordDetails{

        @AuraEnabled public List<String>lstHighLevelAssetClass;

        @AuraEnabled public string strShortName;

        @AuraEnabled public string strName;

        @AuraEnabled public String strCIF;

        @AuraEnabled public String strRegisteredSuburb;

        @AuraEnabled public String strBillingCity;

        @AuraEnabled public String strBillingState;

        @AuraEnabled public String strBillingCountry;

        @AuraEnabled public String strBillingStreet;

        @AuraEnabled public String strBillingPostalCode;

        @AuraEnabled public String strOSDID;

    }

    /**
     * @description Submit the loader form via email
     * @param fields Details Details of the fields
     * @param strManagedFund The ID of the managed fund
     * @param lstHighestAssetClass list of high level asset class
     */

    @AuraEnabled

    public static void submitLoaderForm(String fields, String strManagedFund , String[] lstHighestAssetClass){
        try {
            OMF_ManagedFund__c objManagedFund = (OMF_ManagedFund__c)JSON.deserialize(strManagedFund, OMF_ManagedFund__c.class);
            update objManagedFund;
            Map<String,String> mapEmailBody =  ( Map<String,String>)JSON.deserialize(fields,  Map<String,String>.class);
            sendEmail(mapEmailBody, objManagedFund.Id, lstHighestAssetClass);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    /**
     * @description Send the email
     * @param mapEmailBody A map containing the email body
     * @param omfManagedFundId The ID of the managed fund
     * @param lstAssetClass A list of high-level asset classes
     */

    public static void sendEmail(Map<String,String> mapEmailBody, String omfManagedFundId, String[] lstAssetClass){

        try {

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(userinfo.getUserId()); 
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('OMF_Loader_Form_Submission');
            EmailTemplate emailTemplate;
            if(listEmailTemplate.size()>0){
                emailTemplate = listEmailTemplate[0];
            }

            String body = emailTemplate.HtmlValue;

            message.setSubject(emailTemplate.Subject);

            List<OMF_ManagedFund__c> listManagedFundRecord = new SEL_OMF_ManagedFunds().selectByManagedFundRecordWithId(omfManagedFundId);

            if(!listManagedFundRecord.isEmpty() && String.isNotBlank(listManagedFundRecord[0].Fund__r.Name)){
                message.setSubject(emailTemplate.Subject +' '+ listManagedFundRecord[0].Fund__r.Name);
            }
            String html = '<table border="1" style="border-collapse: collapse; width: 100%;">';

            for(String key:mapEmailBody.keyset()){
                if(key == mapEmailBody.get(key)){
                    html+='<tr><th style="padding: 5px;background-color:#F3F3F2;"> <b><center>'+key+'</center></b></th></tr>'; 
                }
                else{
                    String name = key;
                    if(key.contains('_')){
                        name = key.split('_')[0];
                    }
                    html+='<tr><td style="padding: 5px;">'+name+'</td><td style="padding: 5px;">'+mapEmailBody.get(key)+'</td></tr>'; 
                }
            }
			List<OMFSetting__mdt> omfSetting = OMFSetting__mdt.getAll().values();
            
            html += '</table>';
            html = '<div style="border: 1px solid #ccc; padding: 10px; margin: 10px; border-radius: 5px; box-shadow: 0 2px 2px rgba(0,0,0,0.1);">' + html + '</div>';
            body = body.replace('{FormBody}', html);

            String mailTo = '<a href="mailto:'+UserInfo.getUserEmail()+'">'+UserInfo.getUserEmail()+'</a>';
            body = body.replace('{RecipientEmail}',mailTo);
            
            message.setHtmlBody(body);  
            
           message.toAddresses = omfSetting.size() > 0 ? new String[] {omfSetting[0].LoaderFormEmail__c} : new String[] {};
            if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ message });
            }else {
                LOGGER.INFO('Email limit exceeded, cannot send email at this time.');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());

        }

    }
}