/*************************************************************************
@ Author        : Manoj Gupta
@ Date          : 03-July-2017
@ Test File     : StdBank_Ltn_RegulatoryInfo_test
@ Description   : US-2134 IUI FAIS - To display FAIS related information on Client details tab page : 
FAIS Status, NAV, AUM and FAIS Review Date
-----------------------------------------------------------------------------
************************************************************************/

public with sharing class StdBank_Ltn_RegulatoryInfo {

    @AuraEnabled
    public static Boolean getHasAccess(Id accountId) {
        Account[] accs = [  SELECT OwnerId,
                                (SELECT Team_Member__c
                                FROM Custom_Client_Teams__r
                                WHERE Team_Member__c =: userinfo.getuserID()
                                    AND(Client_Coordinator__c = true 
                                        OR Client_Coordinator_BM__c = true)) 
                            FROM Account
                            WHERE Id =: accountId ];

        return accs.size() == 1 && 
                (userinfo.getuserID() == accs[0].OwnerId 
                    || !accs[0].Custom_Client_Teams__r.isEmpty());
    } 

    @AuraEnabled
    public static Account getRecord(String accountId){
        Account[] accs = [  SELECT AUM__c,NAV__c,FAIS_Status__c,FAIS_Review_Date__c,CurrencyIsoCode
                            FROM Account
                            WHERE Id =:  accountId];

        if(accs.size() == 1){
            return accs[0];
        }

        return null;
    }

    @AuraEnabled
    public static String saveRecord(Account record){

        try{
            update record;
        }
        catch(Exception ex){
            return ex.getMessage();
        }

        return '';
    }
 }