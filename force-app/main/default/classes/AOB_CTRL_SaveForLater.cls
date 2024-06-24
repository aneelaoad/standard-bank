/**
 * Class for Save for Later functions
 *
 * <p></p>
 *
 * @author Franco Pieterse
 *
 * @date 2021/10/14
 */
public with sharing class AOB_CTRL_SaveForLater {

  /**
   * @description gets the current application recordname
   * @param	applicationId 
   * @return list
   */
  @auraEnabled
  public static AOB_Application__c getApplicationName(id applicationId) {
    return [
      SELECT id, Name
      FROM AOB_Application__c
      WHERE id = :applicationId
    ];
  }

  /**
   * @description update the current application record to In Progress Status
   * @param	applicationId 
   * 
   */
  @auraEnabled
  public static void updateApplicationToInProgressStatus(id applicationId) {
    List<AOB_Application__c> appRec;

    appRec = [
      SELECT id, AOB_Status__c
      FROM AOB_Application__c 
      WHERE id = :applicationId
    ];
    if (appRec.size() > 0) {
      appRec[0].AOB_Status__c = 'In Progress';
      Update appRec;
    }

  }
}