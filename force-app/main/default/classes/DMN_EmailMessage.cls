/**
* @author Artur Kepczynski
* @date   February 2019
* @description Domanin Class for Email Messages
* @US US-3445
* @usage    DMN_EmailMessage.publicMethodName(params)
*/
public class DMN_EmailMessage {

    /**
     * mark related case if case was sent to related contact
     * @param emails Type: EmailMessage[]
 */
    public static void markRelatedCases(EmailMessage[] emails){
        Set<Id> casesIds = new Set<Id>();
        
        for (Integer i = 0, j = emails.size(); i < j; i++){
            EmailMessage em = emails[i];
            if(em.ParentId!=null && em.ParentId.getSobjectType() == Case.SObjectType){
                casesIds.add(em.ParentId);
            }
        }
        
        if(casesIds.isEmpty()){
            return;
        }
        
        Case[] casesToUpdate = new Case[]{};
        
        for(Case cas : [SELECT Status
                        FROM Case
                        WHERE Id IN: casesIds]){
            if(cas.Status == DMN_Case.STATUS_COMMENTS){
                casesToUpdate.add(new Case (Id = cas.Id, CCC_Final_Email_Sent__c = true));
            }
        }

        if(!casesToUpdate.isEmpty()){
            try {
                update casesToUpdate;
            }
            catch(Exception ex){
                for(EmailMessage em : emails){
                    em.addError(ex);
                } 
            }
        }
    }
}