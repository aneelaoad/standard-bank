/**
 *
 * @description Controller OSB_SRV_FinancialAccPermissionHandler
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date April 2022
 */
public with sharing class OSB_SRV_FinancialAccPermissionHandler {

    public static final String BALANCE_INQUIRY = 'Balance inquiry';
    public static final String STATEMENT_INQUIRY = 'Email Statement';
    public static final String PAYMENT_TRACKING = 'Payment tracking';

    /**
     *
     * @description DTO class checkPermissions method
     *
     * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
     * @date January 2021
     */
    public class CheckPermissionsInput {
        @InvocableVariable(required=true)
        public String permissionType;
        @InvocableVariable(required=true)
        public String contactId;
        @InvocableVariable
        public String accountNumber;
    }

    /**
     *
     * @description DTO class checkPermissions method
     *
     * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
     * @date January 2021
     */
    public class CheckPermissionsOutput {
        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorMessage;
    }

    /**
     * @description Method checks if Contact with given Id has access to specified
     *
     * @param inputs - List<CheckPermissionsInput>
     *
     * @return List<CheckPermissionsOutput> true for contacts with access, false for contacts without access
     */
    @InvocableMethod
    public static List<CheckPermissionsOutput> checkPermissions(List<CheckPermissionsInput> inputs) {
        List<CheckPermissionsOutput> result = new List<CheckPermissionsOutput>();
        for (CheckPermissionsInput input : inputs) {
            if (input.accountNumber != null) {
                result.add(hasServiceAccessPermissionForAccount(input.contactId, input.accountNumber, input.permissionType));
            } else {
                result.add(hasServiceAccessPermission(input.contactId, input.permissionType));
            }
        }
        return result;
    }

    private static CheckPermissionsOutput hasServiceAccessPermission(String contactId, String permissionType) {
        CheckPermissionsOutput output = new CheckPermissionsOutput();
        Integer permissionsCount = (Integer) [
                SELECT
                        COUNT(Id) numOfPermissions
                FROM Financial_Account_Permission__c
                WHERE Permission__r.Name = :permissionType AND Authorized_Person__r.Id = :contactId
                AND Active__c = true
        ].get(0).get('numOfPermissions');
        
        if (permissionsCount > 0){
            output.hasError = false;
            output.errorMessage = null;
        } else{
            output.hasError = true;
            output.errorMessage = null;
        }
        return output;
    }

    /**
     * @description Method checks if Contact has access to the specified DCS service for given account number
     *
     * @param contactId
     * @param accountNumber - bank account number
     * @param permissionType - name of the service
     *
     * @return true for contact with access, false for contact without access
     */
    public static CheckPermissionsOutput hasServiceAccessPermissionForAccount(String contactId, String accountNumber, String permissionType) {
        CheckPermissionsOutput output = new CheckPermissionsOutput();
        List<Financial_Account__c> accs = [Select Id FROM Financial_Account__c WHERE External_Id__c = :accountNumber];
        if (accs.isEmpty()){
            if(permissionType == PAYMENT_TRACKING){
                output.hasError = false;
            } else{
                output.hasError = true;
            }
            output.errorMessage = System.Label.OSB_VA_Accounts_Not_Found;
            return output;
        }
        Integer permissionsCount = (Integer) [
                SELECT
                        COUNT(Id) numOfPermissions
                FROM Financial_Account_Permission__c
                WHERE Financial_Account__r.External_Id__c = :accountNumber AND Authorized_Person__r.Id = :contactId
                AND Permission__r.Name = :permissionType AND Active__c = true
        ].get(0).get('numOfPermissions');

        if (permissionsCount > 0){
            if(permissionType == PAYMENT_TRACKING){
                output.hasError = true;
            } else {
                output.hasError = false;
            }
            output.errorMessage = null;
        } else{
            if(permissionType == PAYMENT_TRACKING){
                output.hasError = false;
            } else {
                output.hasError = true;
            }
            output.errorMessage = System.Label.OSB_VA_PT_NoPermissionOnAccount;
        }
        return output;
    }
}