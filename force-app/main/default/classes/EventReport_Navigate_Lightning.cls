public class EventReport_Navigate_Lightning {
    public Call_Report__c eventReportRecord {get;set;}
    public String startDate {get;set;}
    public String endDate {get;set;}
    public string eventReportValues {get;set;}
    private integer counter {get;set;}
    
    public EventReport_Navigate_Lightning(ApexPages.StandardController sc){
        eventReportRecord = new Call_Report__c();
        startDate = convertDateTime(system.now());
        endDate = convertDateTime(system.now().AddHours(1));
        eventReportValues = 'Will be Auto Populated';
        eventReportRecord.Assigned_To__c = UserInfo.getUserId();
        eventReportRecord.OwnerId = UserInfo.getUserId();    
    }
    
    public PageReference Save(){
        system.debug('=Save='+eventReportValues);
        eventReportRecord.Name = eventReportValues;
        eventReportRecord.Start__c = constructDateTime(startDate);
        eventReportRecord.End__c = constructDateTime(endDate);
        
        try{
            insert eventReportRecord;
        }catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        if(StdBank_Ltn_EventReportNavigator.corecheck(eventReportRecord.Id)){
            PageReference addInternalAttendee = Page.AddInternalAttendee_lds;
            addInternalAttendee.getParameters().put('reportid', eventReportRecord.id);
            return addInternalAttendee;
        }
        return new PageReference('/'+eventReportRecord.id);
    }
    
    public PageReference SaveAndNew(){
        system.debug('=SaveNew='+eventReportValues);
        eventReportRecord.Name = eventReportValues;
        eventReportRecord.Start__c = constructDateTime(startDate);
        eventReportRecord.End__c = constructDateTime(endDate);
        try{
            insert eventReportRecord;
        }catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/apex/EventReport_New_Navigate');
    }
    
    public pageReference cancelRequest(){
        system.debug('=Cancel=');
        PageReference pgRef1 = new PageReference('/a0K/o');
        pgRef1.setRedirect(true);
        return pgRef1;   
    }
    
    public String convertDateTime(DateTime datetimeString) {
        if(datetimeString != null) {
            return (datetimeString.format('dd/MM/yyyy HH:mm'));
        }
        else {
            return '';
        }
    }

    private Date constructDate(String value) {
        Date d = null;
        
        if (String.isEmpty(value) || !value.contains('/')) {
            return d;
        }
        
        List<String> dateSplit = value.split('/');
        if (dateSplit.size() != 3) {
            return d;
        }
        
        Integer year = Integer.valueOf(dateSplit[2]);
        Integer month = Integer.valueOf(dateSplit[1]);
        Integer day = Integer.valueOf(dateSplit[0]);
        
        d = Date.newInstance(year, month, day);
        
        return d;
    }
    
    private DateTime constructDateTime(String value) {
        DateTime dt = null;
        
        if (String.isEmpty(value) || !value.contains(' ')) {
            return dt;
        }
        
        String datePart = value.split(' ')[0];
        String timePart = value.split(' ')[1];
        
        Date d = constructDate(datePart);
        if (d == null) {
            return dt;
        }
        
        if (!timePart.contains(':')) {
            return dt;
        }
        
        List<String> times = timePart.split(':');
        Integer h = Integer.valueOf(times[0]);
        Integer m = Integer.valueOf(times[1]);
        
        dt = DateTime.newInstance(d.year(), d.month(), d.day());
        dt = dt.addHours(h);
        dt = dt.addMinutes(m);
        
        return dt;
    }
    
}