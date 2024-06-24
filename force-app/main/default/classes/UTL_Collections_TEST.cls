/**
 * Test class for UTL_Collections
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		January 2021
*/
@IsTest
private class UTL_Collections_TEST {
    private static final String TEST_RESULT_VALUES = 'Test;Testing';
    private static final String TEST_FIRST_NAME_ONE = 'Test';
    private static final String TEST_LAST_NAME_ONE = 'Testing';
    private static final String TEST_FIRST_NAME_TWO = 'Tst';
    private static final String TEST_LAST_NAME_TWO = 'Tsting';
    private static final String KEY_NOT_UNIQUE_EXCEPTION_MESSAGE = 'Key {0} is not unique for collection of records';
    private static final Id TEST_CONTACT_ID = fflib_IDGenerator.generate(Contact.SObjectType);

    @IsTest
    static void shouldReturnGeneratedCode() {

        List<String> entryValues = new List<String>{
                'a', 'b', 'c'
        };
        Test.startTest();
        String result = UTL_Collections.generateCode(entryValues);
        Test.stopTest();
        System.assertEquals('A_B_C', result);
    }

    @IsTest
    static void shouldReturnStandardConcatenatedString() {
        List<String> entryValues = new List<String>{
                'a', 'b', 'c'
        };
        Test.startTest();
        String result = UTL_Collections.concatenate(entryValues);
        Test.stopTest();
        System.assertEquals('a;b;c', result);
    }

    @IsTest
    static void shouldGetSobjectListForMapOfIdToList() {
        Map<Id, SObject[]> entryValues = new Map<Id, SObject[]>{
                null => new List<SObject>{
                        null
                },
                null => new List<SObject>{
                        new Contact()
                }
        };
        Test.startTest();
        List<SObject> results = UTL_Collections.getSobjectList(entryValues);
        Test.stopTest();
        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0]);
    }

    @IsTest
    static void shouldGetSobjectListForMapOfSobjectTypeToList() {
        Map<SObjectType, SObject[]> entryValues = new Map<SObjectType, SObject[]>{
                Contact.SObjectType => new List<SObject>{
                        null
                },
                Contact.SObjectType => new List<SObject>{
                        new Contact()
                }
        };
        Test.startTest();
        List<SObject> results = UTL_Collections.getSobjectList(entryValues);
        Test.stopTest();
        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0]);
    }

    @IsTest
    static void shouldReturnJoinedListIsSkipTrue() {
        List<SObject[]> entryValues = new List<SObject[]>{
                new List<SObject>{
                        null
                }, new List<SObject>{
                        new Account()
                }
        };
        Test.startTest();
        List<SObject> results = UTL_Collections.joinLists(entryValues, true);
        Test.stopTest();
        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0]);
    }

    @IsTest
    static void shouldReturnJoinedListIsSkipFalse() {
        List<SObject[]> entryValues = new List<SObject[]>{
                new List<SObject>{
                        null
                }, new List<SObject>{
                        new Account()
                }
        };
        Test.startTest();
        List<SObject> results = UTL_Collections.joinLists(entryValues, false);
        Test.stopTest();
        System.assertEquals(2, results.size());
    }

    @IsTest
    static void shouldReturnMapId2SObject() {
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE), new Account(Name = TEST_FIRST_NAME_TWO)
        };
        insert objects;
        Test.startTest();
        Map<Id, SObject> id2SObjects = UTL_Collections.builMap(objects, Account.Id);

        Test.stopTest();
        System.assertEquals(2, id2SObjects.size());
        System.assert(id2SObjects.containsKey(objects[0].Id));

    }

    @IsTest
    static void shouldThrowMapId2SObjectWithoutDuplicatesException() {
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE), new Account(Name = TEST_LAST_NAME_TWO)
        };
        insert objects;
        List<SObject> duplicatedList = objects;
        duplicatedList.addAll(objects);
        String errorMessage;
        Test.startTest();
        try {
            Map<Id, SObject> id2SObjects =
                    UTL_Collections.builMap(duplicatedList, Account.Id, true, false);
        } catch (UTL_Collections.UTL_CollectionsException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(String.format(KEY_NOT_UNIQUE_EXCEPTION_MESSAGE, new List<String>{
                '\''+Account.Id.getDescribe().name+'\''
        }), errorMessage);
    }

    @IsTest
    static void shouldReturnMapId2SObjects() {
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE)
        };
        insert objects;
        List<SObject> childContacts = new List<SObject>{
                new Contact(LastName = TEST_LAST_NAME_ONE, AccountId = objects[0].Id),
                new Contact(LastName = TEST_LAST_NAME_TWO, AccountId = null)
        };
        insert childContacts;
        Test.startTest();
        Map<Id, SObject[]> id2SObjects = UTL_Collections.builListMap(childContacts, Contact.AccountId);
        Test.stopTest();
        System.assertEquals(1, id2SObjects.size());
        System.assert(id2SObjects.containsKey((Id) childContacts[0].getPopulatedFieldsAsMap().get('AccountId')));
        System.assertEquals(1, (id2SObjects.get((Id) childContacts[0].getPopulatedFieldsAsMap().get('AccountId')).size()));
    }

    @IsTest
    static void shouldReturnMapKey2SObject() {
        List<SObject> objects = new List<SObject>{
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_TWO, FirstName = TEST_LAST_NAME_TWO)
        };

        Test.startTest();
        Map<Id, SObject> key2SObject = UTL_Collections.builMap(objects, Contact.Id);
        Test.stopTest();
        System.assert(key2SObject.containsKey(TEST_CONTACT_ID));
    }

    @IsTest
    static void shouldThrowMapKey2SObjectDuplicatesException() {
        List<SObject> objects = new List<SObject>{
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE)
        };

        String errorMessage;
        Test.startTest();
        try {
            Map<Id, SObject> key2SObject =
                    UTL_Collections.builMap(objects, Contact.Id, true, false);
        } catch (UTL_Collections.UTL_CollectionsException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();
        System.assertEquals(String.format(KEY_NOT_UNIQUE_EXCEPTION_MESSAGE, new List<String>{
                '\''+Contact.Id.getDescribe().name+'\''
        }), errorMessage);
    }

    @IsTest
    static void shouldReturnsMapKey2SObjectWhenIsSkipNullIsFalse() {
        List<SObject> objects = new List<SObject>{
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(Id = TEST_CONTACT_ID, LastName = null, FirstName = null)
        };

        Test.startTest();
        Map<Id, SObject> key2SObject = UTL_Collections.builMap(objects, Contact.Id, false, true);
        Test.stopTest();
        System.assert(key2SObject.containsKey(TEST_CONTACT_ID));

    }

    @IsTest
    static void shouldReturnChildrenRecords() {
        List<ChildRelationship> childRelationships = Schema.Account.SObjectType.getDescribe().childRelationships;
        ChildRelationship childRelationship;
        for (ChildRelationship cp : childRelationships) {
            if (cp.relationshipName == 'Contacts') {
                childRelationship = cp;
            }
        }
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE)
        };
        insert objects;
        List<Contact> contacts = new List<Contact>{new Contact(LastName = TEST_LAST_NAME_ONE, AccountId = objects[0].Id)};
        insert contacts;
        List<SObject> accounts = [SELECT (SELECT Id FROM Contacts) FROM Account WHERE Id  = :objects[0].Id];
        Test.startTest();
        List<SObject> results = UTL_Collections.getChildrenFromParents(accounts, childRelationship);
        Test.stopTest();
        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0]);

    }

    @IsTest
    static void shouldReturnMapWithNewValues() {
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE), new Account(Name = TEST_FIRST_NAME_TWO)
        };
        insert objects;
        System.debug(objects);
        List<SObject> newObjects = new List<SObject>{
                new Account(Name = TEST_LAST_NAME_ONE), new Account(Name = TEST_LAST_NAME_TWO)
        };
        insert newObjects;
        System.debug(newObjects);
        Map<Id, SObject[]> id2SObjects = UTL_Collections.builListMap(objects, Account.Id);
        System.debug(id2SObjects);
        Test.startTest();
        UTL_Collections.addToMap(id2SObjects, objects[0].Id, newObjects);
        System.debug(id2SObjects);
        Test.stopTest();
        System.assertEquals(3, id2SObjects.get(objects[0].Id).size());
    }

    @IsTest
    static void shouldReturnMapId2SObjectBuildMap() {
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE), new Account(Name = TEST_FIRST_NAME_TWO)
        };
        insert objects;
        Test.startTest();
        Map<String, SObject> id2SObjects = UTL_Collections.buildMap(objects, new List<SObjectField>{Account.Id});

        Test.stopTest();
        System.assertEquals(2, id2SObjects.size());
        System.assert(id2SObjects.containsKey(objects[0].Id));

    }

    @IsTest
    static void shouldThrowMapId2SObjectWithoutDuplicatesExceptionBuildMap() {
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE), new Account(Name = TEST_LAST_NAME_TWO)
        };
        insert objects;
        List<SObject> duplicatedList = objects;
        duplicatedList.addAll(objects);
        String errorMessage;
        Test.startTest();
        try {
            Map<String, SObject> id2SObjects = UTL_Collections.buildMap(duplicatedList,
                    new List<SObjectField>{Account.Id}, true, false);
        } catch (UTL_Collections.UTL_CollectionsException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        System.assertEquals(String.format(KEY_NOT_UNIQUE_EXCEPTION_MESSAGE, new List<String>{
                '\''+objects[0].Id+'\''
        }), errorMessage);
    }

    @IsTest
    static void shouldReturnMapKey2SObjectBuildMap() {
        List<SObject> objects = new List<SObject>{
                new Contact(LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(LastName = TEST_LAST_NAME_TWO, FirstName = TEST_LAST_NAME_TWO)
        };
        List<Schema.SObjectField> fieldsList = new List<Schema.SObjectField>{
                Contact.FirstName, Contact.LastName
        };
        Test.startTest();
        Map<String, SObject> key2SObject = UTL_Collections.buildMap(objects, fieldsList);
        Test.stopTest();
        System.assertEquals(2, key2SObject.size());
        System.assert(key2SObject.containsKey(TEST_RESULT_VALUES));
    }

    @IsTest
    static void shouldThrowMapKey2SObjectDuplicatesExceptionBuildMap() {
        List<SObject> objects = new List<SObject>{
                new Contact(LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE)
        };
        List<Schema.SObjectField> fieldsList = new List<Schema.SObjectField>{
                Contact.FirstName,
                Contact.LastName
        };
        String errorMessage;
        Test.startTest();
        try {
            Map<String, SObject> key2SObject =
                    UTL_Collections.buildMap(objects, fieldsList, true, false);
        } catch (UTL_Collections.UTL_CollectionsException ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();
        System.assertEquals(String.format(KEY_NOT_UNIQUE_EXCEPTION_MESSAGE, new List<String>{
                '\''+TEST_RESULT_VALUES+'\''
        }), errorMessage);
    }

    @IsTest
    static void shouldReturnsMapKey2SObjectWhenIsSkipNullIsFalseBuildMap() {
        List<SObject> objects = new List<SObject>{
                new Contact(LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(LastName = null, FirstName = null)
        };
        List<Schema.SObjectField> fieldsList = new List<Schema.SObjectField>{
                Contact.FirstName, Contact.LastName
        };
        Test.startTest();
        Map<String, SObject> key2SObject =
                UTL_Collections.buildMap(objects, fieldsList, false, true);
        Test.stopTest();
        System.assertEquals(2, key2SObject.size());
        System.assert(key2SObject.containsKey(TEST_RESULT_VALUES));
        System.assert(key2SObject.containsKey(';'));

    }

    @IsTest
    static void shouldReturnChildrenRecordsBuildMap() {
        List<ChildRelationship> childRelationships = Schema.Account.SObjectType.getDescribe().childRelationships;
        ChildRelationship childRelationship;
        for (ChildRelationship cp : childRelationships) {
            if (cp.relationshipName == 'Contacts') {
                childRelationship = cp;
            }
        }
        List<SObject> objects = new List<SObject>{
                new Account(Name = TEST_FIRST_NAME_ONE)
        };
        insert objects;
        List<Contact> contacts = new List<Contact>{new Contact(LastName = TEST_LAST_NAME_ONE, AccountId = objects[0].Id)};
        insert contacts;
        List<SObject> accounts = [SELECT (SELECT Id FROM Contacts) FROM Account WHERE Id  = :objects[0].Id];
        Test.startTest();
        List<SObject> results = UTL_Collections.getChildrenFromParents(accounts, childRelationship);
        Test.stopTest();
        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0]);
    }

    @IsTest
    static void shouldGetIdList() {
        List<SObject> objects = new List<SObject>{
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE)
        };
        Test.startTest();
        List<Id> results = UTL_Collections.getIdList(objects, Contact.Id, new Set<SObjectType>{Contact.SObjectType});
        Test.stopTest();
        System.assertEquals(2, results.size());
        System.assertEquals(TEST_CONTACT_ID, results[0]);
        System.assertEquals(TEST_CONTACT_ID, results[1]);
    }

    @IsTest
    static void shouldGetIdListWithWrongType() {
        List<SObject> objects = new List<SObject>{
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE),
                new Contact(Id = TEST_CONTACT_ID, LastName = TEST_LAST_NAME_ONE, FirstName = TEST_FIRST_NAME_ONE)
        };
        Test.startTest();
        List<Id> results = UTL_Collections.getIdList(objects, Contact.Id, new Set<SObjectType>{Account.SObjectType});
        Test.stopTest();
        System.assertEquals(0, results.size());
    }
}