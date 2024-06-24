public without sharing class CI_ClientListController {
    @AuraEnabled
    public static CI_ResponseDto getClientList(String recordType, String searchTerm){
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardListObjectModel clients = new CI_CardListObjectModel();

        //get the list
        clients.Description ='Client List';

        String userID = '\'' + UserInfo.getUserId() + '\'';
        String recordTypeFilter = '';
        String clientNameFilter = '';
        
        if(recordType != null)
            recordTypeFilter = ' AND RecordType.Name = \'' + recordType + '\'';   
        
        if(searchTerm != null && searchTerm != '')
        {
            if(searchTerm.Length() == 1)
                clientNameFilter = searchTerm + '%';
            else
                clientNameFilter = '%' + searchTerm + '%';
            
            clientNameFilter = ' AND Name LIKE \'' + clientNameFilter + '\'';
        }

        String queryString = 'SELECT Name, Id, billingCountry, Overall_CIB_CSI_Rating_Number__c, LastModifiedDate, RecordType.Name FROM Account WHERE Id in (SELECT Account__c FROM Custom_Client_Team__c where Team_Member__c = ' + userID + ')' +
                                                  recordTypeFilter + 
                                                  clientNameFilter +
                                                  ' ORDER BY LastModifiedDate DESC NULLS LAST';

        System.debug('Search   ' + queryString);
        
        List<Account> clientList = Database.query(queryString);

        Map<String, String> clientMap;

        for(Account acc: clientList)
        {
            clientMap = new Map<String, String>();
            Boolean revenueFound = false;

            clientMap.put('Id', acc.Id);
            clientMap.put('Name', acc.Name);
            clientMap.put('BillingCountry', acc.billingCountry);
            clientMap.put('LastModifiedDate', String.valueOf(acc.LastModifiedDate));
            clientMap.put('CSIRating', acc.Overall_CIB_CSI_Rating_Number__c != null ? String.valueOf(acc.Overall_CIB_CSI_Rating_Number__c) : null);
            clientMap.put('ClientHierarchyPosition', acc.RecordType.Name);


            if(!revenueFound)
                clientMap.put('GlobalClientRevenue', '0');

            clients.cardObjectList.add(clientMap);
        }                          
        
        clients.cardObject = searchTerm;
        //return the list
        return new CI_ResponseDto(clients);
    }

    @AuraEnabled
    public static void getClientForViewLastViewed(String clientId){

        List<Account> clientList = [SELECT Id
                                    FROM Account 
                                    WHERE Id =: clientId 
                                    FOR VIEW];
    }
}