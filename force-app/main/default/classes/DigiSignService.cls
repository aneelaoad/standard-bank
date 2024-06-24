/**
* process the API call made on DigiSignResource
* @author Emmanuel Mulea Nocks(BlueSky)
* @date June 2020
*/
public with sharing class DigiSignService {
    public static final String NO_ONBOARD_RECORD_ERROR = 'Correlation Id was not found';
    public static final String SIGNATORY_GUID_ERROR = 'signatoryGuid must not be empty!';
    public static final String APPROVED_CONSENT_STATUS = 'Approved';
    public static final String DECLINED_CONSENT_STATUS = 'Declined';
    public static final String EXPIRED_CONSENT_STATUS = 'Expired';
    /**
    * Convert ApplicationContent to valid JSON String
    *@param applicationConts
    *@return String
    */
    public static String applicationContentToValidJSONString(String applicationConts){
        string updatedApplicationConts;
        applicationConts = applicationConts.replace('\\', '');
        applicationConts = applicationConts.replace('|',';');
        applicationConts = applicationConts.removeEnd(';');
        applicationConts = applicationConts.removeStart(';');
        applicationConts =  removeStringOccurrence(applicationConts,'$null');
        applicationConts = applicationConts.removeEnd(';');
        applicationConts = applicationConts.removeStart(';');
        List<String> applicationContsList = applicationConts.split(';');

        for(String appCon:applicationContsList){
            updatedApplicationConts += '"'+appCon.replace('${','":{')+',';
        }

        if(!String.isBlank(updatedApplicationConts)){
            updatedApplicationConts = updatedApplicationConts.removeStart('null');
            updatedApplicationConts = updatedApplicationConts.removeEnd(',');
            updatedApplicationConts = '{'+updatedApplicationConts+'}';
        }
        return updatedApplicationConts;
    }
    /**
    * Clean up unwanted char
    *@param target
    *@param subStr
    *@return String
    */
    public static String removeStringOccurrence(String target,String subStr){

        target =  target.trim();
        Integer intIndex = target.indexOf(subStr);
        while (intIndex!=-1)
        {
            String tag = target.substring(intIndex-18, intIndex+5);
            target =  target.replace(tag,'');
            target =  target.trim();
            intIndex = target.indexOf(subStr);
        }
        return target;
    }
    /**
    * Check if string is a vaild JSON
    *@param updatedApplicationConts is a string
    *@return boolean
    */
    public static boolean isValid(String updatedApplicationConts){
        try{
            JSON.deserializeUntyped(updatedApplicationConts);
            return true;
        }catch(Exception e){

            return false;
        }
    }
    /**
    * process the API call made on DigiSignResource
    *
    * @param data DigiSignResource.RequestWrapper
    */
    public static void updateOnboardRecords(DigiSignResource.RequestWrapper data){
        try {
            List<Application_Document__c> appDocToUpdate = new List<Application_Document__c>();
            List<Onboarding_Application__c> onboardRecord = new SEL_OnboardingApplications().selectById(
                new Set<Id>{data.callBackRequest.headerDetails.requestCorrelation});
            String updatedApplicationConts = applicationContentToValidJSONString(data.callBackRequest.headerDetails.applicationContent);
            String requestConsentStatus;
            Map<String,Object> applicationContsMap;

            if(isValid(updatedApplicationConts)){
                applicationContsMap = (Map<String, Object>) JSON.deserializeUntyped(updatedApplicationConts);
            }
            if(onboardRecord.isEmpty()) {
                throw new DigiSignServiceException(NO_ONBOARD_RECORD_ERROR);
            }

            Map<Id,Application_Document__c> appDocMap = new Map<Id, Application_Document__c> (SEL_ApplicationDocuments.newInstance().selectByOnboardAppWherePending(new Set<Id>{onboardRecord[0].Id}));

            fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            for (DigiSignResource.SignatoryApprovalDetails signatory : data.callBackRequest.signatoryApprovalDetails) {
                Application_Document__c appDoc = appDocMap.get(signatory.bpid);
                if(String.isBlank(signatory.bpid)) {
                    throw new DigiSignServiceException(SIGNATORY_GUID_ERROR);
                }


                appDoc.Document_Status__c = signatory.approvalStatus;
                appDoc.Reason_For_Decline__c = signatory.declineReason;
                if(isValid(updatedApplicationConts)){

                    Map<String, Object> attribute = (Map<String, Object>) applicationContsMap.get(signatory.bpid);
                    if(attribute!=null){
                        appDoc.Are_you_a_public_official__c = Boolean.valueOf(attribute.get('isPublicOfficial'));
                        appDoc.Are_you_related_to_a_public_official_i__c = Boolean.valueOf(attribute.get('isConnectedToOfficial'));
                        appDoc.Public_Official_Name__c = attribute.get('name')==null ? null:String.valueOf(attribute.get('name'));
                        appDoc.Public_Official_Relationship__c = attribute.get('relationship')==null ? '':String.valueOf(attribute.get('relationship'));
                        appDoc.Public_Official_Surname__c = attribute.get('surname')==null ? null:String.valueOf(attribute.get('surname'));

                    }
                }
                uow.registerDirty(appDoc);

                if(signatory.approvalStatus==DECLINED_CONSENT_STATUS || signatory.approvalStatus==EXPIRED_CONSENT_STATUS){
                    requestConsentStatus = signatory.approvalStatus;
                }
            }
            onboardRecord[0].Status__c = String.isBlank(requestConsentStatus)?APPROVED_CONSENT_STATUS:requestConsentStatus;
            uow.registerDirty(onboardRecord[0]);
            uow.commitWork();
        }
        catch (Exception ex){
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_COMMB, DigiSignService.class.getName());
            throw new DigiSignServiceException('Unable to update Onboarding Application: '+ex.getMessage()+' '+ ex.getStackTraceString());
        }

    }

    /**
    * @description Inner class to handle Exceptions
    */
    public class DigiSignServiceException extends Exception {
    }
}