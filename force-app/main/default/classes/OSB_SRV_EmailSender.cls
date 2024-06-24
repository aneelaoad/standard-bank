/**
 * Service class handling Sending of user emails for OneHub
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 *
 **/
public class OSB_SRV_EmailSender implements IService {

    /**
     * Used to create a new instance of the class
     * @return IService new instance
     **/
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
     * Used to create a new interface for the methods
     *
     **/
    public interface IService {
        void sendApInviteEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendDPNpInviteEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendSignUpEmails(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendApAccessDeclinedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendApAccessApprovedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendDpNpAccessApprovedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendDpNpAccessDeclinedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendDpNpAccessRemovedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
        void sendSolutionEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow,String solutionName);
        void sendReinviteEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow);
    }
	
    /**
     * Used to send email invite to contact 
     * @param contacts list of contacts
     * @param uow unit of work for email 
     *
     **/
    public void sendApInviteEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createCommunityEmailAP(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        } 
    }
    
    /**
     * Used to send email invite to contact 
     *
	 * @param contacts list of contact records
	 * @param uow unit of work for email
     * @param solutionName name of the solution
     **/
    public void sendSolutionEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow,String solutionName){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createCommunitySolutionEmail(contacts,solutionName);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        } 
    }
  
    /**
    * Sends out one or emails to clients that have been invited by an Ap or Dp
    *
    * @param contacts list of contacts
    * @param uow unit of work for email 
    **/
    public void sendDPNpInviteEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){ 
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createCommunityEmailDP_NP(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        } 
    }
    
    /**
    * Sends out one or emails to clients that have signed up. Two emails are sent per contact
    * First email is sent to the contact that signed up, the next is sent to the user that invited said contact
    *
    * @param contacts list of contacts
    * @param uow unit of work for email 
    **/
    public void sendSignUpEmails(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createSignUpEmails(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        } 
    }

    /**
    * Sends out one or emails to AP contacts whose access has been declined
    *
    * @param contacts list of contacts
    * @param uow unit of work for email 
    **/
    public void sendApAccessDeclinedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createApAccessDeclinedEmail(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        }
    }

    /**
    * Sends out one or emails to Ap contacts whose access has been approved 
    *
    * @param contacts list of contacts
    * @param uow unit of work for email 
    **/
    public void sendApAccessApprovedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createApAccessApprovedEmail(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        }  
    }

   /**
    * Sends out one or emails to Dp/Np contacts whose access has been approved
    *
    * @param contacts list of contacts
    * @param uow unit of work for email 
    **/
    public void sendDpNpAccessApprovedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Contact> reinvitedContacts = new List<Contact>();
        List<Contact> existingContacts = new List<Contact>();
        
        for(Contact contact: contacts){
            if(contact.OSB_Contact_Re_invited__c){
                reinvitedContacts.add(contact);
            }else{
                existingContacts.add(contact);
            }
        }
        if(!reinvitedContacts.isEmpty()){
            List<Messaging.SingleEmailMessage> reinviteEmails = OSB_SRV_EmailBuilder.newInstance().createDpNpReinviteAccessApprovedEmail(contacts);
            for(Messaging.SingleEmailMessage reinviteEmail : reinviteEmails){
                uow.registerEmail(reinviteEmail);   
            }
        }
        if(!existingContacts.isEmpty()){
            List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createDpNpAccessApprovedEmail(existingContacts);
            for(Messaging.SingleEmailMessage email : emails){
                uow.registerEmail(email);   
            }
        }
    }

    /**
    * Sends out one or emails to Dp/Np contacts whose access has been declined
    *
    * @param contacts list of contacts
    * @param uow unit of work for email 
    **/
    public void sendDpNpAccessDeclinedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createDpNpAccessDeclinedEmail(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        }
    }
    
    /**
    * Sends out one or emails to Dp/Np contacts whose access has been removed
    *
    * @param contacts list of contacts
    * @param uow unit of work for email 
    **/
    public void sendDpNpAccessRemovedEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createDpNpAccessRemovedEmail(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        } 
    }
    
    /**
     * Sends out one or emails to Dp/Np contacts that have been reinvited to OneHub
     *
     * @param contacts list of contacts
     * @param uow unit of work for email 
     **/
    public void sendReinviteEmail(List<Contact> contacts, fflib_ISObjectUnitOfWork uow){
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createCommunityReinviteEmailDP_NP(contacts);
        for(Messaging.SingleEmailMessage email : emails){
            uow.registerEmail(email);   
        }
    }
}