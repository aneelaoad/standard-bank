/*************************************************************************\
@ Author        :     Raja Kumar
@ Date          :     23rd Sept 2022
@ Test File     :     CustomEmailToCaseHandlerTest
@ Description   :     SFP-12913 : Create New Case using custom email handler
					  creating this custom inbound email handler to replicate standard Email-to-case functionality and 
					  to add features not catered by standard email-to-case such as creating a new when when a mail is 
					  received for a closed case and creating case with spam status for recall emails.
****************************************************************************/
public class CustomEmailToCaseHandler {
    public Messaging.InboundEmail inboundEmail=new Messaging.InboundEmail();
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CustomEmailToCaseHandler');
    
    //instantiated CustomInboundEmailHandlerHelper class
    CustomInboundEmailHandlerHelper CustomInboundEmailHandlerHelperObj=new CustomInboundEmailHandlerHelper();
    
    void setInboundEmail(Messaging.InboundEmail email){
        this.inboundEmail=email;
        CustomInboundEmailHandlerHelperObj.setInboundEmail(email);
        
    }
    
    //function to process Rules
    boolean processRule(Email_Matching_Rule__c matchRec){
        boolean resultOfProcessRule=false;
        //based on field value perform pattern match
        switch on matchRec.field__c {
            when 'subject' {
                resultOfProcessRule=Pattern.matches(matchRec.Value__c,inboundEmail.subject);
            }	
            when 'To Address' {
                for(String toAddress:inboundEmail.toAddresses){
                    if(toAddress.equals(matchRec.Value__c)){
                        resultOfProcessRule=true;
                    }
                }
            }
            when 'From Address' {	
                resultOfProcessRule=Pattern.matches(matchRec.Value__c,inboundEmail.fromAddress);
            }
            When 'CC Address' {
                for(String ccAddress:inboundEmail.ccAddresses){
                    if(ccAddress.equals(matchRec.Value__c)){
                        return true;
                    }
                    
                }
            }
            When 'Body'{
                resultOfProcessRule=Pattern.matches('.*'+matchRec.Value__c+'.*',inboundEmail.plainTextBody);
            }
            
        }
        
       return resultOfProcessRule; 
    }
    
    //perform Block Action- create a new case for this mail and mark it spam
    boolean performBlockAction(Email_Action__c emailActionRec){
        
        CustomInboundEmailHandlerHelperObj.setEmailActionRec(emailActionRec);
        CustomInboundEmailHandlerHelperObj.spamCase=true;
        String caseid=CustomInboundEmailHandlerHelperObj.createCaseRecord();
        String emailMessageid=CustomInboundEmailHandlerHelperObj.createEmailMessageRecord(caseId);
        LOGGER.debug('exiting performBlockAction');
        if(emailMessageid!=null){
            return true;
        }else{
            return false;
        }
        
        
    }//end of performBlockAction
    
    //perform create case Action - standard E2C funationality
    boolean performCreateCaseAction(Email_Action__c emailActionRec){
        boolean returnFromperformCreateCaseAction=false;
        CustomInboundEmailHandlerHelperObj.setEmailActionRec(emailActionRec);
        String checkThreadId='';
        //if ThreadID exists 
        if(inboundEmail.references==null){
            checkThreadId=inboundEmail.messageid;
        }else{
            checkThreadId=inboundEmail.references[0];//assigning message id of first email
        }
        //check if case exists already
        if(CustomInboundEmailHandlerHelperObj.ThreadIdExists(checkThreadId) && !CustomInboundEmailHandlerHelperObj.isClosedCase && !(inboundEmail.references==null) ){
            
            //create emailmessage rec and link to exisiting case
            String emailMessageid=CustomInboundEmailHandlerHelperObj.createEmailMessageRecord(CustomInboundEmailHandlerHelperObj.getParetentCaseId());
            if(emailMessageid!=null){
               returnFromperformCreateCaseAction=true; 
            }else{
                returnFromperformCreateCaseAction=false;}
            
            
        }else{
            LOGGER.debug('case exists but closed  or case do does not exists so creating a new one ');
            String caseid=CustomInboundEmailHandlerHelperObj.createCaseRecord();
            String emailMessageid=CustomInboundEmailHandlerHelperObj.createEmailMessageRecord(caseId);
            if(emailMessageid!=null){
                returnFromperformCreateCaseAction=true;
            }else{
                returnFromperformCreateCaseAction=false;
            }
            
        }
        return returnFromperformCreateCaseAction;
    }
    
    
    //rule engine
    public  boolean ruleEngine(Messaging.InboundEmail email,String toEmailAddress){
        boolean returnCaseCreated=false;
        this.setInboundEmail(email);
        try{
            list<email_action__c> emailActions=[SELECT Id, Name, Exchange_Mailbox__c, Case_Record_Type__c, Case_Priority__c, Assigned_to_Queue__c, Action__c, Sequence__c,Auto_Response_Email_Template_Name__c,
                                                (SELECT Id, Name, Field__c, operator__c, Value__c, Email_Action__c FROM Email_Matching_Rules__r) 
                                                FROM Email_Action__c
                                                WHERE Exchange_Mailbox__c like :toEmailAddress order by Sequence__c ASC];
            
            if(emailActions.size()!=0){
                
                //check email action records
                for(email_action__c emailActionRec:emailActions){
                    //check for recall mails 
                    if(email.subject.startsWithIgnoreCase('recall:')){
                    	returnCaseCreated=performBlockAction(emailActionRec);
                    	return returnCaseCreated;
                	}
                    Boolean performAction=true;
                    //process rules for block action
                    if(emailActionRec.Action__c=='Block'){
                        for(Email_Matching_Rule__c emialMatchingRule:emailActionRec.Email_Matching_Rules__r){
                            
                            if(!processRule(emialMatchingRule)){
                                performAction=false;
                            }
                        }
                    }
                    //perform block action
                    if(performAction && emailActionRec.action__c=='Block'){
                        LOGGER.debug('executing Block Action');
                        returnCaseCreated=performBlockAction(emailActionRec);
                        break;//if block action is performed do not perform other action
                    }
                    //perform standard function
                    if(performAction && emailActionRec.Action__c=='Standard'){
                        LOGGER.debug('executing Standard Action');
                        returnCaseCreated=performCreateCaseAction(emailActionRec);
                        
                    }
                }
            }
        }catch(Exception e){
            LOGGER.debug('Email Action record not found. '+ e);
            
        }
        return returnCaseCreated;
    }    
}