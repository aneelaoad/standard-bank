@isTest
public class SEL_ContactPointEmail_TEST {
  @isTest
  public static void testselectWithoutCondition() {
    Test.startTest();
    List<ContactPointEmail> result = new SEL_ContactPointEmails()
      .selectWithoutCondition();
    Test.stopTest();
    Assert.areEqual(
      true,
      result.isEmpty(),
      'Expected the returned contact point consent to have the correct Id'
    );
  }
  @isTest
  public static void testselectById() {
    Test.startTest();
    new SEL_ContactPointEmails().selectById(new Set<Id>{});
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition().containsIgnoreCase('id IN :ids'),
      'Expected the returned contact point email to have the correct Id'
    );
  }
  @isTest
  public static void testselectByParentId() {
    Test.startTest();
    new SEL_ContactPointEmails().selectByParentId(new Set<Id>{});
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition().containsIgnoreCase('ParentId IN :ids'),
      'Expected the returned contact point consent to have the correct Id'
    );
  }
}