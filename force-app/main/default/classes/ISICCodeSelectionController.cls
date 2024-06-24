/**
 * Created by joracki on 03.10.2018.
 */

public with sharing class ISICCodeSelectionController {

    @AuraEnabled
    public static ISIC_Mapping_Client_Sector__c[] getIsicCodes(String clientSector, String clientSubSector){

        if(clientSector == null || clientSubSector == null)
            throw new ISICCodeSelectionException('Client Sector or Sub-Sector is not defined.');

        ISIC_Mapping_Client_Sector__c[] results =  [SELECT Name, CIF_ISIC_Description__c
                                                        FROM ISIC_Mapping_Client_Sector__c
                                                        WHERE Client_Sector__c =: clientSector
                                                                AND Client_Sub_Sector__c =: clientSubSector];

        return results;
    }

    @AuraEnabled
    public static Map<String, Object> getFieldAttributes(){
        Map<String, Object> attributes = new Map<String, Object>();

        attributes.put('isUpdateable', Account.Industry_Code__c.getDescribe().isUpdateable());

        return attributes;
    }

    public class ISICCodeSelectionException extends Exception{}
}