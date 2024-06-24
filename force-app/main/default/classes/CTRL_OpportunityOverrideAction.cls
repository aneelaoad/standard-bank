/**
 * @description       : Controller for the OpportunityActionOverride LWC that handlers New, Edit, View action overrides
 * @author            : Derek Hughes
 * @group             : Controller
 * @last modified on  : 16-05-2023
 * @last modified by  : Derek Hughes
**/
public with sharing class CTRL_OpportunityOverrideAction {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CTRL_OpportunityOverrideAction.class.getName());

    /**
    * @description Get user info needed for the override LWC
    * @author Derek Hughes | 04-05-2023 
    * @param actionName 
    * @param recordId 
    * @param userId 
    * @return ActionOverrideResult 
    **/
    @AuraEnabled(cacheable=true)
    public static ActionOverrideResult getActionOverride (String actionName, Id recordId, Id userId) {
        try {   
            ActionOverrideResult result = new ActionOverrideResult();

            result.recordId = recordId;

            User user = SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id> {userId}).get(0);

            result.profileName = user.Profile.Name;
            result.userName = user.Name;

            return result;
        } 
        catch (Exception e) {
            LOGGER.fatal('execute: Unhandled exception', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ActionOverrideResult {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String profileName;
        @AuraEnabled public String userName;
    }
    
}