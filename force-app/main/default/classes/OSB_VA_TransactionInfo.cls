/**
 *
 * DTO class for holding financial payment information in chat bot conversation
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_TransactionInfo {

    @AuraEnabled
    @InvocableVariable
    public String uetr;
    @AuraEnabled
    @InvocableVariable
    public String transactionReference;
    @AuraEnabled
    @InvocableVariable
    public String outputText;
}