/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-03-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class SEL_SurveyInvitation_Test {
  @isTest
  static void testSelectByIds() {
    SEL_SurveyInvitation selector = new SEL_SurveyInvitation();

    Test.startTest();
    List<SurveyInvitation> results = selector.selectByIds(new Set<Id>{ null });
    Test.stopTest();

    Assert.areEqual(
      1,
      results.size(),
      'Expected 1 result, got ' + results.size()
    );
  }

  @isTest
  static void testSelectById() {
    SEL_SurveyInvitation selector = new SEL_SurveyInvitation();

    Test.startTest();
    List<SurveyInvitation> results = selector.selectById(null);
    Test.stopTest();

    Assert.areEqual(
      1,
      results.size(),
      'Expected 1 result, got ' + results.size()
    );
  }

  @isTest
  static void testSelectByName() {
    SEL_SurveyInvitation selector = new SEL_SurveyInvitation();

    Test.startTest();
    List<SurveyInvitation> results = selector.selectByName(
      'Test Survey Invitation'
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      results.size(),
      'Expected 1 result, got ' + results.size()
    );
  }

  @isTest
  static void testSelectBySurveyApplicationAndParticipant() {
    SEL_SurveyInvitation selector = new SEL_SurveyInvitation();

    Test.startTest();
    List<SurveyInvitation> results = selector.selectBySurveyApplicationAndParticipant(
      null,
      null,
      null
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      results.size(),
      'Expected 1 result, got ' + results.size()
    );
  }
}