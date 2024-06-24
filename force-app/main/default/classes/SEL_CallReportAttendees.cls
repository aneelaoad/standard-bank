/**
 * @description Selector class for the Call_Report_Attendees object
 *
 * @AUTHOR Omar Berraj
 * @date August 2020
 */
/*************************************************************************
    @ Last Modified By  : Augustine Chirombo
    @ Last Modified On  : Oct 10, 2023
    @ Modification Description : Adding selector for event ids 
****************************************************************************/
public inherited sharing class SEL_CallReportAttendees extends fflib_SObjectSelector {

    /**
     * @description new instance of SEL_CallReportAttendees
     * @return SEL_CallReportAttendees
     */
    public static SEL_CallReportAttendees newInstance() {
        return (SEL_CallReportAttendees) ORG_Application.selector.newInstance(Call_Report_Attendees__c.SObjectType);
    }

    /**
     * @description get object types
     * @return SObjectType
     */
    public SObjectType getSObjectType() {
        return Call_Report_Attendees__c.SObjectType;
    }

    /**
     * @description get object list fields 
     * @return List<SObjectField>
     */
    public List<SObjectField> getSObjectFieldList() {

        return new List<SObjectField> {
                Call_Report_Attendees__c.Attendee_Name__c,
                Call_Report_Attendees__c.Client_Name__c,
                Call_Report_Attendees__c.Client_Team_Role__c,
                Call_Report_Attendees__c.CompositeKey__c,
                Call_Report_Attendees__c.Contact_id__c,
                Call_Report_Attendees__c.Contact_Category__c,
                Call_Report_Attendees__c.Contact_Owner_Id__c,
                Call_Report_Attendees__c.Contact_Type__c,
                Call_Report_Attendees__c.ContactRecordType__c,
                Call_Report_Attendees__c.Costs_Per_Attendee__c,
                Call_Report_Attendees__c.CreatedById,
                Call_Report_Attendees__c.CurrencyIsoCode,
                Call_Report_Attendees__c.Send_Email__c,
                Call_Report_Attendees__c.Email__c,
                Call_Report_Attendees__c.Name,
                Call_Report_Attendees__c.ExtContactId__c,
                Call_Report_Attendees__c.LastModifiedById,
                Call_Report_Attendees__c.Related_Agenda__c,
                Call_Report_Attendees__c.Status__c,
                Call_Report_Attendees__c.Title__c,
                Call_Report_Attendees__c.Type_of_Attendee__c
        };
    }

    /**
     * @description get Report Attendees by Ids
     * @param ids 
     * @return List<Call_Report_Attendees__c>
     */
    public List<Call_Report_Attendees__c> selectById(Set<Id> ids) {

        return (List<Call_Report_Attendees__c>) Database.query(
                newQueryFactory()
                .setCondition('Id IN :ids')
                .toSOQL()
        );
    }

    /**
     * @description get Report Attendees by contact Ids
     * @param contactIds 
     * @return List<Call_Report_Attendees__c>
     */
    public List<Call_Report_Attendees__c> selectByContactId(Set<Id> contactIds) {

        return (List<Call_Report_Attendees__c>) Database.query(
                newQueryFactory()
                .setCondition('Contact_id__c IN :contactIds')
                .toSOQL()
        );
    }

    /**
     * @description get Report Attendees by contact Ids
     * @param eventIds 
     * @return List<Call_Report_Attendees__c>
     */
    public List<Call_Report_Attendees__c> selectByEventIds(Set<Id> eventIds) {

        return (List<Call_Report_Attendees__c>) Database.query(
                newQueryFactory()
            	.selectField('Contact_id__r.FirstName')
                .selectField('Contact_id__r.LastName')
                .selectField('Contact_id__r.Email')
             	.selectField('Related_Agenda__r.NBAC_Name__c')
                .setCondition('Call_Report__c IN :eventIds')
                .toSOQL()
        );
    }
    
    /**
     * @description get Report Attendees by ContactId And Status
     * @param contactIds
     * @param invited
     * @param attended 
     * @return List<Call_Report_Attendees__c>
     */
    public List<Call_Report_Attendees__c> selectByContactIdAndStatus(Set<Id> contactIds, String invited, String attended) {

        return (List<Call_Report_Attendees__c>) Database.query(
                newQueryFactory()
                .setCondition('Contact_id__c IN :contactIds AND (Status__c = :invited OR Status__c = :attended)')
                .selectField('Call_Report__r.CreatedDate')
                .toSOQL()
        );
    }
}