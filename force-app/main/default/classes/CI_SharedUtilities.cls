public class CI_SharedUtilities{

    public Boolean canAccessFields(Map<String,Schema.SObjectField> fieldDescribeTokens, String[] fieldsToCheck ){
        
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isAccessible()) {             
                return false;
            }
        }
        
        return true;
    }

    public String CSIDescription(String text){
        
        String csiRating = '';
        if(text == 'Not Rated'){
            csiRating ='Not Rated';
        }
        else if(integer.valueOf(text) < 7)
            csiRating ='At Risk';
        else if(integer.valueOf(text) < 8)
            csiRating ='Indifferent';      
        else  
            csiRating = 'Satisfied';            

        return csiRating;
    }

    public Set<Id> getCurrentUserHighestLevelClients(Map<String,Boolean> querySettings) {
        Set<Id> clientsForRevenue = new Set<Id> ();
        Set<Id> teamClientsIds = getCurrentUserTeamClients();
        String parentQuery, parentImmediateQuery, childQuery;

        Map<String, String> query = CI_QueryBuilder.getCurrentUserHighestLevelClientsQuery(querySettings, teamClientsIds);

        //Get top parent clients
//        clientsForRevenue.addAll((new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :teamClientsIds AND RecordTypeId = :AccountService.RECORD_TYPE_GROUP_PARENT])).keySet());
        clientsForRevenue.addAll((new Map<Id, Account> ((List<Account>)Database.query(query.get('parentQuery'))) ).keySet());
        //Get immediate parent clients not returned above
//        clientsForRevenue.addAll((new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :teamClientsIds AND ParentId NOT IN :clientsForRevenue AND RecordTypeId = :AccountService.RECORD_TYPE_IMMEDIATE_PARENT])).keySet());
        clientsForRevenue.addAll((new Map<Id, Account> ((List<Account>)Database.query(query.get('parentImmediateQuery'))) ).keySet());
        //Get child clients not returned above
//        clientsForRevenue.addAll((new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :teamClientsIds AND ParentId NOT IN :clientsForRevenue AND Group_Parent__c NOT IN :clientsForRevenue AND RecordTypeId = :AccountService.RECORD_TYPE_CHILD])).keySet());
        clientsForRevenue.addAll((new Map<Id, Account> ((List<Account>)Database.query(query.get('childQuery'))) ).keySet());

//        System.debug(clientsForRevenue);

        return clientsForRevenue;
    }

    public Set<Id> getCurrentUserTeamClients() {
        Id[] activeClientRTIds = new Id[] { };
        activeClientRTIds.add(AccountService.RECORD_TYPE_GROUP_PARENT);
        activeClientRTIds.add(AccountService.RECORD_TYPE_IMMEDIATE_PARENT);
        activeClientRTIds.add(AccountService.RECORD_TYPE_CHILD);

        Set<Id> userTeamClients = (new Map<Id, Account> ([SELECT Id FROM Account
                                                WHERE Id IN(
                                                            SELECT Account__c FROM Custom_Client_Team__c
                                                            WHERE Team_Member__c = :UserInfo.getUserId())
                                                AND RecordTypeId IN :activeClientRTIds])).keySet();

        return userTeamClients;
    }

    public Boolean isStringNumeric(String stringToTest){
        Boolean isNumeric;
        try{
            Decimal.valueOf(stringToTest);
            isNumeric = true; 
        } catch (Exception e) {
            isNumeric = false;
        }
        return isNumeric;
    } 

    public String calculatePercentVariance(String originalVal, String newVal){
        if(isStringNumeric(originalVal) && isStringNumeric(newVal)) {
            Decimal originalValue = Decimal.valueOf(originalVal);
            Decimal newValue = Decimal.valueOf(newVal);

            Decimal difference;
            String symbol = '';
            if(originalValue > newValue){
                difference = originalValue - newValue;
                symbol = '-';
            }
            else {
                difference = newValue - originalValue;
            }

            if (originalValue != 0 && newValue != 0)
                return (newValue - originalValue) == 0 ? '0' : symbol + String.valueOf((difference / originalValue) * 100);
            else
                return null;
        } else
            return null;
    }

    public String join(List<String> values, String separator) {
        List<String> valueCopy = new List<String>(values);
        
        if(valueCopy.isEmpty())
            return null;

        String result = valueCopy[0];
        valueCopy.remove(0);

        while(!valueCopy.isEmpty()) {
            result += separator + valueCopy[0];
            valueCopy.remove(0);
        }
        return result;
    }

    public AggregateResult getAggregateResultByValue(String fieldName, String value, List<AggregateResult> aggregateResultList){
        for(AggregateResult item : aggregateResultList){
            if(String.valueOf(item.get(fieldName)) == value)
             return item;
        }
        return null;
    }

    public class CurrencyConverter {

        public Map <String, Double> RateMap = new Map < String, Double > ();

        public CurrencyConverter() {
            List<CurrencyType> currTypes = [Select cur.IsoCode, cur.ConversionRate From CurrencyType cur LIMIT 300];

            for (CurrencyType c: currTypes) {
                RateMap.put(c.IsoCode, c.ConversionRate);
            }
        }


        public Decimal convert(Decimal val, String oldCurr, String newCurr) {
            //NOTE ON CALCULATION:
            //(current curr / current rate) = USD(1:1) 
            //(USD * new rate) = new curr value
            
            // No point in trying to convert a null.
            if (val == null) return 0;
                Decimal displayVal;

            if ((oldCurr != newCurr) || (val != 0)) {

                Double oldrate = RateMap.get(oldCurr);
                Decimal usdval = (val / oldrate);
                Double newrate = RateMap.get(newCurr);

                displayVal = (usdval * newrate);

            } else {
                displayVal = val;
            }
            return displayVal;
        } 
    }

    public class ClientHierarchyTools {
        private HierarchyComponentController.AccountNode foundAccNode;
        List<String> clientIdsInHierarchy = new List<String>();
        
        public HierarchyComponentController.AccountNode getAccountNodeInHierarchy(HierarchyComponentController.AccountNode hierarchy, String clientId){
            setFoundAccNode(hierarchy, clientId);
            return foundAccNode;
        }

        public List<String> getClientIdsInHierarchy(HierarchyComponentController.AccountNode hierarchy){
            setClientIdsInHierarchy(hierarchy);
            return clientIdsInHierarchy;
        }
        
        private void setFoundAccNode(HierarchyComponentController.AccountNode hierarchy, String clientId) {
            if(hierarchy.account.Id == clientId){
                foundAccNode = hierarchy;
                return;
            }
            
            for(HierarchyComponentController.AccountNode acc : hierarchy.childAccountsNodes)
                setFoundAccNode(acc, clientId);
        }

        private void setClientIdsInHierarchy(HierarchyComponentController.AccountNode hierarchy) {
            clientIdsInHierarchy.add(hierarchy.account.Id);
            
            for(HierarchyComponentController.AccountNode acc : hierarchy.childAccountsNodes)
                setClientIdsInHierarchy(acc);
        }

        public HierarchyComponentController.AccountNode removeClientIdsNotInList(HierarchyComponentController.AccountNode hierarchy, List<Account> clientIds) {
            removeClientIdIfNotInList(hierarchy, clientIds);
            return hierarchy;
        }
        
        private void removeClientIdIfNotInList(HierarchyComponentController.AccountNode hierarchy, List<Account> clientIds) {
            Boolean found = false;
            for(Account accIds : clientIds) {
                if(hierarchy.account.Id == accIds.Id)
                    found = true;
            }

            if(!found)
                hierarchy.account.Id = null;
            
            for(HierarchyComponentController.AccountNode acc : hierarchy.childAccountsNodes)
                removeClientIdIfNotInList(acc, clientIds);
        }
    }
}