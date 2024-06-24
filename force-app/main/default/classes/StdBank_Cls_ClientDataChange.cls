public class StdBank_Cls_ClientDataChange {

    private final Boolean isLightning;
    
    private final Id clientId = ApexPages.currentPage().getParameters().get('ClientId');
    private final Id cOwnerId = ApexPages.currentPage().getParameters().get('ClientOwner');
    
    private final ApexPages.StandardController stdController {get; set;}
    
    public StdBank_Cls_ClientDataChange(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        
        Client_Data_Change__c data = (Client_Data_Change__c) stdController.getRecord();
        
        List<Custom_Client_Team__c> clientTeam = [SELECT Id , Team_Member__c, Client_Role__c FROM Custom_Client_Team__c WHERE Account__c = :clientId AND Client_Coordinator__c = true];
        
        if (!clientTeam.isEmpty()) {
            data.Current_Client_Coordinator__c = clientTeam[0].Team_Member__c;
            data.Current_Client_Coordinator_Role__c = clientTeam[0].Client_Role__c;
        } else {
            data.Current_Client_Coordinator__c = cOwnerId;
            data.Current_Client_Coordinator_Role__c = '';
        }
            
        data.Client_Name__c = clientId;
        data.RecordTypeID = data.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Client Coordinator Request').getRecordTypeId();  
    }
    
    public PageReference cancelRequest() {
        String pgUrl = '/' + clientId;
        PageReference pg = new PageReference(pgUrl);
        
        return pg;
    }
    
    
    public Boolean getIsLightning() {
        return this.isLightning;
    }

    public Boolean getIsClassic() {
        return !this.isLightning;
    }
    
    private Boolean isPageOriginLightning(Map<String, Object> params) {
        if (params.get('sfdcIFrameHost') != null ||
            params.get('sfdcIFrameOrigin') != null ||
            params.get('isdtp') == 'p1') {      
                return true;
            } else {      
                return false;
            }
    }
}