/**
 *
 * DTO class for holding account information in chat bot conversation
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_AccountInfo {

    @AuraEnabled
    public String accountId;
    @AuraEnabled
    public String outputText;
}