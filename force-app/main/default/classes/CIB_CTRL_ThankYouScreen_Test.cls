/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-03-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_ThankYouScreen_Test {
  @isTest
  static void testGetSurveyInvitation() {
    Application__c application = new Application__c();
    insert application;

    SurveyInvitation actualSurveyInvitation = CIB_CTRL_ThankYouScreen.getSurveyInvitation(
      application.Id
    );

    Assert.areEqual(
      null,
      actualSurveyInvitation,
      'Survey invitation link should be generated'
    );
  }

  @isTest
  static void testGetSurveyInvitationWithoutExistingInvitation() {
    Application__c application = new Application__c();
    insert application;

    Test.startTest();
    SurveyInvitation actualSurveyInvitation = CIB_CTRL_ThankYouScreen.getSurveyInvitation(
      application.Id
    );
    Test.stopTest();

    Assert.areEqual(
      null,
      actualSurveyInvitation,
      'Survey invitation link should be generated'
    );
  }
}