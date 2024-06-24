public with sharing class OSB_SRV_FinancialAccSearchHandler
{
    @InvocableVariable
    public String accountNumber;

    @InvocableMethod (Label='Search Financial Accounts By Number')
    public static List<Boolean> searchFinAcc(List<String> input)
    {
        List<Boolean> res = new List<Boolean>();

        List<Financial_Account__c> accs = [SELECT Id FROM Financial_Account__c WHERE External_Id__c IN :input];

        res.add(accs == null || accs.size() < 1 ? false : true);

        return res;
    }
}