/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_ThankYouScreen
@ Description       : Controller class for the Thank You screen in the CIB application. This class provides a method to retrieve a survey invitation for the logged-in user based on the application ID and the survey developer name.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-25236
***************************************************************************************/
public without sharing class CIB_CTRL_ThankYouScreen {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_ThankYouScreen');
  /**
   * @description       : Retrieves a survey invitation for the logged-in user based on the application ID and the survey developer name.
   * @param applicationId : The ID of the application for which the survey invitation is being retrieved.
   * @return SurveyInvitation : A SurveyInvitation object representing the survey invitation for the logged-in user. Returns null if the user has already completed the survey.
   * @throws AuraHandledException :  if an error occurs while retrieving the survey invitation.
   **/
  @AuraEnabled
  public static SurveyInvitation getSurveyInvitation(Id applicationId) {
    Application__c application = new SEL_CIBApplication()
      .selectApplicationById(applicationId);

    User loggedInUser = new SEL_Users()
      .selectById(new Set<Id>{ UserInfo.getUserId() })
      .get(0);

    Survey survey = new SEL_Survey()
      .selectByDeveloperName(CIB_Constants.SURVEY_DEVELOPER_NAME)
      .get(0);

    List<SurveyInvitation> surveyInvitations = new List<SurveyInvitation>();

    surveyInvitations = new SEL_SurveyInvitation()
      .selectBySurveyApplicationAndParticipant(
        survey.Id,
        applicationId,
        loggedInUser.Id
      );

    SurveyInvitation surveyInvitation = surveyInvitations.size() > 0
      ? surveyInvitations.get(0)
      : null;

    if (surveyInvitation == null) {
      surveyInvitation = new SurveyInvitation();
      surveyInvitation.CommunityId = Network.getNetworkId();
      surveyInvitation.Name =
        application.Name +
        ' - ' +
        loggedInUser.FirstName +
        ' ' +
        loggedInUser.LastName;
      surveyInvitation.Application__c = application.Id;
      surveyInvitation.ParticipantId = loggedInUser.ContactId;
      
      surveyInvitation.OptionsAllowGuestUserResponse = false;
      surveyInvitation.SurveyId = survey.Id;

      if (!Test.isRunningTest()) {
        CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
          new List<Schema.SObjectType>{ Schema.SurveyInvitation.SObjectType },
          new List<SurveyInvitation>{ surveyInvitation }
        );
      }

      surveyInvitation = new SEL_SurveyInvitation()
        .selectBySurveyApplicationAndParticipant(
          survey.Id,
          applicationId,
          loggedInUser.ContactId
        )
        .get(0);
    } else if (
      surveyInvitation.ResponseStatus ==
      CIB_Constants.SURVEY_INVITATION_RESPONSE_STATUS_COMPLETED
    ) {
      return null;
    }

    return surveyInvitation;
  }
}