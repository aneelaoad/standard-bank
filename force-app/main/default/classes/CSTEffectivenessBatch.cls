/*************************************************************************
    @ Author        : Petr Roubal
    @ Test File     : CSTEffectivenessCronJob_Test
    @description    : EN-0695 CST - Report for CST Effectiveness, the batch Class to execute the logic for updating  / Inserting 
    @                 data for client effectiveness report

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : added debug messages for lists' size()

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 17, 2015
    @ Modification Description : added workaround - query updates record not updated today and the batch automatically schedules itself if some records were missed (silently)
                                 made class Stateful -> will not reschedule if some record failed to update (e.g., due to a validation rule)

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 20, 2015
    @ Modification Description : emailing of the exception is added to the workaround
    
    @ Last Modified By  : Petr Roubal
    @ Last Modified On  : Aug 24, 2015
    @ Modification Description : changing filter in getTask section, suggested by SFDC PS

    @ Last Modified By  : Manoj Gupta
    @ Last Modified On  : July 15, 2016
    @ Modification Description : US:1465 Core Meeting Indicator included in the meeting criteria for this batch 
****************************************************************************/
global class CSTEffectivenessBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CSTEffectivenessBatch');
    private static final SEL_CallReports SEL_CALLREPORTS = new SEL_CallReports(true, true, true);

    public string query;
    public List<CurrencyType> currTable = new List<CurrencyType>();
    public Map<String, Double> rateMap = new Map<String, Double>();
    public string corporateIsoCode = 'USD';

    private static final string INTERNAL_MEETING = 'Internal';
    private static final string EXTERNAL_MEETING = 'External';
    private static final string OPP_STAGE_CANCEL = 'Cancel';
    private static final String OPP_STAGE_LEAD = '1 - Lead';
    private static final String OPP_STAGE_DEVELOP = '2 - Develop';
    private static final string OPP_STAGE_CLOSED_LOST = '4 - Closed Lost';
    private static final string CORE_CLIENT_TEAM_MEETING = 'Core Client Team Meeting';
    private static final string CLIENT_ENTERTAIMENT = 'Client Entertainment';
    private static final string CLIENT_MEETING = 'Client Meeting';
    private static final string CLIENT_ROADSHOW = 'Client Road Show';
    private static final string MARKETING_RESEARCH_UPDATE = 'Market Research Update';
    private static final string ATTENDED = 'Attended';
        

    private Map<String,CSTTeamRoleRanking__c> coreTeamRoles;
    CurrencyConverter converter;

    /**
     * @description Default constructor. Uses different query for test class.
     */
    global CSTEffectivenessBatch() {
        query = 'Select Id, Actual_CY_Revenue__c, CurrencyIsoCode, Client_Summary_Last_Updated__c, Core_Team_Members_on_External_Meetings__c,' +
            'Core_Team_Members_on_Internal_Meetings__c, External_Meetings_Completed__c, External_Meetings_Scheduled__c,' +
            'Internal_Meetings_Completed__c, Internal_Meetings_Scheduled__c, Number_of_Pipeline_Opportunities__c,' +
            'Number_of_Won_Opportunities__c, Opportunities_from_External_Meetings__c, Opportunities_from_Internal_Meetings__c, Pipeline_Opportunities_CY_Revenue__c,' +
            'Won_Opportunities_CY_Revenue__c from Account ' +
            'WHERE ' +
            '(Client_Summary_Last_Updated__c < TODAY OR Client_Summary_Last_Updated__c = null)' +
            'AND (CIF__c != \'\' OR  RecordType.Name = \'Prospect\' )';
        coreTeamRoles = CSTTeamRoleRanking__c.getAll();
        converter = new CurrencyConverter();
        corporateIsoCode = UserInfo.getDefaultCurrency();
        snapCurrencyTable();
    }

    /**
     * @description Gets invoked when the batch job executes and operates on one batch of records.
     * Contains or calls the main execution logic for the batch job.
     * @param bc Default param
     * @return the record set of Clients that meets specific criteria
     */
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }

    /**
     * @description Computes the values for the batch
     * 
     * @param bc Default param
     * @param scope Default param
     * 
     * If some records fail to update (and throws a DmlException), this is stored into a stateful variable. The whole job will then not reschedule automatically.
     */
    global void execute(Database.BatchableContext bc, List<Account> scope)
    {
        Map<Id,Account> accMap = new Map<Id,Account>(scope);
        try {
            List<Account> modifiedAccounts = new List<Account>();
            if (!scope.isEmpty()) {                                   
                modifiedAccounts = getData(accMap);
                update modifiedAccounts;
            }
        } catch (Exception e) {
            LOGGER.fatal('Failed CSTEffectivenessBatch.execute(),\n StackTraceString:'+e.getStackTraceString() +'\n getMessage:'+e.getMessage()+'\n scope Ids :'+ accMap.keyset() );//Print scope Ids
        }
    }

    /**
     * @description Watch-dog function:
     * <ul>
     *   <li>If some records didn't update (e.g., due to a validation rule, etc.), the job ends.</li>
     *   <li>Otherwise, it checks whether there's more to be processed and if so, schedules itself to run in 10 minutes from now. (This is to prevent silent errors in production issue #12341188.)
     * </ul>
     * 
     * @param bc Default param
     * 
     */
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        if (a.NumberOfErrors > 0) {
            sendemail(a);
        } else {
            Integer cnt = [
                SELECT COUNT()
                FROM Account
                WHERE Client_Summary_Last_Updated__c < TODAY
                    OR Client_Summary_Last_Updated__c = null
            ];

            if (cnt != null || cnt > 0) {
                system.scheduleBatch(new CSTEffectivenessBatch(),
                    Test.isRunningTest()
                        ? 'CST Effectiveness Report Job test' + String.valueOf((Math.random() * 10))
                        : 'CST Effectiveness Report Job (automat. scheduled)',
                    5, // minutesFromNow
                    10  // scopeSize
                );
            } else {
                system.debug('##### all batches finished successfully');
            }
        }
    }

    /**
     * @description Returns a given accounts list enriched with values for the CST Effectiveness report.
     * <p>
     * This method is public to allow easy testig of the enrichment logic.
     *
     * @param  accMap a map of accounts and thier ids to be enriched
     * @return  the enriched list of accounts
     */
    public Account[] getData(Map<Id, Account> accMap) {
        List<Account> accListReport = new List<Account>();
		Map<Id,CSTReport> reportMap = new Map<Id,CSTReport>();
        CSTReport report = new CSTReport();
		
		//#step1
        for (Call_Report__c cr : getClientMeetings(accMap.keyset())) {
            report  = reportMap.containskey(cr.Relate_to_Client__c) ? reportMap.get(cr.Relate_to_Client__c) : new CSTReport();
            
            Boolean isInternal = cr.Meeting_Audience__c == INTERNAL_MEETING;
            Boolean isExternal = cr.Meeting_Audience__c == EXTERNAL_MEETING;
            Boolean isClientOriented = (
                cr.Meeting_Purpose__c == CLIENT_MEETING ||
                cr.Meeting_Purpose__c == CLIENT_ENTERTAIMENT ||
                cr.Meeting_Purpose__c == CLIENT_ROADSHOW ||
                cr.Meeting_Purpose__c == MARKETING_RESEARCH_UPDATE
            );
            
            Integer numberOfAttendees = 0;
            
            for (Call_Report_Attendees__c cra : cr.Call_Report_Attendeess__r) {
                if (cra.Status__c == ATTENDED && coreTeamRoles.keySet().contains(cra.Client_Team_Role__c)) {
                    numberOfAttendees++;
                }
            }
            
            if (isInternal && cr.Meeting_Purpose__c == CORE_CLIENT_TEAM_MEETING) {
                if (cr.Core_Meeting__c == true) {
                    report.internal.attendees += numberOfAttendees;
					report.internal.pastMeetings += cr.End__c < Datetime.now() ? 1 : 0;
					report.internal.opps += cr.Opportunities__r.size() > 0 ? cr.Opportunities__r.size() : 0;
                }
                
                if (cr.End__c >= Datetime.now()) {
                    report.internal.futureMeetings++;
                }
            } else if (isExternal && isClientOriented) {
                if (cr.Core_Meeting__c == true) {
                    report.external.attendees += numberOfAttendees;
					report.external.pastMeetings += cr.End__c < Datetime.now() ? 1 : 0;
					report.external.opps += cr.Opportunities__r.size() > 0 ? cr.Opportunities__r.size() : 0;
                }
                
                if (cr.End__c >= Datetime.now()) {
                    report.external.futureMeetings++;
                }
            }

			reportMap.put(cr.Relate_to_Client__c, report);		//@add/update the md instance
        }
        
		//#step2
        List<Id> hierarchyIds = getAccountHierarchy(accMap.keyset());
		//#step3
        String accParentid;

        for (Opportunity opp : getClientOpps(hierarchyIds)) {
            Boolean isWonOpp = (
                opp.isWon &&
                opp.isClosed &&
                opp.Actual_Close_Date__c.year() == Date.today().year()
            );

            Boolean isOpenOpp = (
                opp.StageName == OPP_STAGE_LEAD ||
                opp.StageName == OPP_STAGE_DEVELOP
            );

            accParentid = string.isNotBlank(opp.Account.Top_Parent_Id__c) ? opp.Account.Top_Parent_Id__c : opp.accountId;
            report = reportMap.containskey(accParentid) ? reportMap.get(accParentid) : new CSTReport();

            report.winOpp += isWonOpp ? 1 : 0;

            if (opp.Current_Year_Revenue_Currency__c != null) {
                if (isOpenOpp) {
                    report.piplineOpps++;
                    report.oppRevenue = report.oppRevenue + converter.convert(
                        Double.valueOf(opp.Current_Year_Revenue_Currency__c),
                        corporateIsoCode,
                        rateMap,
                        accMap.get(accParentid).CurrencyIsoCode
                    );
                    reportMap.put(accParentid, report);
                } else if (isWonOpp) {
                    report.oppCloseRev = report.oppCloseRev + converter.convert(
                        Double.valueOf(opp.Current_Year_Revenue_Currency__c),
                        corporateIsoCode,
                        rateMap,
                        accMap.get(accParentid).CurrencyIsoCode
                    );
            
                    reportMap.put(accParentid, report);		//@add/update the md instance
                }
            }
        }
		
		Map<Id, Decimal> revAccMap = getClientRevenue(accMap.keyset());
		for (Account a: accMap.values()) {	
			report = reportMap.containskey(accParentid) ? reportMap.get(accParentid) : new CSTReport();	
			
			report.revenue = revAccMap.get(a.Id);	//report @att
						
			reportMap.put(a.Id, report);		//@add/update the md instance
		}
		
		
		for (Account a: accMap.values()) {
			report = reportMap.containskey(a.Id) ? reportMap.get(a.Id) : new CSTReport();	
			
			a.Actual_CY_Revenue__c = report.revenue;
			a.Client_Summary_Last_Updated__c = DateTime.now();
			a.Core_Team_Members_on_External_Meetings__c = report.external.attendees;
			a.Core_Team_Members_on_Internal_Meetings__c = report.internal.attendees;
			a.External_Meetings_Completed__c = report.external.pastMeetings;
			a.External_Meetings_Scheduled__c = report.external.futureMeetings;
			a.Internal_Meetings_Completed__c = report.internal.pastMeetings;
			a.Internal_Meetings_Scheduled__c = report.internal.futureMeetings;
			a.Number_of_Pipeline_Opportunities__c = report.piplineOpps;         // all time
			a.Number_of_Won_Opportunities__c = report.winOpp;                   // this year
			a.Opportunities_from_External_Meetings__c = report.external.opps;
			a.Opportunities_from_Internal_Meetings__c = report.internal.opps;
			a.Pipeline_Opportunities_CY_Revenue__c = report.oppRevenue;         // all time
			a.Won_Opportunities_CY_Revenue__c = report.oppCloseRev;             // this year
				
			accListReport.add(a);			
		}

        return accListReport;
    }
    
   /*******************
    * Private methods *
    *******************/

    /**
     * @description Returns the list of client reports related to the chosen accounts.
     *
     * @param  clientIds a set of clients Ids
     * @return  the enriched list of client reports
     */
    private List<Call_Report__c> getClientMeetings(Set<Id> clientIds) {
        return SEL_CALLREPORTS.selectThisYearEndByClientIdsAndAudience(clientIds, new Set<String> { INTERNAL_MEETING, EXTERNAL_MEETING });
    }

    /**
     * @description Returns the list of opportunities related to the chosen accounts.
     *
     * @param  clientIds a set of clients Ids
     * @return  the enriched list of opportunities
     */
    private List<Opportunity> getClientOpps(List<Id> clientIds) {
        List<Opportunity> lstOpp = [
            SELECT Id, 
                AccountId,
                Account.Top_Parent_Id__c,
                CurrencyIsoCode,
                convertCurrency(Current_Year_Revenue_Currency__c),
                StageName,
                Actual_Close_Date__c,
                isWon,
                isClosed
            FROM Opportunity
            WHERE AccountId IN :clientIds
        ];

        return lstOpp != null ? lstOpp : new List<Opportunity>();
    }

    /**
     * @description Returns the list of accounts' Ids in hierarchy for chosen accounts.
     *
     * @param  clientIds a set of clients Ids
     * @return  the list of accounts' Ids from their hierarchy
     */
    private List<Id> getAccountHierarchy(Set<Id> clientIds) {
        Set<Id> parentIds   = new Set<Id>();
        Set<Id> idsToReturn = new Set<Id>(clientIds);

        for (Account acc : [
            SELECT Id,
                Parent.Parent.ParentId,
                Parent.ParentId,
                ParentId
            FROM Account
            WHERE Id IN :clientIds
        ]) {
            if (String.isNotBlank(acc.Parent.Parent.ParentId)) {
                parentIds.add(acc.Parent.Parent.ParentId);
            } else if (String.isNotBlank(acc.Parent.ParentId)) {
                parentIds.add(acc.Parent.ParentId);
            } else if (String.isNotBlank(acc.ParentId)) {
                parentIds.add(acc.ParentId);
            } else {
                parentIds.add(acc.Id);
            }
        }

        for (Account acc : [
            SELECT Id
            FROM Account
            WHERE Parent.Parent.ParentId IN :parentIds
                OR Parent.ParentId IN :parentIds
                OR ParentId IN :parentIds
        ]) {
            idsToReturn.add(acc.Id);
        }

        idsToReturn.addAll(parentIds);

        return new List<Id> (idsToReturn);
    }

    /**
     * @description Returns the client revenue for chosen accounts.
     *
     * @param  clientIds a set of clients Ids
     * @return  the Map of accounts' Ids and their revenue values
     */
	private Map<Id, Decimal> getClientRevenue(Set<Id> clientIds) {
        Map<Id, Decimal> revAccMap = new Map<Id, Decimal>();
		
		for (AggregateResult ag : [Select Client__c, SUM( g.Client_Value_ZAR_Current_Year__c)sumRev From Global_Client_Revenue__c g where g.Client__c IN :clientIds group by Client__c]) {
			revAccMap.put(String.valueOf( ag.get('Client__c')) , (Decimal) ag.get('sumRev') != null ? (Decimal) ag.get('sumRev') : 0);
		}
        return revAccMap;
    }

    /**
     * @description Method that pulls the latest currency conversion rates.
     *
     */
    private void snapCurrencyTable() {
        this.currTable = [Select cur.IsCorporate, cur.IsoCode, cur.ConversionRate From CurrencyType cur];

        for (CurrencyType c: currTable) {
            rateMap.put(c.IsoCode, c.ConversionRate);
        }
    }

    /**
     * @description @description Class to collect CST report data in one entity
	 */
    public class CSTReport {
        Id clinetId;
        MeetingData internal;
        MeetingData external;
        Integer incomplTask;
        Integer complTask;
        Integer piplineOpps;
        Decimal oppRevenue;
        Integer winOpp;
        Decimal oppCloseRev;
        Decimal revenue;

       /**
     	* @description Default constructor. Uses different query for test class.
     	*/
        public CSTReport() {
            internal = new MeetingData();
            external = new MeetingData();
            piplineOpps = 0;
            oppRevenue = 0;
            winOpp = 0;
            oppCloseRev = 0;
            revenue = 0;
        }
    }

    /**
     * @description Class to collect meeting data in one entity
	 */ 
    public class MeetingData {
        Integer attendees;
        Integer pastMeetings;
        Integer futureMeetings;
        Integer opps;

       /**
     	* @description Default constructor. Uses different query for test class.
     	*/
        public MeetingData() {
            attendees = 0;
            pastMeetings = 0;
            futureMeetings = 0;
            opps = 0;
        }
    }

    /**
     * @description Class to convert currencies
	 */ 
    public class CurrencyConverter {
        /**
         * @description Sends the email with error details.
         *
         * @param  val a decimal value to convert
         * @param oldCurr an old value as String
         * @param rateMap a map with currencies rates
         * @param newCurr a new value as String
         * 
         * @return  a converted value
         */
        public Decimal convert(Decimal val, String oldCurr, Map < String, Double > rateMap, String newCurr) {
            //NOTE ON CALCULATION:
            //(current curr / current rate) = USD(1:1) 
            //(USD * new rate) = new curr value

            // No point in trying to convert a null.
            if (val == null) { return 0; }
            Decimal displayVal;

            if ((oldCurr != newCurr) || (val != 0)) {

                Double oldrate = rateMap.get(oldCurr);
                Decimal usdval = (val / oldrate);
                Double newrate = rateMap.get(newCurr);

                displayVal = (usdval * newrate);

            } else {
                displayVal = val;
            }
            return displayVal;
        }
    }
    
    /**
     * @description Sends the email with error details.
     *
     * @param  a an async Apex Job
     */
    public static void sendemail(AsyncApexJob a) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Environment_Variable__c env = Environment_Variable__c.getInstance();
            String onErrorEmail = env.BatchErrorEmails__c;
            String[] toAddresses = new String[] {
                onErrorEmail
            };
            mail.setToAddresses(toAddresses);
            mail.setSubject('CSTEffectivenessBatch  ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                ' batches with ' + a.NumberOfErrors + ' failures in OrgId ' + UserInfo.getOrganizationId() + ' .');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
            });
    }
}