/***
  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  17 Feb 2020
  	@ User Story    	:  US-4493 -- DM NBAC: SPV New PDF format linked to JV record type
  	@description 	    :  As a member of the NBAC team, I should not be allowed to update information on the NBAC once
  	                       the milestone has progressed to "Supported" or "Submitted", however the NBAC should still be
  	                       allowed to generate and attach the PDF, and be able to proceed to the next milestone.  In
  	                       this code I added new field for the constructor to grab and removed commented code.

 * @LastModifiedDate March 2024
 * @author Stane Murhula (stane.murhula@standarbank.co.za)
 * @UserStory SFP-36749
 * @LastModifiedReason Added getNbacRealEstateFinanceFields to show REF fields on NBAC PDF
***/

public class nbacPdfExtension {

    private final Business_Assessment__c b; //Business assessment object 
    public Boolean isCibNbacSpvNoCif { get; set; }
    public Boolean isCibNbacSpvCif { get; set; }
    static final String CIBNBACSPVNOCIF = 'CibNbacSpvNoCif';
    static final String CIBNBACSPVCIF   = 'CibNbacSpvCif';
    static final String ACTIVITY_TYPE   = 'NBAC Action Item';
    static final String FIN_ANALYSIS_REC_TYPE_NAME = 'Metric';
    static final List<String> FIELDS_TO_QUERY = new List<String> {
        'Account__r.Id', 'Account__r.Primary_Relationship_Holder__c', 'Account__r.CIF__c', 'RecordType.DeveloperName'
    };

    public NBAC_Financial_Analysis__c firstMetric {
        get {
            if (firstMetric == null) {
                List<NBAC_Financial_Analysis__c> metrics = [
                    SELECT Id,
                        Metric_Year_1__c,
                        Metric_Year_2__c,
                        Metric_Year_3__c,
                        Metric_Year_4__c
                        FROM NBAC_Financial_Analysis__c
                    WHERE Business_Assessment__c = :b.Id
                        AND RecordType.Name = :FIN_ANALYSIS_REC_TYPE_NAME
                    LIMIT 1
                ];
                firstMetric = metrics.isEmpty() ? new NBAC_Financial_Analysis__c() : metrics.get(0);
            }
            return firstMetric;
        }
        set;
    }

    /**
     * @description standard controller
     * @param standardPageController standardPageController
     */
    public nbacPdfExtension(ApexPages.StandardController standardPageController) {
        if (!Test.isRunningTest()) { 
            standardPageController.addFields(FIELDS_TO_QUERY);
        }

        b = (Business_Assessment__c) standardPageController.getRecord();

        isCibNbacSpvNoCif = FeatureManagement.checkPermission(CIBNBACSPVNOCIF);
        isCibNbacSpvCif   = FeatureManagement.checkPermission(CIBNBACSPVCIF);
    }

    /**
     * @description get related Tasks
     * @return List <Task>
     */
    public List <Task> getActionItems() {
        List <Task> actionList = new List <Task> ();
		for (Account acc : new SEL_Accounts().selectAccountsWithActionItemsByAccountIdAndActionType(b.Account__c, ACTIVITY_TYPE)) {
		    actionList.addAll(acc.Tasks);
        }
        return actionList;
    }

    /**
     * @description method to get related custom Team
     * @return List <Custom_Client_Team__c>
     */
    public List <Custom_Client_Team__c> getTeam() {
        return new SEL_ClientTeams().selectCcAndCcbmByClientIds(new Set<Id> { b.Account__c });
    }

    /**
     * @description method to get Opportunity team
     * @return List <Opportunity>
     */
    public List <Opportunity> getOpportunityTeam() {
        return DMN_Opportunity.getOpportunitiesWithTeamMembers(b.Id);
    }

    /**
     * @description method to get CCAPMap
     * @return Map<String, String>
     */
    public Map<String, String> getCCAPMap() {
        CiCcap_Controller.CcapWrapper ccapWrapper = CiCcap_Controller.getCcapValue(b.Id);

        if (ccapWrapper.isUserAllowedToViewCcap || !ccapWrapper.hasErrors) {
            return ccapWrapper.accountName2Ccap;
        } else {
            List<EmailTemplate> templates = SEL_EmailTemplate.newInstance().selectByName('NBAC PDF CCAP Not Fetched');

            if (templates != null && !templates.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                List<String> bodyMergeFields = new List<String>();
                bodyMergeFields.add(UserInfo.getName());
                bodyMergeFields.add(ccapWrapper.errorMessage);

                String emailBody = String.format(templates.get(0).Body, bodyMergeFields);

                email.setSubject(templates.get(0).Subject);
                email.setPlainTextBody(emailBody);
                email.setToAddresses(new List<String> { UserInfo.getUserEmail() });
                email.setSaveAsActivity(false);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
        return null;
    }

    /**
     * @description retrieve related Ancillary opportunities to show in PDF
     * @return List<SB_Product__c>
     */
    public List<SB_Product__c> getAncillaryOpportunities() {
            return NBAC_AncillaryOpportunities_CTRL.getAncillaryOpportunities(b.Id);
    }


    /**
     * @description retrieve related Real Estate Finance Fields to show in PDF
     * @return List<NBAC_Real_Estate_Finance__c>
     */
    public List<NBAC_Real_Estate_Finance__c> getNbacRealEstateFinanceFields() {
            try {
                return NBACRealEstateFinanceController.getRefData(String.valueOf(b.Id));
            } catch (Exception e) {
                return null;
            }
    }
}