/**
 * @author Emmanuel Mulea Nocks
 * @date March 2023
 * @description  This class is a test class for AOB_SAP_ReferenceDataBatch
 */
@isTest
public class AOB_SAP_ReferenceDataBatch_Test {
	private static User adminUser {
		get {
			if (adminUser == null) {
		
                    adminUser = (User)new BLD_USER()
                    .useSysAdmin()
                    .syncContact()
                    .getRecord();
				
			}
			return adminUser;
		}
		Set;
	}
	@TestSetup
	private static void setup() {

        AOB_ReferencedData__c refDataParent = new AOB_ReferencedData__c(
            AOB_Code__c='2002',
            AOB_CountryCode__c= 'ZA',
            AOB_Default__c = false,
            AOB_Language__c = 'en_US',
            AOB_SAPExternalID__c='BRANCH2002en_US',
            AOB_SAPField__c = 'BRANCH',
            AOB_isActive__c = true,
            AOB_Value__c = '00000'
        );
        insert refDataParent;
        AOB_ReferencedData__c refDataChild = new AOB_ReferencedData__c(
            AOB_Code__c='2004',
            AOB_CountryCode__c= 'ZA',
            AOB_Default__c = false,
            AOB_Language__c = 'en_US',
            AOB_SAPExternalID__c='BRANCH2004en_US',
            AOB_SAPField__c = 'BRANCH',
            AOB_isActive__c = true,
            AOB_Value__c = '2002'
        );
        insert refDataChild;

	}
    @isTest
    private static void runBatch() {

        System.runAs(adminUser)
        {
            Test.startTest();
            AOB_SAP_ReferenceDataBatch rdb = new AOB_SAP_ReferenceDataBatch();
            rdb.execute(null);
            Database.executeBatch(new AOB_SAP_ReferenceDataBatch());
            Test.stopTest();
        }
        List<AOB_ReferencedData__c> refDataWithParent = [SELECT Id FROM AOB_ReferencedData__c Where AOB_Parent__c != null];
		Assert.areEqual(refDataWithParent.size(), 1);
	}
}