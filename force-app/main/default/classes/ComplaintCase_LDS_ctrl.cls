/***************************************
Created By: Manoj Gupta
Created on: 10th April 2017
Test Class: ComplaintCase_LDS_ctrl_Test
Description: US - 1794: SF1/LEX: Enable new complaint functions for contacts

********************************************/


public Class ComplaintCase_LDS_ctrl{
    public Case caserec{get;set;}
    public string errorMsginsert{get;set;}
    public string errorMsgcrinsert{get;set;}
    public string navigateurl{get;set;}
    private string keyprefix;
    private String contId;
    private String accId;
    
 
    
    public ComplaintCase_LDS_ctrl(ApexPages.StandardController controller){
         caserec = (Case) controller.getRecord();
         errorMsginsert='';
         errorMsgcrinsert = '';
         navigateurl = '';
         
         Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
         String recordTypeId = d.getRecordTypeInfosByName().get(Label.Complaint_Case_RecType).getRecordTypeId();
         keyPrefix = d.getKeyPrefix();
         
         caserec.RecordtypeId = recordTypeId;
         
         if(ApexPages.currentPage().getParameters().containsKey('cas4_lkid') && ((ApexPages.currentPage().getParameters().get('cas4_lkid') != null) && (ApexPages.currentPage().getParameters().get('cas4_lkid') != ''))){
             caserec.AccountID = ApexPages.currentPage().getParameters().get('cas4_lkid');
             accId = ApexPages.currentPage().getParameters().get('cas4_lkid');
         }else{
             caserec.AccountID = null;
         }
  
         
         if(ApexPages.currentPage().getParameters().containsKey('cas3_lkid') && ((ApexPages.currentPage().getParameters().get('cas3_lkid') != null) && (ApexPages.currentPage().getParameters().get('cas3_lkid') != ''))){
             caserec.ContactID= ApexPages.currentPage().getParameters().get('cas3_lkid');
             contId = ApexPages.currentPage().getParameters().get('cas3_lkid');
         }else{
             caserec.ContactID = null;
         } 
         
         caserec.Priority = 'High';
         caserec.Subject = 'Client Complaint';
         caserec.Origin = 'General Interaction / Face to Face';
         caserec.Type = 'Complaint';
        
    }
    
    public void savecase(){
        Boolean caseinsertsuccess = false;
        errorMsginsert='';
        errorMsgcrinsert = '';
        navigateurl = '';
        system.debug('Inside save ...');
        try{
            insert caserec;
            navigateurl = '/'+caserec.ID;
            system.debug('Inside save try ...'+caserec.Id);
            caseinsertsuccess = true;
        }catch(DmlException e){
            system.debug('An exception during saving data ...' + e.getdmlMessage(0));
            errorMsginsert = e.getdmlMessage(0);
            caseinsertsuccess = false;
            system.debug('Inside save catch Case...'+errorMsginsert);
        }
        
    }
    
    public Pagereference cancelcase(){
        
            navigateurl = '/'+contId;
            
        Pagereference pg = new Pagereference(navigateurl);
        pg.setRedirect(true);
        return pg;
    }
}