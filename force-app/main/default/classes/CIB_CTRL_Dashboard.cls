/***************************************************************************************
@ Author            : ridhima.saxena@standardbank.co.za
@ Date              : 10-02-2023
@ Name of the Class : CIB_CTRL_Dashboard
@ Description       : Contains the business logic for the dashboard section of Mauritius Onboarding Hub under OneHub
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-02-2023
@ Modification Description : SFP-23731, SFP-25235
***************************************************************************************/
public with sharing class CIB_CTRL_Dashboard {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_Dashboard');
  /**
   * @description get the dashboard applications
   * @return Application
   */
  @AuraEnabled(cacheable=true)
  public static List<Application__c> getDashboardDetails() {
    String userId = UserInfo.getUserId();
    User loggedInUser = new SEL_Users()
      .selectById(new Set<Id>{ userId })
      .get(0);
    List<Application__c> applications = new SEL_CIBApplication()
      .selectDashboardApplications(loggedInUser.ContactId);
    return applications;
  }
  /**
   * @description get login user details
   * @return User
   */
  @AuraEnabled(cacheable=true)
  public static User getLoggedInUserDetail() {
    User loggedInUser = new SEL_Users()
      .selectById(new Set<Id>{ UserInfo.getUserId() })
      .get(0);
    return loggedInUser;
  }
}