/*************************************************************************\
    @ Author        : Abhishel Arya / Anurag Jain
    @ Date      : Dec 2011
    @ Test File     : TC_insertCTOPfromCustClientTeam.cls
    @ Description   : This class is called from the trigger insertCTOPfromCustClientTeam and is 
                      responsible for Inserting and Deleting the records from the Junction object-Client TeamOpportunity_Products
    @
@ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Anurag Jain
    @ Last Modified On  :   07 Mar 2011
    @ Last Modified Reason  :   Code Comments, formatting
****************************************************************************/

public class insertCTOPfromCustClientTeamClass {

    Public virtual class MyCustomException extends Exception {

    }

    public void insertCTOP_frmCCT(List<Custom_Client_Team__c> cct_l){

            Boolean blnBatch;  //Variable to determine if the Batch processing is required.         
            try{                   
                blnBatch = False;
                If (cct_l.size() == 1){
                    blnBatch = False;                
                    Throw new MyCustomException();
                 }
                        
                List<AsyncApexJob> lstvarApexJob = [Select Id, Status, JobType, CreatedBy.Email from AsyncApexJob where 
                           Status In ('Processing','Queued','Preparing') and JobType in ('BatchApex')];
                if (lstvarApexJob.size() < 5) {
                    blnBatch = True;
                    id batchinstanceid = database.executeBatch(new BatchClientTeamJunctionUpdate(cct_l,False));
                    System.Debug('Batch Instance ID (BatchClientTeamJunctionUpdate)>>>> ' + batchinstanceid);
                  }
                else {
                  blnBatch = False; 
                  Throw new MyCustomException();
                }   
               } 
            catch(exception e){
                system.debug('New batch class >> Exception ' + e + '  '  + e.getTypeName());
              if (e.getTypeName() == 'AsyncException' || e.getTypeName() == 'System.AsyncException' || !blnBatch)
                 {                  
                    List<Id> cctList=new List<Id>();
                    List<Opportunity> oppList=new List<Opportunity>();
                    
                    for(Custom_Client_Team__c cct:cct_l)
                            cctList.add(cct.Account__c);            
                    
                    if(cctList.size()>0)
                        oppList=[select Id,AccountId from Opportunity where AccountId in:cctList];
                    
                    if (oppList.size() > 0) {                
                        BatchClientTeamJunctionUpdate objBatch = new BatchClientTeamJunctionUpdate(cct_l,false);
                        objBatch.processExecute(oppList,false,false);
                      }  
                 }
              } //end of catch
    }
    

    public void deleteCTOP_frmCCT(List<Custom_Client_Team__c> cct_lst){
        List<Id> CustomClientTeamMemberIds=new List<Id>();
        
        for(Custom_Client_Team__c cct_obj:cct_lst) {
            CustomClientTeamMemberIds.add(cct_obj.Id);
           }
    
        //Populating the Junction object's records to be deleted in a List type variable.
         try{

           if (cct_lst.size() == 1) {
               List<ClientTeamOpportunity_Products__c> lstobjCTOP =[Select Id,Opportunity__c from ClientTeamOpportunity_Products__c where Custom_Client_Team__c in:CustomClientTeamMemberIds];
               Delete lstobjCTOP;          
            }   
            else {
                list<AsyncApexJob> lstvarApexJob = [Select Id, Status, JobType, CreatedBy.Email from AsyncApexJob where 
                                       Status In ('Processing','Queued','Preparing') and JobType in ('BatchApex')];
                if (lstvarApexJob.size() < 5) {                 
                    id batchinstanceid = database.executeBatch(new BatchClientTeamJunctionUpdate(cct_lst,True), 200);
                  }  
                 else {
                    cct_lst.get(0).addError('Server is Busy processing the other batches. Please try again after sometime.');
                   }
             }                        
           }catch(Exception e){
                  If (e.getTypeName() == 'AsyncException' || e.getTypeName() == 'System.AsyncException' ) {
                       List<ClientTeamOpportunity_Products__c> lstobjCTOP =[Select Id,Opportunity__c from ClientTeamOpportunity_Products__c where Custom_Client_Team__c in:CustomClientTeamMemberIds];
                       Delete lstobjCTOP;          
                    } 
                  else {
                       cct_lst.get(0).addError('The delete operation on Custom Client Team object encountered an error - Method:deleteCTOP_frmCCT>>> Error Type:' + + e.getTypeName() + ' >>> Error******'+e);
                   }                  
             } //catch
        
       } // End of deleteCTOP_frmCCT method
     
  } //End of Class