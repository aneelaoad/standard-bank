/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-03-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class SEL_Survey_Test {

  @isTest
  static void testSelectByIds() {
    SEL_Survey selector = new SEL_Survey();
    Set<Id> ids = new Set<Id>{ null, null };

    Test.startTest();
    List<Survey> surveys = selector.selectByIds(ids);
    Test.stopTest();

    Assert.areNotEqual(0, surveys.size(), 'Wrong number of surveys returned');
  }

  @isTest
  static void testSelectById() {
    SEL_Survey selector = new SEL_Survey();
    
    Test.startTest();
    List<Survey> surveys = selector.selectById(null);
    Test.stopTest();

    Assert.areEqual(1, surveys.size(), 'Wrong number of surveys returned');
  }

  @isTest
  static void testSelectByDeveloperName() {
    SEL_Survey selector = new SEL_Survey();
    Test.startTest();
    List<Survey> surveys = selector.selectByDeveloperName(null);
    Test.stopTest();

    Assert.areEqual(1, surveys.size(), 'Wrong number of surveys returned');
  }
}