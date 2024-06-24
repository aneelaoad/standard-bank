/**
* Class for updating application status when user redirected to IDV and did not initiate anything for 24hr.
*
* <p></p>
*
* @author Sharanya
*
* @date Dec 2022
*/

public class AOB_ApplicationExpirationBatch implements Database.Batchable<SObject> {
   public Database.QueryLocator start(Database.BatchableContext bc) {
          return Database.getQueryLocator(             
            'SELECT Id, Name, AOB_ExpiryDate__c, AOB_Status__c, CreatedDate, Lead__c FROM AOB_Application__c where AOB_Status__c NOT IN (\'Expired\', \'Rejected\', \'Expired by SBG\', \'Expired by Customer\')'
          );
	}

    public void execute(Database.BatchableContext bc, List<AOB_Application__c> listOfApplications) {    
        list<ID> leadIds = new list<ID>();
        List<AOB_Application__c> appsToUpdate = new List<AOB_Application__c>();
        List<ID> appIDs = new List<ID>();
        for( AOB_Application__c app : listOfApplications ) {    
            Boolean expireApp = false;
            if (app.AOB_ExpiryDate__c != null) {
                if (System.today() > app.AOB_ExpiryDate__c) {
                    expireApp = true;
                }
            } else {
                Date expiryDate = app.CreatedDate.date().addDays(7);
                if(System.today() > expiryDate){
                    expireApp = true;
                }  
            }

            if(expireApp){
                app.AOB_Status__c = 'Expired';
                appsToUpdate.add(app);
                if (app.Lead__c!=null) {
                    leadIds.add(app.Lead__c);
                }
                appIDs.add(app.Id);
            }   
        }
        List<Lead> le=[select id,status from Lead where id in: leadIds];
        for(Lead ld:le){
            ld.Status='Closed';
        }
        update le;
        update appsToUpdate;
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    }
}