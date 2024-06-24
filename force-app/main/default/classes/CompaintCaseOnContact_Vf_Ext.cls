/***************************************
Created By: Manoj Gupta
Created on: 10th April 2017
Test Class: CompaintCaseOnContact_Vf_Ext_Test
Description: US - 1794: SF1/LEX: Enable new complaint functions for contacts

********************************************/

public class CompaintCaseOnContact_Vf_Ext {

    public String retUrlStr;
    public String saveNewStr;
    public String acctId;
    public String conId;
   
     public String saveUrlStr;  
     public String urlStr {get;set;} 
     public String urlStrSF1 {get;set;} 
        
     
    public CompaintCaseOnContact_Vf_Ext (ApexPages.StandardController controller) {
       Contact contactRecord;
    if(controller.getRecord().getSObjectType() == Schema.Contact.getSObjectType()){      
      contactRecord = (Contact) controller.getRecord();
    }
    

        retUrlStr = ApexPages.currentPage().getParameters().get('retURL');
        saveNewStr = ApexPages.currentPage().getParameters().get('save_new');
        saveUrlStr = ApexPages.currentPage().getParameters().get('saveURL');
        acctId = '';
        if(ApexPages.currentPage().getParameters().containsKey('cas4_lkid'))
            acctId = ApexPages.currentPage().getParameters().get('cas4_lkid');
    else if(contactRecord != null && String.isNotBlank(contactRecord.AccountId)){
      acctId = contactRecord.AccountId;
    }
            
          
        conId = '';
        if(ApexPages.currentPage().getParameters().containsKey('cas3_lkid'))
            conId = ApexPages.currentPage().getParameters().get('cas3_lkid');
    else if(contactRecord != null) {
      conId = contactRecord.Id;
    }
            
       
       
    }
    
    
    public void redirect(){
        
        urlStr = '';
        urlStrSF1 = '';
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
        String recordTypeId = d.getRecordTypeInfosByName().get(Label.Complaint_Case_RecType).getRecordTypeId();
        String keyPrefix = d.getKeyPrefix();
        String caseType = System.Label.Complaint_Case_Type;
        String caseSubject = System.Label.Complaint_Case_Subject;
        
        //urlStr = urlStr + '/' + keyPrefix + '/e?retURL=' + retUrlStr + '&RecordType=' + recordTypeId + '&nooverride=1';
        
        if(acctId!=null && acctId!='')
            urlStr = urlStr + '&cas4_lkid=' + acctId;
        
           
        if(conId!=null && conId!='')
            urlStr = urlStr + '&cas3_lkid=' + conId;
            urlStr = urlStr + '&cas5=' + caseType + '&cas14=' +caseSubject;
         

        urlStr = '/' + keyPrefix + '/e?retURL=' + retUrlStr + '&RecordType=' + recordTypeId + '&nooverride=1' + urlStr;
        urlStrSF1 = '/apex/ComplaintCase_LDS?retURL=' + retUrlStr + urlStr;

    }

 }