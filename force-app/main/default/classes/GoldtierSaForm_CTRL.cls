/**
 * Created by mjaznicki on 27.06.2018.
 */

public with sharing class GoldtierSaForm_CTRL {

    private Account account{get;set;}
    private PageReference pageReference;
    public String cif {get;set;}
    public String services {get;set;}
    public String singleRevenue{get;set;}
    public String profClient {get;set;}
    public String statusReason {get;set;}
    public String offshore {get;set;}
    public String shell {get;set;}
    public String corespondent {get;set;}
    public String products {get;set;}
    public String toSendParam {get;set;}
    public String entityType {get;set;}
    public String entityClassification {get;set;}
    public String nature {get;set;}
    public String sourceWealth {get;set;}
    public String sourceFunds {get;set;}
    public String anticipatedLevel {get;set;}
    public String natureBusiness {get;set;}
    public String kycName {get;set;}
    public String kycTitle {get;set;}
    public String kycPhone {get;set;}
    public String kycId {get;set;}
    public String expectedIncome {get;set;}
    public Boolean toSend {get;set;}


    public GoldtierSaForm_CTRL() {
        account = [SELECT Id, Name FROM Account WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        Map<String,String> parametersMap = ApexPages.currentPage().getParameters();
        kycId = parametersMap.get('kycId');
        Contact contact = [SELECT Name, Phone, Title FROM Contact WHERE Id = :kycId];
        cif = parametersMap.get('cif');
        services = parametersMap.get('services');
        singleRevenue = parametersMap.get('singleRevenue');
        profClient = parametersMap.get('profClient');
        statusReason = parametersMap.get('statusReason');
        offshore = parametersMap.get('offshore');
        shell = parametersMap.get('shell');
        products = parametersMap.get('products');
        toSendParam = parametersMap.get('toSend');
        entityType = parametersMap.get('entityType');
        entityClassification = parametersMap.get('entityClassification');
        nature = parametersMap.get('nature');
        sourceWealth = parametersMap.get('sourceWealth');
        sourceFunds = parametersMap.get('sourceFunds');
        anticipatedLevel = parametersMap.get('anticipatedLevel');
        natureBusiness = parametersMap.get('natureBusiness');
        corespondent = parametersMap.get('corespondent');
        kycName = contact.Name;
        kycTitle = contact.Title;
        kycPhone = contact.Phone;
        expectedIncome = parametersMap.get('expectedIncome');

        if (toSendParam == 'true') {
            toSend = true;
        } else {
            toSend = false;
        }
    }

    public Account getAccount() {
        return account;
    }

    public PageReference saveAttach() {
        Blob blb;
        if (Test.isRunningTest()) {
            blb = Blob.valueOf('test blob');
        }
        else {
            pageReference = new PageReference('/apex/GoldtierSaFormDoc?cif=' + cif + '&id=' + account.Id + '&services=' +
                services + '&singleRevenue=' + singleRevenue + '&profClient=' + profClient +
                '&statusReason=' + statusReason + '&offshore=' + offshore + '&shell=' + shell + '&products=' + products
                + '&entityType=' + entityType + '&entityClassification=' + entityClassification + '&nature='
                + nature + '&sourceWealth=' + sourceWealth + '&sourceFunds=' + sourceFunds + '&anticipatedLevel=' + anticipatedLevel + '&natureBusiness=' + natureBusiness
                + '&corespondent=' + corespondent + +'&kycName=' + kycName + '&kycTitle=' + kycTitle + '&kycPhone=' + kycPhone + '&expectedIncome=' + expectedIncome);
            blb = pageReference.getContent();
        }
        String attachmentName = 'Goldtier SBSA Origination For_' + account.Name + '.pdf';
        Attachment attach = new Attachment();
        attach.body = blb;
        attach.Name = attachmentName;
        attach.ParentId = account.Id;
        insert attach;
        PageReference clientReference = new PageReference('/' + account.Id);
        clientReference.setRedirect(true);
        if (toSend) {
            Messaging.SingleEmailMessage email = UTL_Email.createEmails(UTL_EmailTemplate.getTemplateId('Generate_Goldtier_SA_Form_notification'),
                    account.Id, new Set<String>{
                            SB_Parameters__c.getValues('KYC Team Email').Value__c
                    }, UTL_User.getCachedUser(UserInfo.getUserId()).Contact_Sync_ID__c);
            email.setCcAddresses(new List<String>{
                    UserInfo.getUserEmail()
            });
            email.saveAsActivity = false;
            Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
            emailFileAttachment.setFileName(attach.Name);
            emailFileAttachment.setBody(attach.body);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    emailFileAttachment
            });
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                    email
            });
        }
        return clientReference;
    }

}