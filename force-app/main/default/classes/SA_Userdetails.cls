public class SA_Userdetails {
/*************************************************************************\
    @ Author        :     Charly 
    @ Date          :     2009
    @ Test File     :     
    @ Description   :    Controller for the Visualforce page "SA_Welcome". 
                         This class retrieves additional information about 
                         the curently logged in user.

    @ Last Modified :    Ignus
    @ Modify Date   :    Nov 2011
    @ Change Reason :    Added user Manager

    @ Last Modified :    C Reinecke
    @ Modify Date   :    Dec 2011
    @ Change Reason :    Added user division and business unit 
                         Case#548 Regression Remove redundant fields.                              
****************************************************************************/


public List<User> getUserDetails() {
    return [SELECT LastLoginDate,Manager.name,FirstName,User_Division__c,Business_Unit__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

}
}