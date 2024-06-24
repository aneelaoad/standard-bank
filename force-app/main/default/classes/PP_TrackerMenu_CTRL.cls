/**
* @description  : Tracker Menu Controller
* User Story : SFP-4873
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Aug 2021
*/
public inherited sharing class PP_TrackerMenu_CTRL {

    /**
    * @description | Used to Onboarding Tasks
    * 
    * @param accountId
    * @return Map<String, Task>
    **/
    @AuraEnabled
    public static Map<String, Task> getOnboardingTasks(String contactId) {  
        
        Map<String, Task> tasksByUniqueName = new Map<String, Task>();
        
        List<PP_PartnerApplication__c> partners = SEL_PartnerApplication.newInstance().selectByPrimaryContactId(new Set<Id>{contactId}); 
        
        if(!partners.isEmpty()) {
            
            Id partnerId = partners.get(0).Id;
            
            List<Task> tasks = new SEL_Tasks().selectByWhatIdsAndRecordTypeIdWithoutSharing(
                new Set<Id> { partnerId }, 
                UTL_RecordType.getRecordTypeId('Task', 'PP_OnboardingStep')
            );
            
            for(Task onboardingTask : tasks) {
                
                //Create a formatted key i.e. registration-submit-application.
                String phase = onboardingTask.PP_Phase__c?.toLowerCase().trim().replaceAll('[^a-z0-9\\s]+', '').replaceAll('[\\s]+', '-');
                String step = onboardingTask.PP_Step__c?.toLowerCase().trim().replaceAll('[^a-z0-9\\s]+', '').replaceAll('[\\s]+', '-');
                tasksByUniqueName.put(phase+'-'+step, onboardingTask);
            }
        }
        
        return tasksByUniqueName;
    }
    
      /**
    * @description | Used to get Related Files
    * 
    * @param recordId
    * @return Map<ID, String>
    **/
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFiles(String recordId) {
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        
        return mapIdTitle;
    }
}