/**
* @author Matthew Hunter
* @date 03/10/2022
* @description Batch class that finds all the User's that have the API Marketplace Member profile
* and updates their permission set so they can access the API Marketplace from OneHub without signing in again.
*/
public without sharing class OneHubToMarketPlaceAccessUpdate implements Database.Batchable<sObject> {

    //The targeted Profile Id for the user.
    final Id targetProfileId = [

        SELECT 
            Id 
        FROM 
            Profile 
        WHERE 
            Name = 'OneHub Community User Login'

    ].Id;

    //The targeted Permission Set for the user.
    final Id targetPermissionSetId = [

        SELECT 
            Id 
        FROM 
            PermissionSet 
        WHERE 
            Name = 'API_Marketplace_Member'

    ].Id;

    /**
     * @description Batch start.
     * 
     * @param   bc  The batchable context
     * 
     * @return  Database.QueryLocator   The database query locator
     */
    public Database.QueryLocator start(Database.BatchableContext scope) {

        String query = 'SELECT Id FROM User WHERE ProfileId = :targetProfileId AND Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :targetPermissionSetId) AND isActive = true' + (Test.isRunningTest()? ' ORDER BY CreatedDate DESC LIMIT 200':'');
        
        return Database.getQueryLocator(query); 

    }

    /**
     * @description Batch execute.
     * 
     * @param   bc      The batchable context
     * @param   scope   The scope of data
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope) {

        List<PermissionSetAssignment> updatedPermissions = new List<PermissionSetAssignment>();
            
            for (User u : (List<User>)scope) {

                PermissionSetAssignment psa = new PermissionSetAssignment(

                    AssigneeId = u.Id,
                    PermissionSetId = targetPermissionSetId

                ); 

                updatedPermissions.add(psa);

            }

            try {

                insert updatedPermissions;

            } catch (DmlException e) {

                System.debug('The following exception has occured: ' + e.getMessage());
                
                Throw new DMLException(e.getMessage());

            }

    }

    /**
     * @description Batch finish.
     * 
     * @param   bc  The batchable context
     */
    public void finish(Database.BatchableContext bc) {}

}