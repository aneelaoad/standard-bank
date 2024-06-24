@isTest
public with sharing class CMN_SerializeSObjectToJSONTest {
    @isTest
    static void testSerialize() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        List<CMN_SerializeSObjectToJSON.Requests> requests = new List<CMN_SerializeSObjectToJSON.Requests>();
        for (Integer i = 0; i < 21; i += 3) {
            CMN_SerializeSObjectToJSON.Requests requestList = new CMN_SerializeSObjectToJSON.Requests();
            requestList.inputSObjectList = accounts;
            requests.add(requestList);
            CMN_SerializeSObjectToJSON.Requests requestSingleton = new CMN_SerializeSObjectToJSON.Requests();
            requestSingleton.inputSObject = accounts[i];
            requests.add(requestSingleton);
            CMN_SerializeSObjectToJSON.Requests requestBoth = new CMN_SerializeSObjectToJSON.Requests();
            requestBoth.inputSObjectList = accounts;
            requestBoth.inputSObject = accounts[i];
            requests.add(requestBoth);
        }
        List<CMN_SerializeSObjectToJSON.Results> results = CMN_SerializeSObjectToJSON.serialize(requests);
        System.assertEquals(21, results.size());
    }
}