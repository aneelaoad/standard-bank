/**
 * @author		Emmanuel Mulea(Nocks)
 * @date	    18/10/2021
 * @description Batch class to insert records returned from smart2 Integration
*/
global  class PbbSmart2ConversationPicklistSyncBatch  implements Database.Batchable<sObject>{
    global List<SObject> dataList;
    /**
    * This is a constructor that get a list of conv list
    * @param	convList List<SObject>
    **/
    global PbbSmart2ConversationPicklistSyncBatch(List<SObject> convList) {
        this.dataList = convList;
    }
    /**
    * This is Start method for a Batch to run the Qyery locator
    * @param	bc Database.BatchableContext of the Apex batch
    * @return   Query locator results
    **/
    global Iterable<sObject> start(Database.BatchableContext bc) {
        return this.dataList;
    }
    /**
    * This is exucute method for a Batch to run the and execute results from dataList
    * @param	bc Database.BatchableContext of the Apex batch
    * @param	scope Object List
    **/
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Conversation_Value__c[] convList = (Conversation_Value__c[]) scope;
        PbbSmart2ConversationPicklistSync.createConversationValues(convList);
    }
    /**
    * This is Finish Method for a batch Job
    * @param	bc Database.BatchableContext of the Apex batch
    **/
    global void finish(Database.BatchableContext bc) {
    }
}