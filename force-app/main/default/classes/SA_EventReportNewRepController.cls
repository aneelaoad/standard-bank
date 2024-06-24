/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2010
    @ Test File     : None - Test Method (testMe()) at the bottom of this class
    @ Description	: Controller that override the Call_Report__c -> New action to open the standard Event->New action 
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Modification Description :
******************************************************************************************************/
public with sharing class SA_EventReportNewRepController {
	
	 public SA_EventReportNewRepController(ApexPages.StandardController stdController) {}
		
	 public PageReference navigateNew(){ 
		String URL = '/setup/ui/recordtypeselect.jsp?ent=Event&retURL=%2Fhome%2Fhome.jsp&save_new_url=%2F00U%2Fe%3FretURL%3D%252Fhome%252Fhome.jsp';
		PageReference eventPage = new PageReference(URL);
		eventPage.setRedirect(true);
		return eventPage;

	 }

	//######################## TEST METHODS #############################
	static testMethod void testMe(){
		ApexPages.StandardController stdController;
		SA_EventReportNewRepController cont = new SA_EventReportNewRepController(stdController);
		PageReference p = cont.navigateNew();
		
		System.assertEquals(p.getUrl(),'/setup/ui/recordtypeselect.jsp?ent=Event&retURL=%2Fhome%2Fhome.jsp&save_new_url=%2F00U%2Fe%3FretURL%3D%252Fhome%252Fhome.jsp');
	}

}