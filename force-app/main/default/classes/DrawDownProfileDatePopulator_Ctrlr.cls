public with sharing class DrawDownProfileDatePopulator_Ctrlr {
    public Draw_Down_Profile__c[] ddProfiles {
        get;
        set {
            ddProfiles = value;
            if (existingProfiles == null) {
                existingProfiles = new Draw_Down_Profile__c[] {};
                existingProfiles.addAll(ddProfiles);
            }
        }
    }
    @TestVisible private Draw_Down_Profile__c[] existingProfiles;
    public Id prodId { get; set; }
    public String CurrencyCode { get;set; }
    public Boolean isLightning {
        get {
            return UTL_User.isLightnigUser();
        }
    }
    public Helper_Object__c startDate {
        get {
            if (startDate == null) {
                startDate = new Helper_Object__c();
            } return startDate;
        }
        set;
    }
    public Helper_Object__c endDate {
        get {
            if (endDate == null) {
                endDate = new Helper_Object__c();
            } return endDate;
        }
        set;
    }
    public SelectOption[] drawDownProfilesFrequencies { get; set; }
    public Integer selectedFrequency { get; set; }
    public Integer dDPsToBeCreated {
        get {
            if (selectedFrequency != 0
                && startDate != null && startDate.Date_Field__c != null
                && endDate != null && endDate.Date_Field__c != null) {
                Integer monthsBetween = startDate.Date_Field__c.monthsBetween(endDate.Date_Field__c);
                if (monthsBetween < 0) {
                    return 0;
                }
                dDPsToBeCreated = monthsBetween / selectedFrequency;
                Date startDatePlusMonths = startDate.Date_Field__c.addMonths(monthsBetween);
                if (startDatePlusMonths.day() <= endDate.Date_Field__c.day()) {
                    dDPsToBeCreated++;
                }
            }
            return dDPsToBeCreated;
        }
        set;
    }

    public DrawDownProfileDatePopulator_Ctrlr() {
        drawDownProfilesFrequencies = new SelectOption[] {
            new SelectOption('0', '-- SELECT ONE --')
        };
        drawDownProfilesFrequencies.addAll(
            UTL_GlobalPicklistValues.getPicklist(DMN_DrawDownProfile.FREQUENCIES_PICKLIST_CATEGORY));
    }

    public void createDrawDownProfiles() {
        if (startDate.Date_Field__c == null || endDate.Date_Field__c == null || selectedFrequency == null || selectedFrequency == 0) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 'Please ensure First Draw Date, Last Draw Date and Frequency fields are completed'));
            return;
        }

        Draw_Down_Profile__c[] refreshedList = new Draw_Down_Profile__c[] {};
        for (Integer i = 0; i < dDPsToBeCreated; i++) {
            Draw_Down_Profile__c dd;
            if (i < existingProfiles.size()) {
                dd = existingProfiles[i];
            }
            else if (i < ddProfiles.size()) {
                dd = ddProfiles[i];
            }
            else {
                dd = new Draw_Down_Profile__c(
                    Product__c = prodId,
                    currencyIsoCode = CurrencyCode,
                    Draw_Down_Number__c = i+1
                );
            }
            dd.Draw_Date__c = startDate.Date_Field__c.addMonths(selectedFrequency * i);
            refreshedList.add(dd);
        }
        ddProfiles.clear();
        ddProfiles.addAll(refreshedList);
    }

}