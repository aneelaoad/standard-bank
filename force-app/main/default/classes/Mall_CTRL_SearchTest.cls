/**
 * 
 * @description Test Class for Mall_CTRL_Search class
 * @author Maham Hassan
 * @since 
 */
@isTest
public with sharing class Mall_CTRL_SearchTest {

    @IsTest
    static void getSearchResultsTest(){            
        Tag__c tg1 = new Tag__c();
        tg1.Position__c=1;
        tg1.Name='Language';
        Insert tg1;
        
        Tag__c tgLang = new Tag__c();
        tgLang.Position__c=1;
        tgLang.Name='en';
        tgLang.Parent__c = tg1.Id;
        tgLang.Root__c = tg1.Id;
        Insert tgLang;
    
        Tag__c categoryTag = new Tag__c();
        categoryTag.Position__c=1;
        categoryTag.Name='Category';
        Insert categoryTag;
        
        Tag__c bankCategory = new Tag__c();
        bankCategory.Position__c=1;
        bankCategory.Parent__c = categoryTag.Id;
        bankCategory.Root__c = categoryTag.Id;
        bankCategory.Name='Bank';
        Insert bankCategory;
        
        Tag__c parentTag = new Tag__c();
        parentTag.Position__c=1;
        parentTag.Name='Country';
        Insert parentTag;

        Tag__c tagCountry = new Tag__c();
        tagCountry.Position__c=1;
        tagCountry.Parent__c = parentTag.Id;
        tagCountry.Name='South Africa';
        Insert tagCountry;
        
        Tag__c tgSol = new Tag__c();
        tgSol.Position__c=1;
        tgSol.Name='Solutions';
        Insert tgSol;
        
        Tag__c tgSol1 = new Tag__c();
        tgSol1.Position__c=1;
        tgSol1.Name='Business loans';
        tgSol1.Parent__c = tgSol.Id;
        tgSol1.Root__c = tgSol.Id;
        Insert tgSol1;
        
        Tag__c tgSol2 = new Tag__c();
        tgSol2.Position__c=1;
        tgSol2.Name='Credit cards';
        tgSol2.Parent__c = tgSol.Id;
        tgSol2.Root__c = tgSol.Id;
        Insert tgSol2;

        Link__c link = new Link__c();
        link.Desktop_url__c = 'www.google.com';
        link.Guest_url__c = 'www.google.com';
        link.Mobile_url__c = 'www.google.com';
        insert link;

        //Create Provider
        Provider__c provider= new Provider__c();
        provider.Name = 'Test Search Provider';
        provider.Link__c = link.Id;
        insert provider;

        //Create publishing unit
        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.IsPreview__c = true;
        publishingUnit.Published_from__c = System.now()-2;
        publishingUnit.Published_until__c = System.now()+10;
        insert publishingUnit;
        
        //Create offerings
        List<Offering__c> offerings = new List<Offering__c>();
        String serviceRecordType = Schema.getGlobalDescribe().get('Offering__c').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Offering__c prod1= new Offering__c();
        prod1.Name='Test Search Offering';
        prod1.Provider__c= provider.id;
        prod1.RecordTypeId = serviceRecordType;
        prod1.Link__c =link.id;
        offerings.add(prod1);

        Offering__c prod2= new Offering__c();
        prod2.Name='Test Search Offering 1';
        prod2.Provider__c=provider.id;
        prod2.RecordTypeId = serviceRecordType;
        prod2.Link__c =link.id;
        offerings.add(prod2);
        
        String guidedSolutionRecordTypeId = Schema.getGlobalDescribe().get('Offering__c').getDescribe().getRecordTypeInfosByName().get('Guided Solution').getRecordTypeId();
        Offering__c prod3= new Offering__c();
        prod3.Name='Test Search Guided solutions';
        prod3.Provider__c=provider.id;
        prod3.RecordTypeId = guidedSolutionRecordTypeId;
        prod3.Link__c =link.id;
        offerings.add(prod3);

        insert offerings;

        //Create event
        Business_Event__c event = new Business_Event__c();
        event.Name='Test Event';
        event.Start_Date__c= System.now()-2;
        event.End_Date__c= System.now() + 2;
        event.Link__c = link.Id;
        insert event;
        
        List<Tag_Business_Event__c> tagEventlist= new List<Tag_Business_Event__c>();
        Tag_Business_Event__c tgEvent0 = new Tag_Business_Event__c();
        tgEvent0.Business_Event__c = event.id;
        tgEvent0.Tag__c=bankCategory.id;
        tagEventlist.add(tgEvent0);

        Tag_Business_Event__c tgEvent1 = new Tag_Business_Event__c();
        tgEvent1.Business_Event__c = event.id;
        tgEvent1.Tag__c=tagCountry.id;
        tagEventlist.add(tgEvent1);

        insert tagEventlist;

        List<Tag_Provider__c> shoplist= new List<Tag_Provider__c>();
        
        Tag_Provider__c tgshop0 = new Tag_Provider__c();
        tgshop0.Provider__c= provider.id;
        tgshop0.Tag__c=tagCountry.id;
        shoplist.add(tgshop0);
        
        Tag_Provider__c tgshop01 = new Tag_Provider__c();
        tgshop01.Provider__c= provider.id;
        tgshop01.Tag__c= bankCategory.id;            
        shoplist.add(tgshop01);
        
        insert shoplist;
        
        List<Tag_Offering__c> tagOfferingLst = new List<Tag_Offering__c>();
        Tag_Offering__c tagp= new Tag_Offering__c();
        tagp.Offering__c=prod1.id;
        tagp.Tag__c=tagCountry.id;
        tagOfferingLst.add(tagp);
        
        Tag_Offering__c tagp01= new Tag_Offering__c();
        tagp01.Offering__c=prod1.id;
        tagp01.Tag__c=bankCategory.id;
        tagOfferingLst.add(tagp01);

        Tag_Offering__c tagp02= new Tag_Offering__c();
        tagp02.Offering__c=prod1.id;
        tagp02.Tag__c=tgSol1.id;
        tagOfferingLst.add(tagp02);

        Tag_Offering__c tagp1= new Tag_Offering__c();
        tagp1.Offering__c=prod2.id;
        tagp1.Tag__c=tagCountry.id;
        tagOfferingLst.add(tagp1);
        
        Tag_Offering__c tagp11= new Tag_Offering__c();
        tagp11.Offering__c=prod2.id;
        tagp11.Tag__c=bankCategory.id;
        tagOfferingLst.add(tagp11);

        Tag_Offering__c tagp12= new Tag_Offering__c();
        tagp12.Offering__c=prod2.id;
        tagp12.Tag__c=tgSol1.id;
        tagOfferingLst.add(tagp12);

        Tag_Offering__c tagp2= new Tag_Offering__c();
        tagp2.Offering__c=prod3.id;
        tagp2.Tag__c=tagCountry.id;
        tagOfferingLst.add(tagp2);
        
        Tag_Offering__c tagp21= new Tag_Offering__c();
        tagp21.Offering__c=prod3.id;
        tagp21.Tag__c=bankCategory.id;
        tagOfferingLst.add(tagp21);

        Tag_Offering__c tagp22= new Tag_Offering__c();
        tagp22.Offering__c=prod2.id;
        tagp22.Tag__c=tgSol1.id;
        tagOfferingLst.add(tagp22);
        
        insert(tagOfferingLst);	
        
        Tag__c tag2 = new Tag__c();
        tag2.Root__c = tg1.id;
        insert tag2;

        List<Content_Unit_Translation__c> contents = new List<Content_Unit_Translation__c>();
        Content_Unit_Translation__c cut= new Content_Unit_Translation__c();
        cut.Language__c=tgLang.id;
        cut.Product__c=prod1.id;
        cut.Title__c = 'Test Search Product';
        cut.Text__c = 'Test Search Product';
        cut.RichText__c = 'Rich Test Search Content Unit';
        cut.Image_Url__c = 'https://google.com';
        contents.add(cut);

        Content_Unit_Translation__c cut1 = new Content_Unit_Translation__c();
        cut1.Language__c=tgLang.id;
        cut1.Provider__c= provider.id;
        cut1.Title__c = 'Test Search Provider';
        cut1.Text__c = 'Test Search Provider';
        cut1.RichText__c = 'Rich Test Search Content Unit';
        cut1.Image_Url__c = 'https://google.com';
        contents.add(cut1);
        
        Content_Unit_Translation__c cut2 = new Content_Unit_Translation__c();
        cut2.Language__c=tgLang.id;
        cut2.Tag__c= tgSol1.id;
        cut2.Title__c = 'Test Search Business loans';
        cut2.Text__c = 'Test Search Business loans';
        cut2.RichText__c = 'Rich Test Search Content Unit';
        cut2.Image_Url__c = 'https://google.com';
        contents.add(cut2);

        Content_Unit_Translation__c cut3 = new Content_Unit_Translation__c();
        cut3.Language__c=tgLang.id;
        cut3.Business_Event__c=event.id;
        cut3.Title__c = 'Test Search Event';
        cut3.Text__c = 'Test Search Event';
        cut3.RichText__c = 'Rich Test Search Content Unit';
        cut3.Image_Url__c = 'https://google.com';
        contents.add(cut3);

        Content_Unit_Translation__c cut4 = new Content_Unit_Translation__c();
        cut4.Language__c=tgLang.id;
        cut4.Product__c= prod3.id;
        cut4.Title__c = 'Test Search Guided solutions';
        cut4.Text__c = 'Test Search Guided solutions';
        cut4.RichText__c = 'Rich Test Search Content Unit';
        cut4.Image_Url__c = 'https://google.com';
        contents.add(cut4);

        
        insert contents;
        
        List<Id> cuts = new List<Id>();
        cuts.add(cut.Id);
        cuts.add(cut1.Id);
        cuts.add(cut2.Id);
        cuts.add(cut3.Id);
        cuts.add(cut4.Id);

        provider.Publishing_Unit__c = publishingUnit.Id;
        update provider;
        
        prod1.Publishing_Unit__c = publishingUnit.Id;
        prod2.Publishing_Unit__c = publishingUnit.Id;
        prod3.Publishing_Unit__c = publishingUnit.Id;
        List<Offering__c> offeringsUpdated = new List<Offering__c>();
        offeringsUpdated.add(prod1);
        offeringsUpdated.add(prod2);
        offeringsUpdated.add(prod3);

        update offeringsUpdated;
        
        event.Publishing_Unit__c = publishingUnit.Id;
        update event;


        Id [] fixedSearchResults= new Id[9];
        fixedSearchResults[0] = cut.Id;
        fixedSearchResults[1] = cut1.Id;
        fixedSearchResults[2] = cut2.Id;
        fixedSearchResults[3] = cut3.Id;
        fixedSearchResults[4] = cut4.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
        Map<String,Object> searchResult = Mall_CTRL_Search.getSearchResults('Test Search');
        String extractedWord = Mall_CTRL_Search.extractWords('Test', '<p>Test Search Product, Services, Providers and Offerings</p>', 3, 8); 
        Assert.isTrue(String.IsNotBlank(extractedWord), 'should not be blank');
        Test.stopTest();

        List<Mall_CTRL_Search.SearchData> searchProducts = (List<Mall_CTRL_Search.SearchData>) searchResult.get('Products');
        List<Mall_CTRL_Search.SearchData> searchShops = (List<Mall_CTRL_Search.SearchData>) searchResult.get('Shops');
        
        if(searchProducts.size() > 0) {
            Assert.areEqual(searchProducts.get(0).title, 'Test Search Product', 'should be equal');    
        }

        if(searchShops.size() > 0) {
            Assert.areEqual(searchShops.get(0).title, 'Test Search Provider', 'should be equal');    
        }
    }
}