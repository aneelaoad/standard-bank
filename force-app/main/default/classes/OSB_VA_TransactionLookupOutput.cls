/**
 *
 * DTO class for holding result of financial transaction search information
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_TransactionLookupOutput {

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
    public String uetr;
    @AuraEnabled
    @InvocableVariable
    public String transactionReference;
    @InvocableVariable
    public String errorLogId;
    @InvocableVariable
    public String actionType;
}