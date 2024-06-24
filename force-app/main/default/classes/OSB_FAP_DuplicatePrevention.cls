public class OSB_FAP_DuplicatePrevention
{
	public static void preventDupe(List<Financial_Account_Permission__c> lstFAPs)
    {
        SEL_FinancialAccountPermissions selector = SEL_FinancialAccountPermissions.newInstance();
        List<Id> faList = new List<Id>();
        List<Id> fapIds = new List<Id>();
        
        for(Financial_Account_Permission__c finAccPerm : lstFAPs)
        {
            faList.add(finAccPerm.Financial_Account__c);
            if(!String.isBlank(finAccPerm.Id)) fapIds.add(finAccPerm.Id);
        }
        
        List<Financial_Account_Permission__c> lstExtPermissions = selector.selectFAPs(faList, fapIds);
        
        Map<Id, List<Id>> mapFAToCon = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapConToPerm = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapFAToPerm = new Map<Id, List<Id>>();

        for(Financial_Account_Permission__c faPerm : lstExtPermissions)
        {
            if(mapFAToCon.containsKey(faPerm.Financial_Account__c))
            {
                List<Id> lstIds = mapFAToCon.get(faPerm.Financial_Account__c);
                if(!lstIds.contains(faPerm.Authorized_Person__c)) lstIds.add(faPerm.Authorized_Person__c);
                mapFAToCon.put(faPerm.Financial_Account__c, lstIds);
            }
            else
            {
                List<Id> lstIds = new List<Id>{faPerm.Authorized_Person__c};
                mapFAToCon.put(faPerm.Financial_Account__c, lstIds);
            }
            
            if(mapConToPerm.containsKey(faPerm.Authorized_Person__c))
            {
                List<Id> lstIds = mapConToPerm.get(faPerm.Authorized_Person__c);
                if(!lstIds.contains(faPerm.Permission__c)) lstIds.add(faPerm.Permission__c);
                mapConToPerm.put(faPerm.Financial_Account__c, lstIds);
            }
            else
            {
                List<Id> lstIds = new List<Id>{faPerm.Permission__c};
                mapConToPerm.put(faPerm.Authorized_Person__c, lstIds);
            }
            
            if(mapFAToPerm.containsKey(faPerm.Financial_Account__c))
            {
                List<Id> lstIds = mapFAToPerm.get(faPerm.Financial_Account__c);
                if(!lstIds.contains(faPerm.Permission__c)) lstIds.add(faPerm.Permission__c);
                mapFAToPerm.put(faPerm.Financial_Account__c, lstIds);
            }
            else
            {
                List<Id> lstIds = new List<Id>{faPerm.Permission__c};
                mapFAToPerm.put(faPerm.Financial_Account__c, lstIds);
            }
        }
        
        for(Financial_Account_Permission__c finAccPerm : lstFAPs)
        {
            if(String.isBlank(finAccPerm.Id) || (!String.isBlank(finAccPerm.Id) && !Approval.isLocked(finAccPerm.Id)))
            {
                List<Id> conIds = mapFAToCon.get(finAccPerm.Financial_Account__c);
                List<Id> permIds1 = mapConToPerm.get(finAccPerm.Authorized_Person__c);
                List<Id> permIds2 = mapFAToPerm.get(finAccPerm.Financial_Account__c);
                if(permIds1 != null && permIds2 != null && conIds != null && permIds1.size() > 0 && permIds2.size() > 0 && conIds.size() > 0)
                {
                    if(conIds.contains(finAccPerm.Authorized_Person__c) && permIds1.contains(finAccPerm.Permission__c) && permIds2.contains(finAccPerm.Permission__c)) finAccPerm.addError(Label.OSB_FA_Duplicates_FA_Permissions);
                }
            }
        }
    }
}