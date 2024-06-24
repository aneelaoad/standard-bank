/*
        *    @Author        : Manoj Gupta
        *    @Modified Date : Feb 2016
        *    @Description   : EN:1043 Functionality to update Group KYC in progress field value for clients in the same hierarchy  
                              This method checks if for a KYC status record (Entity Code:SBSA) KYC review status value is any of the following values 
                              In progress,KYC Processing Documents,KYC Reviewer Approval Outstanding,Entities Still to Contact,
                              Client Risk Committee Approval Outstanding,Awaiting Compliance/Legal Guidance,Potential Closure
                              then update Group KYC In Progress as true for Clients in the Hierarchy.                             
                              
                              For KYC status records if KYC review status (Entity Code:SBSA) is closed,Suspended,CRC Deferred,SGC Deferred  
                              and all the clients in the hierarchy none have any open KYC Status record,then update Group KYC Review In Progress
                              field for clients in the hierarchy to False                             
        
        
        */

public without sharing class KYCStatusTriggerUtility {

    public static void updateGroupKYCInProgressFalse(Set<Id> clientIds) {

        Set<String> openedKycReviewStatuses = Open_KYC_Review_Status__c.getAll().keySet();

        Set<String> allSbsaCifs = new Set<String>();
        Set<String> notInProgressCifs = new Set<String>();
        Set<String> inProgressCifs = new Set<String>();
        for (KYC_Status__c kycRec : getRelatedKycRecords(clientIds)) {
            allSbsaCifs.add(kycRec.Client__r.Group_Parent_CIF_Number__c);
            if (openedKycReviewStatuses.contains(kycRec.KYC_Review_Status__c)) {
                inProgressCifs.add(kycRec.Client__r.Group_Parent_CIF_Number__c);
            }
        }
        for (String cif : allSbsaCifs) {
            if (!inProgressCifs.contains(cif)) {
                notInProgressCifs.add(cif);
            }
        }

        updateAccountsGroupKycReviewStatus(allSbsaCifs, notInProgressCifs, inProgressCifs);

    }

    private static List<KYC_Status__c> getRelatedKycRecords(Set<Id> clientIds) {
        List<Account> accounts = [
            SELECT Group_Parent_CIF_Number__c
            FROM Account
            WHERE Id IN :clientIds
                AND Group_Parent_CIF_Number__c != NULL
        ];
        Set<String> groupParCIF = new Set<String>();
        for (Account acc : accounts) {
            groupParCIF.add(acc.Group_Parent_CIF_Number__c);
        }

        List<KYC_Status__c> kYCRecList = [
            SELECT KYC_Review_Status__c, Client__r.Group_Parent_CIF_Number__c
            FROM KYC_Status__c
            WHERE Client__r.Group_Parent_CIF_Number__c IN :groupParCIF
                AND Entity_Code__c = :DMN_KYC_Status.ENTITY_CODE_SBSA
        ];
        return kYCRecList;
    }

    private static void updateAccountsGroupKycReviewStatus(Set<String> allSbsaCifs, Set<String> notInProgressCifs, Set<String> inProgressCifs) {
        List<Account> allAccs = [
            SELECT Group_KYC_Review_In_Progress__c, Group_Parent_CIF_Number__c
            FROM Account
            WHERE (CRT_Parent_Child__c = :DMN_Account.CRT_PC_TP AND CIF__c IN :allSbsaCifs)
                OR (CRT_Parent_Child__c != :DMN_Account.CRT_PC_TP AND Group_Parent__r.CIF__c IN :allSbsaCifs)
        ];

        List<Account> toUpdate = new List<Account>();
        for (Account ac : allAccs) {
            if (ac.Group_KYC_Review_In_Progress__c && notInProgressCifs.contains(ac.Group_Parent_CIF_Number__c)) {
                ac.Group_KYC_Review_In_Progress__c = false;
                toUpdate.add(ac);
            }
            if (!ac.Group_KYC_Review_In_Progress__c && inProgressCifs.contains(ac.Group_Parent_CIF_Number__c)) {
                ac.Group_KYC_Review_In_Progress__c = true;
                toUpdate.add(ac);
            }
        }

        if (toUpdate.size() > 0) {
            update toUpdate;
        }
    }

}