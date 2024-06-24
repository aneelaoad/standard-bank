public class CI_GemController {
    @AuraEnabled
    public static CI_ResponseDto getGemsAction(String clientId) {   
        //News article lead notifications
        List<CI_Gem__c> leadGems = CI_GemLeadController.getLeadGems(clientId);

        //Combine all above gems lists into single list
        List<CI_Gem__c> allGems = new List<CI_Gem__c>();
        allGems.addAll(leadGems);
        
        removeDeletedGems(allGems);
        
        return new CI_ResponseDto(allGems);        
    }

    @AuraEnabled
    public static CI_ResponseDto dismissGemAction(String gemId) {   
        CI_Gem__c gemToDismiss = [SELECT Dismissed__c FROM CI_Gem__c WHERE Id = :gemId AND User__c =: UserInfo.getUserId()];
        gemToDismiss.Dismissed__c = true;
        update gemToDismiss;

        return new CI_ResponseDto(gemToDismiss);        
    }

    @AuraEnabled
    public static CI_ResponseDto deleteGemAction(String gemId) {   
        CI_Gem__c gemToDelete = [SELECT Deleted__c FROM CI_Gem__c WHERE Id = :gemId AND User__c =: UserInfo.getUserId()];
        gemToDelete.Deleted__c = true;
        update gemToDelete;

        return new CI_ResponseDto(gemToDelete);        
    }

    public static void removeDeletedGems(List<CI_Gem__c> gems) {
        Integer j = 0;
        while (j < gems.size())
        {
            if(gems.get(j).Deleted__c) {
                gems.remove(j);
            } else {
                j++;
            }
        }
    }
}