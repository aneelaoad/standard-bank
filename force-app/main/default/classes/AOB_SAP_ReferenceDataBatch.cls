/**
 * @author Emmanuel Mulea Nocks
 * @date March 2023
 * @description  schedulable Batch to execute the allocation of parent rrecords to AOB_ReferencedData__c childs   
 */
global without sharing class AOB_SAP_ReferenceDataBatch implements Database.Batchable<SObject>, Schedulable{

    /**
    * @description The Iterator with SOQL
    *
    * @param bc Database.BatchableContext
    * @return Iterable<sObject>
    */
    global Iterable<sObject> start(Database.BatchableContext bc) {
        return [SELECT AOB_Code__c, AOB_CountryCode__c, AOB_Default__c,AOB_Parent__r.AOB_SAPExternalID__c, AOB_FieldAPIName__c, AOB_Language__c, AOB_ObjectName__c, AOB_Parent__c, AOB_ProductCategory__c, AOB_Product__c, AOB_SAPExternalID__c, AOB_SAPField__c, AOB_Sequence__c, AOB_Value__c, AOB_isActive__c, AOB_ParentCode__c, Parent_Code__c, Id 
        FROM AOB_ReferencedData__c WHERE AOB_Value__c!=null AND AOB_Value__c!='00000' AND (LastModifiedDate < LAST_N_DAYS:1 OR LastModifiedDate=Today)];
    }

    /**
    * @description The batch executor to call AOB_SAP_ReferenceData.allocateParents
    *
    * @param bc Database.BatchableContext
    * @param scope List<sObject>
    */
    global void execute(Database.BatchableContext bc, List<sObject> scope) {

        AOB_ReferencedData__c[] refList = (AOB_ReferencedData__c[]) scope;
        AOB_SAP_ReferenceData.allocateParents(refList);

    }

    /**
    * @description The Schedule executor to run a batch
    *
    * @param ctx System.SchedulableContext
    */    
	global void execute(System.SchedulableContext ctx){
		AOB_SAP_ReferenceDataBatch batchJob = new AOB_SAP_ReferenceDataBatch();
		Database.executeBatch(batchJob);
	}
    /**
    * @description Finish method 
    *
    * @param bc Database.BatchableContext
    */     
    global void finish(Database.BatchableContext bc) {

    }

}