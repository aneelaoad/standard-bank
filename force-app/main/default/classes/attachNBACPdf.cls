/***
  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  09 Sep 2022
  	@ User Story    	:  US-4504 -- DM NBAC: SPV PDF copy at Supported and Submitted milestone - Read Only
  	@ Description 	    :  As a NBAC user I want to select Generate and Attach PDF.  In order to attach a copy of the
  	                       SPV NBAC PDF to the record. In this code I added new field for the constructor to grab and
  	                       removed commented code.  Amended the attachPDF to change the filename based on the milestone
  	                       of the business assessment
***/
public class attachNBACPdf {

    static final String CIBNBACSPVNOCIF = 'CibNbacSpvNoCif';
    static final String CIBNBACSPVCIF = 'CibNbacSpvCif';
    private final Business_Assessment__c b; //Business assessment object 
    static final List<String> FIELDS_TO_QUERY = new List<String> {
        'Account__r.Name', 'RecordType.DeveloperName', 'Milestone__c'
    };
    
    //Constructor
    public attachNBACPdf(ApexPages.StandardController standardPageController) {
        if (!Test.isRunningTest()) { 
            standardPageController.addFields(FIELDS_TO_QUERY);
        }

        b = (Business_Assessment__c) standardPageController.getRecord();
    }
  
    //method called from the Visualforce's action attribute
    //generate and attach the PDF document
    public PageReference attachPDF() {
        return DMN_BusinessAssessment.generateBAFinalPdf(new Set<Id> { b.Id });
    }
}