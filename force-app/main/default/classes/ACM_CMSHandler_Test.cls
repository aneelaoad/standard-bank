@IsTest
public class ACM_CMSHandler_Test {

@IsTest(SeeAllData=true)
    public static void testGetManagedContentByContentKeysInternal() {
        List<Network> communityId = [SELECT Id FROM Network where name='Internal API Marketplace' limit 1]; 
        String cId=communityId[0].Id;
        List<String> managedContentIds = new List<String>{'contentId1', 'contentId2'}; 
        
        List<ConnectApi.ManagedContentVersion> result = ACM_CMSHandler.getManagedContentByContentKeys(cId, managedContentIds);
        Assert.areEqual(false, result.size()>0, 'Result is not null');
        
    } 
    
     public static void testGetManagedContentByContentKeysExternal() {
        List<Network> communityId = [SELECT Id,Name FROM Network where name='API Marketplace' limit 1]; 
        String cId=communityId[0].Id;
        List<String> managedContentIds = new List<String>{'contentId1', 'contentId2'}; 
        
        List<ConnectApi.ManagedContentVersion> result = ACM_CMSHandler.getManagedContentByContentKeys(cId, managedContentIds);

        Assert.areEqual(false, result.size()>0, 'Result is not null');
        
    } 
    
    public static void testGetManagedContentByContentKeys_invalid() {

        String communityId = null; 
        List<String> managedContentIds = new List<String>{null, null}; 
        
        List<ConnectApi.ManagedContentVersion> result = ACM_CMSHandler.getManagedContentByContentKeys(communityId, managedContentIds);

        Assert.areEqual(null, result, 'Result should not be null');
        
    }
}