/*****************************************************************************************************\
    @ Func Area     : Contact list view, Campaign members, Campaign member hosts
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @ Test File     : Test Method TestCampaignMemberHostAssignerController.cls
    @ Description   : Case#1168
                      Controller class for the Visualforce pages CampaignMemberHostAssigner.page. The page is used to
                      add members and additional hosts from a Contact List View
   
    @ Modification Description : API Version moved from 24 to 25         
                                 Case #6521- Change contact to use TestFatcory  
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 5 Feb 2013
    @ Last Modified Reason  :  EN 12 :-
                               Added the error message in a custom setting
                               API version moved from 25 to 27. 
******************************************************************************************************/

public class CampaignMemberHostAssignerController {

    public final Contact[] cont;
    public Campaign lookupCamp {get;set;}
    public CampaignMemberStatus pickStatus {get;set;}
    private Id selectedCampId;
    public String campId {get;set;}
    String status = null;
    String radio = 'nooverride';
    Boolean userHost = false;
    public List<SelectOption> chkOptions;
    public List<SelectOption> radioOptions;
    public List<SelectOption> options {get;set;}
    private Set<Id> contIds = new Set<Id>();
    private Boolean addMembers = false;
    public Integer newMemCount = 0;
    public Integer updateMemCount = 0;
    public Boolean lockThis = false;
    public Boolean disableThis = true;
    public String retURL{get;set;}
    private String SupportEmailAddress = '';
    private Environment_Variable__c settings = null;
    public Boolean camLocked {get;set;}
    public static final String POCKET_RSVP_PARAM_NAME = 'PocketRsvp_User';


    //Class Constructor
    public CampaignMemberHostAssignerController(ApexPages.StandardSetController controller){

        //get current page return URL
        PageReference pageRef = ApexPages.currentPage();
        retURL = pageRef.getParameters().get('retURL');

        if(!Test.isRunningTest()){
            //Get current contect and user information
            this.cont = controller.getSelected();
        }else if(Test.isRunningTest()){
            //Get all the contact records not just the seleted once
            this.cont = controller.getRecords();
        }
        if(cont.size() < 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,ErrorMessages__c.getValues('No_Contact_Selected').Error_String__c));
            lockThis=true;
            return;
        }

        for(Contact c : cont){
            contIds.add(c.Id);
        }

        //Get CRM Production support email address from custom settings in order to email
        //error messages
        this.settings = Environment_Variable__c.getInstance();
        this.SupportEmailAddress = settings.CRM_Production_Support__c;

    }

    //Class Constructor
    public CampaignMemberHostAssignerController(){
        //Reset select lists
        chkOptions = new List<SelectOption>();
        radioOptions = new List<SelectOption>();
        options = new List<SelectOption>();

        //Get CRM Production support email address from custom settings in order to email
        //error messages
        this.settings = Environment_Variable__c.getInstance();
        this.SupportEmailAddress = settings.CRM_Production_Support__c;
    }

    //Add new members to a campaign from the Contact list view
    public PageReference AddCamp(){

        Set<Id> existingIds = new Set<Id>();
        Set<Id> newIds = new Set<Id>();
        List<String> newMemIds = new List<String>();

        //Get existing members that are in the new member list to be added and update status if user selected this option
        List<CampaignMember> existingMemList = [select Id, Status, ContactId, CampaignId from CampaignMember where ContactId IN: contIds and CampaignId =: selectedCampId];

        for(Integer x=0;x<existingMemList.size();x++){

            if(radio.equals('override')){
                //update existing member status
                existingMemList[x].Status = this.status;
                updateMemCount++;
            }

            //add existing contact id to set
            System.debug('1 - Contact ID = ' + existingMemList[x].ContactId);
            existingIds.add(existingMemList[x].ContactId);
        }

        List<CampaignMember> memList = new List<CampaignMember>();

        for(Contact c : cont){

            System.debug('2 - Contact ID = ' + c.Id);

            //only add non existing members
            if(existingIds.contains(c.Id)){
                System.debug('Member exists, do not add to campaign');

            }else{
                System.debug('Member DO NOT exists, add to campaign');
                CampaignMember mem = new CampaignMember();
                mem.Status = this.status;
                mem.ContactId = c.Id;
                mem.CampaignId = selectedCampId;

                memList.add(mem);

                //count
                newMemCount++;
            }

            //add all selected id's to set so the user have the ability to add new nosts to all selected contacts and not
            //just new once.
            newIds.add(c.Id);
        }
        if(existingMemList.size() > 0){
            try{
                Database.saveresult[] s = Database.update(existingMemList, false);
            }catch(System.DMLException ex){
                System.debug('Error when updating existing members status' + ex.getMessage());
                sendErrorMail('Error when updating existing members status : CampaignMemberHostAssignerController.cls : AddCamp()' + ex.getMessage());
            }
        }
        try{
            if(memList.size()>0) {
                List<Database.SaveResult> sResults = Database.insert(memList,false);
                for(Database.SaveResult result : sResults){

                    if (result.isSuccess()){
                        newMemIds.add(result.getId());
                    }
                }
            }
        }catch(System.DMLException ex){
            System.debug('Error when adding new members to the Object CampaignMember' + ex.getMessage());
            sendErrorMail('Error when adding new members to the Object CampaignMember : CampaignMemberHostAssignerController.cls : AddCamp()' + ex.getMessage());
        }

        if(userHost){

            List<Campaign_Member_Host__c> memberList = [Select Id From Campaign_Member_Host__c Where Member__c =: contIds AND Campaign__c =: selectedCampId];

            List<Campaign_Hosts__c> hostList = new List<Campaign_Hosts__c>();
            System.debug('Get name of user to be add as host');
            String uName = UserInfo.getName();
            List<Contact> BankContact = [select Name from Contact where Name =: uName limit 1];

            System.debug('Name is ' + uName);

            if(BankContact.size() > 0){
                System.debug('Loop through the new members to add user as hosts');
                for(Integer x=0;x<memberList.size();x++){

                    Campaign_Hosts__c h = new Campaign_Hosts__c();
                    h.Bank_Contact__c = BankContact[0].Id;
                    h.Host_Id__c = memberList[x].Id + '' + BankContact[0].Id;
                    h.Campaign_Member_Host__c = memberList[x].Id;

                    hostList.add(h);

                }
                System.debug('Try to upsert now...');
                try{
                    upsert hostList Host_Id__c;
                }catch(System.DMLException ex){
                    System.debug('Adding owner as a host to selected memeber Failed: ' + ex.getMessage());
                    sendErrorMail('Adding owner as a host to selected memeber Failed : CampaignMemberHostAssignerController.cls : AddCamp()' + ex.getMessage());
                }
            }

        }

        List<Campaign_Member_Host__c> newMembers = [Select Id From Campaign_Member_Host__c Where Member__c IN : newIds AND Campaign__c =: selectedCampId];

        if(addMembers){

            Pagereference addMemPage = Page.CampaignHostAssigner;
            addMemPage.getParameters().put('ids',memberIds(newMembers));
            addMemPage.getParameters().put('campid',selectedCampId);
            addMemPage.getParameters().put('returl',retURL);

            addMemPage.setRedirect(false);

            return addMemPage;

        }else{

            Pagereference lastPage = Page.CampaignMemberAddingComplete;
            lastPage.getParameters().put('returl',retURL);
            lastPage.getParameters().put('ncount',String.valueOf(newMemCount));
            lastPage.getParameters().put('ucount',String.valueOf(updateMemCount));
            lastPage.getParameters().put('campname',campId);
            lastPage.getParameters().put('campstatus',status);

            lastPage.setRedirect(false);

            return lastPage;
        }

    }

    //Id's of all the selected conatcts in the contact list view
    public String memberIds(List<Campaign_Member_Host__c> cmh) {
        String ids = '';

        for (Campaign_Member_Host__c cm : cmh){
            ids = ids + cm.Id + '-';
        }
        if(ids.length() > 0){
            ids = ids.substring(0,ids.length()-1);
        }

        return ids;
    }

    //Below is a few methods used for disply logic.
    public Boolean getDisableThis(){
        return this.disableThis;
    }
    public Boolean getLockThis(){
        return this.lockThis;
    }

    public Integer getNewMemCount(){
        return this.newMemCount;
    }
    public Integer getUpdateMemCount(){
        return this.updateMemCount;
    }

    public String getStatus(){
        return this.status;
    }
    public void setStatus(String status){
        this.status = status;
    }

    public String getRadio(){
        return this.radio;
    }
    public void setRadio(String radio){
        this.radio = radio;
    }
    public Boolean getUserHost(){
        return this.userHost;
    }
    public void setUserHost(Boolean userhost){
        this.userHost = userhost;
    }

    public PageReference AddCampPlusMember(){
        addMembers = true;

        return AddCamp();

    }

    public PageReference Previous(){
        PageReference pageRef = Page.CampaignMemberHostAssigner;

        pageRef.setRedirect(false);
        return pageRef;
    }

    public PageReference Done(){
        PageReference pageRef = ApexPages.currentPage();
        PageReference ret = new PageReference(pageRef.getParameters().get('returl'));


        return ret;
    }

    public PageReference Cancel(){

        PageReference ret = new PageReference(retURL);

        return ret;
    }

    //Display the radion selection on the page
    public List<SelectOption> getRadioSelect() {
        radioOptions = new List<SelectOption>();
        radioOptions.add(new SelectOption('nooverride','Do not override the member status'));
        radioOptions.add(new SelectOption('override','Override the member status'));
        return radioOptions;
    }

    //Display the checkbox selection on the page
    public List<SelectOption> getCheckBox() {
        chkOptions = new List<SelectOption>();
        chkOptions.add(new SelectOption('true','I am hosting these members'));
        return chkOptions;
    }

    //Get all the current Campaign status values, there are always two default but uses can also add new once and rename existing once per Campaign
    public void fetchLabels() {

        if (campId != null){
            options = new List<SelectOption>();
            List<Campaign> theCampaign = [select Id, Lock_Campaign__c from Campaign where Name = :campId limit 1];

            if (theCampaign.size() > 0) {
                camLocked = theCampaign[0].Lock_Campaign__c;
                if(!camLocked || UserInfo.getName() == SB_Parameters__c.getValues(POCKET_RSVP_PARAM_NAME).Value__c){
                    selectedCampId = theCampaign[0].Id;
                    for(CampaignMemberStatus c : [select Label From CampaignMemberStatus where CampaignId =: selectedCampId order by SortOrder asc]){
                        options.add(new SelectOption(c.Label,c.Label));
                    }
                    disableThis = false;
                }
            }
        }
    }
    //The lookup field that allows a user to select a Campaign from a lookup dialog to Campaign
    public Campaign getlookupCamp(){
        return [select ParentId from Campaign limit 1];
    }

    //Function that sends an email to the CRM production support
    //team when an exception was thrown. Email address gets retrieved from the 
    //custom settings Environment_Variable__c                   
    public void sendErrorMail(String msg){
        if (SupportEmailAddress == null)
        {
            SupportEmailAddress = 'testtest@test.co.za';
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {SupportEmailAddress};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex Error in : ' + UserInfo.getOrganizationName());
        mail.setSubject('Apex Error related to Campaign Members Hosts');
        mail.setPlainTextBody('Error in Class: CampaignMemberHostAssignerController\n' + msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}