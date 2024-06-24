/**
 *
 * DTO class for holding account search result
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_AccountSearchOutput {

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
    public List<OSB_VA_AccountInfo> accounts;
    @AuraEnabled
    @InvocableVariable
    public String errorLogId;
    @AuraEnabled
    @InvocableVariable
    public String actionType;
}