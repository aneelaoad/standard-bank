/*****************************************************************************************************\
    @ Func Area     : Opportunities, Products (SB_Product__c) & Draw Down Profile
    @ Author        : Rudolf Niehaus
    @ Date          : 15/08/2012
    @ Test File     : Test Method DrawDownProfile_Vf_Ext_Test
    @ Description   : Case#141
                      This is the controller class for the visualforce pages "DrawDownProfileMassEdit_Vf" & "DrawDownProfileMassDelete_Vf".
                      The controller / page enable users to update / delete multiple draw down profiles linked to a specific product. 
                      The controller also flags a field on the opportunity that gets used by some validation rules as an indicator not to fire.
                      This was done to prevent the two validations rules between draw down and the opportunity that validate the same field
                      do not validation into an endless loop               
    -------------------------------------------------------------------------------------
    @ Func Area         : Opportunities, Draw Down Profile
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 2012-10-02
    @ Modification Description : Case#8330 - Validation on Draw Down Profiles should not fire for Closed Deals.
    
    --------------------------------------------------------------------------------------
    @ Last Modified By  : Jorel Naidoo
    @ Last Modified On  : 18-Feb-2013
    @ Modification Description : Case#9974 - Updated residualUndrawn Calculation to return the value in the correct format    
                                
******************************************************************************************************/
public with Sharing class DrawDownProfileMassActions_Vf_Ext {

    private Id productId = ApexPages.currentPage().getParameters().get('id');
    private Id oppId = null;
    public String residualUndrawn{get;set;}
    public String currencyIsoCode{get;set;}
    public String prodCurrencyIsoCode{get;set;}
    public Boolean renderBlock{get;set;}
    public String prodCode{get;set;}
    public String prodProfile{get;set;}
    public String prodID{get;set;}
    public Boolean isLightning {
        get {
            return UTL_User.isLightnigUser();
        }
    }
    public Boolean isCibUser {
        get {
            return !UTL_User.isCommBUser(UserInfo.getUserId());
        }
    }
    ApexPages.StandardSetController setCon;
    private Environment_Variable__c settings = null;
    private String adminIds = '';
    private Id runnigUserId = null;
    private Boolean wasOppoRedirect = false;
    private Boolean isAdminUser = false;
   
    public DrawDownProfileMassActions_Vf_Ext(ApexPages.StandardSetController controller) {
          //check if this is a admin user
          this.settings = Environment_Variable__c.getInstance();
          adminIds = settings.Admin_Profile_IDs__c;
          runnigUserId = System.Userinfo.getProfileId();
          if(adminIds.contains(runnigUserId)){
                isAdminUser = true;
          }
          
          setCon = controller;
          
          //Product
          lstProducts = [select Id, Opportunity__c, Earliest_Draw_Date_Rollup__c, Loan_Profile__c, SB_Gross_Participation__c, CurrencyIsoCode, Sell_Down__c, Funding_Required_Rollup__c, Name from SB_Product__c where Id =: productId limit 1];
          //get some values from prod record
          oppId = lstProducts[0].Opportunity__c;
          prodCode = lstProducts[0].Name;
          prodProfile = lstProducts[0].Loan_Profile__c;
          prodID = lstProducts[0].Id;
          prodCurrencyIsoCode = lstProducts[0].CurrencyIsoCode;
            //do some calculations on the residual draw amount
            Decimal notionalVal = 0.0;
            Decimal sellDownVal = 0.0;
            Decimal requiredFundsVal = 0.0;
            if(lstProducts.size() > 0){
            if(lstProducts[0].SB_Gross_Participation__c != null){notionalVal = lstProducts[0].SB_Gross_Participation__c;}
            if(lstProducts[0].Sell_Down__c != null){sellDownVal = lstProducts[0].Sell_Down__c;}
            if(lstProducts[0].Funding_Required_Rollup__c != null){requiredFundsVal = lstProducts[0].Funding_Required_Rollup__c;}
            currencyIsoCode = lstProducts[0].CurrencyIsoCode;
            }
             residualUndrawn = String.valueof((notionalVal - sellDownVal - requiredFundsVal).SetScale(2));
            
          //Related Opportunity
          list<Opportunity> lstOppo = [select Id, IsClosed, CloseDate, IgnoreDrawDownValidation__c, Earliest_Draw_Date_Rollup__c from Opportunity where Id =: oppId];
          relatedOpportunity = lstOppo;
          
          
          if(ApexPages.currentPage().getParameters().get('drawid') != null){
            
            Id drawid = ApexPages.currentPage().getParameters().get('drawid');
            list<Draw_Down_Profile__c> lstDraw = [select Id,Residual_Undrawn__c,Product__c,Name, IsRequiredRecord__c, 
                                                    Funding_Required__c,Draw_Down_Number__c, 
                                                    Draw_Down_Maturity_Date__c,Draw_Date__c 
                                                    from Draw_Down_Profile__c where Id =: drawid];
            setCon.setSelected(lstDraw);
                
          }else if(ApexPages.currentPage().getParameters().get('source') != null){
            //this page was loaded from the opp view state where we do the product redirect
            //at this point we have a product and the opp close date is before one of this products
            //earliest draw down date. We only get draw down records that are before the opp close date
            
                list<Draw_Down_Profile__c> lstDraw = [select Id,Residual_Undrawn__c,Product__c,Name, IsRequiredRecord__c, 
                                                    Funding_Required__c,Draw_Down_Number__c, 
                                                    Draw_Down_Maturity_Date__c,Draw_Date__c 
                                                    from Draw_Down_Profile__c where Product__c =: productId and
                                                     Draw_Date__c <: relatedOpportunity[0].CloseDate];
                setCon.setSelected(lstDraw);
                
                renderBlock = true;
                ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The Draw Date cannot be earlier than the Opportunity Estimated Close Date.<BR><LI>Please select a Draw Date after the Estimated Close Date OR<BR><LI>Please update the Opportunity Estimated Close Date and try again.');
                ApexPages.addMessage(apexPageMsg);
          }
          else {
              setCon.setSelected([
                  SELECT Residual_Undrawn__c, Product__c, Name, IsRequiredRecord__c,
                      Funding_Required__c, Draw_Down_Number__c,
                      Draw_Down_Maturity_Date__c, Draw_Date__c
                  FROM Draw_Down_Profile__c
                  WHERE Id IN :setCon.getSelected()
                  ORDER BY Draw_Down_Number__c
              ]);
          }
          
          selectedRecords = setCon.getSelected();
          allRecords = new List<Draw_Down_Profile__c>(selectedRecords);
          selectedRecords.sort();

          //if the page was loaded from the Oppo due to close date being before draw dates then do not run validation again
          if(ApexPages.currentPage().getParameters().get('source') == null){
            validateData(relatedOpportunity, lstProducts);
          }
                
    }

    public List<Draw_Down_Profile__c> allRecords { get; set; }
    public list<Draw_Down_Profile__c> selectedRecords {
        get { return selectedRecords; }
        set { selectedRecords = value; }
    }
    public list<Opportunity> relatedOpportunity {
        get { return relatedOpportunity; }
        set { relatedOpportunity = value; }
    }
    public list<SB_Product__c> lstProducts {
        get { return lstProducts; }
        set { lstProducts = value; }
    }
    
    private void validateData(list<Opportunity> opp, list<SB_Product__c> pro){
        
        if(!isAdminUser && !opp[0].IsClosed){
            if(opp[0].CloseDate < System.today() && (!opp[0].IsClosed)){
                renderBlock = true;
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please update the Opportunity Estimated Close Date to a Date in the future');
            ApexPages.addMessage(apexPageMsg);
            
          }else if(opp[0].CloseDate > pro[0].Earliest_Draw_Date_Rollup__c){
            renderBlock = true;
            
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The Draw Date cannot be earlier than the Opportunity Estimated Close Date:<BR><LI>Please select a Draw Date after the Estimated Close Date OR<BR><LI>Please update the Opportunity Estimated Close Date and try again.');
            ApexPages.addMessage(apexPageMsg);
            
          }else{
            renderBlock = false;
          }
        }
    }
    
    public PageReference updateCloseDate() {
        
        //update related opp
        try{
            relatedOpportunity[0].IgnoreDrawDownValidation__c = !relatedOpportunity[0].IgnoreDrawDownValidation__c;
            update relatedOpportunity;
            
        }catch(DMLException ex){
            renderBlock = False;
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have insufficient permissions to perform this action. Please contact your salesforce system administrator');
            ApexPages.addMessage(apexPageMsg);
        }catch(NoAccessException  ex){
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have insufficient permissions to perform this action. Please contact your salesforce system administrator');
            ApexPages.addMessage(apexPageMsg);
        }
        
        return null;
    }
    
    public PageReference saveAll(){
        PageReference pageRef = null;
        
        upsertRecords();
            
        if (!ApexPages.hasMessages()) {
           
           pageRef = new PageReference('/' + oppId);
           pageRef.setRedirect(true);
        }

        return pageRef;
        
    }
    
    private void upsertRecords(){
       set<Date> existingDates = new set<Date>();
       map<Id,Date> drawMap = new map<Id,Date>();
       Boolean dateError = false; 

        //get existing draw dates for this product
        
        for(Draw_Down_Profile__c d : [select Id, Draw_Date__c from Draw_Down_Profile__c where Product__c =: productId]){
                existingDates.add(d.Draw_Date__c);
                drawMap.put(d.Id,d.Draw_Date__c);
        }

        List<Draw_Down_Profile__c> ddProfilesToUpsert = new List<Draw_Down_Profile__c>();
        for (Draw_Down_Profile__c dd : allRecords) {
            if (dd.Funding_Required__c != null) {
                ddProfilesToUpsert.add(dd);
            }
        }
        
        for(Draw_Down_Profile__c dd : ddProfilesToUpsert){
            if(dd.Draw_Date__c < relatedOpportunity[0].CloseDate){
                if(!isAdminUser && !relatedOpportunity[0].IsClosed){
                    dateError = true;
                    dd.Draw_Date__c.addError('The Draw Date is before the Opportunity Estimated Closed Date');
                }
            }
            if(dd.Id != null && drawMap.containsKey(dd.Id)){
                if(drawMap.get(dd.Id) != dd.Draw_Date__c){
                    if(existingDates.contains(dd.Draw_Date__c)){
                        dd.Draw_Date__c.addError('The Draw Down Date cannot fall on the same day as another existing Draw Down.');
                    }
                }
            }
            
        }
        if(!isAdminUser && !relatedOpportunity[0].IsClosed){
            if(relatedOpportunity[0].CloseDate < System.today() && (!relatedOpportunity[0].IsClosed)){
                ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please update the Opportunity Estimated Close Date to a Date in the future');
                ApexPages.addMessage(apexPageMsg);
                dateError=true;
            }
        }
      
        //update selected records
        if(dateError){
            renderBlock = true;
        }else{
            try{
                updateCloseDate();

                // TODO: use upsert instead of insert+update after trigger on Draw_Down_Profile__c will be fixed
                Draw_Down_Profile__c[] ddProfilesToInsert = new Draw_Down_Profile__c[]{};
                Draw_Down_Profile__c[] ddProfilesToUpdate = new Draw_Down_Profile__c[]{};
                for (Draw_Down_Profile__c dd : ddProfilesToUpsert) {
                    if (dd.Id == null) {
                        ddProfilesToInsert.add(dd);
                    }
                    else {
                        ddProfilesToUpdate.add(dd);
                    }
                }

                if (!ddProfilesToInsert.isEmpty()) {
                    insert ddProfilesToInsert;
                }
                if (!ddProfilesToUpdate.isEmpty()) {
                    update ddProfilesToUpdate;
                }

                // upsert ddProfilesToUpsert;
            
            }catch(Exception ex){
                
                System.debug('An Error occurred when a user saved draw down records. ERROR MSG:' + ex.getMessage());
                
            }
        }
    }
    
    public PageReference deleteAll() {
       
        PageReference pageRef = null;
        
        //update selected records
        try{
            delete selectedRecords;
        }catch(DMLException ex){
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error occurred when you tried to delete selected records. Please try again. If the problem persist contact your Salesforce Administrator');
            ApexPages.addMessage(apexPageMsg);
        }
        
        if (!ApexPages.hasMessages()) {
           
           pageRef = new PageReference('/' + oppId);
           pageRef.setRedirect(true);
        }

        return pageRef;
    }

    public void addRow() {
        allRecords.add(new Draw_Down_Profile__c(Product__c = productId, currencyIsoCode = prodCurrencyIsoCode));
    }

    public void removeRow() {
        allRecords.remove(Integer.valueOf(ApexPages.currentPage().getParameters().get('rowToRemove')));
    }
    
}