/*************************************************************************************************
Class Name          : OnboardingTrackerExt
Date Created        : 18 Aug 2015
Function            : Extension class for the onboarding tracker                                                               
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer              Date                    Description
--------------        ----------             ---------------------
  Vishnu               18/8/2015                  Created
  Horky                21/9/2016                  E-0892 Added styling for Lightning
**************************************************************************************************/
public class OnboardingTrackerExt{
  
    public Id accId {get;set;}
    public account acc{get;set;}  
    public boolean exceededLimit {get;set;}

    private final Boolean isLightning;

    public String naviProspect {get; set;}
    public String naviPotential {get; set;}
    public String naviDueDeligence {get; set;}

    public OnboardingTrackerExt(ApexPages.StandardController controller) {
       
        // Get the current record's id from the page
        accId = controller.getId();
        exceededLimit = false;
        try {
            acc = [select id,status__c,submission_date__c,recordTypeId,Client_Relationship_Hierarchy__c,recordType.Name from Account where id =:accId];
        } catch(Exception ex) {
            acc = new account();
        }
        integer intDays = 0 ;
        if(acc.submission_date__c != null){
            intDays =  acc.submission_date__c.daysBetween(date.today());  
            if(intDays > 30){
                exceededLimit = true;
            }
        }

        isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());

        naviProspect = 'incomplete';
        naviPotential = 'incomplete';
        naviDueDeligence = 'incomplete';

        if ((acc.RecordType.Name == 'Prospect') && (acc.Status__c == 'Prospect')) {
            naviProspect = 'current';
        } else if (((acc.RecordType.Name == 'Potential Client') || (acc.RecordType.Name == 'Potential (CIF)') || (acc.RecordType.Name == 'Potential (Goldtier)')) && ((acc.Status__c == 'Approved') || (acc.Status__c == 'Rejected') || (acc.Status__c == 'Submitted for Approval'))) {
            naviProspect = 'complete';
            naviPotential = 'current';
        } else if ((acc.RecordType.Name == 'Potential Client') && ((acc.Status__c == 'Potential') || (acc.Status__c == 'Need Approval Again'))) {
            naviProspect = 'complete';
            naviPotential = 'current';
        } else if (((acc.RecordType.Name == 'Potential (CIF)') || (acc.RecordType.Name == 'Potential (Goldtier)')) && ((acc.Status__c == 'Potential') || (acc.Status__c == 'Need Approval Again') || (acc.Status__c == 'Approved'))) {
            naviProspect = 'complete';
            naviPotential = 'current';
        } else if (((acc.RecordType.Name == 'Potential Client') || (acc.RecordType.Name == 'Locked Potential (CIF)') || (acc.RecordType.Name == 'Locked Potential (Goldtier)')) &&  (acc.Status__c == 'Submitted for Onboarding') && !exceededLimit) {
            naviProspect = 'complete';
            naviPotential = 'complete';
            naviDueDeligence = 'current';
        } else if (((acc.RecordType.Name == 'Potential Client') || (acc.RecordType.Name == 'Locked Potential (CIF)') || (acc.RecordType.Name == 'Locked Potential (Goldtier)')) &&  (acc.Status__c == 'Submitted for Onboarding') && exceededLimit) {
            naviProspect = 'complete';
            naviPotential = 'complete';
            naviDueDeligence = 'lost';
        }
    }

    public Boolean getIsLightning() {
        return this.isLightning;
    }

    public Boolean getIsClassic() {
        return !this.isLightning;
    }

    private Boolean isPageOriginLightning(Map<String, Object> params) {
        if (params.get('sfdcIFrameHost') != null ||
                params.get('sfdcIFrameOrigin') != null ||
                params.get('isdtp') == 'p1') {
            return true;
        } else {
            return false;
        }
    }
}