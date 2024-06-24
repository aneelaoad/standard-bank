/*************************************************************************\
    @Author        :     Caro Reinecke
    @Date          :     10 June 2011
    @Test File     :
    @description   :     General trigger utility class for SB_Product (Custom Product).
                          Handles setting of Maturity Date Reminder.

    @Last Modified By  :   Caro Reinecke
    @Last Modified On  :   13 June 2011
    @Last Modified Reason  : Used code from SA_Create_MM_Reminder trigger as basis for this class.
                              Removed profile dependency as part of regression profile standardisation

    @Last Modified By  : Tracy Roberts
    @Last Modified On  : 19 November 2012
    @Last Modified Reason  : Case#8735 - Client Name on Product not updating if Client Name on Opportunity updates.
    @Description   : Create new Method handleProductBeforeInsertTrigger() that will update the Client on the
                        Product when a Product is Cloned and linked to a diffrent Opportunity.

    @Last Modified By  : Shubham Khilauria
    @Last Modified On  : 30 June 2014
    @Last Modified Reason  : EN#427- Opportunity Currency should be reflected on Product Currency.
    @Description   : Add the logic in already create handleProductBeforeInsertTrigger() that will run on before insert and update the
    				  product currency ISO code as of Opportunity Currency.

    @Last Modified By  : Petr Svestka
    @Last Modified On  : Aug 11, 2015
    @Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

	@Last Modified By  : Augustine Chirombo
    @Last Modified On  : Sep 13, 2023
    @Modification Description : Change the static reference of Record types to new labels 

****************************************************************************/
public with sharing class ProductTriggerUtility {
    static final String className = 'ProductTriggerUtility';
    static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(className);
    
	/**
	* @description : Method to handle the After Insert Trigger logic on the SB_Product__c
	*
	* @param : newRecs List of new Product records
	* @param : newMap  Map of new Product records
	*/ 
    public static void handleProductAfterInsertTrigger(List<SB_Product__c> newRecs, Map<Id, SB_Product__c> newMap) {
        String errorDetails = '';
        String transactionUser = UserInfo.getUserName();
        String transactionUserId = UserInfo.getUserId();
        /*************************************************************************\
        Case 599 - Money Market Standardisation
        “When a user creates a Lost Opportunity with a trading product and ticks the
                                “Maturity Date Reminder” tick box, a task will be created immediately for the
                                owner of the Opportunity and the due date of the task will be set to one day
                                before the Maturity Date on the Trading Product”
        ****************************************************************************/
        List<Id> tradingProductReminderOpportunityIds = new List<Id>();
        Map<Id, Date> opportunityMaturityDateMap = new Map<Id, Date>();
        Map<Id, Id> opportunityProductMap = new Map<Id, Id>();

        Map<String, Schema.RecordTypeInfo> mapProdRecordTypes = SB_Product__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id multiRiskRecTypeId = mapProdRecordTypes.get('CIB GM Multi-Risk').getRecordTypeId();

        for (SB_Product__c newRec: newRecs) {
            if (newRec.recordtypeid == multiRiskRecTypeId && newRec.Maturity_Date_Reminder__c) {
                tradingProductReminderOpportunityIds.add(newRec.Opportunity__c);
                opportunityMaturityDateMap.put(newRec.Opportunity__c, newRec.SA_Maturity_Date__c);
                opportunityProductMap.put(newRec.Opportunity__c, newRec.Id);
            }
        }
        
        if (tradingProductReminderOpportunityIds.size() > 0) {
            try {
                List<Opportunity> closedTradingProductReminderOpportunities = new SEL_Opportunities().selectByIdAndStage(tradingProductReminderOpportunityIds,new Set<String>{'4 - Closed Lost'});

                Task[] newTasks = new Task[]{ };
                for (Opportunity closedOpp : closedTradingProductReminderOpportunities) {
                    
                    //Regression: Changed Date newReminderDate = opp.CloseDate - 1;
                    Date newReminderDate = opportunityMaturityDateMap.get(closedOpp.Id);

                    Datetime newReminderDateTime = datetime.newInstance(newReminderDate.year(), newReminderDate.month(), newReminderDate.addDays(-1).day());

                    newTasks.add(new Task(
                            Description = 'Follow up on Lost Opportunity. Click on the Related to link to see more details.',
                            Priority = 'Normal',
                            Status = 'In Progress',
                            Subject = 'Reminder: ' + closedOpp.Name + ', ' + closedOpp.Account.Name,
                            IsReminderSet = true,
                            ReminderDateTime = newReminderDateTime,
                            ActivityDate = newReminderDate,
                            OwnerId = closedOpp.OwnerId,
                            WhatId = closedOpp.Id,
                            IsRecurrence = false));
                }
                
                Database.SaveResult[] insertSaveResults = Database.Insert(newTasks, False);
                for (Database.SaveResult insertSaveResult : insertSaveResults) {
                    if (!insertSaveResult.isSuccess()) {
                        Database.Error err = insertSaveResult.getErrors()[0];
                        errorDetails = errorDetails + err.getMessage() + ', ';
                    }
                }
            } catch (Exception e) {
                errorDetails = errorDetails + 'ERROR:' + e;
            } finally {
                if (Test.isRunningTest()) {
                    errorDetails = 'Apex Test Method Simulating Error Condition';
                }
                if (errorDetails <> '') {
                    boolean emailsTurnedOn = false;
                    try {
                        Messaging.reserveSingleEmailCapacity(0);
                        emailsTurnedOn = true;
                    } 
                    catch (System.NoAccessException e) {
                        LOGGER.error(e.getMessage());
                    }

                    if (emailsTurnedOn && Limits.getLimitEmailInvocations() > 0) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String[] toAddresses = new String[]{
                                'CIBSACRMITProductionSuppo@standardbank.co.za'
                        };
                        mail.setToAddresses(toAddresses);
                        mail.setSenderDisplayName('Apex error message');
                        mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName() + ' in ' + className +
                                ' Invoked by ' + transactionUser + ' (' + transactionUserId + ') ');
                        mail.setPlainTextBody('Error Encountered:: ' + className + '.handleProductAfterInsertTrigger: ' + errorDetails);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
                    } else {
                         LOGGER.error('Unable to send emails, check daily limit for the org or if permitted to send emails');
                    }
                }
            }
        }
    }

    /**
	* @description : Method to update the Client on a Product when a Product is Cloned and linked to a diffrent Opportunity
	*
	* @param : newRecs List of Product records
	*/ 
    public static void handleProductBeforeInsertTrigger(List<SB_Product__c > newRecs) {
        //Set of Opportunity Id's
        Set<Id> oppIds = new Set<Id>();
        //A Map with the Opportunity Id and Client
        Map<Id, Opportunity> oppsAccountMap = new Map <Id, Opportunity>();

        //Loop through the Product and add the Opportunity Id to the Opportunity Set
        for (SB_Product__c newRec: newRecs) {
            oppIds.add(newRec.Opportunity__c);
        }

        //Loop hrough the Opportunity's to get the Client Id
        for (Opportunity oppToMap : [Select Id, AccountId, CurrencyISOCode from Opportunity where Id IN :oppIds]) {
            oppsAccountMap.put(oppToMap.Id, oppToMap);
        }

        //Loop through the Product to assign the new Client to the Product
        if (oppsAccountMap.size() > 0) {
            for (SB_Product__c newRec: newRecs) {
                if (oppsAccountMap.containsKey(newRec.Opportunity__c)) {
                    if (oppsAccountMap.get(newRec.Opportunity__c).AccountId != null) {
                        newRec.Client__c = oppsAccountMap.get(newRec.Opportunity__c).AccountId;
                    }
                }
            }
        }
    }
}