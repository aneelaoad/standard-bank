/*************************************************************************\
@Author        :     Raja Kumar
@Date          :     Feb 2024
@Test File     :     OMF_OnboardMyFundServiceJSON_TEST and OMF_API_CIFController_TEST
@description   :     Domain class for platform event OMF_ManagedFundRecordUpdate__e
*/

public with sharing class DMN_ManagedFund{
 /**
* @description updates anaged fund Record
* @param managedFundRecordList
*/
    public static void updateManagedFund(List<OMF_ManagedFundRecordUpdate__e> managedFundRecordList) {
        for(OMF_ManagedFundRecordUpdate__e busEvent: managedFundRecordList) {
            if(String.isNotBlank(busEvent.ManagedFundRecordId__c) && busEvent.NewOnboardingStatus__c=='KYC Submission Failed') {
                OMF_API_OnboardMyFundServiceJSON.handleKYCAPIFailureNotification(busEvent.ManagedFundRecordId__c);
            }else if(String.isNotBlank(busEvent.ManagedFundRecordId__c) && busEvent.NewOnboardingStatus__c=='CIF Submission Failed'){
                OMF_API_CIFController.handleCIFAPIFailureNotification(busEvent.ManagedFundRecordId__c);
            }
        }
    }
    
}