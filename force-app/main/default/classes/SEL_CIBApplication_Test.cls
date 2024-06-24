/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-02-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class SEL_CIBApplication_Test {
  @isTest
  public static void testSelectWithoutCondition() {
    SEL_CIBApplication selector = new SEL_CIBApplication();
    List<Application__c> apps = selector.selectWithoutCondition();
    Assert.areEqual(0, apps.size(), 'Expected no applications to be returned');
  }

  @isTest
  public static void testSelectAppsById() {
    SEL_CIBApplication selector = new SEL_CIBApplication();
    Application__c app = new Application__c();
    insert app;
    List<Application__c> apps = selector.selectAppsById(app.Id);
    Assert.areEqual(1, apps.size(), 'Expected one application to be returned');
    Assert.areEqual(
      app.Id,
      apps[0].Id,
      'Expected the returned application to have the correct Id'
    );
  }

  @isTest
  public static void testSelectAppsByClient() {
    SEL_CIBApplication selector = new SEL_CIBApplication();
    Account client = new Account(Name = 'Test Client');
    Application__c app = new Application__c(Client__c = client.Id);
    insert app;
    List<Application__c> apps = selector.selectAppsByClient(app.Client__c);
    Assert.areEqual(1, apps.size(), 'Expected one application to be returned');
    Assert.areEqual(
      app.Id,
      apps[0].Id,
      'Expected the returned application to have the correct Id'
    );
  }

  @isTest
  public static void testSelectAppsByClientStatus() {
    SEL_CIBApplication selector = new SEL_CIBApplication();
    Account client = new Account(Name = 'Test Client');
    Application__c app = new Application__c(
      Client__c = client.Id,
      Status__c = 'New'
    );
    insert app;
    List<Application__c> apps = selector.selectAppsByClientStatus(
      app.Client__c,
      'New'
    );
    Assert.areEqual(1, apps.size(), 'Expected one application to be returned');
    Assert.areEqual(
      app.Id,
      apps[0].Id,
      'Expected the returned application to have the correct Id'
    );
  }

  @isTest
  public static void testSelectAppsByStatus() {
    SEL_CIBApplication selector = new SEL_CIBApplication();
    Application__c app = new Application__c(Status__c = 'New');
    insert app;
    List<Application__c> apps = selector.selectAppsByStatus('New');
    Assert.areEqual(1, apps.size(), 'Expected one application to be returned');
    Assert.areEqual(
      app.Id,
      apps[0].Id,
      'Expected the returned application to have the correct Id'
    );
  }

  @isTest
  public static void testSelectApplicationById() {
    SEL_CIBApplication selector = new SEL_CIBApplication();
    Application__c app = new Application__c();
    insert app;
    Application__c selectedApp = selector.selectApplicationById(app.Id);
    Assert.areEqual(
      app.Id,
      selectedApp.Id,
      'Expected the returned application to have the correct Id'
    );
  }

  @isTest
  public static void testSelectDashboardApplications() {
    Test.startTest();
    new SEL_CIBApplication().selectDashboardApplications(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          'Status__c != \'Closed\' AND Client__c IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId = :contactId)'
        ),
      'Expected the returned application to have the correct Id'
    );
  }
}