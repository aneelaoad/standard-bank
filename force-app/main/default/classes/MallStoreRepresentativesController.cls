/**
 * 
 * @description MallStoreRepresentativesController
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallStoreRepresentativesController {    
    /**
     * 
     * @description getContactRecords
     * @param accountId String
     * @return  `List<Contact>`
     */
    @AuraEnabled
    public static List<Contact> getContactRecords(String accountId) {
        try{
            List<Contact> contacts= SEL_Contacts.newInstance().selectByClientId(new Set<Id>{(Id)accountId});
            return contacts;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStoreRepresentativesController.getContactRecords', e);
        }
    }
}