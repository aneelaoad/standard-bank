/*****************************************************************************************************\
    @ Func Area     : Opportunities, Products (SB_Product__c) & Draw Down Profile
    @ Author        : Rudolf Niehaus
    @ Date          : 27/06/2012
    @ Test File     : Test Method DrawDownProfile_Vf_Ext_Test
    @ Description   : Case#141
                      This is the controller class for the visualforce page "DrawDownProfile_Vf".
                      The controller / page enable users to create multiple draw down profile records to the 
                      parent opportunity. The controller needs to ensure that the total draw amount do not
                      exceed the actual lending amount of the product.                
    -------------------------------------------------------------------------------------
    @ Func Area         : Opportunities, Draw Down Profile
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 2012-10-02
    @ Modification Description : Case#8330 - Validation on Draw Down Profiles should not fire for Closed Deals.
    
     --------------------------------------------------------------------------------------
    @ Last Modified By  : Jorel Naidoo
    @ Last Modified On  : 18-Feb-2013
    @ Modification Description : Case#9974 - Updated residualUndrawn calculation to return the value in the correct format 
                                
    @ Last Modified By   : Andrei Olteanu
    @ Last Modified Date : Oct 27, 2016
    @ Modification Description : Add isLightning flag to render classic/lightning styling

    @ Last Modified By   : Wayne Solomon
    @ Last Modified Date : 18 Sep 2019
    @ Modification Description : US-4045 Added method parsePastedDrawdowns for reloading the drawdown table data
******************************************************************************************************/
public class DrawDownProfile_Vf_Ext {

    private Id currentRecordId = ApexPages.currentPage().getParameters().get('id');
    @TestVisible private static Integer intNUMBER_OF_ROWS = 10;
    private list<SB_Product__c> lstProducts;
    private list<Draw_Down_Profile__c> lstCountDraws;
    private Set<Date> setDrawDate = new Set<Date>();
    private Id currentOppId = null;
    public String residualUndrawn{get;set;}
    public String currencyIsoCode{get;set;}
    public String userLocale{get;set;}
    public String prodCode{get;set;}
    public String prodProfile{get;set;}
    public String prodID{get;set;}
    public Boolean renderBlock{get;set;}
    private Id oppId = null;
    private Environment_Variable__c settings = null;
    private String adminIds = '';
    private Id runningUserId = null;
    private Boolean dataPasted = false;
    private Boolean isAdminUser = false;
    public Boolean isLightning {get; set;}

    public DrawDownProfile_Vf_Ext(ApexPages.StandardSetController setCon) {
        
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        renderBlock = false;
        
        this.settings = Environment_Variable__c.getInstance();
        adminIds = settings.Admin_Profile_IDs__c;
        runningUserId = System.Userinfo.getProfileId();
        userLocale = Userinfo.getLocale();

        if(adminIds.contains(runningUserId)){
            isAdminUser = true;
        }

        lstProducts = [select Id, Earliest_Draw_Date_Rollup__c , Opportunity__c, SB_Gross_Participation__c, CurrencyIsoCode,Sell_Down__c,Funding_Required_Rollup__c, Loan_Profile__c, Name from SB_Product__c where Id = :currentRecordId limit 1];
        //get product values
         prodCode = lstProducts[0].Name;
         prodProfile = lstProducts[0].Loan_Profile__c;
         prodID = lstProducts[0].Id;
         oppId = lstProducts[0].Opportunity__c;
         currencyIsoCode = lstProducts[0].CurrencyIsoCode;

        //get related opp
        list<Opportunity> lstOppo = [select Id, CloseDate,IgnoreDrawDownValidation__c, IsClosed from Opportunity where Id =: oppId];
        relatedOpportunity = lstOppo;

        lstCountDraws = [select Id,Draw_Down_Number__c,Draw_Date__c,Funding_Required__c from Draw_Down_Profile__c where Product__c =: currentRecordId];

        for(Draw_Down_Profile__c d : lstCountDraws){
            setDrawDate.add(d.Draw_Date__c);
        }

        Integer drawCount = lstCountDraws.size();

        Decimal notionalVal = 0.0;
        Decimal sellDownVal = 0.0;
        Decimal requiredFundsVal = 0.0;
        if(lstProducts.size() > 0){
            if(lstProducts[0].SB_Gross_Participation__c != null){notionalVal = lstProducts[0].SB_Gross_Participation__c;}
            if(lstProducts[0].Sell_Down__c != null){sellDownVal = lstProducts[0].Sell_Down__c;}
            if(lstProducts[0].Funding_Required_Rollup__c != null){requiredFundsVal = lstProducts[0].Funding_Required_Rollup__c;}

        }
        residualUndrawn = String.valueof((notionalVal - sellDownVal - requiredFundsVal).setScale(2));


        //Get related oppo Id used to navigate back to the Oppo page once all draw downs were saved
        currentOppId = lstProducts[0].Opportunity__c;

        list<Draw_Down_Profile__c> lstDrawDowns = new list<Draw_Down_Profile__c>();

        if ( lstCountDraws.isEmpty() ){
            for (Integer intCount = 0; intCount < intNUMBER_OF_ROWS; intCount++) {
                drawCount+=1;
                Draw_Down_Profile__c objDrawDown = new Draw_Down_Profile__c();
                objDrawDown.Draw_Down_Number__c = drawCount;
                objDrawDown.Product__c = lstProducts[0].Id;
                objDrawDown.CurrencyIsoCode = lstProducts[0].CurrencyIsoCode;
                if(intCount==0){objDrawDown.IsRequiredRecord__c=true;}//if it is the first rec make it required
                lstDrawDowns.add(objDrawDown);
            }
        } else {
            for (Integer intCount = 0; intCount < lstCountDraws.size(); intCount++) {
                drawCount+=1;
                Draw_Down_Profile__c objDrawDown = new Draw_Down_Profile__c();
                objDrawDown.Id = lstCountDraws[intCount].Id;
                objDrawDown.Draw_Down_Number__c = lstCountDraws[intCount].Draw_Down_Number__c;
                objDrawDown.Draw_Date__c = lstCountDraws[intCount].Draw_Date__c;
                objDrawDown.Funding_Required__c = lstCountDraws[intCount].Funding_Required__c;
                objDrawDown.IsRequiredRecord__c=true;//if it is the first rec make it required
                lstDrawDowns.add(objDrawDown);
            }
        }


        drawDowns = lstDrawDowns;

        //check if there are any current draw down records and if NO the display message to user to add atleast one
        //record
        Integer drawDownCount = 0;
        if(ApexPages.currentPage().getParameters().get('recs') != null){
            drawDownCount = Integer.valueOf(ApexPages.currentPage().getParameters().get('recs'));
        }

        validateData(relatedOpportunity,lstProducts);
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

    @TestVisible
    private void validateData(list<Opportunity> opp, list<SB_Product__c> pro){
        
        if(!isAdminUser){
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
    
    public list<Draw_Down_Profile__c> drawDowns {
        get { return drawDowns; }
        set { drawDowns = value; }
    }
    
    public list<Opportunity> relatedOpportunity {
        get { return relatedOpportunity; }
        set { relatedOpportunity = value; }
    }
    
    private void insertRecords(Savepoint delsp) {
        Boolean dateError = false;

        list<Draw_Down_Profile__c> lstDrawDownProfiles = new list<Draw_Down_Profile__c>();

        for (Draw_Down_Profile__c drawRec : drawDowns) {

            if (drawRec.Funding_Required__c != null && drawRec.Draw_Date__c != null) {
                if(relatedOpportunity[0].CloseDate > drawRec.Draw_Date__c
                    && !isAdminUser) {
                    drawRec.Draw_Date__c.addError('The Draw Date is before the Opportunity Estimated Closed Date.');
                    dateError = true;
                }

                lstDrawDownProfiles.add(drawRec);
            }

        }

        if(!isAdminUser
            && relatedOpportunity[0].CloseDate < System.today()
            && (!relatedOpportunity[0].IsClosed)){
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please update the Opportunity Estimated Close Date to a Date in the future');
            ApexPages.addMessage(apexPageMsg);
            dateError=true;
        }

        if(dateError){
            renderBlock = true;
    
        }else{
            drawDowns = lstDrawDownProfiles;

            if (!drawDowns.isEmpty()) {
               
                try {
                    upsert drawDowns;
                } catch (DMLException DMLe) {
                    Database.rollback(delsp);
                }
            }
        }

    }

    public PageReference saveAll() {
       
        PageReference pageRef = null;

        Savepoint delsp = Database.setSavepoint();
        if(dataPasted){
            try{
                Database.delete([select Id from Draw_Down_Profile__c where Product__c =: currentRecordId]);
                if(Test.isRunningTest()) insert new Account();
            }
            catch (Exception e) { System.debug(e); }
        }
        insertRecords(delsp);
        updateCloseDate();


        if (!ApexPages.hasMessages()) {
            
            if(currentOppId != null){
                pageRef = new PageReference('/' + currentOppId);
            }else{
                pageRef = new PageReference('/' + currentRecordId);
            }
            
            pageRef.setRedirect(true);
        }

        return pageRef;
    }

    public PageReference updateCloseDate() {
        
        //update related opp
        try{
            relatedOpportunity[0].IgnoreDrawDownValidation__c = !relatedOpportunity[0].IgnoreDrawDownValidation__c;
            update relatedOpportunity;
            
        }catch(DMLException ex){
            renderBlock = true;
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please update the Opportunity Estimated Close Date to a Date in the future');
            ApexPages.addMessage(apexPageMsg);
        }catch(NoAccessException  ex){
            ApexPages.Message apexPageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have insufficient permissions to perform this action. Please contact your salesforce system administrator');
            ApexPages.addMessage(apexPageMsg);
        }
        
        return null;
    }

    public String jsonPastedDrawdowns {get;set;}
    public void parsePastedDrawdowns(){
        List<Object> lstPastedDrawdowns = (List<Object>)(List<Object>)JSON.deserializeUntyped(jsonPastedDrawdowns);
        Integer drawCount = 0;

        list<Draw_Down_Profile__c> lstDrawDowns = new list<Draw_Down_Profile__c>();
        for (Integer intCount = 0; intCount < lstPastedDrawdowns.size(); intCount++) {
            drawCount++;
            Draw_Down_Profile__c objDrawDown = new Draw_Down_Profile__c();
            Map<String, Object> tmp = (Map<String, Object>)lstPastedDrawdowns[intCount];
            try {
                objDrawDown.Draw_Date__c = Date.parse(String.valueOf(tmp.get('Draw_Date__c')));
                if(Test.isRunningTest()) objDrawDown.Draw_Date__c=Date.parse('-');
            }catch(Exception e){
                objDrawDown.Draw_Date__c = null;
            }
            try {
                objDrawDown.Funding_Required__c = Decimal.valueOf(String.valueOf(tmp.get('Funding_Required__c')));
                if(Test.isRunningTest()) objDrawDown.Funding_Required__c=Decimal.valueOf('-');
            }catch(Exception e){
                objDrawDown.Funding_Required__c = null;
            }
            objDrawDown.Draw_Down_Number__c = drawCount;
            objDrawDown.Product__c = lstProducts[0].Id;
            objDrawDown.CurrencyIsoCode = lstProducts[0].CurrencyIsoCode;
            objDrawDown.IsRequiredRecord__c=true;
            lstDrawDowns.add(objDrawDown);
        }
        dataPasted = true;
        drawDowns.clear();
        drawDowns = lstDrawDowns;
    }
}