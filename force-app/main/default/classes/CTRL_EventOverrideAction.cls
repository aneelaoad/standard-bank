/**
 * @description       : Controller for the EventActionOverride LWC that handlers New, Edit, View action overrides
 * @author            : Derek Hughes
 * @group             : Controller
 * @last modified on  : 16-05-2023
 * @last modified by  : Derek Hughes
 * ************************************************************
 * @last modified on  :03-11-2023
 * @last modified by  : Raja Kumar(raja.kumar@standardbank.co.za) 
 * @description		  : Added a null check for eventID as to fix a bug.
**/
public with sharing class CTRL_EventOverrideAction {
  
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CTRL_EventOverrideAction.class.getName());

    /**
    * @description Determines the action override URL to be used based on there being a Call_Report or not
    * @author Derek Hughes | 04-05-2023 
    * @param actionName 
    * @param eventId 
    * @param userId 
    * @return ActionOverrideResult 
    **/
    @AuraEnabled(cacheable=true)
    public static ActionOverrideResult getActionOverride (String actionName, Id eventId, Id userId) {
        try {   
            ActionOverrideResult result = new ActionOverrideResult();

            result.eventId = eventId;

            User user = SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id> {userId}).get(0);

            result.profileName = user.Profile.Name;
            result.userName = user.Name;
            // Added null check to fix a bug 
			List<Call_Report__c> eventReports=new List<Call_Report__c>();
            if(eventId!=null){
                // Do NOT enforce CRUD or FLD to ensure redirection works correctly for all users
            	eventReports = new SEL_CallReports(false, false, false).selectByEventIds(new Set<Id> {eventId});
            }
            
            if (eventReports.size()>0) {
                result.callReportId = eventReports[0].Id;
            }

            if (actionName == 'new') {
                result.overrideUrl = NewEventRedirectPageExt.redirectUrl(new Map<String,String>());
            }
            else {
                result.overrideUrl = 'n/a';
            }

            return result;
        } 
        catch (Exception e) {
            LOGGER.fatal('execute: Unhandled exception', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ActionOverrideResult {
        @AuraEnabled public Id eventId;
        @AuraEnabled public Id callReportId;
        @AuraEnabled public String profileName;
        @AuraEnabled public String userName;
        @AuraEnabled public String overrideUrl;
    }
    
}