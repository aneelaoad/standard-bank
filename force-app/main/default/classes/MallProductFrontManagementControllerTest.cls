/**
 * 
 * @description Test Class for MallProductFrontManagementController
 * @author Maham Hassan
 * @since 
 */

@isTest
public class MallProductFrontManagementControllerTest {
    
    /**
   * 
   * @description getProductsTest
   */

    @isTest
    public static void getProductsTest(){
        Tag__c segment = new Tag__c();
        segment.Name = 'Segment';
        
        insert segment;
        
        Tag__c category = new Tag__c();
        category.Name = 'Category';
        insert category;
        
        Tag__c tag = new Tag__c();
        tag.Name = 'Test Segment';
        tag.Parent__c = segment.id;
        insert tag;
        
        Tag__c tag1 = new Tag__c();
        tag1.Name = 'Test Category';
        tag1.Parent__c = category.id;
        insert tag1;

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Provider__c provider = new Provider__c();
        provider.Name = 'Test Provider';
        provider.Related_Client__c = account.Id;
        insert provider;
        
        Offering__c parentOffering=new Offering__c();
        parentOffering.Provider__c = provider.id;
        insert parentOffering;
        
        Offering__c prod=new Offering__c();
        prod.Provider__c = provider.id;
        prod.Parent_Offering__c = parentOffering.id;
        insert prod;
        
        Tag_Offering__c tagOffering = new Tag_Offering__c();
        tagOffering.Tag__c = tag.Id;     
        tagOffering.Offering__c  = prod.id;  
        insert tagOffering;
        
        Tag_Offering__c tagOffering1 = new Tag_Offering__c();
        tagOffering1.Tag__c = tag1.Id;     
        tagOffering1.Offering__c  = prod.id;  
        insert tagOffering1;
        
        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
        cut.Product__c = prod.id;
        cut.Provider__c = provider.id;
        insert cut;
        
        MallProductFrontManagementController.ProductInfo  prodInfo = new MallProductFrontManagementController.ProductInfo(); 
        prodInfo.shopPublished = prod.Provider__r.IsOnline__c;
        prodInfo.productId=prod.Id;
        prodInfo.name=prod.Name;
        List<MallProductFrontManagementController.ProductInfo> result = MallProductFrontManagementController.getProducts(account.Id);
        MallProductFrontManagementController.ProductInfo product = MallProductFrontManagementController.getProductById(parentOffering.Id);

        Assert.areEqual(1, result.size(), 'Expected outcome');
        Assert.areEqual(parentOffering.Id, product.productId, 'Expected outcome');
    }
    
    @isTest
    public static void createProductsTest(){
        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.IsPreview__c = true;
        publishingUnit.Published_from__c = system.today();
        publishingUnit.Published_until__c = system.today()+2;
        insert publishingUnit;
        
        Tag__c langTag = new Tag__c();
        langTag.Name = 'Language';
        insert langTag;
        
        Tag__c engTag = new Tag__c();
        engTag.Name = 'en';
        engTag.Root__c = langTag.id;
        insert engTag;
        engTag.Publishing_Unit__c = publishingUnit.id;
        update engTag;
        
        Tag__c countryTag = new Tag__c();
        countryTag.Name = 'Country';
        countryTag.Publishing_Unit__c = publishingUnit.id;
        
        insert countryTag;
        countryTag.Publishing_Unit__c = publishingUnit.id;
        update countryTag;
        
        
        Tag__c saTag = new Tag__c();
        saTag.Name = 'South Africa';
        saTag.Parent__c = countryTag.id;
        
        insert saTag;
        saTag.Publishing_Unit__c = publishingUnit.id;
        update saTag;
        
        Provider__c pro = new Provider__c();
        pro.name = 'test';
        pro.Publishing_Unit__c = publishingUnit.id;
        insert pro;
        
        Tag__c segment = new Tag__c();
        segment.Name = 'Segment';
        
        insert segment;
        
        Tag__c category = new Tag__c();
        category.Name = 'Category';
        insert category;
        
        Tag__c tag = new Tag__c();
        tag.Name = 'Test Segment';
        tag.Parent__c = segment.id;
        insert tag;
        
        Tag__c tag1 = new Tag__c();
        tag1.Name = 'Test Category';
        tag1.Parent__c = Category.id;
        insert tag1;
        
        
        Offering__c parentOffering=new Offering__c();
        parentOffering.Provider__c = pro.id;
        insert parentOffering;
        
        Offering__c prod=new Offering__c();
        prod.Provider__c = pro.id;
        prod.Parent_Offering__c = parentOffering.id;
        insert prod;
        
        Tag_Offering__c tagOffering = new Tag_Offering__c();
        tagOffering.Tag__c = tag.Id;     
        tagOffering.Offering__c  = prod.id;  
        insert tagOffering;
        
        Tag_Offering__c tagOffering1 = new Tag_Offering__c();
        tagOffering1.Tag__c = tag1.Id;     
        tagOffering1.Offering__c  = prod.id;  
        insert tagOffering1;
        
        
        List<String> productInfos = new List<String>();
        MallProductFrontManagementController.ProductInfo productInfo = new  MallProductFrontManagementController.ProductInfo();
        productInfo.name = 'Test Offering';
        productInfo.providerId = pro.id;
        productInfo.segmentId = tag.id;
        
        productInfos.add(JSON.serialize(productInfo));
        
        Link__c link = new Link__c();
        link.name = 'Test';
        insert link;
        
        productInfo = new  MallProductFrontManagementController.ProductInfo();
        productInfo.name = 'Test Offering';
        productInfo.segmentId = tag.id;
        productInfo.providerId = pro.id;
        productInfo.productId = prod.id;
        productInfo.linkId = link.id;
        productInfo.publishingUnitId = publishingUnit.Id;

        productInfos.add(JSON.serialize(productInfo));
        
        MallProductFrontManagementController.saveProduct(productInfos);
        MallProductFrontManagementController.publishProduct(productInfos);
        MallProductFrontManagementController.unpublishProduct(new List<Id> {prod.id});
        Assert.areEqual('Test Offering', productInfo.name, 'expected productInfo name');
    }
    
    
    @isTest
    public static void submitForApprovaltTest(){
        UserRole portalRole = [Select Id From UserRole where Name = 'CIB Global Non SBG Division' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User u = new User();
        u.federationIdentifier = 'abcx';
        u.FirstName='superman';
        u.LastName='lasttestuser';
        u.alias='testuser';
        u.LastName = 'User1';
        u.UserRoleId = portalRole.id;
        u.ProfileId=profile1.id;
        u.Email = 'testUser11111@test.com';
        u.username='supermanuser1@test.com';
        u.State='Western Cape';
        u.Business_Unit__c='Bank Sector';
        u.Country='South Africa';
        u.City='Cape Town';
        u.User_Division__c='Business Banking';
        u.User_CIB_Global_Area__c='CIBI';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        u.emailEncodingKey = 'ISO-8859-1';
        insert u;    
        
        System.runAs(u) {
            Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
            publishingUnit.IsPreview__c = true;
            publishingUnit.Published_from__c = system.today();
            publishingUnit.Published_until__c = system.today()+2;
            insert publishingUnit;
            
            Tag__c langTag = new Tag__c();
            langTag.Name = 'Language';
            insert langTag;
            
            Tag__c engTag = new Tag__c();
            engTag.Name = 'en';
            engTag.Root__c = langTag.id;
            insert engTag;
            engTag.Publishing_Unit__c = publishingUnit.id;
            update engTag;
            
            Tag__c countryTag = new Tag__c();
            countryTag.Name = 'Country';
            countryTag.Publishing_Unit__c = publishingUnit.id;
            
            insert countryTag;
            countryTag.Publishing_Unit__c = publishingUnit.id;
            update countryTag;
            
            
            Tag__c saTag = new Tag__c();
            saTag.Name = 'South Africa';
            saTag.Parent__c = countryTag.id;
            
            insert saTag;
            saTag.Publishing_Unit__c = publishingUnit.id;
            update saTag;
            
            Provider__c pro = new Provider__c();
            pro.name = 'test';
            pro.Publishing_Unit__c = publishingUnit.id;
            insert pro;
            
            Tag__c segment = new Tag__c();
            segment.Name = 'Segment';
            
            insert segment;
            
            
            Tag__c category = new Tag__c();
            category.Name = 'Category';
            insert category;
            
            Tag__c tag = new Tag__c();
            tag.Name = 'Test Segment';
            tag.Parent__c = segment.id;
            insert tag;
            
            Tag__c tag1 = new Tag__c();
            tag1.Name = 'Test Category';
            tag1.Parent__c = Category.id;
            insert tag1;
            
            
            Offering__c parentOffering=new Offering__c();
            parentOffering.Provider__c = pro.id;
            insert parentOffering;
            
            Link__c link = new Link__c();
            link.name = 'Test';
            insert link;
            
            Offering__c prod=new Offering__c();
            prod.Provider__c = pro.id;
            prod.Status__c = 'Draft';
            prod.Parent_Offering__c = parentOffering.id;
            insert prod;
            
            Tag_Offering__c tagOffering = new Tag_Offering__c();
            tagOffering.Tag__c = tag.Id;     
            tagOffering.Offering__c  = prod.id;  
            insert tagOffering;
            
            Tag_Offering__c tagOffering1 = new Tag_Offering__c();
            tagOffering1.Tag__c = tag1.Id;     
            tagOffering1.Offering__c  = prod.id;  
            insert tagOffering1;
            
            MallProductFrontManagementController.newProducts = new List<Offering__c>{prod};
            
            
            List<String> productInfos = new List<String>();
            MallProductFrontManagementController.ProductInfo productInfo = new  MallProductFrontManagementController.ProductInfo();
            productInfo.name = 'Test Offering';
            productInfo.providerId = pro.id;
            productInfo.segmentId = tag.id;
            
            productInfos.add(JSON.serialize(productInfo));
            
            productInfo = new  MallProductFrontManagementController.ProductInfo();
            productInfo.name = 'Test Offering';
            productInfo.segmentId = tag.id;
            productInfo.providerId = pro.id;
            productInfo.productId = prod.id;
            productInfo.linkId = link.id;
        	productInfo.publishingUnitId = publishingUnit.Id;
            productInfos.add(JSON.serialize(productInfo));
            
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setProcessDefinitionNameOrId('Content_update_Submitted_by_Worker');
            requests.add(req);
            
            Test.startTest();
            MallProductFrontManagementController.submitForApproval(productInfos);
            Assert.areEqual('Test Offering', productInfo.name, 'expected productInfo name');
            Test.stopTest();            
        }        
       
    }
    
    @isTest
    public static void recallProductsTest(){
        List<Id> productIds = new List<Id>();
        Test.startTest();
        MallProductFrontManagementController.recallProducts(productIds);
        List<Offering__c> offerings = SEL_Offerings.newInstance().selectByCustomFilterCondition('Id != NULL');
        Assert.areEqual(0, offerings.size(), 'expected image link');
        Test.stopTest();            
    }
    
    @isTest
    public static void testUploadImage(){
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        ContentVersion cv1=new Contentversion();
        cv1.title='ABC';
        cv1.PathOnClient ='test';
        cv1.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv1;
        Test.startTest();
        String imageLink = MallProductFrontManagementController.handleImageUpload(cv1.Id);
        Assert.areNotEqual(true, String.IsBlank(imageLink), 'expected image link');
        Test.stopTest();            
    }    

    
    @IsTest
    public static void testUpdateSobject() {
        Link__c link =  new Link__c();
        insert link;
        Test.startTest();
        MallProductFrontManagementController.updateSObjects(new List<Link__c>{link});
        List<Link__c> links = SEL_Links.newInstance().selectByCustomFilterCondition('Id != NULL');
        Assert.areNotEqual(0, links.size(), 'expected image link');
        Test.stopTest();            
    }
}