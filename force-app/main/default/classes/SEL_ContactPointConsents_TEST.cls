@isTest
public class SEL_ContactPointConsents_TEST {
  @isTest
  public static void testselectWithoutCondition() {
    Test.startTest();
    List<ContactPointConsent> result = new SEL_ContactPointConsents()
      .selectWithoutCondition();
    Test.stopTest();
    Assert.areEqual(
      true,
      result.isEmpty(),
      'Expected the returned contact point consent to have the correct Id'
    );
  }
  @isTest
  public static void testSelectById() {
    Test.startTest();
    new SEL_ContactPointConsents().selectById(new Set<Id>{});
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition().containsIgnoreCase('id IN :ids'),
      'Expected the returned contact point consent to have the correct Id'
    );
  }
  @isTest
  public static void testSelectByContactPointId() {
    Test.startTest();
    new SEL_ContactPointConsents().selectByContactPointId(new Set<Id>{});
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition().containsIgnoreCase('ContactPointId IN :ids'),
      'Expected the returned contact point consent to have the correct Id'
    );
  }
}