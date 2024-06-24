/**************************************************************************************
  Retrieving action items for current user
  There are four types of action items:
  1.
  - opportunity_owner = current_user
  - opportunity has loan product/s that don't have drawdown date 
  or it is expired
  - opportunity stage not closed
 
  2.
  - opportunity_owner = current_user
  - opportunity_state = developed
  - opportunity_value = 0
 
  3.
  - client service team (CB \/ CCBM) = current_user
  - CIB_Target_Client__c = true
  - record_type = Ultimate Group Parent / Immediate Parent
  - no external event report where for last 6 month and future dates
 
  4.
  - client service team (CB or CCBM) = current_user
  - CIB_Target_Client__c = true
  - record_type = Ultimate Group Parent / Immediate Parent
  - no core client team event report where for last 6 month and future dates
  5.
  - task where AssignedTo = current_user
  - Subject = 'Update FAIS Information'
  - Status = 'Not Started'
  - type ='Follow-up'
  - Task priority = Medium
  Developer            Date            Description
  -----------------------------------------------------------------------------------
  Marko Dvečko         24/1/2017       Original version
  Michal Lipinski		1/07/2017		US-2217
  Jarred Schultz		02/11/2018		US-3287 Added in functionality to translate to display NBAC action items
  Jorel Naidoo		    03/2019			US-3466

  @user			Maksim Dzianisik
  @date 		09/2022
  @description 	SFP-17383 Business decided to reduce the number of information and create a new UI for Wholesale_Client_Coverage_Homepage
 *************************************************************************************/
public class StdBank_Ltn_ActionItems {
	public static final String DEVELOP_STAGE = '2 - Develop';
	public static final String CORE_CLIENT_TEAM_MEETING = 'Core Client Team Meeting';
	public static final String EXTERNAL = 'External';
	public static final String EXTERNAL_MEETING_ERROR = 'You have not seen your Target Client!';
	public static final String CORE_TYPE_ERROR = 'Schedule a Core CST Meeting';
	public static final String FAIS_REMINDER_SUBJECT = Label.FAIS_reminder_subject;
	public static final String ATTENDEE_REMINDER_SUBJECT = 'Update Total Event Cost on Entertainment Meeting';

    public static final String ITEM_TO_ACTION_DONE_STATUS = 'Completed';
    public static final String FAIS_REMINDER_ICON = 'note';

	@TestVisible private static final String HEADER_OPP_ZERO_REVENUE = 'This Opportunity displays Zero Revenue';

	public class Item {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public Id recordId;

		@AuraEnabled
		public String objectName;

		public Item(String name, Id recordId) {
			this.name = name;
			this.recordId = recordId;
			this.objectName = recordId.getSobjectType().getDescribe().getName().toLowerCase();
		}

		/**
		 * @description Constructor
		 * @param name Name value of the object
		 * @param recordID Id of the object
		 * @param iconName Name for SLDS icon.
		 */
		public Item(String name, Id recordID, String iconName) {
			this.name = name;
			this.recordId = recordId;
			this.objectName = iconName;
		}
	}

	public class ActionItem {
		@AuraEnabled
		public String header;
		@AuraEnabled
		public Item item;
		@AuraEnabled
		public String[] footer;

		/**
		 * @description Constructor
         * @param header
         * @param item
         * @param footer
         */
		public ActionItem(String header, Item item, String[] footer) {
			this.header = header;
			this.item = item;
			this.footer = footer;
		}
	}

	public class ItemsToActionWrapper {
		@AuraEnabled
		public List<Task> tasks { get; set; }
		@AuraEnabled
		public List<Opportunity> opportunities { get; set; }

		/**
         * @description Constructor
         */
		public ItemsToActionWrapper() {
			this.tasks = new List<Task>();
			this.opportunities = new List<Opportunity>();
		}
	}

	/**
	 * @description main method for Aura component
	 * @return ActionItem[]
	 */
	@AuraEnabled
	public static ActionItem[] getActionItems() {
		ActionItem[] result = new List<ActionItem> ();

		result.addAll(getOpportunityZeroValue());
		result.addAll(getAccountWithoutMeetingLately());
		result.addAll(getTaskBasedActionItems());
		return result;
	}

	/**
	 * @description main method for LWC component
	 * @return ItemsToActionWrapper
	 */
	@AuraEnabled (Cacheable=true)
	public static ItemsToActionWrapper getItemsToAction() {
		ItemsToActionWrapper result = new ItemsToActionWrapper();
		result.tasks.addAll(getCsiAndNbacTasks());
		result.opportunities.addAll(getOppWithZeroRevenue());

		return result;
	}

	/**
	 * @description select necessary tasks
	 * @return List<ActionItem>
	 */
	@TestVisible
	private static List<ActionItem> getTaskBasedActionItems() {
		Set<Id> ccbmClients = new Map<Id,Account>(
		[ SELECT id FROM Account WHERE id in (SELECT Account__c FROM Custom_Client_Team__c WHERE Client_Coordinator_BM__c = true AND Team_Member__c = : UserInfo.getUserId())]
		).keySet();
		List<Task> taskActions =
		[SELECT Id, Subject, Description, WhatId, Status, What.Name, WhoId, OwnerId, Type FROM Task
		WHERE Status != : ITEM_TO_ACTION_DONE_STATUS AND
		Item_to_Action__c = true AND
		(
		 OwnerId = : UserInfo.getUserId()
		 OR WhatId in :ccbmClients
		)
		];
		List<ActionItem> result = new List<ActionItem> ();
		for (Task actionTask : taskActions) {
			ActionItem translated = translate(actionTask);
			if (translated != null) {
				result.add(translated);
			}
		}
		return result;
	}

	/**
	 * @description fill in the wrapper using values from the Task
	 * @param actionTask Task
	 * @return ActionItem
	 */
	private static ActionItem translate(Task actionTask) {
		if (actionTask.Subject.contains(FAIS_REMINDER_SUBJECT) && actionTask.Status != ITEM_TO_ACTION_DONE_STATUS) {
			return new ActionItem(actionTask.Subject, new Item(actionTask.What.Name, actionTask.WhatId, FAIS_REMINDER_ICON), new List<String> ());
		} else if (actionTask.Subject.contains(Label.CSI_Case_reminder_subject)) {
			return new ActionItem(actionTask.Subject, new Item('(' + actionTask.What.Name + ')', actionTask.WhatId), new List<String> ());
		} else if (actionTask.Type == 'NBAC Action Item' && actionTask.Status != ITEM_TO_ACTION_DONE_STATUS && actionTask.Status != 'Cancelled' ) {
			return new ActionItem(actionTask.Subject, new Item('Action this task', actionTask.Id, 'task'), new List<String> ());
		} else if (actionTask.Subject.contains(ATTENDEE_REMINDER_SUBJECT)&& actionTask.Status != ITEM_TO_ACTION_DONE_STATUS){
			return new ActionItem(actionTask.Subject, new Item(actionTask.What.Name, actionTask.WhatId, FAIS_REMINDER_ICON), new List<String> ());
		} else {
			return new ActionItem(actionTask.Subject, new Item(actionTask.What.Name, actionTask.WhatId), new List<String> ());
		}

		return null;
	}

	/**
	 * @description select necessary opportunities
	 * @return List<ActionItem>
	 */
	@TestVisible
	private static List<ActionItem> getOpportunityZeroValue() {
		List<ActionItem> result = new List<ActionItem> ();
		//
		// Opportunities in developed stage with zero value
		//
		for (Opportunity opp :
		     [SELECT Id, Name, StageName, Probability, Current_Year_Revenue_Currency__c, CurrencyIsoCode
		     FROM Opportunity
		     WHERE OwnerId = : UserInfo.getUserId()
		     AND StageName = : DEVELOP_STAGE
		     AND(Current_Year_Revenue_Currency__c = null OR Current_Year_Revenue_Currency__c = 0)]) {
			result.add(new ActionItem(
			                          HEADER_OPP_ZERO_REVENUE,
			                          new Item(opp.Name, opp.Id),
			                          new String[] {
				                         opp.StageName,
				                         '' + opp.Probability + '%',
				                         getAmount(opp.Current_Year_Revenue_Currency__c, opp.CurrencyIsoCode)
			                          }
			));
		}

		return result;
	}

	/**
	 * @description select necessary accounts
	 * @return List<ActionItem>
	 */
	private static List<ActionItem> getAccountWithoutMeetingLately() {
		List<ActionItem> result = new List<ActionItem> ();
		//
		// Accounts without Core Client Team or External meetings 
		// in last 6 months or future dates
		//
		for (Account acc : [
			SELECT Name, (
				SELECT Meeting_Audience__c, Meeting_Purpose__c
				FROM Event_Reports__r
				WHERE(Meeting_Audience__c = :EXTERNAL
					OR Meeting_Purpose__c = :CORE_CLIENT_TEAM_MEETING)
					AND End__c >= LAST_N_MONTHS : 6
			)
			FROM Account
			WHERE CIB_Target_Client__c = TRUE
				AND Selected_Core_CST__c = TRUE
				AND (RecordType.DeveloperName = :DMN_Account.RT_IMMEDIATE_PARENT
					OR RecordType.DeveloperName = :DMN_Account.RT_ULTIMATE_PARENT)
				AND Id IN (
					SELECT Account__c
					FROM Custom_Client_Team__c
					WHERE Team_Member__c = :UserInfo.getUserId()
						AND (Client_Coordinator__c = TRUE
							OR Client_Coordinator_BM__c = TRUE)
				)
				AND Id NOT IN (
					SELECT Relate_to_Client__c
					FROM Call_Report__c
					WHERE Meeting_Audience__c = :EXTERNAL
						AND Meeting_Purpose__c = :CORE_CLIENT_TEAM_MEETING
						AND End__c >= LAST_N_MONTHS : 6
				)
		]) {
			Set<String> errorMessages = new Set<String> { EXTERNAL_MEETING_ERROR, CORE_TYPE_ERROR };

			for (Call_Report__c cr : acc.Event_Reports__r) {
				if (cr.Meeting_Audience__c == EXTERNAL) {
					errorMessages.remove(EXTERNAL_MEETING_ERROR);
				}
				if (cr.Meeting_Purpose__c == CORE_CLIENT_TEAM_MEETING) {
					errorMessages.remove(CORE_TYPE_ERROR);
				}
			}

			for (String er : errorMessages) {
				result.add(new ActionItem(
				                          er,
				                          new Item(acc.Name, acc.Id),
				                          new String[] { }));
			}
		}

		return result;
	}

	/**
	 * @description calculate amount using values from the opportunity
	 * @param amount Decimal
	 * @param isoCode String
	 *
	 * @return String
	 */
	private static String getAmount(Decimal amount, String isoCode) {
		String result = isoCode + ' ' + (amount == null ? '0' : String.valueOf(amount));
		return result;
	}

	private static List<Task> getCsiAndNbacTasks() {
		String csiFilter = '%' + Label.CSI_Case_reminder_subject + '%';

		Set<Id> ccbmClients = new Map<Id,Account>([
				SELECT Id FROM Account
				WHERE Id IN (
						SELECT Account__c
						FROM Custom_Client_Team__c
						WHERE Client_Coordinator_BM__c = TRUE AND Team_Member__c = : UserInfo.getUserId())
				WITH SECURITY_ENFORCED
		]).keySet();

		return [
				SELECT Id, Subject, Type, ActivityDate
				FROM Task
				WHERE Status != : ITEM_TO_ACTION_DONE_STATUS AND Item_to_Action__c = TRUE
				AND (OwnerId = : UserInfo.getUserId() OR WhatId IN :ccbmClients)
				AND ( (Subject LIKE :csiFilter) OR (Type = 'NBAC Action Item' AND Status != 'Cancelled'))
				WITH SECURITY_ENFORCED
				ORDER BY ActivityDate ASC NULLS LAST
		];
	}

	private static List<Opportunity> getOppWithZeroRevenue() {
		return [
				SELECT Id, Name
				FROM Opportunity
				WHERE OwnerId = : UserInfo.getUserId() AND StageName = : DEVELOP_STAGE
				AND(Current_Year_Revenue_Currency__c = NULL OR Current_Year_Revenue_Currency__c = 0)
				WITH SECURITY_ENFORCED
		];
	}
}