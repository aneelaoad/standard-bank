/**
 * @author      tbc
 * @date        tbc
 * @description Call Report domain class
 * @user story  tbc
 * @func area   Call Report
 */
/*************************************************************************
    @ Last Modified By  : Nikita Haruk
    @ Last Modified On  : September 14, 2022
    @ Modification Description : SFP-29983: Added logic to sync chairperson between event reports and linked to it NBACs 
****************************************************************************/
public class DMN_CallReport {  

    public static final String 
        INTERNAL                    = 'Internal',
        EXTERNAL                    = 'External',
        DAY_TO_DAY_MEETING          = 'Day To Day Meeting',
        CORE_TEAM_MEETING           = 'Core Client Team Meeting',
        CLIENT_CONFERENCE_CALL      = 'Client Conference Call',
        CLIENT_EMAIL                = 'Client Email',
        CLIENT_ENTERTAINMENT        = 'Client Entertainment',
        CLIENT_MEETING              = 'Client Meeting',
        CLIENT_ROAD_SHOW            = 'Client Road Show',
        CLIENT_SERVICE_DISCUSSION   = 'Client Service Discussion',
        CLIENT_SOCIAL               = 'Client Social',
        CLIENT_TRAINING             = 'Client Training',
        MARKET_RESEARCH_UPDATE      = 'Market Research Update';

    public static final String OBJ_NAME = 'Call_Report__c';
    public static final String RT_NBAC_MEETING = 'NBAC_Meeting';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('NBACMeetingController');


   /**
    * @description removes related Event Reports if Event has been deleted
    * @param oldREcords - the list of Events that will be deleted
    */
    public static void removeRelatedToEvents(Event[] oldREcords){
        Set<String> eventIds = new Set<String>();

        for(Event eveObj : oldREcords){
            eventIds.add(eveObj.Id);
        }

        Call_Report__c[] reportsToDelete = [SELECT Id
                                            FROM Call_Report__c
                                            WHERE EventId__c IN :eventIds];

        if(reportsToDelete.isEmpty()){
            return;
        }

        Database.DeleteResult[] results = Database.delete(reportsToDelete, false);
    }

   /**
    * @description removes related Event Reports if Event has been deleted
    * @param eveObj - the Event record based on which report will be built
    * @param id2Sobject - the Map of Sobjects by Ids
    * @return Call_Report__c - the Call_Report__c record that will be created
    */
    public static Call_Report__c buildReport(Event eveObj, Map<Id, Sobject> id2Sobject){

        DateTime startTime;
        DateTime endTime;

        if(eveObj.ActivityDateTime != null){
            startTime = eveObj.IsAllDayEvent ? 
                    DateTime.newInstance((Date)eveObj.ActivityDateTime, Time.newInstance(0, 0, 0, 0)) 
                    : eveObj.ActivityDateTime;
            endTime = eveObj.IsAllDayEvent ? 
                    DateTime.newInstance((Date)eveObj.ActivityDateTime, Time.newInstance(23, 59, 59, 0)) 
                    : eveObj.ActivityDateTime.addMinutes(eveObj.DurationInMinutes);
        }

        Call_Report__c report = new Call_Report__c( 
            Name                                        = eveObj.Subject,
            EventId__c                                  = eveObj.Id,
            Subject__c                                  = eveObj.Subject,
            Location__c                                 = eveObj.Location,
            Assigned_To__c                              = eveObj.OwnerId,
            AllDayEvent__c                              = eveObj.IsAllDayEvent,
            Start__c                                    = startTime,
            End__c                                      = endTime,
            Meeting_Audience__c                         = eveObj.Meeting_Audience__c,
            Meeting_Purpose__c                          = eveObj.Meeting_Purpose__c,
            Report_Show_Time_As__c                      = eveObj.ShowAs,
            Description__c                              = eveObj.Description,
            Related_To_Non_CIB_Client__c                = eveObj.SA_Related_to_Non_CIB_Client__c,
            Instigated_By__c                            = eveObj.SA_Activity_Instigated__c,
            OwnerId                                     = eveObj.OwnerId,
            Event_Priority__c                           = eveObj.SA_Priority__c,
            Visible_to_Internal_Attendees_only__c       = eveObj.Visible_to_Internal_Attendees_only__c,
            Meeting_Format__c                           = eveObj.Type
        ); 
        
        Id targetId = eveObj.WhoId != null ? eveObj.WhoId : eveObj.WhatId != null ? eveObj.WhatId : null;
        SobjectType st = targetId != null ? targetId.getSobjectType() : null;
        Sobject targetObject = id2Sobject.containsKey(targetId) ? id2Sobject.get(targetId) : null;
        
        if(st == null || targetObject == null){
            return report;
        } else if(st == Opportunity.SobjectType){
            report.Relate_to_Opp__c = (Id)targetObject.get('Id');
        } else if(st == Campaign.SobjectType){
            report.Related_to_Campaign__c = (Id)targetObject.get('Id');
        } else if(st == Case.SobjectType){
            report.Related_to_Case__c = (Id)targetObject.get('Id');
        } else if(st == Contact.SobjectType){
            report.Report_Client_Contact__c = (Id)targetObject.get('Id');
            if(id2Sobject.containsKey((Id)targetObject.get('AccountId'))){
                report.Relate_to_Client__c = (Id)targetObject.get('AccountId');
            }
        } else if(st == Lead.SobjectType){
            report.Report_Client_Lead__c = (Id)targetObject.get('Id');
        } else if(st == Account.SobjectType){
            report.Relate_to_Client__c = (Id)targetObject.get('Id');
        }

        String reportName = eveObj.Subject + ' - ' +
                (st == Contact.SobjectType ? (String)targetObject.getSobject('Account').get('Name')
                : st == Case.SObjectType ? (String)targetObject.get('Subject')
                : (String)targetObject.get('Name'));

        Integer nameLength = Call_Report__c.Name.getDescribe().getLength();
        reportName = reportName.length() <= nameLength ? reportName : reportName.substring(0, nameLength);

        report.Name = reportName;

        return report;
    }

   /**
    * @description removes related Event Reports if Event has been deleted
    * @param creditLineIds - the set of Event Report Ids that will be shared
    * @param userIds - the set of User Ids to that records will be shared
    * @param sharingReson - the sharing reason
    * @param accessLvl - the access level
    * @return Call_Report__share[] - the list of Call_Report__share record that will be generated
    */
    public static Call_Report__share[] shareCallReports(Set<Id> creditLineIds, Set<Id> userIds, String sharingReson, String accessLvl){

        Call_Report__share[] sharingRecords = new Call_Report__share[]{};
        for(Id clId : creditLineIds){
            for(Id usrId : userIds){
                Call_Report__share cls = new Call_Report__share(ParentId  = clId,
                                                                UserOrGroupId = usrId,
                                                                AccessLevel = accessLvl);
                if(String.isNotBlank(sharingReson)){
                    cls.RowCause = sharingReson;
                }
                sharingRecords.add(cls);
            }
        }
        return sharingRecords;  
    }

   /**
    * @description syncs division information
    * @param callReports - the list of Event Report records that were updated
    * @param id2OldReport - the map of old versions Event Report records by Ids
    */
    public static void syncDivsionInfo(Call_Report__c[] callReports, Map<Id, Call_Report__c> id2OldReport){

        Set<Id> accIds = new Set<Id>();

        for(Call_Report__c cr : callReports){ 
            if(cr.Relate_to_Client__c != null 
                && id2OldReport == null){
                accIds.add(cr.Relate_to_Client__c);
            }
            else if(cr.Relate_to_Client__c != null 
                    && cr.Relate_to_Client__c != id2OldReport.get(cr.Id).Relate_to_Client__c){
                accIds.add(cr.Relate_to_Client__c);
            } 
        }

        if(accIds.isEmpty()){
            return;
        }

        Map<Id, Call_Report__c[]> accId2CallReports = UTL_Collections.builListMap(callReports, Call_Report__c.Relate_to_Client__c);
        
        for(Account acc : [ SELECT Primary_Relationship_Holder__c
                            FROM Account
                            WHERE Id IN: accIds]){
            if(!accId2CallReports.containsKey(acc.Id)){
                continue;
            }

            for(Call_Report__c cr : accId2CallReports.get(acc.Id)){
                cr.Division__c = acc.Primary_Relationship_Holder__c;
            }
        }
    }

   /**
    * @description sends email to related clients
    * @param callReports - the list of Event Report records to which emails should be sent
    */
    public static void sendEmailToRelatedClients(List<Call_Report__c> callReports){

        Set<String> meetingToProcess = new Set<String>{ CORE_TEAM_MEETING,
                                                        CLIENT_ENTERTAINMENT,
                                                        CLIENT_MEETING,
                                                        CLIENT_ROAD_SHOW,
                                                        MARKET_RESEARCH_UPDATE};
        Set<Id> accIds      = new Set<Id>();
        Call_Report__c[] reportsToProcess = new Call_Report__c[]{};

        for(Call_Report__c cr : callReports){
            if(cr.Date__c > System.today()
                && meetingToProcess.contains(cr.Meeting_Purpose__c)
                && cr.Relate_to_Client__c != null){
                accIds.add(cr.Relate_to_Client__c);
                reportsToProcess.add(cr);
            }
        } 

        Map<Id, Set<String>> accId2Emails = new Map<Id, Set<String>>();

        for(Custom_Client_Team__c cct : [   SELECT Team_Member__r.Email, Account__c
                                            FROM Custom_Client_Team__c
                                            WHERE Account__c IN: accIds
                                                AND Core__c = true
                                                AND Team_Member__r.Email != null]){
            if(!accId2Emails.containsKey(cct.Account__c)){
                accId2Emails.put(cct.Account__c, new Set<String>());
            }
            accId2Emails.get(cct.Account__c).add(cct.Team_Member__r.Email);
        }  

        if(accId2Emails.isEmpty()){
            return;
        }

        Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.CLIENT_PLAN_APPROVED);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for(Call_Report__c cr : reportsToProcess){
            if(!accId2Emails.containsKey(cr.Relate_to_Client__c)){
                continue;
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] adresses = new List<String>(accId2Emails.get(cr.Relate_to_Client__c));
            email.setTemplateId(templateId);
            email.setToAddresses(adresses);
            email.setTargetObjectId([SELECT Id, Contact_Sync_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Contact_Sync_ID__c);
            email.setTreatTargetObjectAsRecipient(false);
            email.setWhatId(cr.Id);
            email.setSaveAsActivity(false);

            emailMessages.add(email);
        }
        if(!emailMessages.isEmpty()){
            Messaging.sendEmail(emailMessages); 
        } 
    }

   /**
    * @description syncs chairperson between event reports and linked to it NBACs
    * @param callReports - the list of updated Event Reports
    * @param idToOldCallReports - the map of old Event Reports
    */
    public static void updateChairpersonOnNBACs(List<Call_Report__c> callReports, Map<Id, Call_Report__c> idToOldCallReports) {
        try {
            Map<Id, Id> eventReportIdToChairpersonId = new Map<Id, Id>();
            List<Business_Assessment__c> nbacsToUpdate = new List<Business_Assessment__c>();
            Set<Id> lockedNBACIds = new Set<Id>();

            for (Call_Report__c callReport : callReports) {
                if (callReport.Chairperson__c != idToOldCallReports.get(callReport.Id).Chairperson__c) {
                    eventReportIdToChairpersonId.put(callReport.Id, callReport.Chairperson__c);
                }
            }

            for (Agenda__c agenda : new SEL_Agendas().selectByEventReportIds(eventReportIdToChairpersonId.keySet())) {
                if (Approval.isLocked(agenda.NBAC_Id__c)) {
                    lockedNBACIds.add(agenda.NBAC_Id__c);
                }
                nbacsToUpdate.add(new Business_Assessment__c(Id = agenda.NBAC_Id__c, Chairperson__c = eventReportIdToChairpersonId.get(agenda.Event_Report__c)));
            }

            if (!nbacsToUpdate.isEmpty()) {
                Approval.unlock(new List<Id> (lockedNBACIds));
                update nbacsToUpdate;
                Approval.lock(new List<Id> (lockedNBACIds));
            }
        } catch(Exception ex) {
            LOGGER.error('Message: ' + ex.getMessage() + '\nStakeTrace' + ex.getStackTraceString(), new String[] { DMN_CallReport.class.getName() });
        }
    }

   /**
    * @description fetches map of SObjectType by field Name for the Call Report object
    * @return Map<String, SObjectType> - the map of SObjectType by field Name
    */
    public static Map<String, SObjectType> relateField2SobjectType {
        get {
            if (relateField2SobjectType == null) {
                relateField2SobjectType = new Map<String, SObjectType>();
                Map<String, Schema.SObjectField> fields = Call_Report__c.SObjectType.getDescribe().fields.getMap();

                for (String fieldName : fields.keySet()) {
                    if (fields.get(fieldName).getDescribe().getType() == Schema.DisplayType.REFERENCE && fieldName.startsWithIgnoreCase('Relate')) {
                        if (fields.get(fieldName).getDescribe().getReferenceTo().size() > 0) {
                            SObjectType objectTypeName = fields.get(fieldName).getDescribe().getReferenceTo().get(0);
                            relateField2SobjectType.put(fieldName, objectTypeName);
                        }
                    }
                }
            }
            return relateField2SobjectType;
        }
        private set;
    }

    public static final String ACCESS_LEVEL_OWNER = 'All';
    public static final String ACCESS_LEVEL_READ_WRITE = 'Edit';
}