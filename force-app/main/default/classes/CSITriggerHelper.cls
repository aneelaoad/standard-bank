/*************************************************************************
    @ Author        : Praneeth Indraganti
    @ Date          : 20- Apr -2015
    @ Test File     : 
    @ Description   : when client satisfaction record is created, the latest record's rating will be updated in Account

    @ author :- Praneeth Indraganti
    @ date  :-  20-April-2015
    @ description :- Public void method updateCIBCSIRating
                    update the Overall CIB CSI Rating on Account based on latest CSI Record's value 
    @ param :- List<Account>

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Oct 1, 2015
    @ Modification Description : EN-865 - upon upsert, share CSI records with users in the client team

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Oct 8, 2015
    @ Modification Description : EN-865 - improved performance

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Oct 15, 2015
    @ Modification Description : EN-962 - adding checks for CSI Country
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified On  : Dec 02, 2015
    @ Modification Description : EN-981 - Removed logic of removeCsiSharingsForUsers method to CSITriggerUtility Class
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified On  : Apr 15, 2016
    @ Modification Description : EN-1210 - CSI - Improve Case automation & data quality control - Update.
                                 Included CSI Client at Risk field to client which will be updated based on latest CSIs Record value

    @ Last Modified By  : Balint Gyokeres
    @ Last Modified On  : Aug 13, 2021
    @ Modification Description : SFP-4119 - CSI tile not displaying 2021 ratings. Added Tile Survey Year update on deletion.
*************************************************************************/
/**
 * @description CSI Trigger method
 */
public with sharing class CSITriggerHelper {

    private final static String CSI_SHARING_REASON = Schema.Client_Satisfaction_Index__Share.rowCause.CST_Member_Can_Read_CSI_Records__c;
    private final static Set<String> CSI_COUNTRIES = new Set<String>();
    
    static {
        for (CsiProjectCountry__c cpc: CsiProjectCountry__c.getAll().values()) {
            CSI_COUNTRIES.add(cpc.name);
        }
    }
    /**
    * @description Update CSI on insert or Update
    * @param lstCSI
    */
    public static void updateCIBCSIRatingOnInsertingOrUpdating(List<Client_Satisfaction_Index__c> lstCSI)
    {
        Set<ID> accountIds = new Set<ID>();
        List<Account> accList = new List<Account>();
        
        for(Client_Satisfaction_Index__c csiObj:lstCSI)
        {
            AccountIds.add(csiObj.Client__c);
        }
        for(Account acc:[select Overall_CIB_CSI_Rating_Number__c,CSI_Client_at_Risk__c,Survey_Year__c,(select id,Name,Survey_Year__c,Client__c,Overall_CIB_CSI_Rating_Number__c,CSI_Client_at_Risk__c from Client_Satisfaction_Index__r order by Survey_Year__c DESC, SystemModStamp DESC,Name DESC limit 1 )from Account where Id IN:accountIds ])
        {   
            acc.Overall_CIB_CSI_Rating_Number__c= acc.Client_Satisfaction_Index__r[0].Overall_CIB_CSI_Rating_Number__c;
            acc.Survey_Year__c = acc.Client_Satisfaction_Index__r[0].Survey_Year__c;
            acc.CSI_Client_at_Risk__c = acc.Client_Satisfaction_Index__r[0].CSI_Client_at_Risk__c;
            accList.add(acc);
        }
        if(accList.size()>0)
        {
            Database.saveresult[] s = Database.update(accList, False);
        }
    }
    /**
    * @description Update CSI on insert or Update
    * @param records
    * @param id2OldRecords
    */
    public static void updateCIBCSIRatingOnInsertingOrUpdating (List<Client_Satisfaction_Index__c> records, Map<Id, Client_Satisfaction_Index__c> id2OldRecords) {
        List<Client_Satisfaction_Index__c> csiList = new List<Client_Satisfaction_Index__c>();

        for (Client_Satisfaction_Index__c csiObj : records) {
            if (csiObj.Overall_CIB_CSI_Rating_Number__c != id2OldRecords.get(csiObj.Id).Overall_CIB_CSI_Rating_Number__c
                    || csiObj.Survey_Year__c != id2OldRecords.get(csiObj.Id).Survey_Year__c) {
                csiList.add(csiObj);
            }
        }

        if (csiList.size() > 0) {
            updateCIBCSIRatingOnInsertingOrUpdating(csiList);
        }
    }
         
    /**
              @author Praneeth Indraganti
              @date 22-April-2015
              @description Public void method updateCIBCSIRating update the Overall CIB CSI Rating on Account based on latest CSI Record's value 
              @param lstCSI
    **/
    public static void updateCIBCSIRatingOnDeletion(List<Client_Satisfaction_Index__c> lstCSI)
    {
        Set<ID> accountIds = new Set<ID>();
        List<Account> accList = new List<Account>();
        
        for(Client_Satisfaction_Index__c csiObj:lstCSI)
        {
            AccountIds.add(csiObj.Client__c);
        }
        for(Account acc:[select Overall_CIB_CSI_Rating_Number__c,CSI_Client_at_Risk__c,Survey_Year__c,(select id,Survey_Year__c,name,Client__c,Overall_CIB_CSI_Rating_Number__c,CSI_Client_at_Risk__c from Client_Satisfaction_Index__r order by Survey_Year__c DESC,SystemModStamp DESC,name DESC limit 1 )from Account where Id IN:accountIds ])
        {   
            if(acc.Client_Satisfaction_Index__r.isEmpty())
            {
                acc.Overall_CIB_CSI_Rating_Number__c = null;
                acc.CSI_Client_at_Risk__c = ' ';
                accList.add(acc);
            }
            else
            {
                acc.Overall_CIB_CSI_Rating_Number__c= acc.Client_Satisfaction_Index__r[0].Overall_CIB_CSI_Rating_Number__c;
                acc.Survey_Year__c = acc.Client_Satisfaction_Index__r[0].Survey_Year__c;
                acc.CSI_Client_at_Risk__c= acc.Client_Satisfaction_Index__r[0].CSI_Client_at_Risk__c;
                accList.add(acc);
            }
        }
        if(!accList.isEmpty())
        {
            Database.saveresult[] s = Database.update(accList, False);
        }
    }

     /**
    * @description Checks if values in CSI_Project_Country__c are allowed.
    * @param csis
    */
    public static void validateCsiCountries(List<Client_Satisfaction_Index__c> csis) {
        if (csis == null || csis.isEmpty()) {
            system.debug('####### CSITriggerHelper.validateCsiCountries(): csis null or empty');
            return;
        }

        for (Client_Satisfaction_Index__c csi: csis) {
            if (!CSI_COUNTRIES.contains(csi.csi_Project_Country__c)) {
                csi.addError(csi.csi_Project_Country__c + ' is a not allowed value for the CSI_Project_Country__c field');
            }
        }
    }
}