@IsTest
class Develop_Prospect_LEX_Controller_Test {

    @IsTest
    static void shouldNotContainMarketSegments() {
        Develop_Prospect_LEX_Controller ctrlr;
        System.runAs((User) new BLD_USER().useCib().commitWork().getRecord()) {
            Test.startTest();
            ctrlr = Develop_Prospect_LEX_Controller.getComponentAttributes();
            Test.stopTest();
        }
        System.assertEquals(UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT), ctrlr.potentialClientRecordTypeId);
        System.assertEquals(Develop_Prospect_LEX_Controller.DESIRED_FIELDS.size()-1, ctrlr.fieldsToQuery.size());
        System.assert( !ctrlr.fieldsToQuery.contains('Market_Segments__c'));
    }

    @IsTest
    static void fieldsToQueryShouldBeEqual() {
        Develop_Prospect_LEX_Controller ctrlr;
        System.runAs((User) new BLD_USER().useCommB().commitWork().getRecord()) {
            Test.startTest();
            ctrlr = Develop_Prospect_LEX_Controller.getComponentAttributes();
            Test.stopTest();
        }
        System.assertEquals(UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT), ctrlr.potentialClientRecordTypeId);
        System.assertEquals(Develop_Prospect_LEX_Controller.DESIRED_FIELDS.size(), ctrlr.fieldsToQuery.size());
    }
    
}