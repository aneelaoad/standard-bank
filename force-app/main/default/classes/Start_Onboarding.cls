/*************************************************************************
    @ Author        : Abhishek Vaideeswaran
    @ Date          : August 2015
    @ Test File     : Start_Onboarding_Test
    @ Description   : Controller class for Start_Onboarding visual force page
    @ Enhancement   : EN-0792
    
    
    @ Last modified: Jiri Lahoda
    @ Last modified date: 10/8/2015
    @ Last modified note: SFDC tag update when onboarding starts in SFDC
    
    @ Last Modified By  :   Abhishek Vaideeswaran        
    @ Last Modified On  : August 2015
    @ Modification Description: EN - 0792 : Renaming of New Corporate and Investment Banking Entity (Africa) to Potential (CIF) and 
                                            New Corporate and Investment Banking Entity (South Africa / International) to Potential (Goldtier)
                                            and hence removing the reference
                                            
    @ Last modified: Manoj Gupta
    @ Last modified date: Oct 2015
    @ Last modified note: EN-0845 Updated the page reference to open the account in edit mode and updated the return URL  

    @ Last modified: Petr Svestka
    @ Last modified date: Jan 2016
    @ Last modified note: EN-961 added defaulting based on the primary relationship holder
    
    @ Last modified: Manoj Gupta
    @ Last modified date: July 2016
    @ Last modified note: US-1390 Introduced DML Exception message to display validation error message
    
    @ Last modified: Andrei Olteanu
    @ Last modified date: Oct 2016
    @ Last modified note: EN-0892 DEF-002170 added LEX styling
    
    @ Last modified: Manoj Gupta
    @ Last modified date: Auguts 5 2016
    @ Last modified note: US-1427 : OB: Addition of Cote d'Ivoire KYC Location  (Code merged from Ivory Coast org)
    
    @ Last Modified By  : Upender Nath Sharma
    @ Last Modified On  : Jan 13, 2017
    @ Modification Description : Test Class Failure , Debug Statements
*************************************************************************/

public class Start_Onboarding {
    private final Account acct;
    
    public Boolean isLightning {get; set;}
    public boolean IsSARelationshipRoles {get; set;}
    public String catchex{get;set;}
    
    public Start_Onboarding(ApexPages.StandardController controller){
        this.acct = (Account) controller.getRecord();
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        IsSARelationshipRoles = false;
        System.Debug('++'+acct.KYC_Location__c+'++'+acct.Relationship_Roles__c);

        if (this.acct.primary_relationship_holder__c == 'Commercial Banking') {
            this.acct.kyc_location__c = 'SBSA - Standard Bank of South Africa Ltd';
            this.acct.relationship_roles__c = 'Client';
        }
    }

    public Boolean updateacct(){
        Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes =  Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id potentialcifRecTypeId = mapAccountRecordTypes.get('Potential (CIF)').getRecordTypeId(); 
        Id potentialgtRecTypeId = mapAccountRecordTypes.get('Potential (Goldtier)').getRecordTypeId();
        
       
        //Change the record type of account and update KYC Location and Relationship Roles
        list<Account> accountrecord = [ SELECT Id, RecordTypeId, Relationship_Roles__c, KYC_Location__c, Description 
                                        FROM Account 
                                        WHERE Id = : acct.id];
        
        //Setting KYC Location and Relationship Roles to newly selected values
        if(accountrecord.isEmpty()){
            catchex = 'No Client with Id ' + acct.id;
            return null;
        }

        Account acc = accountrecord[0];
         
        acc.KYC_Location__c = acct.KYC_Location__c;
        acc.Relationship_Roles__c = acct.Relationship_Roles__c;

        if(acc.KYC_Location__c == 'NONE - Asia (for Asia User Only)'
            && acc.Relationship_Roles__c != 'potential client'){
            catchex = 'For this KYC Location you can only select Potential Client as a Relationship Role';
            return false;
        }
        
        //To check if relationship roles has Client/Corresponding Bank/Managed Fund and set IsSARelationshipRoles to true if it does
        System.Debug('++'+acc.KYC_Location__c+'++'+acc.Relationship_Roles__c);
        WRP_Account accountObj = new WRP_Account(acc);


        if(accountObj.getRecord().Relationship_Roles__c != null){

             this.IsSARelationshipRoles = accountObj.isSARelationshipRoles();

        }
        else{
            catchex = 'Please enter value for Relationship Roles';
            return false;
        }
        /* Checks if KYC Location is SBSA and if the IsSARelationshipRoles boolean is set to true. 
        If so, Recordtype of the account is changed to Potential (Goldtier) 
        else to Potential (CIF) */ 
            
        if(accountObj.getGTRequestCode()!=null && IsSARelationshipRoles) {            
            acc.RecordTypeId = potentialgtRecTypeId ;           
        }    
        else{
            acc.RecordTypeId = potentialcifRecTypeId; 
        }
        
        
        if(Test.isRunningtest() 
            && acc.Description == 'TEST_Cover_DML_Exception_2016-03-22'){
                     acc.RecordTypeId = '001000000000000';
        }
                         
        try{
            update acc;
            return true; 
        }
        catch(System.DmlException e) {
            ApexPages.addMessage(
                new ApexPages.Message(  ApexPages.Severity.ERROR, 
                                        e.getDmlMessage(0)));
            catchex = e.getDmlMessage(0);
            return false;
        }
    }
    
    public PageReference selectconfirm(){
        if(updateacct()){
            PageReference pg = new PageReference('/'+acct.ID+'/e?retURL'+'='+acct.ID);
            return pg;
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, catchex);
            ApexPages.addmessage(myMsg);
            return null;
        }
    }
    
    public void selectconfirmLDS() {
        if(!updateacct()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, catchex);
            ApexPages.addmessage(myMsg);
        }
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
}