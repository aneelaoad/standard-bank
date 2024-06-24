@IsTest
private class BCH_PopulateClientsSector_Test {

    private static final String USER_NAME = '3iu432890ujiojsdur89043u@testdwadwada.com';
    private static final String KNOWN_SECTOR = 'Known Sector';
    private static User commBUser {
        get {
            if (commBUser == null) {
                commBUser = [SELECT Id FROM User WHERE UserName = :USER_NAME];
            }
            return commBUser;
        }
    }

    @TestSetup
    static void setup() {
        new BLD_USER(USER_NAME)
                .useCommB()
                .setField(User.User_Division__c, 'Commercial Banking')
                .commitWork();

        System.runAs(commBUser) {

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            new BLD_Account(uow)
                    .CIF('testCif1')
                    .setField(Account.Name, 'dwadawdawdfdfewafdea')
                    .setField(Account.Industry_Code__c, '00001')
                    .setField(Account.Client_Sector__c, 'Unknown Sector')
                    .setField(Account.Client_Sub_Sector__c, 'Unknown Sub-Sector')
                    .setField(Account.Primary_Relationship_Holder__c, 'Commercial Banking')
                    .setField(Account.CIF_Client_Type__c, 'R');

            new BLD_Account(uow)
                    .CIF('testCif2')
                    .setField(Account.Name, 'lijlihkliiuliuh')
                    .setField(Account.Industry_Code__c, 'dwadwadwad')
                    .setField(Account.Client_Sector__c, 'Unknown Sector')
                    .setField(Account.Client_Sub_Sector__c, 'Unknown Sub-Sector')
                    .setField(Account.Primary_Relationship_Holder__c, 'Commercial Banking')
                    .setField(Account.CIF_Client_Type__c, 'R');

            uow.commitWork();
        }

        insert new ISIC_Mapping_Client_Sector__c(
            Name = '00001'
            , Client_Sector__c = KNOWN_SECTOR
            , Client_Sub_Sector__c = 'Known Sub-Sector'
        );
    }

    @IsTest
    static void test() {
        Test.startTest();
            BCH_PopulateClientsSector batch = new BCH_PopulateClientsSector(new String[]{'bartosz.j.sliwinski+testRun@gmail.com'});
            Database.executeBatch(batch, 40);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Client_Sector__c = :KNOWN_SECTOR]);
    }

}