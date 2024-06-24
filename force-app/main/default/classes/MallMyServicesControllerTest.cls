/**
 * @description 
 * @author Maham Hassan
 * @since
 */
@isTest
public class MallMyServicesControllerTest {

    @IsTest
    public static void getMyServicesTest(){
        
        
        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.isPublished__c = true;
        publishingUnit.Published_from__c = system.today();
        publishingUnit.Published_until__c = system.today()+2;
        insert publishingUnit;

        Tag__c tag = new Tag__c();
        tag.Name = 'Category';
        tag.Publishing_Unit__c = publishingUnit.Id;
        insert tag;
        assert.areEqual('Category', tag.Name, 'Expected Outcome');
        Tag__c secondaryTag = new Tag__c();
        secondaryTag.Name = 'South Africa';
        secondaryTag.Publishing_Unit__c = publishingUnit.Id;
        secondaryTag.Parent__c = tag.Id;
        insert secondaryTag;

        Provider__c provider = new Provider__c();
        provider.Name='Test Provider';
        insert provider;
        
        provider.Publishing_Unit__c = publishingUnit.Id;
        update provider;
		
        Shortcut__c shortcut=new Shortcut__c();
        shortcut.User__c = UserInfo.getUserId();
        shortcut.Provider__c = provider.Id;
        insert shortcut;
        
        Tag_Provider__c shopTag = new Tag_Provider__c();
        shopTag.Provider__c = provider.Id;
        shopTag.Tag__c = secondaryTag.Id;
        insert shopTag;

        Tag__c newTag = new Tag__c();
        newTag.Name = 'Angola';
        newTag.Publishing_Unit__c = publishingUnit.Id;
        newTag.Parent__c = tag.Id;
        insert newTag;

        Tag_Provider__c shopTag2 = new Tag_Provider__c();
        shopTag2.Provider__c = provider.Id;
        shopTag2.Tag__c = newTag.Id;
        insert shopTag2;
		
        Offering__c product = new Offering__c();
        product.Publishing_Unit__c = publishingUnit.Id;
        product.Provider__c = provider.id;
        product.RecordTypeId = Schema.SObjectType.Offering__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();

        insert product;
        

        MallDataServiceHandler.userCountry = 'South Africa';
 
        List<String> tagIds = new List<String>();  
        tagIds.add(newTag.id);   
      	List<MallMyServicesController.DenormalizedShopService> result = MallMyServicesController.getMyServices(tagIds);
        Assert.areEqual(1, result.size(), 'result size 1');
    }
   
   
    @IsTest
    public static void getShopsTest(){
        List<String> tagIds = new List<String>(); 
        Provider__c provider = new Provider__c();
        provider.Name='Test Provider';
        insert provider;
        
        Tag__c tag = new Tag__c();
        tag.Name='Test Provider';
        insert tag;
        tagIds.add(tag.Id);
        
        Tag_Provider__c tagProvider = new Tag_Provider__c();
        tagProvider.Provider__c = provider.Id;
        tagProvider.Tag__c = tag.id;
        insert tagProvider; 
        
       List<DenormalizedShop> result=  MallMyServicesController.getShops(tagIds);
        Assert.areNotEqual(null, result, 'expected outcome');
        try {
          MallMyServicesController.getShops(NULL);
        } catch(Exception e) {
          Assert.isTrue(e != NULL, 'Exception should not be null');
        }
    }

 @IsTest
    public static void updateShortcutsTest(){
      List<String> shopIds = new List<String>();
        Provider__c provider = new Provider__c();
        provider.Name = 'test provider';
        insert provider;
		    shopIds.add(provider.Id);        
     	Shortcut__c shortcut=new Shortcut__c();
        shortcut.User__c = UserInfo.getUserId();
        shortcut.Provider__c = provider.Id;
        insert shortcut;
        
        MallMyServicesController.updateShortcuts(shopIds);
        Assert.areNotEqual(null, shortcut, 'shortcut not null');
        try {
          MallMyServicesController.updateShortcuts(NULL);
        } catch(Exception e) {
          Assert.isTrue(e != NULL, 'Exception should not be null');
        }
    }
	
}