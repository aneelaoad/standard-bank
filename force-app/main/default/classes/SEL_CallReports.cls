/**
 * @description Selector class for the Call_Report object
 *
 * @AUTHOR Omar Berraj
 * @date August 2020
 * 
 * 2023-05-10   DErek Hughes    Added constructor to control CURD and FLS enforcement.
 */
public inherited sharing class SEL_CallReports extends fflib_SObjectSelector {

    /**
     * @description Creates a new instance of the selector via the application class.
     *
     * @return
     */
    public static SEL_CallReports newInstance() {
        return (SEL_CallReports) ORG_Application.selector.newInstance(Call_Report__c.SObjectType);
    }

    public SEL_CallReports() {
        super();
    }

     /**
     * Constructs the Selector
     *
     * @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well 
     * @param enforceCRUD Enforce CRUD security
     * @param enforeFLS Enforce Field Level Security
     * **/
    public SEL_CallReports(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }

    public SObjectType getSObjectType() {
        return Call_Report__c.SObjectType;
    }

    /**
     * @description Returns the list of Call Report fields
     *
     * @return List of fields
     */
    public List<SObjectField> getSObjectFieldList() {

        return new List<SObjectField> {
                Call_Report__c.Account_Name__c,
                Call_Report__c.Description__c,
                Call_Report__c.AgendaMeetingDate__c,
                Call_Report__c.AllDayEvent__c,
                Call_Report__c.Assigned_To__c,
                Call_Report__c.Attendee_Reminder_Required__c,
                Call_Report__c.BPID__c,
                Call_Report__c.C_Suite_Attendance__c,
                Call_Report__c.Chairperson__c,
                Call_Report__c.Client_Contact__c,
                Call_Report__c.Report_Client_Contact__c,
                Call_Report__c.Client_Contact_Name__c,
                Call_Report__c.Report_Client_Contact__c,
                Call_Report__c.ClientId__c,
                Call_Report__c.Competitor_Information__c,
                Call_Report__c.Contact__c,
                Call_Report__c.Core_Client_Team_Attendees__c,
                Call_Report__c.Core_Meeting__c,
                Call_Report__c.CreatedById,
                Call_Report__c.Created_By_Name__c,
                Call_Report__c.CurrencyIsoCode,
                Call_Report__c.Customer_Segment__c,
                Call_Report__c.Date__c,
                Call_Report__c.Division__c,
                Call_Report__c.End__c,
                Call_Report__c.Enforce_Core_Attendee_Validation__c,
                Call_Report__c.Event_Priority__c,
                Call_Report__c.Event_Record__c,
                Call_Report__c.Name,
                Call_Report__c.Event_Report_Count__c,
                Call_Report__c.EventId__c,
                Call_Report__c.Follow_Up_Items__c,
                Call_Report__c.Instigated_By__c,
                Call_Report__c.Issues_Risks__c,
                Call_Report__c.LastModifiedById,
                Call_Report__c.Location__c,
                Call_Report__c.Meeting_Audience__c,
                Call_Report__c.Meeting_Notes__c,
                Call_Report__c.Meeting_Purpose__c,
                Call_Report__c.NBAC_Committee__c,
                Call_Report__c.NBAC_Secretary__c,
                Call_Report__c.Number_Of_Attended_Attendees__c,
                Call_Report__c.Number_of_attendees__c,
                Call_Report__c.Outcomes__c,
                Call_Report__c.OwnerId,
                Call_Report__c.RecordTypeId,
                Call_Report__c.Related_To__c,
                Call_Report__c.Related_to_Campaign__c,
                Call_Report__c.Related_To_Case__c,
                Call_Report__c.Relate_to_Client__c,
                Call_Report__c.Related_To_Non_Corporate_Clients_del__c,
                Call_Report__c.Related_To_Non_CIB_Client__c,
                Call_Report__c.Relate_to_Opp__c,
                Call_Report__c.Report_Show_Time_As__c,
                Call_Report__c.Start__c,
                Call_Report__c.Subject__c,
                Call_Report__c.Topics__c,
                Call_Report__c.Total_Event_Costs__c,
                Call_Report__c.Report_Type__c,
                Call_Report__c.Visible_to_Internal_Attendees_only__c
        };
    }

    public List<Call_Report__c> selectThisYearEndByClientIdsAndAudience(Set<Id> clientIds, Set<String> meetingAudience) {
        fflib_QueryFactory factory = newQueryFactory();
        factory.subselectQuery('Opportunities__r', true);
        factory.subselectQuery('Call_Report_Attendeess__r', true).selectField('Status__c').selectField('Client_Team_Role__c');

        return (List<Call_Report__c>) Database.query(
            factory
            .setCondition('Relate_to_Client__c IN :clientIds AND End__c = THIS_YEAR AND Meeting_Audience__c IN :meetingAudience')
                .toSOQL()
        );
    }

    public List<Call_Report__c> selectByEventIds(Set<Id> ids) {

        return (List<Call_Report__c>) Database.query(
                newQueryFactory()
                .setCondition('Eventid__c IN :ids')
                .toSOQL()
        );
    }
}