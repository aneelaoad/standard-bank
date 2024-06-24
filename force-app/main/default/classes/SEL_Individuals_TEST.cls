@isTest
private class SEL_Individuals_TEST {
  @TestSetup
  private static void createCommitData() {
    fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

    Account ac1 = new Account();
    ac1.Name = 'First Account';
    Account ac2 = new Account();
    ac2.Name = 'Second Account';

    Contact c1 = new Contact();
    c1.LastName = 'l1';
    c1.FirstName = 'F1';
    c1.Email = 'a1@test.com';
    c1.HasOptedOutOfEmail = true;

    Contact c2 = new Contact();
    c2.LastName = 'l1';
    c2.FirstName = 'F2';
    c2.Email = 'a2@test.com';
    c2.HasOptedOutOfEmail = true;

    Contact c3 = new Contact();
    c3.LastName = 'l3';
    c3.FirstName = 'F3';
    c3.Email = 'a3@test.com';
    c2.HasOptedOutOfEmail = false;

    Individual i1 = new Individual();
    i1.FirstName = 'Wendy';
    i1.LastName = 'Jones';
    i1.Email_Address__c = 'i1@test.com';

    Individual i2 = new Individual();
    i2.FirstName = 'Wendy';
    i2.LastName = 'Jones';
    i2.Email_Address__c = 'i2@test.com';

    uow.registerNew(ac1);
    uow.registerNew(ac2);
    uow.registerNew(c1, Contact.AccountId, ac1);
    uow.registerNew(c2, Contact.AccountId, ac1);
    uow.registerNew(c3, Contact.AccountId, ac2);
    uow.registerNew(i1);
    uow.registerNew(i2);

    uow.commitWork(); //insert all

    c1.IndividualId = i1.Id;
    c2.IndividualId = i2.Id;

    uow.registerDirty(c1);
    uow.registerDirty(c2);
    uow.commitWork();
  }

  @isTest
  static void getByIdsTest() {
    Set<Id> ids = new Set<Id>();
    List<Individual> individuals = new List<Individual>();
    for (Individual individual : [SELECT Id FROM Individual]) {
      ids.add(individual.Id);
    }

    Test.startTest();
    individuals = SEL_Individuals.newInstance().selectById(ids);
    Test.stopTest();

    Assert.isFalse(individuals.isEmpty(), 'Expected the returned Individuals to have the correct Id');
    Assert.areEqual(ids.size(), individuals.size(), 'Expected the returned Individuals to have the correct Id');
  }

  @isTest
  static void getIdsFromContactListTest() {
    List<Contact> contacts = [SELECT Id, IndividualId FROM Contact];
    Set<Id> indIds = new Set<Id>();

    Test.startTest();
    indIds = SEL_Individuals.newInstance().getIdsFromContactList(contacts);
    Test.stopTest();

    Assert.isFalse(indIds.isEmpty(), 'Expected the returned Individuals to have the correct Id');
    Assert.areEqual(contacts.size(), indIds.size(), 'Expected the returned Individuals to have the correct Id');
  }

  @isTest
  public static void testSelectByIndividualIdOrFirstNameLastNameEmail() {
    Test.startTest();
    new SEL_Individuals()
      .selectByIndividualIdOrFirstNameLastNameEmail(null, null, null, null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          'Id = :individualId OR (FirstName = :firstName AND LastName = :lastName AND Email_Address__c = :email)'
        ),
      'Expected the returned Individuals to have the correct Id, firstName, lastName, and email'
    );
  }
}