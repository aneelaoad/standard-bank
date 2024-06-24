/*************************************************************************
    @ Author        : psvestka
    @ Date          : 22. 7. 2015
    @ Description   : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By      : Petr Svestka
    @ Last Modified On      : 11 - Aug - 2015
    @ Last Modified Reason  : added test data
****************************************************************************/

@IsTest
private class ClientOperatingCountryControllerTest {

    @TestSetup
    private static void prepareData() {
        List<CS_Client_Operating_Countries__c> countries = new List<CS_Client_Operating_Countries__c> {
                new CS_Client_Operating_Countries__c(name = '1', CIB_Presence__c = false, Country_Name__c = 'Afghanistan'),
                new CS_Client_Operating_Countries__c(name = '2', CIB_Presence__c = false, Country_Name__c = 'Albania'),
                new CS_Client_Operating_Countries__c(name = '3', CIB_Presence__c = true, Country_Name__c = 'Angola')
            };

        insert countries;
    }

    private static testmethod void fetchValuesWithoutSoql() {
        //old approach - SOQL
        Map<String, CS_Client_Operating_Countries__c> CS_COC_Map = new Map <String, CS_Client_Operating_Countries__c> ();
        List<CS_Client_Operating_Countries__c> lstCountries = new List<CS_Client_Operating_Countries__c>();
        for(CS_Client_Operating_Countries__c cOC : [SELECT name,CIB_Presence__c,Country_Name__c from CS_Client_Operating_Countries__c order by Country_Name__c limit 500]){
            CS_COC_Map.put(cOC.Country_Name__c,cOC);
            lstCountries.add(cOC);
        }

        //new approach
        List<CS_Client_Operating_Countries__c> lstCountriesNew = CS_Client_Operating_Countries__c.getAll().values();
        List<CS_Client_Operating_Countries__c> lstCountriesNew2 = new List<CS_Client_Operating_Countries__c>(); // to hold values with only required fields, for an efficient Map comparison
        Map<String, CS_Client_Operating_Countries__c> CS_COC_MapNew = new Map <String, CS_Client_Operating_Countries__c>();

        CS_Client_Operating_Countries__c cOCSparse;
        for (CS_Client_Operating_Countries__c cOC: lstCountriesNew) {
            cOCSparse = new CS_Client_Operating_Countries__c(Name = cOC.name, CIB_Presence__c = cOC.CIB_Presence__c, Country_Name__c = cOC.Country_Name__c, Id = cOC.Id);
            lstCountriesNew2.add(cOCSparse);
            CS_COC_MapNew.put(cOCSparse.Country_Name__c, cOCSparse);
        }

        Test.startTest();

        system.assert(lstCountriesNew2.equals(lstCountries), 'Difference in Custom Settings values (list) as fetched via SOQL and Apex: CS_Client_Operating_Countries__c');
        system.assert(CS_COC_MapNew.equals(CS_COC_Map), 'Difference in Custom Settings values (map) as fetched via SOQL and Apex: CS_Client_Operating_Countries__c');

        Test.stopTest();
    }
}