@isTest
private class DMN_Event_TEST {

	public static final Integer UPPER_LIMIT 	= 200;
	public static final String SAMPLE_SUBJECT	= 'Some Subject';

	private static ABS_ObjectBuilderBase accBld;
	private static ABS_ObjectBuilderBase eveBld;
	private static ABS_ObjectBuilderBase conBld;
	private static User usr;
	
	private static testmethod void eventCreationTest() {

		usr = (User)new BLD_USER().useCommB().syncContact().commitWork().getRecord();
  
		System.runAs(usr){
			Test.startTest();
				accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 
		
				eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.linkToParent(accBld.getRecordId()).commitWork();
			Test.stopTest();
		} 

		Event eve = (Event)eveBld.refreshFromDB(new Set<String>{'WhatId', 'WhoId'}).getRecord();

		Event[] events = [	SELECT Id, WhatId, WhoId, Related_Event_Report__c
							FROM Event 
							WHERE Id =: eve.Id];

		Call_Report__c[] eveMeetings = [SELECT Id, EventId__c 
										FROM Call_Report__c
										WHERE EventId__c =: eve.Id];

		System.assertEquals(accBld.getRecordId(), eve.WhatId); 
		System.assertEquals(null, eve.WhoId);
		System.assertEquals(1, eveMeetings.size());
		System.assertEquals(1, events.size()); 
		System.assertEquals(events[0].Id, eveMeetings[0].EventId__c);
		System.assertEquals(eveMeetings[0].Id, events[0].Related_Event_Report__c); 
	}

	private static testmethod void deleteEvents_Test() {
		usr = (User)new BLD_USER().useCommB().syncContact().commitWork().getRecord();

		System.runAs(usr){
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 
		
			eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.linkToParent(accBld.getRecordId()).commitWork();
		}

		Call_Report__c[] eveMeetings = [SELECT Id, EventId__c
										FROM Call_Report__c
										WHERE EventId__c =: eveBld.getRecordId()];
		System.assertEquals(1, eveMeetings.size());
		Database.DeleteResult[] results;

		System.runAs(usr){
			Test.startTest();
				results = DMN_Event.deleteEvents(eveMeetings); 
			Test.stopTest();
		}

		Event[] events = [	SELECT Id  
                           	FROM Event 
                          	WHERE Id =: eveBld.getRecordId()];

       	System.assertEquals(0, events.size());
       	System.assertEquals(1, results.size());
       	System.assertEquals(true, results[0].isSuccess());
	}
	
	private static testmethod void deleteEvents_Test_Multiple() {
		usr = (User)new BLD_USER().useCommB().syncContact().commitWork().getRecord();

		Event[] sourceEvents = new Event[]{};

		System.runAs(usr){
			
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 
			
			for(Integer i = 0; i < 5; i++){
				sourceEvents.add((Event)new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.linkToParent(accBld.getRecordId()).getRecord());
			}
            
            insert sourceEvents;
		}

		sourceEvents = [SELECT Id, WhatId, WhoId
						FROM Event 
						WHERE Id IN: sourceEvents];

		Set<String> eventIds = new Set<String>();
		for(Event sourceEve : sourceEvents){
			eventIds.add(sourceEve.Id);
		}

		Call_Report__c[] eveMeetings = [SELECT Id, EventId__c 
										FROM Call_Report__c
										WHERE EventId__c IN: eventIds];
		System.assertEquals(5, eveMeetings.size());
		Database.DeleteResult[] results;

		System.runAs(usr){
			Test.startTest();
				results = DMN_Event.deleteEvents(eveMeetings); 
			Test.stopTest();
		} 

		Event[] events = [	SELECT Id  
                           	FROM Event 
                          	WHERE Id IN: eventIds];

       	System.assertEquals(0, events.size());
       	System.assertEquals(5, results.size());
       	for(Database.DeleteResult res : results){
       		System.assertEquals(true, res.isSuccess());
       	}
	}
	
	private static testmethod void syncRelatedObjects_Test_Acc_NoDml() {
		usr = (User)new BLD_USER().useCommB().syncContact().commitWork().getRecord();

		System.runAs(usr){
			
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 
			eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.unrestricted().linkToParent(accBld.getRecordId()).commitWork();
		}

		Account acc = (Account)accBld.refreshFromDB(new set<String>{'Event_Name__c', 'Event_URL__c'}).getRecord();
		Event eve = (Event)eveBld.getRecord();
		System.assertNotEquals(SAMPLE_SUBJECT, acc.Event_Name__c );
		System.assertEquals(String.valueOf(eve.id).subString(0,15), acc.Event_URL__c );

		System.runAs(usr){  
			Test.startTest();
				eve.Subject = SAMPLE_SUBJECT;
				DMN_Event.syncRelatedObjects(new Event[]{eve});
			Test.stopTest();  
		}

		acc = (Account)accBld.refreshFromDB(new set<String>{'Event_Name__c', 'Event_URL__c'}).getRecord();

		System.assertEquals(SAMPLE_SUBJECT, acc.Event_Name__c );
		System.assertEquals(String.valueOf(eve.id).subString(0,15), acc.Event_URL__c );
	}  
	
	private static testmethod void syncRelatedObjects_Test_Acc_Dml() {
		usr = (User)new BLD_USER().useCommB().syncContact().commitWork().getRecord();

		System.runAs(usr){
			
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 
			eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.unrestricted().linkToParent(accBld.getRecordId());
		}

		Account acc = (Account)accBld.refreshFromDB(new set<String>{'Event_Name__c', 'Event_URL__c'}).getRecord();
		Event eve = (Event)eveBld.getRecord();


		System.assertNotEquals(SAMPLE_SUBJECT, acc.Event_Name__c );
		System.assertEquals(null, acc.Event_URL__c );

		System.runAs(usr){
			Test.startTest();
				eve.Subject = SAMPLE_SUBJECT;
				insert eve;
			Test.stopTest();
		}

		acc = (Account)accBld.refreshFromDB(new set<String>{'Event_Name__c', 'Event_URL__c'}).getRecord();

		System.assertEquals(SAMPLE_SUBJECT, acc.Event_Name__c );
		System.assertEquals(String.valueOf(eve.id).subString(0,15), acc.Event_URL__c );
	}
    
    private static testmethod void populateRelatedTo_NoDml() {
       	usr = (User)new BLD_USER().useCommB().syncContact().commitWork().getRecord();

		System.runAs(usr){
			
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 
			eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.linkToParent(accBld.getRecordId()).commitWork();
            conBld = new BLD_Contact().useClientContact().accountId(accBld.getRecordId()).commitWork();
		}
        
        Event eve = (Event)eveBld.refreshFromDB(new Set<String>{'WhatId', 'WhoId'}).getRecord();
        Account acc = (Account)accBld.getRecord();
        Contact con = (Contact)conBld.getRecord();
        System.assertEquals(eve.WhoId, null);
        System.assertEquals(eve.WhatId, acc.Id);
        
        System.runAs(usr){
			Test.startTest();
            	eve.Report_Client_Contact__c = con.Id;
        		eve.WhatId = null;
            	DMN_Event.populateRelatedTo(new Event[]{eve}); 
			Test.stopTest();
		}
        
        System.assertEquals(eve.WhoId, con.Id);
        System.assertEquals(eve.WhatId, acc.Id); 
    }

    private static testmethod void populateRelatedTo_Dml() {
        usr = (User)new BLD_USER().useCommB().syncContact().commitWork().getRecord();

		System.runAs(usr){
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 
            conBld = new BLD_Contact().useClientContact().accountId(accBld.getRecordId()).commitWork();
			eveBld = new BLD_Event()
								.externalMeeting().meetingPurpose(DMN_Event.CLIENT_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.setField(Event.Report_Client_Contact__c, conBld.getRecordId()); 
		}
        
        Event eve = (Event)eveBld.refreshFromDB(new Set<String>{'WhatId', 'WhoId'}).getRecord();
        Account acc = (Account)accBld.getRecord();
        Contact con = (Contact)conBld.getRecord();
        
        System.runAs(usr){ 
			Test.startTest();
            	eve.whatId = null;
            	insert eve; 
			Test.stopTest();
		}

        eve = (Event)eveBld.refreshFromDB(new Set<String>{'WhatId', 'WhoId', 'Report_Client_Contact__c'}).getRecord(); 
        System.assertEquals(con.Id, eve.Report_Client_Contact__c);
        System.assertEquals(con.Id, eve.WhoId);
        System.assertEquals(acc.Id, eve.WhatId); 
    }
    
}