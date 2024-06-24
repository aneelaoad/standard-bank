/**
 * CST - Report for Individual View - Client Engagement
 * @description batch class executes the logic to update the fields used in the report.
 * <br/>EN-0777, US:1465, US-1495, US-1614
 *
 * @author Petr Svestka, Petr Roubal, Manoj Gupta
 * @date 24. 7. 2015
 */
public without sharing class CSTIndividualEffectivenessBatch implements Database.Batchable<SObject> {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CSTEffectivenessBatch');
    private static String query = 'SELECT id, name FROM User WHERE isActive = TRUE AND frozen_Account__c = FALSE AND name NOT IN (\'Integration User\', \'Security User\', \'Salesforce Administration\')';

    public List<CurrencyType> currTable = new List<CurrencyType>();
    public Map<String, Double> rateMap = new Map<String, Double>();
    public string corporateIsoCode = 'USD';

    private static final Integer THIS_YEAR = System.Datetime.now().year();

    private static final String ATTENDED = 'Attended';
    private static final string INTERNAL_MEETING = 'Internal';
    private static final string EXTERNAL_MEETING = 'External';
    private static final string CORE_CLIENT_TEAM_MEETING = 'Core Client Team Meeting';
    private static final String DAY_TO_DAY_MEETING = 'Day to Day Meeting';
    private static final String CLIENT_ENTERTAIMENT = 'Client Entertainment';
    private static final String CLIENT_MEETING= 'Client Meeting';
    private static final String CLIENT_ROADSHOW= 'Client Road Show';
    private static final String MARKETING_RESEARCH_UPDATE= 'Market Research Update';
    private static final String CLIENT_SERVICE_DISCUSSION = 'Client Service Discussion';
    private static final String CLIENT_CONFERENCE_CALL = 'Client Conference Call';
    private static final String CLIENT_SOCIAL = 'Client Social';
    private static final String CLIENT_TRAINING = 'Client Training';
    private static final String CLIENT_EMAIL = 'Client Email';
    private static final String CLIENT_CASE = 'CIB Client Case';
    private static final String CLOSED = 'Closed';
    private static final String COMPLETED = 'Completed';

    CSTEffectivenessBatch.currencyConverter converter; //todo refactor this to a helper class

    private class CSTReport {
        Id userId;
        DateTime userSummaryLastUpdate = DateTime.now();
        Integer internalCoreMeetingsAttended = 0;
        Integer internalDaytoDayMeetingsAttended = 0;
        Integer totalInternalCoreMeetings = 0;
        Integer totalInternalDaytoDayMeetings = 0;
        Integer opportunitiesFromInternalMeetings = 0;
        Integer externalCoreMeetingsAttended = 0;
        Integer externalDaytoDayMeetingsAttended = 0;
        Integer totalExternalCoreMeetings = 0;
        Integer totalExternalDaytoDayMeetings = 0;
        Integer opportunitiesFromExternalMeetings = 0;
        Integer closedClientCases = 0;
        Integer incompleteClientCases = 0;
        Integer incompleteTasks = 0;
        Integer completeTasks = 0;

        private CSTReport(User u) {
            this.userId = u.id;
        }
    }

    /**
     * @description Fetch the latest currency conversion rates.
     */
    private void snapCurrencyTable() {
        this.currTable = [
            SELECT IsoCode,
                ConversionRate
            FROM CurrencyType
            LIMIT 300
        ];

        for (CurrencyType c : currTable) {
            rateMap.put(c.isoCode, c.conversionRate);
        }
    }

    /**
     * @description Default constructor. Uses different query for test class.
     */
    public CSTIndividualEffectivenessBatch() {
        if (Test.isRunningTest()) {
            query = 'SELECT id, name FROM User WHERE isActive = TRUE AND frozen_Account__c = FALSE AND name NOT IN (\'Integration User\',\'Security User\', \'Salesforce Administration\') AND city!=NULL AND country!=NULL AND state!=NULL AND user_cib_global_area__c!=NULL AND user_division__c!=NULL AND business_unit__c!=NULL AND userType != \'Guest\' LIMIT 5';
        }
        //converter = new currencyConverter();
        corporateIsoCode = UserInfo.getDefaultCurrency();
        snapCurrencyTable();
    }

    /**
     * @description Gets invoked when the batch job executes and operates on one batch of records.
     * Contains or calls the main execution logic for the batch job.
     * @param bc Default param
     * @return the record set of Clients that meets specific criteria
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    /**
     * @description Method that fires Batch processing
     * @param bc Default param
     * @param scope Default param
     */
    public void execute(Database.BatchableContext bc, List<User> scope) {
        if (!scope.isEmpty()) {
            try {
                update enrichUser(new Map<Id, User> (scope));
            } catch (Exception ex) {
                LOGGER.fatal(
                    'Failed CSTIndividualEffectivenessBatch.execute(),\n StackTraceString:' +
                    ex.getStackTraceString() +
                    '\n getMessage:' +
                    ex.getMessage() +
                    '\n scope :' +
                    (new Map<Id, User> (scope)).keySet()
                );
            }
        }
    }

    /**
     * @description Returns a given User object enriched with values for the CST Effectiveness - Individual report.
     * <p>
     * This method is public to allow easy testig of the enrichment logic.
     *
     * @param  userById  a map of users and thier ids to be enriched
     * @return    the enriched list of users
     */
    public List<User> enrichUser(Map<Id, User> userById) {
        Map<Id, CSTReport> reportsByUserIds = new Map<Id, CSTReport>();
        Map<Id, Id> userIdByEventReportId = new Map<Id, Id>();

        for (User user : userById.values()) {
            reportsByUserIds.put(user.Id, new CSTReport(user));
        }

        final Set<String> coreMeetingTypes = new Set<String> {
            CLIENT_ENTERTAIMENT,
            CLIENT_MEETING,
            CLIENT_ROADSHOW,
            MARKETING_RESEARCH_UPDATE,
            CLIENT_SERVICE_DISCUSSION
        };

        final Set<String> dayToDayMeetingTypes = new Set<String> {
            CLIENT_CONFERENCE_CALL,
            CLIENT_SOCIAL,
            CLIENT_TRAINING,
            CLIENT_EMAIL
        };

        //get all call reports connected to client
        List<Call_Report_Attendees__c> listOfEventReports = [
            SELECT Id,
                Name,
                Status__c,
                Call_Report__r.Id,
                Call_Report__r.Meeting_audience__c,
                Call_Report__r.Meeting_Purpose__c,
                Call_Report__r.Core_Meeting__c,
                Call_Report__r.Start__c,
                Call_Report__r.Relate_to_opp__r.Primary_event_report_source__c,
                Call_Report__r.Related_to_case__r.Recordtype.Name,
                Call_Report__r.Related_to_case__r.Ownerid,
                Call_Report__r.Related_to_case__r.Status, // IsClosed could be used too
                Call_Report__r.Related_to_case__r.Closeddate,
                Contact_Id__r.Owner.Name,
                Contact_Id__r.Name          
            FROM Call_Report_Attendees__c
            WHERE Contact_Id__r.Owner.Id IN :reportsByUserIds.keySet()
                AND CALENDAR_YEAR(Call_Report__r.Start__c) = :THIS_YEAR
        ];

        for (Call_Report_Attendees__c cra: listOfEventReports) {
        
            //if you are attandee (contact) and also owner of that contact -> means you are standards bank employee
            if (cra.Contact_Id__r.Owner.Name == cra.Contact_Id__r.Name) {

                Boolean isAttended = cra.Status__c == ATTENDED;
                Boolean isInternal = cra.Call_Report__r.Meeting_Audience__c == INTERNAL_MEETING;
                Boolean isExternal = cra.Call_Report__r.Meeting_Audience__c == EXTERNAL_MEETING;
                Boolean isIntCoreClientMeeting = (
                    cra.Call_Report__r.Meeting_Purpose__c == CORE_CLIENT_TEAM_MEETING &&
                    cra.Call_Report__r.Core_Meeting__c == true
                );
                Boolean isExtCoreClientMeeting = (
                    coreMeetingTypes.contains(cra.Call_Report__r.Meeting_Purpose__c) &&
                    cra.Call_Report__r.Core_Meeting__c == true
                );
                Boolean isIntDayToDayPurpose = cra.Call_Report__r.Meeting_Purpose__c == DAY_TO_DAY_MEETING;
                Boolean isExtDayToDayPurpose = dayToDayMeetingTypes.contains(cra.Call_Report__r.Meeting_Purpose__c);

                
                if (isAttended) {
                    userIdByEventReportId.put(cra.Call_Report__r.id, cra.Contact_Id__r.Owner.Id);
                }

                if (isInternal) {
                    if (isIntCoreClientMeeting) {
                        if (isAttended) {
                            reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).internalCoreMeetingsAttended++;
                        }

                        
                        reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).totalInternalCoreMeetings++;
                    }

                    if (isIntDayToDayPurpose) {
                        if (isAttended) {
                            reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).internalDaytoDayMeetingsAttended++;
                        }

                        reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).totalInternalDaytoDayMeetings++;
                    }
                } else if (isExternal) {
                    if (isExtCoreClientMeeting) {
                        if (isAttended) {
                            reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).externalCoreMeetingsAttended++;
                        }

                        reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).totalExternalCoreMeetings++;
                    }

                    if (isExtDayToDayPurpose) {
                        if (isAttended) {
                            reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).externalDaytoDayMeetingsAttended++;
                        }

                        reportsByUserIds.get(cra.Contact_Id__r.Owner.Id).totalExternalDaytoDayMeetings++;
                    }
                }
            }
        }

        for (Opportunity op : [
            SELECT Id,
                Primary_Event_Report_Source__r.Meeting_Audience__c, Primary_Event_Report_Source__c
            FROM Opportunity
            WHERE Primary_Event_Report_Source__c  IN :userIdByEventReportId.keySet()
        ]) {
            if (op.Primary_Event_Report_Source__r.Meeting_Audience__c == INTERNAL_MEETING) {
                reportsByUserIds.get(userIdByEventReportId.get(op.Primary_Event_Report_Source__c)).opportunitiesFromInternalMeetings++;
            } else {
                reportsByUserIds.get(userIdByEventReportId.get(op.Primary_Event_Report_Source__c)).opportunitiesFromExternalMeetings++;
            }
        }

        for (Case c  : [
            SELECT Id,
                Status,
                ClosedDate,
                OwnerId,
                Recordtype.Name
            FROM Case
            WHERE OwnerId IN :reportsByUserIds.keySet()
                AND Recordtype.Name = :CLIENT_CASE
                AND Accountid <> null
        ]) {
            if (c.Status == CLOSED
                && c.ClosedDate.year() == THIS_YEAR) {

                reportsByUserIds.get(c.OwnerId).closedClientCases++;
            }

            if (c.Status != CLOSED) {
                reportsByUserIds.get(c.OwnerId).incompleteClientCases++;
            }
        }

        for (AggregateResult aggResult : [
            SELECT OwnerId, COUNT(Id)completeTasks
            FROM Task
            WHERE OwnerId IN :reportsByUserIds.keySet()
                AND Status = :COMPLETED
                AND ActivityDate = THIS_YEAR
                AND What.Type = :DMN_Account.OBJ_NAME
            GROUP BY OwnerId
        ]) {
            reportsByUserIds.get((Id) aggResult.get('OwnerId')).completeTasks = (Integer) aggResult.get('completeTasks');
        }

        for (AggregateResult aggResult : [
            SELECT OwnerId, COUNT(Id)incompleteTasks
            FROM Task
            WHERE OwnerId IN :reportsByUserIds.keySet()
                AND Status != :COMPLETED
                AND What.Type = :DMN_Account.OBJ_NAME
            GROUP BY OwnerId
        ]) {
            reportsByUserIds.get((Id) aggResult.get('OwnerId')).incompleteTasks = (Integer) aggResult.get('incompleteTasks');
        }

        List<User> modifiedUsers = new List<User>();
        for (Id userId : reportsByUserIds.keySet()) {
            modifiedUsers.add(new User(
                Id = userId,
                Internal_Core_Meetings_Attended__c = reportsByUserIds.get(userId).internalCoreMeetingsAttended,
                Internal_Day_to_Day_Meetings_Attended__c = reportsByUserIds.get(userId).internalDaytoDayMeetingsAttended,
                Total_Internal_Core_Meetings__c = reportsByUserIds.get(userId).totalInternalCoreMeetings,
                Total_Internal_Day_to_Day_Meetings__c = reportsByUserIds.get(userId).totalInternalDaytoDayMeetings,
                Opportunities_from_Internal_Meetings__c = reportsByUserIds.get(userId).opportunitiesFromInternalMeetings,
                External_Core_Meetings_Attended__c = reportsByUserIds.get(userId).externalCoreMeetingsAttended,
                External_Day_to_Day_Meetings_Attended__c = reportsByUserIds.get(userId).externalDaytoDayMeetingsAttended,
                Total_External_Core_Meetings__c = reportsByUserIds.get(userId).totalExternalCoreMeetings,
                Total_External_Day_to_Day_Meetings__c = reportsByUserIds.get(userId).totalExternalDaytoDayMeetings,
                Opportunities_from_External_Meetings__c = reportsByUserIds.get(userId).opportunitiesFromExternalMeetings,
                Closed_Client_Cases__c = reportsByUserIds.get(userId).closedClientCases,
                Incomplete_Client_Cases__c = reportsByUserIds.get(userId).incompleteClientCases,
                Incomplete_Tasks__c = reportsByUserIds.get(userId).incompleteTasks,
                Complete_Tasks__c = reportsByUserIds.get(userId).completeTasks,
                User_Summary_Last_Updated__c = reportsByUserIds.get(userId).userSummaryLastUpdate
            ));
        }

        return modifiedUsers;
    }

    /**
     * @description Gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param bc Default param
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {
        // empty
    }
}