/**
 *
 * DTO class for holding result of financial transactions search information
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_TransactionsSearchOutput {

    @AuraEnabled
    @InvocableVariable
    public Boolean hasError;
    @AuraEnabled
    @InvocableVariable
    public String errorType;
    @AuraEnabled
    @InvocableVariable
    public String errorOutPutMessage;
    @AuraEnabled
    @InvocableVariable
    public List<OSB_VA_TransactionInfo> transactions;
    @InvocableVariable
    public String  errorLogId;
    @InvocableVariable
    public String  actionType;
}