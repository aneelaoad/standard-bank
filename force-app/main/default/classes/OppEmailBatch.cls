/*************************************************************************

    @ Author        : Anusha Marrivagu
    @ Date          : 15 Nov 2013
    @ Description   : OppEmailBatch Batch class is used to send emails to the OpportunityOwners & Account Owners 7 or 14 days before to the close date. 
                            
    @ Test Class    : TestOppBatch
                      
****************************************************************************/


global class OppEmailBatch implements Database.Batchable<sObject>{
    
    public String queryString;
    public Date expDate1 = System.today().addDays(7);
    public Date expDate2 = System.today().addDays(14); 

    global OppEmailBatch(){
        try {  
            queryString = 'Select id,Name,StageName,IsPrivate,CloseDate,Owner.Email,Account.Owner.Email,Owner.Name from Opportunity where (CloseDate=: expDate1 OR CloseDate=: expDate2) AND Isprivate = true  AND ( StageName != \'3 - Closed Won\' AND StageName != \'4 - Closed Lost\')';
        }
        catch(Exception ex){
            system.debug('***An Unexpected Exception occurred. Please contact your System Admin' + ex.getMessage());
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> Opplist){
        Messaging.SingleEmailMessage[] msgs = new Messaging.SingleEmailMessage[]{};

        try{   
            for(Opportunity opp : Opplist ){       
                if( system.today() == opp.CloseDate-7 ) {
                    Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.OPP_CLOSE_DATE_FINAL);
                    msgs.add(UTL_Email.createEmails(templateId, opp.Id, new Set<String>{ opp.Owner.Email }));
                }   
                else  if( system.today() == opp.CloseDate-14 ){
                    Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.OPP_CLOSE_DATE);
                    msgs.add(UTL_Email.createEmails(templateId, opp.Id, new Set<String>{ opp.Owner.Email }));     
                }  
            }        

            if(!msgs.isEmpty()){
                Messaging.sendEmail(msgs);
            }
        }
        catch(Exception ex){
            System.debug('Exception' + ex);
        }
    }
    
    global void finish(Database.BatchableContext BC){}     
}