/**

@ Author        : Youssef Ibrahim
@ Date          : 09/09/2019
@ Feature       : C-00002931
@ Description   : APEX controller for the NavigateEventReport lighnting component

*/

public with sharing class NavigateEventController {

    @AuraEnabled
    public static String getClientIdFromEvent(Id eventId) {
        return  SA_EventReportNavigateController.getEventReport(String.valueOf(eventId));
    }
}