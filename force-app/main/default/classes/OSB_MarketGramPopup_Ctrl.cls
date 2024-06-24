/**
 * Controller class for OSB_MarketGramPopup_Ctrl component
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 *
 **/
public without sharing class OSB_MarketGramPopup_Ctrl {

    /**
     * Creates a case for the contact us request access form
     *
     * @param case fields
     * @param Id number
     * @param passport number
     *
     * @return Case
     **/
    @AuraEnabled
    public static Case saveCase(Case MarketGramCase,String IdentityNum, String PassNum) {
        Id QueueId = UTL_Queue.getQueueId(DMN_Queue.ONEHUB_QUEUE);
        try{
            List <Contact> contact = [Select Id,RecordTypeId,Email,Identity_Number__c from Contact
                                      where Email =: MarketGramCase.SuppliedEmail AND (Identity_Number__c =: IdentityNum OR OSB_Passport_Number__c =: PassNum)  LIMIT 1];
            if(!contact.isEmpty()){ 
                MarketGramCase.ContactId = contact[0].Id;
                if(contact[0].RecordTypeId == UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK)){
                	MarketGramCase.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE);
                }
                else{
                    MarketGramCase.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CIB_CLIENT_CASE);
                }
            }else{
                MarketGramCase.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CIB_CLIENT_CASE);
            }
            
            MarketGramCase.Priority = DMN_Case.PRIORITY_LOW;
            MarketGramCase.OwnerId = QueueId;
            insert MarketGramCase;
            return MarketGramCase;
        }catch(Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }
}