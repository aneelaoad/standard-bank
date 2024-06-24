/**
 * Builder class for Call_Report__c SObject
 */
@IsTest
public without sharing class BLD_CallReport extends ABS_ObjectBuilderBase {
	
	public BLD_CallReport() {  
		this(getNewUnitOfWork());        
	}

    public BLD_CallReport(fflib_SObjectUnitOfWork workUnit) { 
        super(Call_Report__c.SObjectType, workUnit);
    }

    private BLD_CallReport(Call_Report__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

	protected override void setDefaultData() {
		startDate(System.now());
		endDate(System.now().addHours(1));
	}

	public BLD_CallReport useNbacMeeting() {
		return (BLD_CallReport) setField(Call_Report__c.RecordTypeId,
			UTL_RecordType.getRecordTypeId(DMN_CallReport.OBJ_NAME, DMN_CallReport.RT_NBAC_MEETING));
	}

	public BLD_CallReport subject(String subject){
		return (BLD_CallReport)setField(Call_Report__c.Subject__c, subject);
	}

	public BLD_CallReport internal(){
		return (BLD_CallReport)setField(Call_Report__c.Meeting_Audience__c, DMN_CallReport.INTERNAL);
	}

	public BLD_CallReport external(){
		return (BLD_CallReport)setField(Call_Report__c.Meeting_Audience__c, DMN_CallReport.EXTERNAL);
	}

	public BLD_CallReport meetingPurpose(String meetingPurpose){
		return (BLD_CallReport)setField(Call_Report__c.Meeting_Purpose__c, meetingPurpose);
	}

	public BLD_CallReport linkWithParent(Id parentId){

		Schema.SObjectField sField;

		if(parentId.getSobjectType() == Account.SobjectType){ 
			sField = Call_Report__c.Relate_to_Client__c;
		}
		else{
			throw new BuilderCallReportException('No matching parent for Id');
		}

		return (BLD_CallReport)setField(sField, parentId);
	}

	public BLD_CallReport linkWithParent(ABS_ObjectBuilderBase parentBuilder){

		Schema.SObjectField sField;

		if(parentBuilder instanceOf BLD_Account){ 
			sField = Call_Report__c.Relate_to_Client__c;
		}
		else{
			throw new BuilderCallReportException('No matching parent for Id');
		}

		super.setRelation(sField, parentBuilder);  
		return this;
	}

	public BLD_CallReport clientContact(BLD_Contact contactBuilder) {
		return (BLD_CallReport) setRelation(Call_Report__c.Report_Client_Contact__c, contactBuilder);
	}

	public BLD_CallReport startDate(Datetime startDate){
		return (BLD_CallReport)setField(Call_Report__c.Start__c, startDate);
	}

	public BLD_CallReport endDate(Datetime endDate){
		return (BLD_CallReport)setField(Call_Report__c.End__c, endDate);
	}

	public BLD_CallReport assign(Id userId){
		return (BLD_CallReport)setField(Call_Report__c.Assigned_To__c, userId);
	}

	public BLD_CallReport description(String description){
		return (BLD_CallReport)setField(Call_Report__c.Description__c, description);
	}

	public BLD_CallReport topics(String topics){
		return (BLD_CallReport)setField(Call_Report__c.Topics__c, topics);
	}

	public BLD_CallReport addAttendee(BLD_CallReportAttendee attendeeBld) {
		return(BLD_CallReport) addChild(Call_Report_Attendees__c.Call_Report__c, attendeeBld);
	}

	public BLD_CallReport addShare(BLD_CallReportShare shareBuilder) {
		return(BLD_CallReport) addChild(Call_Report__Share.ParentId, shareBuilder);
	}

	public BLD_CallReport createdDate(DateTime createdDate) {
		return (BLD_CallReport) setField(Call_Report__c.CreatedDate, createdDate);
	}

	public BLD_CallReport meetingFormat(String meetingFormat) {
		return (BLD_CallReport) setField(Call_Report__c.Meeting_Format__c, meetingFormat);
	}

	public BLD_CallReport meetingAudience(String meetingAudience) {
		return (BLD_CallReport) setField(Call_Report__c.Meeting_Audience__c, meetingAudience);
	}

	public BLD_CallReport attendeeReminderRequired(String reminder) {
		return (BLD_CallReport) setField(Call_Report__c.Attendee_Reminder_Required__c, reminder);
	}

	public BLD_CallReport nbacCommittee(String nbacCommittee) {
		return (BLD_CallReport) setField(Call_Report__c.NBAC_Committee__c, nbacCommittee);
	}

	public BLD_CallReport ownerId(Id ownerId) {
		return (BLD_CallReport) setField(Call_Report__c.OwnerId, ownerId);
	}

	public class BuilderCallReportException extends Exception {}
}