/***
    @ Func Area         : Event Object 
    @ Author            : Artur Kępczynski 
    @ Date              : 03.2017
    @ Test File         : DMN_Event_TEST    
    @ Specification     : Refactoring of existing logic to fit new framework
***/

public class DMN_Event {

    public static final String 
    INTERNAL                 = 'Internal',
    EXTERNAL                 = 'External',
    CORE_TEAM_MEETING        = 'Core Client Team Meeting', 
    DAY_TO_DAY_MEETING       = 'Day To Day Meeting',
    CLIENT_MEETING           = 'Client Meeting',
    NBAC_Meeting              = 'NBAC Meeting',
    PARENT_OBJ_EVENT_NAME    = 'Event_Name__c',
    PARENT_OBJ_EVENT_URL     = 'Event_URL__c';
    
    /***
        Delete Events related to removed Call_Reports__c (Event Reports)

        Use     DMN_Event.deleteEvents(reports);
        @param  Call_Report__c[]        reports
        @return Database.DeleteResult[] deleteEvents
    ***/
    public static Database.DeleteResult[] deleteEvents(Call_Report__c[] reports){

        Set<Id> eventIds = new Set<Id>();
            
        for (Call_Report__c rep : reports){
            if(String.isNotBlank(rep.EventId__c)){
                eventIds.add(rep.EventId__c);
            }    
        }

        if(eventIds.isempty()){
            return new Database.DeleteResult[]{}; 
        }
   
        return Database.delete([SELECT Id  
                                FROM Event 
                                WHERE Id IN :eventIds],false);  
    } 

    /***
        Update Event with related Call_Report__c record Id

        Use     DMN_Event.synchWithEvenReports(reports);
        @param  Call_Report__c[]        reports
    ***/
    public static void synchWithEvenReports(Call_Report__c[] reports){

        List<Event> eventsToUpdate = new List<Event>();

        for(Call_Report__c cr : reports){
            if(String.isNotBlank(cr.EventId__c)){
                eventsToUpdate.add(new Event(   Id = cr.EventId__c, 
                                                Related_Event_Report__c = cr.Id, 
                                                Call_Report_Created__c = true)
                                        );
            }
        }

        if(!eventsToUpdate.isEmpty()){
            UTL_DmlResult.updateRecords(eventsToUpdate, true);
        }
    } 

    /***
        Update parent (Who/What) of record with Event name and Url

        Use     DMN_Event.syncRelatedObjects(events);
        @param  Event[]     events
        @param  Boolean     isUpdateRequired
    ***/
    public static void syncRelatedObjects(Event[] events){
        // two map combo to ensure proper Sobject distribution in insert list
        Map<SobjectType, Sobject[]> type2Sobjects = new Map<SobjectType, Sobject[]>{
                                                                Account.SobjectType => new Sobject[]{},
                                                                Opportunity.SobjectType => new Sobject[]{},
                                                                Contact.SobjectType => new Sobject[]{}
                                                            };
        Map<Id, Sobject> id2Sobject = new Map<Id, Sobject>();

        for(Event eveObj : events){
            Id targetId = eveObj.WhatId!=null ? eveObj.WhatId : eveObj.WhoId;
            SobjectType st = targetId != null ? targetId.getSobjectType() : null;
            if(st != null  
                && type2Sobjects.containsKey(st)) { 
                Sobject sobj = st.newSobject(targetId);
                sObj.put(PARENT_OBJ_EVENT_NAME, eveObj.Subject);
                sObj.put(PARENT_OBJ_EVENT_URL, String.valueOf(eveObj.id).subString(0,15));
                id2Sobject.put(targetId, sObj);
            }   
        }

        for(Sobject sobj : id2Sobject.values()){
            SobjectType st = sobj.getSObjectType();
            type2Sobjects.get(st).add(sobj);
        }

        Sobject[] sobjToInsert = new Sobject[]{}; 

        for(Sobject[] sobjects : type2Sobjects.values()){
            sobjToInsert.addAll(sobjects);
        }

        if(!sobjToInsert.isEmpty()){
            UTL_DmlResult.updateRecords(sobjToInsert, false);
        }
    } 

    /***
        Update Event WhatId if record is Related to Report Client Contact (Report_Client_Contact__c)

        Use     DMN_Event.populateRelatedTo(records);
        @param  Event[]     records
    ***/
    public static void populateRelatedTo(Event[] records){
        Set<Id> contactIds = new Set<Id>();
        for(Event eid : records){
            eid.WhoId = eid.Report_Client_Contact__c;
            if(eid.WhoId != null){
                contactIds.add(eid.WhoId);
            }
        }
		
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        
        if(!contactIds.isEmpty()){
            contactMap = new Map<Id,Contact>([  SELECT AccountId 
                                                FROM Contact 
                                                WHERE Id IN : contactIds]);
        }

        for (Event e : records){
            if(e.WhoId != null && (e.WhatId == null)/* && !Test.isRunningTest() commented by AK - why is it here??? */){
                e.WhatId = contactMap.get(e.WhoId).AccountId;
            }
        } 
    }
}