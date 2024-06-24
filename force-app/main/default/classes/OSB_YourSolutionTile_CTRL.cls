/**
 * @description OSB_YourSolutionTile_CTRL class for OSBYourSolutionTile Lightning Component
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 *
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason New method for removing multiple subscribed solutions
 **/
public class OSB_YourSolutionTile_CTRL {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_YourSolutionTile_CTRL');

    /**
    * @description Deletes a Subscribed Solution record
    *<br/>SFP-SFP-21026
    * 
    * @param  solutionIdList List<sObject>
    *
    **/
    @AuraEnabled(Cacheable=false)
    public static void removeUserMultipleSubscribedSolution(List<sObject> solutionIdList) {
        LOGGER.info('OSB_YourSolutionTile_CTRL : removeUserMultipleSubscribedSolution Removes provided list of subscribed solutions Ids');
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try {

            List<Subscribed_Solutions__c> subscribedSolutionList = new List<Subscribed_Solutions__c>();
            for(sObject solution : solutionIdList){
                Subscribed_Solutions__c subscribedSolution = new Subscribed_Solutions__c(Id=solution.Id);
                subscribedSolutionList.add(subscribedSolution);
            }
            
            uow.registerDeleted(subscribedSolutionList);
            uow.commitWork();
            
        } catch (Exception e) {
            LOGGER.error('OSB_YourSolutionTile_CTRL : removeUserMultipleSubscribedSolution  Removing subscribed solutions Exception logged: ',e);
        }

        LOGGER.info('OSB_YourSolutionTile_CTRL : removeUserMultipleSubscribedSolution Successful subscribed solutions for user removed');
    }
    
    /**
    * @description Checks if the user signed in using Multi-factor Authentication or not
    *
    * @return Boolean strongAuth
    **/
     @AuraEnabled(Cacheable=true)
    public static Boolean mfaLogin() {
        LOGGER.info('OSB_YourSolutionTile_CTRL : mfaLogin Checks if user signed in with MFA');

        Boolean strongAuth = false;

        try {
            if(!Test.isRunningTest()){ 
                strongAuth = OSB_SRV_PingIntegration.newInstance().mfaLogin();
            }
        } catch (Exception e) {
            LOGGER.error('OSB_YourSolutionTile_CTRL : mfaLogin  Checking MFA login Exception logged: ',e);
        }

        LOGGER.info('OSB_YourSolutionTile_CTRL : mfaLogin Successful received whether user logged in with mfa or not');
        return strongAuth;
    }
}