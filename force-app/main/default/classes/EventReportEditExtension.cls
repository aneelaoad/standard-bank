/*******************************************************************************
   Created by: Marko Dvecko
   Created on: 11/01/2017
   Description:
     Needed to convert DateTime <=> String
     Initialization: DateTime => String
     Saving: String => DateTime
*******************************************************************************/

public with sharing class EventReportEditExtension {
    public String endDate { get; set; }
    public String startDate {get; set;}

    private final ApexPages.StandardController stdController;
    private final Call_Report__c eventReport;

    public EventReportEditExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.eventReport = (Call_Report__c)stdController.getRecord();
        this.endDate = convertDateTime(this.eventReport.End__c);
        this.startDate = convertDateTime(this.eventReport.Start__c);
    }

    public PageReference save() {
        eventReport.End__c = constructDateTime(endDate);
        eventReport.Start__c = constructDateTime(startDate);
        return stdController.save();
    }
    
    public PageReference SaveAndNew(){
        eventReport.Start__c = constructDateTime(startDate);
        eventReport.End__c = constructDateTime(endDate);
        try{
            upsert eventReport;
        }catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/apex/EventReport_New_Navigate');
        //return stdController.;
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