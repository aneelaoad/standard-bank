/**
 * 
 * @description Test Class for MallServiceFrontQuicklinksCtrl_Test
 * @author Ankit Kumar  
 * @since 
 */


@isTest
public with sharing class MallServiceFrontQuicklinksCtrl_Test {

    @TestSetup
    static void makeData() {
        List < Tag__c > categories = MallTestDataFactory.createCategories();
        Tag__c langTag = new Tag__c();
        langTag.Position__c = 1;
        langTag.Name = 'Language';
        insert langTag;

        Tag__c engTag = new Tag__c();
        engTag.Root__c = langTag.id;
        engTag.Name = 'en';
        insert engTag;

        //insert publishing unit
        Publishing_unit__c pu = new Publishing_unit__c(isPublished__c = true, Published_From__c = System.today(), Published_Until__c = (System.today()).AddDays(1));
        insert pu;

        List < Offering__c > offeringsToInsert = new List < Offering__c > ();
        for (Provider__c store: MallTestDataFactory.createShops()) {
            Offering__c service = new Offering__c(name = 'test service', Publishing_unit__c = pu.Id, Status__c = 'Published');
            offeringsToInsert.add(service);
        }
        insert offeringsToInsert;


        List < Content_Unit_Translation__c > translationsToInsert = new List < Content_Unit_Translation__c > ();
        List < Tag_Offering__c > tagOfferingsToInsert = new List < Tag_Offering__c > ();
        List < Link__c > linksToInsert = new List < Link__c > ();
        List < Shortcut__c > shortcutsToInsert = new List < Shortcut__c > ();

        //insert content unit
        Content_Unit__c icon = new Content_Unit__c(hasImage__c = true);
        insert icon;
        Content_Unit_Translation__c iconTranslation = new Content_Unit_Translation__c(Content_Unit__c = icon.Id, Language__c = engTag.Id);
        translationsToInsert.add(iconTranslation);

        for (Offering__c service: offeringsToInsert) {
            Content_Unit_Translation__c translation = new Content_Unit_Translation__c(Product__c = service.Id, Title__c = service.name, Language__c = engTag.Id);
            translationsToInsert.add(translation);
            Tag_Offering__c tagOffering = new Tag_Offering__c(Tag__c = categories[0].Id, Offering__c = service.Id);
            tagOfferingsToInsert.add(tagOffering);
            Link__c link = new Link__c(name = 'test link', Offering__c = offeringsToInsert[0].Id, Icon__c = icon.Id, status__c = 'Draft', Desktop_Url__c = 'https://test.com');
            linksToInsert.add(link);
        }

        insert tagOfferingsToInsert;
        insert linksToInsert;

        for (Link__c link: linksToInsert) {
            Content_Unit_Translation__c translation = new Content_Unit_Translation__c(Link__c = link.Id, Title__c = 'test link', Language__c = engTag.Id);
            translationsToInsert.add(translation);
            Shortcut__c shortcut = new Shortcut__c(Link__c = link.Id, User__c = UserInfo.getUserId());
            shortcutsToInsert.add(shortcut);
        }

        insert translationsToInsert;
        insert shortcutsToInsert;
    }


    @istest
    static void getApprovalHistoryByLinkIdsTest() {
        List < Link__c > links = SEL_Links.newInstance().selectByCustomFilterCondition('Id != NULL');
        List < String > linkIds = new List < String > ();
        for (Link__c link: links) {
            linkIds.add(link.Id);
        }
        Test.startTest();
        List < ProcessInstanceStep > result = MallServiceFrontQuicklinksCtrl.getApprovalHistoryByLinkIds(linkIds);
        Assert.areEqual(0, result.size(), '0 approval history');
        try {
            MallServiceFrontQuicklinksCtrl.getApprovalHistoryByLinkIds(NULL);
        } catch (Exception e) {
            MallExceptionUtil.throwAuraException('exception test', e);
            assert.areNotEqual(NULL, e, 'error expected');
        }
        Test.stopTest();
    }

    @Istest
    static void getQuickLinksTest() {
        List < Offering__c > offerings = SEL_Offerings.newInstance().selectByCustomFilterCondition('Id != NULL');
        List < String > offeringIds = new List < String > ();
        for (Offering__c offering: offerings) {
            offeringIds.add(offering.Id);
        }
        Test.startTest();
        List < MallServiceFrontQuicklinksCtrl.QuickLinkInfo > result = MallServiceFrontQuicklinksCtrl.getQuickLinks(offeringIds[0]);
        Assert.areEqual(2, result.size(), '2 quick link');
        try {
            MallServiceFrontQuicklinksCtrl.getQuickLinks(NULL);
        } catch (Exception e) {
            MallExceptionUtil.throwAuraException('exception test', e);
            assert.areNotEqual(NULL, e, 'error expected');
        }
        Test.stopTest();
    }

    @Istest
    static void saveQuicklinksTest() {
        List < Link__c > links = SEL_Links.newInstance().selectByCustomFilterCondition('Id != NULL');
        List < MallServiceFrontQuicklinksCtrl.QuickLinkInfo > linkInfos = new List < MallServiceFrontQuicklinksCtrl.QuickLinkInfo > ();
        for (Link__c link: links) {
            MallServiceFrontQuicklinksCtrl.QuickLinkInfo info = new MallServiceFrontQuicklinksCtrl.QuickLinkInfo();
            info.name = link.name;
            info.desktopUrl = link.Desktop_Url__c;
            linkInfos.add(info);
        }
        Test.startTest();
        MallServiceFrontQuicklinksCtrl.saveQuicklinks(System.JSON.serialize(linkInfos));
        List < MallServiceFrontQuicklinksCtrl.QuickLinkInfo > result = MallServiceFrontQuicklinksCtrl.getQuickLinks(links[0].Offering__c);
        Assert.areEqual(2, result.size(), '2 quick link');
        try {
            MallServiceFrontQuicklinksCtrl.saveQuicklinks(System.JSON.serialize(NULL));
        } catch (Exception e) {
            MallExceptionUtil.throwAuraException('exception test', e);
            assert.areNotEqual(NULL, e, 'error expected');
        }
        Test.stopTest();
    }

    @istest
    static void submitQuickLinksForApprovalTest() {
        List < Link__c > links = SEL_Links.newInstance().selectByCustomFilterCondition('Id != NULL');
        List < String > linkInfosString = new List < String > ();
        List < String > linkIds = new List < String > ();
        for (Link__c link: links) {
            MallServiceFrontQuicklinksCtrl.QuickLinkInfo info = new MallServiceFrontQuicklinksCtrl.QuickLinkInfo();
            info.name = link.name;
            info.desktopUrl = link.Desktop_Url__c;
            linkInfosString.add(System.JSON.serialize(info));
            linkIds.add(link.Id);
        }
        Test.startTest();
        MallServiceFrontQuicklinksCtrl.submitQuickLinksForApproval(linkInfosString, true);
        MallServiceFrontQuicklinksCtrl.recallQuickLinks(linkIds);
        List < MallServiceFrontQuicklinksCtrl.QuickLinkInfo > result = MallServiceFrontQuicklinksCtrl.getQuickLinks(links[0].Offering__c);
        Assert.areEqual(2, result.size(), '2 quick link');
        Test.stopTest();
    }

    @istest
    static void submitQuickLinksForApprovalTest2() {
        List < Link__c > links = SEL_Links.newInstance().selectByCustomFilterCondition('Id != NULL');
        List < String > linkInfosString = new List < String > ();
        List < String > linkIds = new List < String > ();
        for (Link__c link: links) {
            MallServiceFrontQuicklinksCtrl.QuickLinkInfo info = new MallServiceFrontQuicklinksCtrl.QuickLinkInfo();
            info.name = link.name;
            info.desktopUrl = link.Desktop_Url__c;
            linkInfosString.add(System.JSON.serialize(info));
            linkIds.add(link.Id);
        }
        Test.startTest();
        try {
            MallServiceFrontQuicklinksCtrl.submitQuickLinksForApproval(linkInfosString, false);
            MallServiceFrontQuicklinksCtrl.recallQuickLinks(linkIds);
        } catch (Exception e) {
            MallExceptionUtil.throwAuraException('exception test', e);
            assert.areNotEqual(NULL, e, 'error expected');
        }
        Test.stopTest();
    }

    @istest
    static void publishQuickLinksTest() {
        List < Link__c > links = SEL_Links.newInstance().selectByCustomFilterCondition('Id != NULL');
        List < Id > linkIds = new List < Id > ();
        for (Link__c link: links) {
            linkIds.add((Id) link.Id);
        }
        Test.startTest();
        MallServiceFrontQuicklinksCtrl.publishQuickLinks(linkIds);
        try {
            MallServiceFrontQuicklinksCtrl.publishQuickLinks(NULL);
        } catch (Exception e) {
            MallExceptionUtil.throwAuraException('exception test', e);
            assert.areNotEqual(NULL, e, 'error expected');
        }
        Test.stopTest();
    }

    @IsTest
    static void testException() {
        try {
            Contact c = new Contact();
            insert c;
        } catch (Exception e) {
            MallExceptionUtil.throwAuraException('exception test', e);
            assert.areNotEqual(NULL, e, 'error expected');
        }
    }
}