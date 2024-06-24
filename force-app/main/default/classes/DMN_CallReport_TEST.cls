/**
 * @author      tbc
 * @date        tbc
 * @description Test class for the DMN_CallReport apex class.
 * @user story  tbc
 * @func area   Call Report
 */
/*************************************************************************
    @ Last Modified By  : Nikita Haruk
    @ Last Modified On  : September 14, 2022
    @ Modification Description : SFP-29983: Increased the test coverage. 
****************************************************************************/
@isTest
private class DMN_CallReport_TEST {
	
	private static ABS_ObjectBuilderBase accBld;
	private static ABS_ObjectBuilderBase conBld;
	private static ABS_ObjectBuilderBase oppBld;
	private static ABS_ObjectBuilderBase eveBld;
	private static ABS_ObjectBuilderBase callBld;
	private static User testUsr;
	public static final String TEST_USER_NAME = 'test.DMN_CallReport_TEST@test.com';

	@TestSetup
	private static void createDate(){
		System.runAs(new User(Id = UserInfo.getUserId())){
			TEST_DataFactory.generateConfiguration();
		}
		Test.startTest();
			System.runAs(new User(Id = UserInfo.getUserId())){
				new BLD_USER(TEST_USER_NAME)
					.useCommB()
					.syncContact()
					.setField(User.Outlook_Exchange_System_ID__c, '11')
					.setField(User.Email, 'test.DMN_CallReport_TEST@gmail.com')
					.commitWork().getRecord(); 
			}
		Test.stopTest(); 
	}

	private static void fetchData(){

		for(User usr : [SELECT Contact_Sync_ID__c, UserName, Sync_with_Contact__c
						FROM User
						WHERE UserName =: TEST_USER_NAME]){
			if(usr.UserName == TEST_USER_NAME){
				testUsr = usr;
			}
		}
	}

	private static testmethod void eventCreationTest() {

		fetchData();
		Assert.areNotEqual(null, testUsr.Contact_Sync_ID__c, 'Success');
		System.runAs(testUsr){
			Test.startTest();
				accBld = new BLD_Account().useCommB().useGroupParent().commitWork();
				new BLD_ClientTeam().account(accBld.getRecordId()).coordinator(true).user(testUsr.Id).role(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER).commitWork();
				
				callBld = new BLD_CallReport().internal().meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
									.startDate(System.now().addDays(14)).endDate(System.now().addDays(15).addHours(-1))
									.assign(testUsr.Id).linkWithParent(accBld.getRecordId()).commitWork();

			Test.stopTest(); 
		} 
	}
	
	private static testmethod void removeRelatedToEvents_NoDml() {

		fetchData();
		System.runAs(testUsr){
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork();

			eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.linkToParent(accBld.getRecordId()).commitWork();
		} 

		Event eve = (Event)eveBld.refreshFromDB(new Set<String>{'WhatId', 'WhoId'}).getRecord();

		Event[] events = [	SELECT Id, WhatId, WhoId, Related_Event_Report__c
							FROM Event 
							WHERE Id =: eve.Id];

		Call_Report__c[] eveMeetings = [SELECT Id, EventId__c 
										FROM Call_Report__c
										WHERE EventId__c =: eve.Id];

		Assert.areEqual(accBld.getRecordId(), eve.WhatId, 'Success'); 
		Assert.areEqual(null, eve.WhoId, 'Success');
		Assert.areEqual(1, eveMeetings.size(), 'Success');
		Assert.areEqual(1, events.size(), 'Success'); 
		Assert.areEqual(events[0].Id, eveMeetings[0].EventId__c, 'Success');
		Assert.areEqual(eveMeetings[0].Id, events[0].Related_Event_Report__c, 'Success'); 

		System.runAs(testUsr){
			Test.startTest();
				DMN_CallReport.removeRelatedToEvents(new Event[]{eve});
			Test.stopTest();
		} 

		events = [	SELECT Id, WhatId, WhoId, Related_Event_Report__c
					FROM Event 
					WHERE Id =: eve.Id];

		eveMeetings = [	SELECT Id, EventId__c 
						FROM Call_Report__c
						WHERE EventId__c =: eve.Id];

		Assert.areEqual(0, eveMeetings.size(), 'Success');
		Assert.areEqual(0, events.size(), 'Success');  
	}

	private static testmethod void removeRelatedToEvents_Dml() {

		fetchData();
		System.runAs(testUsr){
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork(); 

			eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(System.now()).stopDate(System.now().addHours(1))
								.linkToParent(accBld.getRecordId()).commitWork();
		}

		Event eve = (Event)eveBld.refreshFromDB(new Set<String>{'WhatId', 'WhoId'}).getRecord();

		Event[] events = [	SELECT Id, WhatId, WhoId, Related_Event_Report__c
							FROM Event 
							WHERE Id =: eve.Id];

		Call_Report__c[] eveMeetings = [SELECT Id, EventId__c 
										FROM Call_Report__c
										WHERE EventId__c =: eve.Id];

		Assert.areEqual(accBld.getRecordId(), eve.WhatId, 'Success'); 
		Assert.areEqual(null, eve.WhoId, 'Success');
		Assert.areEqual(1, eveMeetings.size(), 'Success');
		Assert.areEqual(1, events.size(), 'Success'); 
		Assert.areEqual(events[0].Id, eveMeetings[0].EventId__c, 'Success');
		Assert.areEqual(eveMeetings[0].Id, events[0].Related_Event_Report__c, 'Success'); 

		System.runAs(testUsr){
			Test.startTest();
				delete eve;
				new TRH_CallReport().sendErrorNotification('testEmailMessage');
			Test.stopTest();
		} 

		events = [	SELECT Id, WhatId, WhoId, Related_Event_Report__c
					FROM Event 
					WHERE Id =: eve.Id];

		eveMeetings = [	SELECT Id, EventId__c 
						FROM Call_Report__c
						WHERE EventId__c =: eve.Id];

		Assert.areEqual(0, eveMeetings.size(), 'Success');
		Assert.areEqual(0, events.size(), 'Success'); 
	}
	
	private static testmethod void buildReport_Account() {

		fetchData();
		Datetime startTime = System.now();
		Datetime endTime = System.now().addHours(1);

		System.runAs(testUsr){
			accBld = new BLD_Account().useCommB().useGroupParent().commitWork();

			eveBld = new BLD_Event()
								.internalMeeting().meetingPurpose(DMN_Event.CORE_TEAM_MEETING)
								.startDate(startTime).stopDate(endTime)
								.linkToParent(accBld.getRecordId()).commitWork();
		}

		Event eve = (Event)eveBld.refreshFullFromDB().getRecord();
		Account acc = (Account)accBld.refreshFullFromDB().getRecord();
		Call_Report__c callRep;
		Map<Id, Sobject> id2Sobject = new Map<Id, Sobject>{acc.Id => acc};
		

		System.runAs(testUsr){
			Test.startTest();
				callRep = DMN_CallReport.buildReport(eve, id2Sobject);
			Test.stopTest();
		} 

		Assert.areEqual(eve.OwnerId, 					callRep.OwnerId, 'Success');
		Assert.areEqual(eve.Subject + ' - '+ acc.Name, 	callRep.Name, 'Success');
		Assert.areEqual(eve.Meeting_Purpose__c, 		callRep.Meeting_Purpose__c, 'Success');
		Assert.areEqual(eve.Id, 						callRep.EventId__c, 'Success');
		Assert.areEqual(eve.Subject, 					callRep.Subject__c, 'Success');
		Assert.areEqual(eve.Meeting_Audience__c, 		callRep.Meeting_Audience__c, 'Success');
		Assert.areEqual(eve.Description, 				callRep.Description__c, 'Success');
		Assert.areEqual(eve.Visible_to_Internal_Attendees_only__c, 	callRep.Visible_to_Internal_Attendees_only__c, 'Success');

		Assert.areEqual(startTime, 						callRep.Start__c, 'Success');
		Assert.areEqual(endTime, 						callRep.End__c, 'Success');
	}
}