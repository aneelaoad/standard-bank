/**
 * 
 * @description MallCaseManagementUtil
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallCaseManagementUtil {

    private static final String DEFAULT_CASE_RECORD_TYPE = 'Cross_Border_CoE_Record_Type';
    private static final String CASE_DEFAULT_RECORDTYPEID = UTL_RecordType.getRecordTypeId('Case', DEFAULT_CASE_RECORD_TYPE);

    /**
     * 
     * @description getUserRecord
     * @param userId String
     * @return  `User`
     */
    @AuraEnabled
    public static User getUserRecord(String userId) {
        try{
            List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)userId});
            return (!users.isEmpty() ? users[0] : NULL);
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallCaseManagementUtil.getUserRecord', e);
        }
    }


    /**
     * 
     * @description createCaseRecord
     * @param caseRecord Case
     * @return  `String`
     */
    @AuraEnabled
    public static String createCaseRecord(Case caseRecord){
        try {
            if(Schema.SObjectType.Case.isCreateable()) {
                caseRecord.RecordTypeId = CASE_DEFAULT_RECORDTYPEID;
                if(Schema.sObjectType.Case.isCreateable()) {
                    insert caseRecord;
                    return caseRecord.Id;
                }
            }
            return NULL;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallCaseManagementUtil.createCaseRecord', e);
        }
    } 
}