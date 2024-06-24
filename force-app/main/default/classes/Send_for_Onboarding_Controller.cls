/*************************************************************************
    @ Author        : Prabhanshu Agrawal
    @ Date          : June 2015
    @ Test File     : Send_for_Onboarding_Controller_Test
    @ Description   : Controller class for Send_for_Onboarding visual force page
    @ Enhancement   : EN-0704 & EN-0762
    
    -----------------------------------------------------------------------------
    @ Last Modified By      :   Sandeep Dharwar
    @ Last Modified On      :   July 2015
    @ Last Modified Reason  :   DEF-1348- added contact information to the Visualforce Page
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   July 2015
    @ Last Modified Reason  :   Created a Custom Setting KYC_Locations__c to replace hard coded picklist values of KYC Location field as to impart best practices.
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   July 2015
    @ Last Modified Reason  :   DEF - 01352 : Changed Trade_Roles__c to Relationship_Roles__c as part of field API change
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   July 2015
    @ Last Modified Reason  :   EN - 787 - Removed Primary_Relationship__c references from the controller as the field is deleted and removed shouldrenderPBB as PBB ROA functionality is removed.
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   August 2015
    @ Last Modified Reason  :   EN - 0792 - Change of routing criteria and the condition to set shouldrenderCIBROA/shouldrenderCIBSA as per the new criteria. 
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   August 2015
    @ Last Modified Reason  :   DEF - 1411 - Included two new Locked Potential Client record types - one for SA and another for ROA
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   August 2015
    @ Last Modified Reason  :   DEF - 1385 - Included email template when a client is submitted for Onboarding
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   September 2015
    @ Last Modified Reason  :   EN - 0861 - Modified Body and Subject of the mail which is sent out when the client is submitted for Onboarding.
    
    @ Last Modified By      :   Manoj Gupta
    @ Last Modified On      :   Oct 2015
    @ Last Modified Reason  :   EN-0870 - Onboarding: Send a copy of the Submission PDF to Production Support CRM
    
    @ Last Modified By      :   Deeksha Singhal
    @ Last Modified On      :   Dec 2015
    @ Last Modified Reason  :   EN-0810 - Added one new email address in the to address list for SBMU Location

    @ Last Modified By      :   Petr Svestka
    @ Last Modified On      :   Jan 2016
    @ Last Modified Reason  :   EN-0691 - Added a branch to send the PDF to a distinct address for Commercial Banking clients

    @ Last Modified By      :   Petr Svestka
    @ Last Modified On      :   May 24 2016
    @ Last Modified Reason  :   US-1365 / DEF-001902 - change of logic for routing onboarding emails for CommB clients
    
    @ Last Modified By      :   Manoj Gupta
    @ Last Modified On      :   July 2016
    @ Last Modified Reason  :   EN-0390: Addition of Asia and China KYC Location

    @ Last Modified By      :   Andrei Olteanu
    @ Last Modified On      :   Jan 2017
    @ Last Modified Reason  :   DEF-2342: LEX Style for header
    
    @ Last modified By      : Manoj Gupta
    @ Last modified date    : Auguts 5 2016
    @ Last modified note    : US-1427 : OB: Addition of Cote d'Ivoire KYC Location (Code merged from Ivorycoast org)  

    @ Last modified By      : Jakub Oracki
    @ Last modified date    : Feb 9 2017
    @ Last modified note    : US-1322 : Customer Contact Phone Country Fetched

    @ Last modified By      : Chibuye Kunda
    @ Last modified date    : Feb 16 2018
    @ Last modified note    : US-2725 : Commb onboarding mail box
*************************************************************************/

public class Send_for_Onboarding_Controller {

    @testvisible private final Account acct;
    public boolean shouldrenderCIBROA {get; set;}
    public boolean shouldrenderCIBSA {get; set;}
    public String KYCLocation {get; set;}
    public boolean IsSARelationshipRoles {get; set;}
    public list<contact> contactList;
    public list<contact> clientContactList {get;set;}
    public list<contact> bankContactList {get;set;}
    public list<contact_Record_Type__c> crt;
    public list<user> cclist {get; set;}
    public Boolean isCommBClient { get; private set; }
    public Boolean isCibClient { get; private set; }
    public Boolean isLightning {get; set;}
    private List<SelectOption> sccTypeItems;
    @testvisible private OnboardingService onboardingService;

    private String gtRequestCode;


    public Boolean confirmed{
        get{
            if(confirmed==null)
                confirmed=false;

            return confirmed;
        }
        private set;}

    public Send_for_Onboarding_Controller(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>{'Business_Support_and_Recovery__c'
                    ,'Client_contacted_in_person__c'
                    ,'Entity_Actively_Trade__c'
                    ,'High_Risk_Business__c'
                    ,'Country_of_Revenue__c'
                    , 'Client_Co_ordinator__c'
                    , 'Percentage_Holding_Onboarding__c'
                    , 'Source_of_Funds_Type__c'
                    ,'KYC_Contact__r.Id'
                    ,'KYC_Contact__r.Name'
                    ,'KYC_Contact__r.Phone'
                    ,'KYC_Contact__r.Email'
                    ,'KYC_Contact__r.Phone_Country__c'
                    ,'Client_Co_ordinator__r.EmployeeNumber'
                    ,'Client_Co_ordinator__r.Name'
                    ,'Client_Co_ordinator__r.Email'
                    ,'Client_Coordinator_Division__c'
                    ,'Industry_Code__c'
                    ,'SA_Industry_Description__c'
                    ,'KYC_Location__c'
                    ,'ISIC_C_ode__c'});
        }
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        this.shouldrenderCIBROA = false;
        this.shouldrenderCIBSA = false;
        //this.IsSARelationshipRoles = False;
        this.acct = (Account) controller.getRecord();
        this.KYCLocation = this.acct.KYC_Location__c;
        this.contactList=[select id,name,phone,email,recordtypeID, Phone_Country__c from contact where accountId=:acct.id];
        this.ccList= [select name,phone,email from user where id in (SELECT UserId FROM AccountTeamMember where accountID=:acct.id and userId=:acct.Client_Co_ordinator__c)];

        WRP_Account accountObj = new WRP_Account(this.acct);

        isCommBClient = accountObj.isCommB();
        isCibClient = accountObj.isCIB();

        IsSARelationshipRoles = accountObj.isSARelationshipRoles();
        //TO BE CHANGED: we should consider change KYC_Location__c picklist values to simple codes and not long description
        gtRequestCode = accountObj.getGTRequestCode();


        if(gtRequestCode!=null && IsSARelationshipRoles){
            this.shouldrenderCIBSA = true;
        }else{
            this.shouldrenderCIBROA = true;
        }

        System.Debug('++'+this.shouldrenderCIBSA+'++'+this.shouldrenderCIBROA+'++'+acct.Relationship_Roles__c+'++'+ acct.Relationship_Roles__c == 'Client');

        populateContactList();
    }

    private Boolean isPageOriginLightning(Map<String, Object> params) {
        if (params.get('sfdcIFrameHost') != null ||
                params.get('sfdcIFrameOrigin') != null ||
                params.get('isdtp') == 'p1') {
            return true;
        } else {
            return false;
        }
    }

    public void populateContactList(){
        crt =[select name,contactRecordTypeID__c from contact_Record_Type__c];
        bankContactList =new List<Contact>();
        clientContactList = new List<Contact>();

        if(acct.KYC_Contact__c!=null){
            clientContactList.add(acct.KYC_Contact__r);
        }

        for(contact c : contactList){

            if(c.RecordTypeId == crt.get(0).contactRecordTypeID__c
                    && crt.get(0).Name=='Bank Contact Record Type'
                    && acct.KYC_Contact__c != c.Id){
                bankContactList.add(c);
            }

            else if(c.RecordTypeId == crt.get(1).contactRecordTypeID__c
                    && crt.get(1).Name=='Client Contact Record Type'
                    && acct.KYC_Contact__c != c.Id){
                clientContactList.add(c);
            }
        }
        system.debug('@@ Bank Contact Record Type' +bankContactList +'Client Contact Record Type'+clientContactList);
    }



    public boolean check(){

        //Sub Business Classification should be selected when available
        if(shouldrenderCIBSA){
            if(Account.SCC_Type__c.getDescribe().isAccessible() && getSCCTypeItems().size()>1 && acct.SCC_Type__c==null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select Business Sub Classification before clicking Confirm.');
                ApexPages.addmessage(myMsg);
            }
            validateClientContacts();
        }

        return !apexpages.hasmessages();
    }

    public void validateClientContacts(){

        for(Contact cont : clientContactList){
            if( Contact.Phone_Country__c.getDescribe().isAccessible() && String.isBlank(cont.Phone_Country__c)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select the Phone Country value related to the Contact Phone Number');
                ApexPages.addmessage(myMsg);
                break;
            }
        }

    }

    public Boolean updateContacts(){
        if(!shouldrenderCIBSA || clientContactList.size() == 0){
            return true;
        }

        Database.saveresult[] sr = Database.update(clientContactList, False);

        return processResults(sr, clientContactList);

    }

    public boolean updateacct(){

        Account[] acctsForUpdate = new Account[]{acct};
        Database.saveresult[] sr = Database.update(acctsForUpdate, False);
        return processResults(sr, acctsForUpdate);

    }

    private Boolean processResults(Database.saveresult[] results, Sobject[] records){
        Sobject[] failedRecords = new Sobject[]{};

        for(Integer i = 0; i < results.size(); i++){
            Database.saveresult result = results[i];

            if(result.isSuccess()){
                continue;
            }

            failedRecords.add(records[i]);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.getErrors()[0].getMessage()));
        }

        if(!failedRecords.isEmpty()){
            return false;
        }
        return true;
    }

    public PageReference onAfterConfirm(){

        if(confirmed){
            try{
                sendForOnboarding();

                Account client = new Account(Id = acct.Id);
                client.Status__c = AccountService.STATUS_SUBMITTED_FOR_ONBOARDING;
                if (shouldrenderCIBSA)
                    client.RecordTypeId = AccountService.RECORD_TYPE_LOCKED_POTENTIAL_GT;
                else
                        client.RecordTypeId = AccountService.RECORD_TYPE_LOCKED_POTENTIAL_CIF;

                update client;

                sendEmail();
            }
            catch(OnboardingService.OnboardingServiceException ex) {
                ApexPages.addMessages(ex);
                confirmed = false;
                return null;
            }
            catch(DMLException ex){
                ApexPages.addMessages(ex);
                confirmed = false;
                return null;
            }

            pagereference returnpageref = new PageReference('/' + acct.id);
            return returnpageref;
        }
        return null;
    }

    private void sendForOnboarding(){


        if( ( this.isCibClient || this.isCommBClient ) &&
                this.shouldrenderCIBSA &&
                gtRequestCode!=null) {
            //US-1189 - For SBSA Location customer data are sent for onboarding to GoldTier via web service
            onboardingService = new OnboardingService(acct.Id, gtRequestCode);
            onboardingService.sendClientsData();
        }
    }

    @testvisible private Messaging.EmailFileAttachment getOnboardingXmlAttachment(){
        Messaging.EmailFileAttachment efa;
        if(onboardingService!=null && onboardingService.getRequestBody()!=null){
            efa = new Messaging.EmailFileAttachment();
            efa.setFileName(Label.Onboarding_XML_Attachment_name);
            efa.setBody(Blob.valueOf(onboardingService.getRequestBody()));
        }

        return efa;
    }

    private Blob getOnboardingPDFContent(){

        PageReference pdf = Page.Send_for_Onboarding_pdf;           //get the onbaording pdf
        Blob pdf_body;

        //setup up pdf data
        pdf.getParameters().put( 'id', ( String )acct.Id );

        pdf.setRedirect( true );

        if(Test.isRunningTest())
            pdf_body = blob.valueOf('Unit.Test');
        else
                pdf_body = pdf.getContentAsPDF();

        return  pdf_body;                 //get the pdf

    }


    private Messaging.EmailFileAttachment getOnboardingPdfAttachment(){
        Messaging.EmailFileAttachment efa;
        efa = new Messaging.EmailFileAttachment();
        efa.setFileName(Label.Onboarding_Attachment_name);
        efa.setBody( getOnboardingPDFContent() );

        return efa;
    }

    private String getOnboardingEmailBody(){
        String plainBody;

        List<EmailTemplate> onboarding = new List<EmailTemplate>();
        try{
            onboarding.add([Select ID, Name, body from EmailTemplate where Name = 'Onboarding: Submit for Onboarding Template']);
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that email template Onboarding: Submit for Onboarding Template is not modified');
            ApexPages.addmessage(myMsg);
            return plainBody;
        }

        plainBody = onboarding[0].body;
        plainBody = plainBody.replace('{!$User.FirstName}', UserInfo.getFirstName());
        plainBody = plainBody.replace('{!$User.LastName}', UserInfo.getLastName());
        plainBody = plainBody.replace('{!$User.Email}', UserInfo.getUserEmail());
        plainBody = plainBody.replace('{!Account.Name}', acct.Name);
        plainBody = plainBody.replace('{!Account.Client_Co_ordinator__c}', acct.Client_Co_ordinator__r.Name);

        if( acct.Client_Coordinator_Division__c != null )
            plainBody = plainBody.replace('{!Account.Client_Coordinator_Division__c}', acct.Client_Coordinator_Division__c);

        plainBody = plainBody.replace('{!Account.Client_Coordinator_Email__c}', acct.Client_Co_ordinator__r.Email);

        return plainBody;
    }

    private Messaging.SingleEmailMessage getEmail(List<String> toAddresses
            , List<String> CcAddresses
            , List<String> BccAddresses
            , String emailBody
            , Messaging.EmailFileAttachment[] attachments){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // Sets the parameters of the email
        email.setSubject(Label.Subject_Onboarding_form +' '+ acct.Name);
        email.setToAddresses(toAddresses);
        email.setCcAddresses(CcAddresses);
        email.setBccAddresses(BccAddresses);
        email.setPlainTextBody(emailBody);

        if(attachments!=null && !attachments.isEmpty())
            email.setFileAttachments(attachments);

        return email;

    }

    /**
   * Method setting e-mail object while onboarding to KYC Team
   * @param attachment_list is list of attachments for the email
   * @return Message.SingleEmailMessage object will be returned
   */
    private Messaging.SingleEmailMessage getOnboardingNotificationToKYCTeamEmail(Messaging.EmailFileAttachment[] attachment_list) {
        Messaging.SingleEmailMessage email = UTL_Email.createEmails(UTL_EmailTemplate.getTemplateId('Onboarding_notification_to_KYC_Team'),
                this.acct.Id,
                new Set<String>{
                        SB_Parameters__c.getValues('KYC Team Email').Value__c
                },
                UTL_User.getCachedUser(UserInfo.getUserId()).Contact_Sync_ID__c);
        email.setCcAddresses(new String []{
                UserInfo.getUserEmail()
        });
        email.saveAsActivity = false;
        if (attachment_list != null && !attachment_list.isEmpty()) {
            email.setFileAttachments(attachment_list);
        }
        return email;
    }

    private Messaging.SingleEmailMessage getOnboardingEmail(String emailBody, Messaging.EmailFileAttachment[] attachments){
        list<String> toAddresses = new list<String>();
        list<String> CcAddresses = new list<String>();
        list<String> BccAddresses = new list<String>();


        //EN - 810 - Add logic to route mail to Mauritius system if KYC Location is SBMU and rest others to CIF.
        if (this.isCommBClient) {
            toAddresses.add(SB_Parameters__c.getValues( 'CommB_Inbox' ).Value__c);
        }
        // US-1189 decommission of email functionality
        //else if(this.shouldrenderCIBSA && this.KYCLocation == KYC_Locations__c.getValues('SBSA').Value__c) {
        //    toAddresses.add(Label.Gold_Tier_To_Address_Onboarding_form);
        //}               
        else if(!(this.shouldrenderCIBSA && gtRequestCode!=null))
        {
            toAddresses.add(Label.To_Address_Onboarding_form);
        }

        CcAddresses.add(UserInfo.getUserEmail());
        // EN-0870 Added CRM Data Mailbox email address among CClist
        //BccAddresses.add(Label.CIB_CRM_Production_Support_email_for_Onboarding);

        return getEmail(toAddresses,CcAddresses,BccAddresses,emailBody,attachments);

    }

    private Messaging.SingleEmailMessage getProductionSupportEmail(String emailBody, Messaging.EmailFileAttachment[] attachments){
        list<String> toAddresses = new list<String>();
        list<String> CcAddresses = new list<String>();
        list<String> BccAddresses = new list<String>();
        toAddresses.add(Label.CIB_CRM_Production_Support_email_for_Onboarding);

        return getEmail(toAddresses,CcAddresses,BccAddresses,emailBody,attachments);
    }

    @testvisible private void sendEmail(){
        String onboardingEmailBody = getOnboardingEmailBody();

        Messaging.EmailFileAttachment onboardingPdfAttachment = getOnboardingPdfAttachment();
        Messaging.EmailFileAttachment onboardingXmlAttachment = getOnboardingXmlAttachment();

        Messaging.EmailFileAttachment[] prodSupportEmailAttachments = new Messaging.EmailFileAttachment[]{};
        Messaging.EmailFileAttachment[] onboardingEmailAttachments = new Messaging.EmailFileAttachment[]{};
        if(onboardingXmlAttachment!=null)
            prodSupportEmailAttachments.add(onboardingXmlAttachment);
        if(onboardingPdfAttachment!=null){
            prodSupportEmailAttachments.add(onboardingPdfAttachment);
            onboardingEmailAttachments.add(onboardingPdfAttachment);
        }
        Messaging.SingleEmailMessage productionSupportEmail = getProductionSupportEmail(onboardingEmailBody, prodSupportEmailAttachments);
        Messaging.SingleEmailMessage onboardingEmail = getOnboardingEmail(onboardingEmailBody, onboardingEmailAttachments);

        Messaging.SingleEmailMessage[] toSend = new Messaging.SingleEmailMessage[] {onboardingEmail, productionSupportEmail};
        if(KYCLocation == 'SBSA - Standard Bank of South Africa Ltd' && isCibClient && IsSARelationshipRoles){
            toSend.add(getOnboardingNotificationToKYCTeamEmail(onboardingEmailAttachments));
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(toSend);

    }

    public PageReference confirm(){

        if(check() && updateacct() && updateContacts()){
            confirmed = true;
        }
        return null;
    }


    public List<SelectOption> getSCCTypeItems(){
        if(sccTypeItems==null){
            sccTypeItems = new List<SelectOption>{new SelectOption('','--None--')};
            Map<String, String> sccTypeValueToLabel = new Map<String,String>();
            Schema.DescribeFieldResult sscTypeDescribe = Account.SCC_Type__c.getDescribe();
            List<Schema.PicklistEntry> sccTypeEntries = sscTypeDescribe.getPicklistValues();

            for(Schema.PicklistEntry sccTypeEntrie:sccTypeEntries){
                sccTypeValueToLabel.put(sccTypeEntrie.getValue(), sccTypeEntrie.getLabel());
            }

            for(SubClassification_Mapping__c sscTypeMapping : [SELECT SubClassification__c FROM SubClassification_Mapping__c
            WHERE Client_Type__c=:acct.Client_Type_OnBoard__c
            and Business_Classification__c=:acct.Business_Classification__c]){
                String sccTypeLabel = sccTypeValueToLabel.get(sscTypeMapping.SubClassification__c);
                if(sccTypeLabel!=null)
                    sccTypeItems.add(new SelectOption(sscTypeMapping.SubClassification__c, sccTypeLabel));
            }
        }
        return sccTypeItems;
    }

}