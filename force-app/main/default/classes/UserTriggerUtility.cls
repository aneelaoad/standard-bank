/*************************************************************************\
    @ Author        :     Anurag Jain
    @ Date          :     23 June 2011
    @ Test File     :     UserClassAndTriggerTests
    @description   :     General trigger utility class for User Object.
                          Set the Case Owner user details on the User Object custom fields.        
                          
    @ Last Modified By  : Anurag Jain    
    @ Last Modified On  : 17 August 2011
    @ Last Modified Reason  : The users were encountering the Mixed DMl operation error while 
                              updating the user records who is the owner of any open case. 
                              To fix the error the 'handleUserBeforeUpdateTrigger' has been made @future. Also the parameter has been chnaged to Primitive type Set<ID> 
    @ Last Modified By  : Balabramham.y    
    @ Last Modified On  : 23 August 2011
    @ Last Modified Reason: removed break from if condition.
                            modified the variable names as per the coding standards.        
                                 
****************************************************************************/
public with sharing class UserTriggerUtility {

    /**
    * handleUserBeforeUpdateTrigger
    * @param ids2Users
    */
    public static void handleUserBeforeUpdateTrigger(Map<Id, User> ids2Users) {


        /**************************************************************************\
        A new field Case Owner is created on Case object that shall be populated with the value in Case Owner 
        standard field. This will help in defining the formula fields on the Case object 
        viz. User CIB Global Area, User Division, User Business Unit, User Team, User City, User State/Province, User Country
        ****************************************************************************/

       Id crossBoarderRT = Schema.SObjectType.case.getRecordTypeInfosByName ().get('Cross Border CoE Record Type').getRecordTypeId();
       Id tpsRT = Schema.SObjectType.case.getRecordTypeInfosByName().get('TPS Client Case').getRecordTypeId();
        
        List<Case> openCases = [
            SELECT Id, OwnerId, Case_Owner_Business_Unit__c,Case_Owner_CIB_Global_Area__c,
                Case_Owner_City__c,Case_Owner_Country__c,Case_Owner_Division__c,
                Case_Owner_State_Province__c, Case_Owner_Team__c, RecordTypeId 
            FROM Case
            WHERE OwnerId IN :ids2Users.keySet()
                AND Status != :DMN_Case.STATUS_CLOSED
            	AND RecordTypeId !=: crossBoarderRT
            	AND RecordTypeId !=: tpsRT
        ];

        for(Case openCase : openCases){
                openCase.Case_Owner_Business_Unit__c = ids2Users.get(openCase.OwnerId).Business_Unit__c;
                openCase.Case_Owner_CIB_Global_Area__c = ids2Users.get(openCase.OwnerId).User_CIB_Global_Area__c;
                openCase.Case_Owner_City__c = ids2Users.get(openCase.OwnerId).User_City__c;
                openCase.Case_Owner_Country__c = ids2Users.get(openCase.OwnerId).User_Country__c;
                openCase.Case_Owner_Division__c = ids2Users.get(openCase.OwnerId).User_Division__c;
                openCase.Case_Owner_State_Province__c = ids2Users.get(openCase.OwnerId).User_State_Province__c;
                openCase.Case_Owner_Team__c = ids2Users.get(openCase.OwnerId).User_Team__c;
        }
        
        try{
            update openCases;
        }catch(DMLException ex){
            SRV_Logger.newInstance().log(ex, DMN_Log.TYPE_ERROR, UserTriggerUtility.class.getName());
        }

    }

    /**
	* handleWelcomeNotificationInsert
	* @param newUserIdSet Set of user ids.
	*/
    public static void handleWelcomeNotificationInsert(Set<Id> newUserIdSet){
        DMN_User.handleWelcomeNotificationInsert(newUserIdSet);
    }

    /**
     * Checks if relevant fields on User have been changed
     *
     * @param userOld
     * @param userNew
     *
     * @return Boolean
     **/
    public static Boolean isFieldOnUserChanged(User userOld, User userNew) {
        return userOld.Department != userNew.Department ||
                userOld.Email != userNew.Email ||
                userOld.Fax != userNew.Fax ||
                userOld.FirstName != userNew.FirstName ||
                userOld.LastName != userNew.LastName ||
                userOld.Street != userNew.Street ||
                userOld.State != userNew.State ||
                userOld.PostalCode != userNew.PostalCode ||
                userOld.Country != userNew.Country ||
                userOld.City != userNew.City ||
                userOld.MobilePhone != userNew.MobilePhone ||
                userOld.Phone != userNew.Phone ||
                userOld.Title != userNew.Title ||
                userOld.Birth_Day_Month__c != userNew.Birth_Day_Month__c ||
                userOld.User_Division__c != userNew.User_Division__c ||
                userOld.User_Team__c != userNew.User_Team__c ||
                userOld.User_Franco__c != userNew.User_Franco__c ||
                userOld.User_CIB_Global_Area__c != userNew.User_CIB_Global_Area__c ||
                userOld.Business_Unit__c != userNew.Business_Unit__c ||
                userOld.User_Country__c != userNew.User_Country__c ||
                userOld.Outlook_Exchange_System_ID__c != userNew.Outlook_Exchange_System_ID__c ||
                userOld.IsActive != userNew.IsActive ||
                userOld.EmployeeNumber != userNew.EmployeeNumber ||
                userOld.SA_Cost_Centre__c != userNew.SA_Cost_Centre__c ||
                userOld.Non_SBG_User__c != userNew.Non_SBG_User__c;
    }

    /**
     * Checks if Contact needs to be updated
     *
     * @param userNew
     * @param isTriggerInsert - value for Trigger.isInsert
     * @param id2userOld - value for Trigger.oldMap
     *
     * @return Boolean
     **/
    public static Boolean needsContactUpdate(User userNew, Boolean isTriggerInsert, Map<Id, User> id2userOld) {
        User userOld;
        if(!isTriggerInsert) {
            userOld = id2userOld.get(userNew.Id);
        }
        return userNew.Sync_with_Contact__c && (isTriggerInsert || isFieldOnUserChanged(userOld, userNew));
    }
}