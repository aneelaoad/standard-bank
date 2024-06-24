@IsTest
public without sharing class BLD_Event extends ABS_ObjectBuilderBase {

	public BLD_Event() {
		this(getNewUnitOfWork());
	}

	public BLD_Event(fflib_SObjectUnitOfWork workUnit) {
		super(Event.sObjectType, workUnit);
	}

	private BLD_Event(Event sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	public BLD_Event callReportCreated(Boolean isCallReportCreated) {
		return (BLD_Event) setField(Event.Call_Report_Created__c, isCallReportCreated);
	}

	public BLD_Event internalMeeting() {
		return(BLD_Event) setField(Event.Meeting_Audience__c, DMN_Event.INTERNAL);
	}

	public BLD_Event externalMeeting() {
		return(BLD_Event) setField(Event.Meeting_Audience__c, DMN_Event.EXTERNAL);
	}

	public BLD_Event allDayEvent(Boolean isAllDayEvent) {
		return (BLD_Event) setField(Event.IsAllDayEvent, isAllDayEvent);
	}

	public BLD_Event durationInMinutes(Integer durationInMinutes) {
		return (BLD_Event) setField(Event.DurationInMinutes, durationInMinutes);
	}

	public BLD_Event meetingPurpose(String meetingPurpose) {
		return(BLD_Event) setField(Event.Meeting_Purpose__c, meetingPurpose);
	}

	public BLD_Event startDate(DateTime startDate) {
		return(BLD_Event) setField(Event.StartDateTime, startDate);
	}

	public BLD_Event stopDate(DateTime stopDate) {
		return(BLD_Event) setField(Event.EndDateTime, stopDate);
	}

	public BLD_Event reportContact(BLD_Contact contactBld) {
		return(BLD_Event) setRelation(Event.Report_Client_Contact__c, contactBld);
	}

	public BLD_Event owner(Id ownerI) {
		return(BLD_Event) setField(Event.OwnerId, ownerI);
	}
	
	public BLD_Event restricted() {
		return(BLD_Event) setField(Event.Visible_to_Internal_Attendees_only__c, true);
	}

	public BLD_Event unrestricted() {
		return(BLD_Event) setField(Event.Visible_to_Internal_Attendees_only__c, false);
	}

	public BLD_Event linkToParent(Id parentId) {

		Schema.SObjectField sojF;

		if (parentId.getSobjectType() == Account.SobjectType) {
			sojF = Event.WhatId;
		}
		else if (parentId.getSobjectType() == Contact.SobjectType) {
			sojF = Event.WhoId;
		}
		else {
			throw new BuilderEventException('Wrong parent Id ' + parentId);
		}

		return(BLD_Event) setField(sojF, parentId);
	}

	public BLD_Event linkToParent(ABS_ObjectBuilderBase parent) {

		Schema.SObjectField sojF;

		if (parent.getRecord().getSobjectType() == Account.SobjectType) {
			sojF = Event.WhatId;
		}
		else if (parent.getRecord().getSobjectType() == Contact.SobjectType) {
			sojF = Event.WhoId;
		}
		else {
			throw new BuilderEventException('Wrong parent Id ' + parent.getRecordId());
		}

		return(BLD_Event) setRelation(sojF, parent);
	}

	public class BuilderEventException extends Exception { }
}