/**
 * Builder class for Call_Report_Attendees__c SObject
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		March 2020
 */
@IsTest
public without sharing class BLD_CallReportAttendee extends ABS_ObjectBuilderBase {

    public BLD_CallReportAttendee() {
        this(getNewUnitOfWork());
    }

    public BLD_CallReportAttendee(fflib_SObjectUnitOfWork uow) {
        super(Call_Report_Attendees__c.SObjectType, uow);
    }

    public BLD_CallReportAttendee status(String status) {
        return (BLD_CallReportAttendee) setField(Call_Report_Attendees__c.Status__c, status);
    }

    public BLD_CallReportAttendee callReportId(Id callReportId) {
        return (BLD_CallReportAttendee) setField(Call_Report_Attendees__c.Call_Report__c, callReportId);
    }

    public BLD_CallReportAttendee callReport(BLD_CallReport callReportBld) {
        return (BLD_CallReportAttendee) setRelation(Call_Report_Attendees__c.Call_Report__c, callReportBld);
    }

    public BLD_CallReportAttendee contact(BLD_Contact contactBuilder) {
        return (BLD_CallReportAttendee) setRelation(Call_Report_Attendees__c.Contact_id__c, contactBuilder);
    }

    public BLD_CallReportAttendee contactId(Id contactId) {
        return (BLD_CallReportAttendee) setField(Call_Report_Attendees__c.Contact_id__c, contactId);
    }

    public BLD_CallReportAttendee type(String type) {
        return (BLD_CallReportAttendee) setField(Call_Report_Attendees__c.Type_of_Attendee__c, type);
    }

    public BLD_CallReportAttendee addTopic(BLD_Topic topicBuilder) {
        return (BLD_CallReportAttendee) addChild(Topic__c.Event_Report_Attendees__c, topicBuilder);
    }

}