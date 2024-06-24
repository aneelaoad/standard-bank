public with sharing class SharedCalPrefs {
    
    public string recentRecord { get; set; } 
    public string recentView { get; set; } 
    public string recentChildren { get; set; } 
    public string recentFilter { get; set; } 
    public string recentFilterName { get; set; }
    public string recentContacts { get; set; }
    public string recentOppys { get; set; }
    //public string color { get; set; } 
    //public string backgroundcolor { get; set; } 
    public string recentDate { get; set; }
    public string recentMonth { get; set; } 
    public string recentYear { get; set; } 
    
    public SharedCalPrefs() {  
        Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
        if (setting != null) { // if no default we can still have a null setting 
            recentRecord = setting.Recent_Record__c; 
            recentView = setting.Recent_View__c;
            recentDate = setting.Recent_Date__c;
            recentMonth = setting.Recent_Month__c;
            recentYear = setting.Recent_Year__c;
            recentChildren = setting.Recent_Children__c;
            recentContacts = setting.Recent_Contacts__c;
            recentFilter = setting.Recent_Filter__c;
            recentFilterName = setting.Recent_Filter_Name__c;
            recentOppys = setting.Recent_Opportunities__c;
            //color = setting.color__c;
            //backgroundcolor = setting.background_color__c;
        }   
    }

    public void saveDate(String theDay, String theMonth, String theYear) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_Month__c = String.escapeSingleQuotes( theMonth);
            setting.Recent_Date__c = String.escapeSingleQuotes( theDay);
            setting.Recent_Year__c = String.escapeSingleQuotes( theYear);
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    } 

    public void saveView(String view) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_View__c = String.escapeSingleQuotes( view );
            
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    } 
    
    public void saveContacts(String contacts) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_Contacts__c = String.escapeSingleQuotes(contacts);
            
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    } 
    
     public void saveOppys(String opportunities) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_Opportunities__c= String.escapeSingleQuotes(opportunities);
            
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    } 
    
    public void saveChildren(String children) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_Children__c = String.escapeSingleQuotes(children);
            
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    public void saveRecord(String rekord) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_Record__c = String.escapeSingleQuotes(rekord);
            
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    }  
    
    public void saveFilter(String filterId) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_Filter__c = filterId;
            
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    }  
     
    public void saveFilterName(String filterName) {
        try {
            Shared_Calendar_Prefs__c setting = getSettings( UserInfo.getUserId() ); 
            setting.Recent_Filter_Name__c = filterName.replace('\\','');
            
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    public static Shared_Calendar_Prefs__c getSettings( id id ) {
        Shared_Calendar_Prefs__c setting = Shared_Calendar_Prefs__c.getValues( id ); 
        if ( setting == null ) {
            setting = new Shared_Calendar_Prefs__c(setupownerid = id);
        } 
        return setting;
    } 

    public static testMethod void t1() {
        SharedCalPrefs lp = new SharedCalPrefs();
        
        lp.saveRecord('foo');
        Shared_Calendar_Prefs__c setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('foo',setting.Recent_Record__c);
        
        lp.saveRecord(null);
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('foo',setting.Recent_Record__c);  
        
        Database.delete(setting);
        SharedCalPrefs lp2 = new SharedCalPrefs();
        
        lp.saveRecord('bar');
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Record__c); 
        
        lp.saveFilter('bar');
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Filter__c); 
        
        lp.saveFilter('12345678901234567890');
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Filter__c); 
        
        lp.saveChildren('bar');
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Children__c); 
        
        lp.saveChildren(null);
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Children__c); 
        
        lp.saveContacts('bar');
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Contacts__c); 
        
        lp.saveContacts(null);
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Contacts__c); 
        
        lp.saveOppys('bar');
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Opportunities__c); 
        
        lp.saveOppys(null);
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('bar',setting.Recent_Opportunities__c); 
        
        lp.saveFilterName('Foo\'s');
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('Foo\'s',setting.Recent_Filter_Name__c); 
        
        lp.saveFilterName(null);
        setting = Shared_Calendar_Prefs__c.getValues(UserInfo.getUserId());
        system.assertEquals('Foo\'s',setting.Recent_Filter_Name__c); 

        lp2.saveView('view');
        Shared_Calendar_Prefs__c p = SharedCalPrefs.getSettings( UserInfo.getUserId() );
        system.assert( p != null);
        
        lp2.saveView(null);
        p = SharedCalPrefs.getSettings( UserInfo.getUserId() );
        system.assert( p != null);
        
        lp2.saveDate('23','10','1968');
        setting  = SharedCalPrefs.getSettings( UserInfo.getUserId() );
        system.assert( setting  != null);
        
        lp2.saveDate(null,null,null);
        setting = SharedCalPrefs.getSettings( UserInfo.getUserId() );
        system.assert( setting  != null);
   }
}