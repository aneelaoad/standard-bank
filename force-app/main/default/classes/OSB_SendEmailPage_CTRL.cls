/**
 * Controller class for OSB_sendEmailPage Visualforce Page
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 *
 **/
public class OSB_SendEmailPage_CTRL {
	public Id recordID {get;set;}
    public Contact contactRecord { get; set;}
    
    /**
     * Constructor used for the OSB_SendEmailPage (Visual force page)
     *
     * @param apex controller of contact type
     **/
    public OSB_SendEmailPage_CTRL(ApexPages.StandardController controller) {
        contactRecord =  (Contact) controller.getRecord();
        recordID = contactRecord.Id;
    }
    
    /**
     * Method is used to send AP invite Email
     *
     * @return PageReference to current record
     **/
    public PageReference sendApEmailInvite(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Contact> apContacts = SEL_Contacts.newInstance().selectById(new Set<Id>{recordID});
        OSB_SRV_EmailSender.newInstance().sendApInviteEmail(apContacts, uow);
        updateContact(contactRecord.Id);
        try{
            uow.commitWork(); 
        }catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_SendEmailPage_CTRL.class.getName());
        }
        PageReference currentPage = new PageReference('/' + recordID);
        return currentPage;
    }
    
    /**
     * Used to update the the contact record after the invite email has been sent
     *
     * @param Contact ID of contact to update
     **/
    @future
    private static void updateContact(Id contactId){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
		Contact contact = new Contact(Id = contactId);
        User AdminUser = UTL_User.getSfAdministrationUser();
        contact.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INVITE_SENT;
        contact.OSB_Date_Invite_Sent__c = system.now();
        if(contact.RecordTypeId == UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK)){
           contact.OSB_IsCommunityUser__c = true;
           contact.ownerId =AdminUser.Id;  
        }
        uow.registerDirty(contact);
		uow.commitWork();
    }
}