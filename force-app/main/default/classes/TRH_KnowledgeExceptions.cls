/**
 * Trigger handler class for Knowledge_Entitlement_Exception__c
 * <br/> US-2974
 *
 * @Author Wayde Fagan(wayde.fagan@tetrad.co.za)
 * @Date October 2020
 */
public class TRH_KnowledgeExceptions extends ABS_TriggerHandlerBase {
	private List<Knowledge_Entitlement_Exception__c> knowledgeExceptions {
        get {
            return (List<Knowledge_Entitlement_Exception__c>) Trigger.new;
        }
    }
    public override void handleBeforeInsert() {
        for(Knowledge_Entitlement_Exception__c currentException : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{knowledgeExceptions[0].OSB_Contact_Exception__c})){
            if(currentException.OSB_Knowledge_Article__c == knowledgeExceptions.get(0).OSB_Knowledge_Article__c){
               knowledgeExceptions.get(0).addError('You are creating a duplicate record for this contact.');
            }
        }        
    }
}