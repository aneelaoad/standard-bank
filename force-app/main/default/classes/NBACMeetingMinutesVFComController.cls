/**
 ***********************************************************************
 * @author       Nikita Haruk 
 * @date         September 2023
 * @description  SFP-29983: The controller apex class for the NBACMeetingMinutesVFCom VF component.
 ***********************************************************************
 */
public without sharing class NBACMeetingMinutesVFComController {
    public Id nbacId { get; set; }
    public String nbacName { get; set; }
    public String otmLocation { get; set; }
    public String omtNBACCommite { get; set; }
    public String startDateOutput { get; set; }
    public String startTimeOutput { get; set; }
    public String endTimeOutput { get; set; }
    public String outputSubject { get; set; }
    public String timeZone { get; set; }
    public String comments { get; set; }
    public String chairpersonOutput { get; set; }
    public String nbacSecretaryoutput { get; set; }
    public Id eventReportId { get; set; }
    public String otmApproval { get; set; }
    public List<Task> tasks { 
        get{
            if(tasks == null){
                tasks = getTasksData(); 
            }
            return tasks;
        } 
        set; 
    }

    public Agenda__c agenda {
        get {
            if (agenda == null) {
                agenda = getData();
                
            }
            return agenda;
        }
        set;
    }

    /**    
     * @description Fetches an Agenda record by NBAC's Id.
	 *
     *  @return Agenda__c - the Agenda record that is related to the NBAC record.
     **/
    private Agenda__c getData() {
        Agenda__c agenda = new SEL_Agendas().selectByNBACIds(new Set<Id> { nbacId }).get(0);

        otmLocation         = agenda.Event_Report__r.Location__c;
        omtNBACCommite      = agenda.Event_Report__r.NBAC_Committee__c;
        startDateOutput     = agenda.Event_Report__r.Start__c?.format('hh:mm a');
        startTimeOutput     = agenda.Event_Report__r.Start__c?.format('EEEEE, dd MMM yyyy');
        endTimeOutput       = agenda.Event_Report__r.End__c?.format('hh:mm a');
        timeZone            = value2TimeZones.get(UserInfo.getTimeZone().toString()); 
        outputSubject       = agenda.Event_Report__r?.Subject__c;
        comments            = agenda.Related_NBAC__r.Committee_Commentary__c;
        chairpersonOutput   = agenda.Event_Report__r.Chairperson__r.Name;
        nbacSecretaryoutput = agenda.Event_Report__r.NBAC_Secretary__r.Name;
        nbacName            = agenda.Related_NBAC__r.Name;
        eventReportId       = agenda.Event_Report__r.Id;
        otmApproval         = agenda.Related_NBAC__r.Approval_Status__c;

        return agenda;
    }

    private List<Task> getTasksData(){
        return new SEL_Tasks().selectByWhatIdWithCustomFilterAndLimit(new Set<Id>{nbacId}, 'Type = \'NBAC Action Item\'', 100); 
    }

    /**    
     * @description Fetches the map of values by labels for Time Zones in Org.
	 *
     *  @return Map<String, String> - the map of values by labels for Time Zones in Org.
     **/
    private Map<String, String> value2TimeZones {
        get {
            if (value2TimeZones != null) {
                return value2TimeZones;
            } else {
                List<Schema.PicklistEntry> entries = User.TimeZoneSidKey.getDescribe().getPicklistValues();
                value2TimeZones = new Map<String, String>();
                for(Schema.PicklistEntry entry : entries) {
                    value2TimeZones.put(entry.getValue(), entry.getLabel());
                }
                return value2TimeZones;
            }
        } private set;
    } 
}