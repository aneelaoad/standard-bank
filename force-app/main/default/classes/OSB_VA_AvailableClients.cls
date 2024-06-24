/**
 * @description Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 */
public with sharing class OSB_VA_AvailableClients {

    /**
     * @description DTO class with input for getting clients for which user can query account information
     */
    public class GetClientSInput{
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String serviceType;
        @InvocableVariable
        public String countryName;
    }

    /**
     * @description Invocable method for getting clients for which user can query account information
     *
     * @param inputs List<GetClientSInput>
     *
     * @return List<List<String>>
     */
    @InvocableMethod(Label='VA get available clients')
    public static List<List<String>> getClients(List<GetClientSInput> inputs) {
        List<List<String>> result = new List<List<String>>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String, Set<String>> contact2Clients = new Map<String, Set<String>>();
        for (GetClientSInput input : inputs) {
            contactIdSet.add(Id.valueOf(input.contactId));
        }
        SEL_FinancialAccountPermissions selector = SEL_FinancialAccountPermissions.newInstance();
        List<Financial_Account_Permission__c> permissions = selector.selectActiveByAuthorizedPersonsWithClientName(contactIdSet, inputs.get(0).serviceType, inputs[0].countryName);
        for (Financial_Account_Permission__c permission : permissions) {
            Set<String> clients = contact2Clients.get(permission.Authorized_Person__c);
            if (clients == null) {
                clients = new Set<String>();
                contact2Clients.put(permission.Authorized_Person__c, clients);
            }
            clients.add(permission.Financial_Account__r.Client__r.Name);
        }
        for (GetClientSInput input : inputs) {
            List<String> clientNames = new List<String>();
            Set<String> clientNamesSet = contact2Clients.get(input.contactId);
            if(clientNamesSet != null && !clientNamesSet.isEmpty()){
                clientNames.addAll(clientNamesSet);
                clientNames.sort();
            }
            result.add(clientNames);
        }
        return result;
    }
}