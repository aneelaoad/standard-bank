public Class Opprtunity_New_LDS_ctrl{
    public Opportunity opprec{get;set;}
    public string OppDesc{get;set;}
    public string errorMsginsert{get;set;}
    public string errorMsgcrinsert{get;set;}
    public string navigateurl{get;set;}
    private string keyprefix;
    private String contId;
    private String campId;
    private String accId;
    
    public String Enddatestring{
        get;
        set {
            Enddatestring = value;
            
            opprec.CloseDate = constructDate(Enddatestring);
        }
    }
    
    public String StartDateString{
        get;
        set {
            StartDateString = value;
            
            opprec.Start_Date__c = constructDate(StartDateString);
        }
    }
    
    private Date constructDate(String value) {
        Date d = null;
        
        if (String.isEmpty(value) || !value.contains('/')) {
            return d;
        }
        
        List<String> dateSplit = value.split('/');
        if (dateSplit.size() != 3) {
            return d;
        }
        
        Integer year = Integer.valueOf(dateSplit[2]);
        Integer month = Integer.valueOf(dateSplit[1]);
        Integer day = Integer.valueOf(dateSplit[0]);
        
        d = Date.newInstance(year, month, day);
        
        return d;
    }   
    
    public Opprtunity_New_LDS_ctrl(ApexPages.StandardController controller){
         opprec = (Opportunity) controller.getRecord();
         errorMsginsert='';
         errorMsgcrinsert = '';
         navigateurl = '';
         
         Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
         String recordTypeId = d.getRecordTypeInfosByName().get(Label.Opportunity_Create_Type).getRecordTypeId();
         keyPrefix = d.getKeyPrefix();
         
         opprec.RecordtypeId = recordTypeId;
         
         if(ApexPages.currentPage().getParameters().containsKey('accid') && ((ApexPages.currentPage().getParameters().get('accid') != null) && (ApexPages.currentPage().getParameters().get('accid') != ''))){
             opprec.AccountID = ApexPages.currentPage().getParameters().get('accid');
             accId = ApexPages.currentPage().getParameters().get('accid');
         }else{
             opprec.AccountID = null;
         }
         
         if(ApexPages.currentPage().getParameters().containsKey(Label.Cross_Sell_Opportunity+'_lkid') && ((ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity+'_lkid') != null) && (ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity+'_lkid') != ''))){
             opprec.Parent_Opportunity__c = ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity+'_lkid');
         }else{
             opprec.Parent_Opportunity__c = null;
         }
         
         if(ApexPages.currentPage().getParameters().containsKey('opp14')){
             OppDesc = ApexPages.currentPage().getParameters().get('opp14'); 
         }    
         
         if(ApexPages.currentPage().getParameters().containsKey('conid')){
             contId = ApexPages.currentPage().getParameters().get('conid');
         }  
         
         if(ApexPages.currentPage().getParameters().containsKey('campid')){
             campId = ApexPages.currentPage().getParameters().get('campid');
             opprec.CampaignId = campId;
         }else{
             opprec.CampaignId = null;
         }
           
         if(OppDesc !=null && OppDesc !=''){
             opprec.Description = OppDesc;
         }else{
             opprec.Description = '';
         }
         
         opprec.StageName = '1 - Lead';
         opprec.Probability = 10;
         opprec.Lead_Source__c = 'Cross Sell';
        
    }
    
    public void saveoppty(){
        Boolean opptyinsertsuccess = false;
        errorMsginsert='';
        errorMsgcrinsert = '';
        navigateurl = '';
        system.debug('Inside save ...');
        try{
            insert opprec;
            navigateurl = '/'+opprec.ID;
            system.debug('Inside save try ...'+opprec.Id);
            opptyinsertsuccess = true;
        }catch(DmlException e){
            system.debug('An exception during saving data ...' + e.getdmlMessage(0));
            errorMsginsert = e.getdmlMessage(0);
            opptyinsertsuccess = false;
            system.debug('Inside save catch Opportunity...'+errorMsginsert);
        }
        
        try{
            if(contId != null && contId != '' && opptyinsertsuccess){
                OpportunityContactRole ocrrec = new OpportunityContactRole(ContactId = contId, IsPrimary = true, OpportunityId = opprec.Id );
                insert ocrrec;
            }
        }catch(DmlException e){
            system.debug('An exception during saving data ...' + e.getdmlMessage(0));
            errorMsgcrinsert = e.getdmlMessage(0);
            system.debug('Inside save catch Contact Role...'+errorMsgcrinsert);
        }
    }
    
    public Pagereference canceloppty(){
        navigateurl = '';
        if(ApexPages.currentPage().getParameters().containsKey(Label.Cross_Sell_Opportunity+'_lkid') && ((ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity+'_lkid') != null) && (ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity+'_lkid') != ''))){
            navigateurl = '/'+ApexPages.currentPage().getParameters().get(Label.Cross_Sell_Opportunity+'_lkid');
        }else if(contId != null && contId != ''){
            navigateurl = '/'+contId;
        }else if(campId != null && campId != ''){
            navigateurl = '/'+campId;
        }else if(accId != null && accId != ''){
            navigateurl = '/'+accId;
        }
        else{
            navigateurl = '/'+keyPrefix+'/o';
            system.debug('>>>navigateurl>>>'+navigateurl );
        }
        Pagereference pg = new Pagereference(navigateurl);
        pg.setRedirect(true);
        return pg;
    }
}