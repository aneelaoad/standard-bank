/**
 * 
 * @description MallStoreCasesController
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallStoreCasesController {
    /**
     * 
     * @description getCaseRecords
     * @param accountId String
     * @return  `List<Case>`
     */
    @AuraEnabled
    public static List<Case> getCaseRecords(String accountId) {
        try{
            List<Case> cases= SEL_Cases.newInstance().selectCasesByAccountIds(new Set<Id>{(Id)accountId});
            return cases;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStoreCasesController.getCaseRecords', e);
        }
    }
}