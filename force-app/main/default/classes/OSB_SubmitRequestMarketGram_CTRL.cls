/**
 * Controller class for OSBSubmitRequestMarketGram component
 * <br/>
 *
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date May 2020
 *
 **/
public with sharing class OSB_SubmitRequestMarketGram_CTRL {
    /**
     * Checks if the current user is login to community
     *
     * @return Boolean
     **/
    @AuraEnabled(Cacheable=true)
    public static Boolean isUserLoggedIn() {
        return UTL_User.isLoggedInUser();
    }

    /**
     * Used for the submit a reguest component
     *
     * @param newCase case record to insert
     *
     * @return Boolean true if case created successfully and false if some exception occurs
     **/
    @AuraEnabled
    public static Boolean saveSuggestion(Case newCase) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Boolean caseCreated;
        try {
            OSB_SRV_NewCase.newInstance().saveCasesInUserContext(new List<Case>{newCase},uow);
            caseCreated = true;
         } catch (Exception e) {
            caseCreated = false;
        }
        return caseCreated;
    }
}