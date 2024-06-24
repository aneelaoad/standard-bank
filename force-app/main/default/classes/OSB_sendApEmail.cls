/**
 * Class used to send email invites to contact. Detail button on Contact called OneHub Send Email
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 *
 **/
public without sharing class OSB_sendApEmail{
    
    public Id recordID {get;set;}
    public Contact contactRecord { get; set;}
    
    /**
     * Constructor used for the OSB_SendEmailPage (Visual force page)
     *
     * @param apex controller of contact type
     **/
    public OSB_sendApEmail(ApexPages.StandardController controller) {
        contactRecord =  (Contact) controller.getRecord();
        recordID = contactRecord.Id;
    }
    
  	/**
     * Returns a pagereference and sends a email to the Contact email with a link to the sign up page for OneHub
     *
     * @return PageReference to current record
     **/
    public PageReference sendEmail(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Contact> apContact = SEL_Contacts.newInstance().selectById(new Set<Id>{recordID});
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createCommunityEmailAP(apContact);
        updateContact(contactRecord.Id);
        try{
            for(Messaging.SingleEmailMessage Email : emails){
              uow.registerEmail(Email);   
            } 
            uow.commitWork(); 
        }catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_sendApEmail.class.getName());
        }
        PageReference currentPage = new PageReference('/' + recordID);
        return currentPage;
    }
  
    /**
     * Sends out one or multiple DP/NP emails to clients
     *
     * @param Contact list sent from OSB_TeamProfile_Ctrl
     **/
    public static void sendDPNpLink (List<Contact> inviteList){ 
        try{ 
            fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createCommunityEmailDP_NP(inviteList);
            for(Messaging.SingleEmailMessage Email : emails){
              uow.registerEmail(Email);   
            } 
            uow.commitWork(); 
        }catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_sendApEmail.class.getName());
        }
    }

    /**
     * Sends out one or multiple DP/NP emails to clients
     *
     * @param Contact list sent from OSB_TeamProfile_Ctrl
     **/
    public static void sendReinviteLink (List<Contact> inviteList){
        try{ 
            fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance().createCommunityReinviteEmailDP_NP(inviteList);
            for(Messaging.SingleEmailMessage Email : emails){
                uow.registerEmail(Email);   
            } 
            uow.commitWork(); 
        }
        catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_sendApEmail.class.getName());
        }
    }

    /**
     * Used to update the date invite sent,owner of record and Boolean if they are a community user of the client AP/DP/NP
     *
     * @param Contact ID to update
     **/
    @future
    private static void updateContact(Id contactId){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
		Contact contact = new Contact(Id = contactId);
        User AdminUser = UTL_User.getSfAdministrationUser();
        contact.OSB_Date_Invite_Sent__c = system.now();
        if(contact.RecordTypeId == UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK)){
           contact.OSB_IsCommunityUser__c = true;
           contact.ownerId =AdminUser.Id;  
        }
        uow.registerDirty(contact);
		uow.commitWork();
    }
}