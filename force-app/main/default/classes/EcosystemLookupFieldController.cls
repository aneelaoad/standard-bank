/**
 * Created by Chibuye Kunda on 2019/07/12.
 */

/** this is the lookup controller for ecosystem lookup
 */
public with sharing class EcosystemLookupFieldController{

    /**
    * @description this function will return a list of matching records
    * @param cifORnameP this is the target value
    * @param ecosystemIdP this is ID of the ecosystem we are searching
    * @return list of possible matching records
    */
    @AuraEnabled
    public static List< Account > findMatchingBankedAccounts( String cifORnameP, String ecosystemIdP ){

        String likeQuery = cifORnameP + '%';                 //append the wildcard character
        List< Account > accountList;

        try{

            accountList = [ SELECT Id, Name, CIF__c,Primary_Relationship_Holder__c
                             FROM Account
                             WHERE ( CIF__c LIKE:likeQuery or Name LIKE:likeQuery ) AND
                                   ( CIF__c != null ) AND Status__c NOT IN( 'Prospect', 'Potential' ) AND
                                   ( Id NOT IN( SELECT Entity__c FROM Ecosystem_Entity__c WHERE Ecosystem__c =: ecosystemIdP ) )
                             LIMIT 5 ];

        }
        catch( QueryException query_exception ){
            return null;
        }

        return accountList;

    }





    /** this function will search for unbanked clients
	 * @param nameP is the name of account we are searching for
	 * @param ecosystemIdP is the ID of the ecosystem we are searching against
	 * @return this function will return list of unbanked clients
	 */
    @AuraEnabled
    public static Account[] findMatchingUnbankedAccounts( String nameP, String ecosystemIdP){

        String likeQuery = nameP + '%';
        Account[] accountList;

        try{

            //execute query
            accountList = [ SELECT Id, Name, Status__c, CIF__c,Primary_Relationship_Holder__c
                             FROM Account
                             WHERE ( ( CIF__c = null ) or ( CIF__c = '' ) ) AND ( Name LIKE:likeQuery )
                             AND ( Id NOT IN ( SELECT Entity__c FROM Ecosystem_Entity__c WHERE Ecosystem__c =: ecosystemIdP ) )
                             LIMIT 5 ];

        }
        catch( QueryException query_exception ){
            return null;
        }

        return accountList;

    }

}