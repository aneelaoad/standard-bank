public without sharing class CI_ClientSearchController {

    @AuraEnabled
    public static List<Account> searchClients(String searchKey) {
        Account[] accs = [select Name, Id, ParentId  from Account where Name LIKE : '%'+searchKey+'%' ]; 
        return accs;
    }

    /*@AuraEnabled
    public static String searchClientHierarchies(String searchKey) {
        Account[] accs = searchClients(searchKey);
        
        //We only want the highest level accounts because the getClientHierarchy below will return any lower level accounts that we are now filtering out
        List<Account> highestLevelAccounts = getHighestLevelAccounts(accs);

        List<HierarchyComponentController.AccountNode> accHierList = new List<HierarchyComponentController.AccountNode>();
        for(Account highestAcc : highestLevelAccounts)
        {
            accHierList.add(getClientHierarchy(highestAcc.Id));
        }

        return JSON.serialize(accHierList); 
    }*/

    @AuraEnabled
    public static String getClientHierarchyJson(Id clientId) {

        CI_SharedUtilities.ClientHierarchyTools sharedUtilsTools = new CI_SharedUtilities.ClientHierarchyTools();
        
        Id userID = UserInfo.getUserId();  
        List<Account> clientList = [SELECT Name, Id
                            FROM Account
                            where Id in 
                            (SELECT Account__c 
                            FROM Custom_Client_Team__c 
                            where Team_Member__c =: userID)];
        
        List<HierarchyComponentController.AccountNode> accHierList = new List<HierarchyComponentController.AccountNode>();
        
        //Remove client ID's that the user is not in the CST
        accHierList.add(sharedUtilsTools.removeClientIdsNotInList(getClientHierarchy(clientId), clientList));

        return JSON.serialize(accHierList);
    }

    @AuraEnabled
    public static HierarchyComponentController.AccountNode getClientHierarchy(Id accountId) {
        HierarchyComponentController hierComp = new HierarchyComponentController();
        hierComp.currentAccountId = accountId; 
        List<HierarchyComponentController.AccountNode> accHier = hierComp.accountNodes;

        //We only want the first object in the returned list because that is the parent (which contains it's children, and childrens children etc)
        return accHier[0];
    }

    /*@AuraEnabled
    public static List<Account> getHighestLevelAccounts(List<Account> accounts) {
        List<Account> highestLevelAccounts = new List<Account>();

        //Compare each account to each other looking for it's parent
        for(Account accOuter : accounts)
        {
            Boolean parentFound = false;
            for(Account accInner : accounts)
            {
                if(accOuter.ParentId == accInner.Id)
                    parentFound = true;
            }

            if(!parentFound)//No parent found so it must be the highest level account in incoming accounts
                highestLevelAccounts.add(accOuter);
        }

        return highestLevelAccounts;
    }*/
}