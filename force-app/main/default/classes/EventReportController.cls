/**
 * Created by mjaznicki on 13.08.2018.
 */

public with sharing class EventReportController {

    /**
    * Returns a new Call_Report__c record
    * @return Call_Report__c a new record
    */
    @AuraEnabled
    public static Call_Report__c getCallReport() {
        Call_Report__c callReport = new Call_Report__c();
        return callReport;
    }

    /**
    * Checks core Attendees
    * @param recordId Id
    * @return Boolean result from StdBank_Ltn_EventReportNavigator.corecheck by record Id.
    */
    @AuraEnabled
    public static Boolean checkCoreAttendees(Id recordId){
        return StdBank_Ltn_EventReportNavigator.corecheck(recordId);
    }

    /**
    * Checks if User Profile is Commercial Banking
    * @return Boolean result of Profile check
    */
    @AuraEnabled
    public static Boolean isCommBUser(){
        return UserInfo.getProfileId()  == UTL_Profile.getProfileId('Commercial Banking Communities User') ||
                UserInfo.getProfileId()  == UTL_Profile.getProfileId('Commercial Banking Custom Std User') ||
                UserInfo.getProfileId()  == UTL_Profile.getProfileId('Commercial Banking Custom Std User - Mobile');
    }

    /**
    * Checks if User Profile is not Credit Credit Manager in order to determine license that user has and if he/she is
    * able to access Opportunity and Campaign lookup fields
    * <br/>SFP-7019
    * @return Boolean result of Profile check
    */
    @AuraEnabled
    public static Boolean isSalesforceLicenseUser() {
        return UserInfo.getProfileId() != UTL_Profile.getProfileId('Credit Credit Manager');
    }
}