@IsTest
private class DrawDownProfileDatePopulator_Ctrlr_Test {

    private static final String USER_NAME = '3iu432890ujiojsdur89043u@testdwadwada.com';
    private static User cibUser {
        get {
            if (cibUser == null) {
                cibUser = [SELECT Id FROM User WHERE UserName = :USER_NAME];
            }
            return cibUser;
        }
        set;
    }
    private static final Integer RECORDS_NUMBER = 5;

    @TestSetup
    static void setup() {

        new BLD_USER(USER_NAME).useCib().commitWork();

        System.runAs(cibUser) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Product prodBld = new BLD_Product(uow)
                .linkToOpp(new BLD_Opportunity(uow));

            BLD_DrawDownProfile[] ddBuilders = new BLD_DrawDownProfile[]{};
            for (Integer i = 0; i < RECORDS_NUMBER; i++) {
                ddBuilders.add(
                    new BLD_DrawDownProfile(uow).linkToProduct(prodBld)
                );
            }

            uow.commitWork();
        }
    }

    @IsTest
    static void testConstructor() {
        SelectOption[] expectedOptions = new SelectOption[]{
            new SelectOption('0', '-- SELECT ONE --')
        };
        expectedOptions.addAll(
            UTL_GlobalPicklistValues.getPicklist(DMN_DrawDownProfile.FREQUENCIES_PICKLIST_CATEGORY));
        DrawDownProfileDatePopulator_Ctrlr ctrlr;
        System.runAs(cibUser) {
            Test.startTest();
            ctrlr = new DrawDownProfileDatePopulator_Ctrlr();
            Test.stopTest();
        }

        System.assertEquals(expectedOptions, ctrlr.drawDownProfilesFrequencies);
    }

    @IsTest
    static void shouldPopulateDDProfilesAndExistingProfiles() {
        Draw_Down_Profile__c[] profiles = [SELECT Id FROM Draw_Down_Profile__c];
        DrawDownProfileDatePopulator_Ctrlr ctrlr;
        System.runAs(cibUser) {
            Test.startTest();
            ctrlr = new DrawDownProfileDatePopulator_Ctrlr();
            ctrlr.ddProfiles = profiles;
            Test.stopTest();
        }

        System.assertEquals(profiles, ctrlr.ddProfiles);
        System.assertEquals(profiles, ctrlr.existingProfiles);
    }

    @IsTest
    static void shouldPopulateOneDdp() {
        Draw_Down_Profile__c[] profiles = [SELECT Draw_Date__c FROM Draw_Down_Profile__c];
        DrawDownProfileDatePopulator_Ctrlr ctrlr;
        System.runAs(cibUser) {
            Test.startTest();
            ctrlr = new DrawDownProfileDatePopulator_Ctrlr();
            ctrlr.ddProfiles = profiles;
            ctrlr.startDate.Date_Field__c = System.today();
            ctrlr.endDate.Date_Field__c = ctrlr.startDate.Date_Field__c.addDays(1);
            ctrlr.selectedFrequency = 1;
            ctrlr.createDrawDownProfiles();
            Test.stopTest();
        }

        System.assertEquals(1, ctrlr.ddProfiles.size());
        System.assertEquals(profiles[0].Id, ctrlr.ddProfiles[0].Id);
        System.assertEquals(System.today(), ctrlr.ddProfiles[0].Draw_Date__c);
        System.assertEquals(RECORDS_NUMBER, ctrlr.existingProfiles.size());
    }

    @IsTest
    static void shouldAddPageMessage() {
        Draw_Down_Profile__c[] profiles = [SELECT Draw_Date__c FROM Draw_Down_Profile__c];
        DrawDownProfileDatePopulator_Ctrlr ctrlr;
        System.runAs(cibUser) {
            Test.startTest();
            ctrlr = new DrawDownProfileDatePopulator_Ctrlr();
            ctrlr.ddProfiles = profiles;
            ctrlr.startDate = null;
            ctrlr.endDate = null;
            ctrlr.selectedFrequency = 0;
            System.assert(!ApexPages.hasMessages());
            ctrlr.createDrawDownProfiles();
            System.assert(ApexPages.hasMessages());
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldCreateNewProfilesWithProduct() {
        Draw_Down_Profile__c[] profiles = [SELECT Draw_Date__c FROM Draw_Down_Profile__c];
        SB_Product__c prod = [SELECT Id FROM SB_Product__c];
        DrawDownProfileDatePopulator_Ctrlr ctrlr;
        System.runAs(cibUser) {
            Test.startTest();
            ctrlr = new DrawDownProfileDatePopulator_Ctrlr();
            ctrlr.ddProfiles = profiles;
            ctrlr.prodId = prod.Id;
            ctrlr.startDate.Date_Field__c = System.today();
            ctrlr.endDate.Date_Field__c = ctrlr.startDate.Date_Field__c.addMonths(RECORDS_NUMBER * 2);
            ctrlr.selectedFrequency = 1;
            ctrlr.createDrawDownProfiles();
            Test.stopTest();
        }

        System.assertEquals(RECORDS_NUMBER * 2 + 1, ctrlr.ddProfiles.size());
        for (Integer i = 0; i < ctrlr.ddProfiles.size(); i++) {
            System.assertEquals(System.today().addMonths(i), ctrlr.ddProfiles[i].Draw_Date__c);
            if (ctrlr.ddProfiles[i].Id == null) {
                System.assertEquals(prod.Id, ctrlr.ddProfiles[i].Product__c);
            }
        }


    }

}