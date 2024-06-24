/*****************************************************************************************************
    @ Func Area     : Client Plan
    @ Author        : Navin Rai
    @ Date          : 10/2013
    @ Test File     : TestProductPotential.cls
    @ Description   : This controller is used for creating the ProductPotential VF componnet which is used in the Product Potential section of the client plan.       
    
    @ Func Area     : Client Plan
    @ Author        : Charles Mutsu
    @ Date          : 02/2014
    @ Test File     : TestProductPotential.cls
    @ Description   : Updated Status field with Not Available value
    
    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Jan, 2016
    @ Last Modified Reason  : EN-927 - Customizations so that it can be reused for CommB
    
    @ Last Modified By  : Abhishek V
    @ Last Modified Date : Nov 08, 2016
    @ Modification Description : US - 1662 : Commented page reference to same page on save/cancel methods
******************************************************************************************************/
/**
*
* @LastModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date Oct 2021
* @description add Business Banking PRH where commB is included and fix static code analysis
*/
Public with sharing class ProductPotentialController{
    private final String COMMB = DMN_Account.PRIMARY_REL_HOLDER_COMMB;
    public Boolean lightning{get;set;}
    public Map<string,ProductSubsets__c> ProdSubset_Map = new Map<string,ProductSubsets__c> ();
    public List<Product_Potential__c> ProdPotential_List {get;set;}
    public List<Product_Potential__c> prodResults {get;set;}
    public map<String,String> prodDivMap {get;set;}
    
    public map<String, List<Product_Potential__c>> map_ProdPotential {get;set;}

    private Boolean ppFetched = false;

    public String clientHolder {
        get;
        set {
            clientHolder = value;

            if (!ppFetched) {

                if (clientHolder == COMMB || clientHolder == DMN_Account.PRIMARY_REL_HOLDER_BUSINESS) { // careful: clientHolder will be null for existing CIB clients
                    Divisions = new List<String>{'Payments', 'Working Capital', 'Investments', 'Loans', 'Wealth and Insurance', 'Transaction Accounts', 'Trade and Forex', 'Card'};
                } else {
                    Divisions = new List<String> {'Global Markets','Investment Banking','Transactional Products and Services','Real Estate','Business Banking','Wealth'};
                }

                //method to generate list of records in Product_Potential__c object. This list is used in the component for traversing through each product subset.
                PPRecords();

                ppFetched = true;
            }
        }
    }
    
    public Id clientid;
    public static boolean SavedOnce = true;
    public boolean showwindow {get;set;}
    public List<String> Divisions {get;set;}

    /**
    * constructor - custom controller
    */
    Public ProductPotentialController(){
        
        map_ProdPotential = new map<String, List<Product_Potential__c>>();
        
        ProdPotential_List = new List<Product_Potential__c> ();
        
        prodDivMap = new map<String,String>();
         
        ProdSubset_Map = ProductSubsets__c.getall();
        
        clientid = ApexPages.currentPage().getParameters().get('id');
        
        showwindow = false;
        
   }
    /**
    * Constructor to pull the information in Client Plan Page
    * @param controller
    */
   Public ProductPotentialController(ApexPages.StandardController controller){ 
        map_ProdPotential = new map<String, List<Product_Potential__c>>();
        
        ProdPotential_List = new List<Product_Potential__c> ();

        clientid = ApexPages.currentPage().getParameters().get('id');
        
        Account client = [SELECT primary_relationship_holder__c FROM Account WHERE id = :clientId LIMIT 1];
        clientHolder = client.primary_relationship_holder__c;
        
        ProdSubset_Map = ProductSubsets__c.getall();
        
        showwindow = false;
   }
    /**
    * toggle the page by true or false
    *@return PageReference
    */
    private PageReference returnPage() {
        PageReference pageref;
        if (clientHolder == COMMB || clientHolder == DMN_Account.PRIMARY_REL_HOLDER_BUSINESS) {
            pageref = new PageReference ('/apex/ClientPlanCommB?id='+ clientid);
        } else {
            pageref = new PageReference ('/apex/ClientPlan?id='+ clientid+'&Lightning='+lightning);
        }

        return pageref; 
    }

    /**
    * Method to save the record from the product potential pop up screen. It actually updates the default or exiting values for the Product_Division__c picklist.
    This ensures that the user sees the latest status on the potential, for each product, on the product potential section.
    *@return PageReference
    */
    Public PageReference SaveRecord(){
    
      list<Product_Potential__c> templst = new list<Product_Potential__c>();
      
      for(list<Product_Potential__c> lst : map_ProdPotential.Values()){
         for (Product_Potential__c pr : lst){
            templst.add(pr);
         }
      }
      
       try{

            Update templst;
        }catch (DmlException e){
            system.debug('Error in Upserting the records in Product_Potential__c in ProductPotential class'); 
        }
        
       PageReference pageref = returnPage();
       pageref.setRedirect(true);
      
       return pageref;
        
    }//End of SaveRecord
    /**
    * toggle the page by true or false
    */
    public void EditPotential(){
       showwindow = true;
    }// End of AddContacts
    /**
    * Cancel pop
    * @return PageReference
    */
    public pageReference CancelPop(){
       
       PageReference pageref = returnPage();
       pageref.setRedirect(true);
       return pageref;
    }// End of CancelPop
    /**
    * get list of product potential and map them
    */
    public void PPRecords(){
    
        ProdPotential_List = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
                              FROM Product_Potential__c
                              WHERE Client__c = :clientid 
                              Order BY Product_Subset__c];

        if (clientHolder == COMMB || clientHolder == DMN_Account.PRIMARY_REL_HOLDER_BUSINESS) {
            map_ProdPotential.put('Payments', getPPRecordsP());
            map_ProdPotential.put('Working Capital', getPPRecordsWC());
            map_ProdPotential.put('Investments', getPP_RecordsI());
            map_ProdPotential.put('Loans', getPP_RecordsL());
            map_ProdPotential.put('Wealth and Insurance', getPPRecordsWI());
            map_ProdPotential.put('Transaction Accounts', getPPRecordsTA());
            map_ProdPotential.put('Trade and Forex', getPPRecordsTF());
            map_ProdPotential.put('Card', getPPRecordsC());
        } else {
            map_ProdPotential.put('Global Markets', getPP_RecordsGM());
            map_ProdPotential.put('Investment Banking', getPP_RecordsIB());
            map_ProdPotential.put('Transactional Products and Services', getPP_RecordsTPS());
            map_ProdPotential.put('Real Estate', getPP_RecordsRE());
            map_ProdPotential.put('Business Banking', getPP_RecordsBB());
            map_ProdPotential.put('Wealth', getPP_RecordsW());
        }
         
    }//End of PP_Records
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPP_RecordsGM(){
     
      List<Product_Potential__c>  prodPotentialListGM = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
                              FROM Product_Potential__c
                              WHERE Client__c = :clientid And Product_Division__c = 'Global Markets'
                              Order BY Product_Subset__c];

        
        return prodPotentialListGM ;
        
    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
     public List<Product_Potential__c> getPP_RecordsTPS(){
     
      List<Product_Potential__c>  prodPotentialListTPS = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
                              FROM Product_Potential__c
                              WHERE Client__c = :clientid And Product_Division__c = 'Transactional Products and Services'
                              Order BY Product_Subset__c];

        
        return prodPotentialListTPS ;
        
    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPP_RecordsIB(){
     
      List<Product_Potential__c>  prodPotentialListIB = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
                              FROM Product_Potential__c
                              WHERE Client__c = :clientid And Product_Division__c = 'Investment Banking'
                              Order BY Product_Subset__c];

        
        return prodPotentialListIB ;
        
    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPP_RecordsBB(){
     
      List<Product_Potential__c>  prodPotentialListBB = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
                              FROM Product_Potential__c
                              WHERE Client__c = :clientid And Product_Division__c = 'Business Banking'
                              Order BY Product_Subset__c];

        
        return prodPotentialListBB ;
        
    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPP_RecordsRE(){
     
      List<Product_Potential__c>  prodPotentialListRE = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
                              FROM Product_Potential__c
                              WHERE Client__c = :clientid And Product_Division__c = 'Real Estate'
                              Order BY Product_Subset__c];

        
        return prodPotentialListRE ;
        
    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPP_RecordsW(){
     
      List<Product_Potential__c>  prodPotentialListW = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
                              FROM Product_Potential__c
                              WHERE Client__c = :clientid And Product_Division__c = 'Wealth'
                              Order BY Product_Subset__c];

        
        return prodPotentialListW ;
        
    }

    /**
    * get list of product potential by product division (CommB specifics)
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPPRecordsC(){

        List<Product_Potential__c>  prodPotentialListGM = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Card'
        Order BY Product_Subset__c];


        return prodPotentialListGM ;

    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPP_RecordsI(){

        List<Product_Potential__c>  prodPotentialListTPS = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Investments'
        Order BY Product_Subset__c];


        return prodPotentialListTPS ;

    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPP_RecordsL(){

        List<Product_Potential__c>  prodPotentialListIB = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Loans'
        Order BY Product_Subset__c];


        return prodPotentialListIB ;

    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPPRecordsP(){

        List<Product_Potential__c>  prodPotentialListBB = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Payments'
        Order BY Product_Subset__c];

        //ProdPotential_ListBB.sort();

        return prodPotentialListBB ;

    }

    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPPRecordsTF(){

        List<Product_Potential__c>  prodPotentialListRE = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Trade and Forex'
        Order BY Product_Subset__c];


        return prodPotentialListRE ;

    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPPRecordsTA(){

        List<Product_Potential__c>  prodPotentialListW = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Transaction Accounts'
        Order BY Product_Subset__c];


        return prodPotentialListW ;

    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPPRecordsWI(){

        List<Product_Potential__c>  prodPotentialListW = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Wealth and Insurance'
        Order BY Product_Subset__c];


        return prodPotentialListW ;

    }
    /**
    * get list of product potential by product division
    * @return List<Product_Potential__c>
    */
    public List<Product_Potential__c> getPPRecordsWC(){

        List<Product_Potential__c>  prodPotentialListW = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
        FROM Product_Potential__c
        WHERE Client__c = :clientid And Product_Division__c = 'Working Capital'
        Order BY Product_Subset__c];

        //ProdPotential_ListW.sort();

        return prodPotentialListW ;

    }
    /**
    * get list of option
    * @return List<SelectOption>
    */
    public List<SelectOption> getOptions(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Not on Track','Not on Track'));
        options.add(new SelectOption('Medium on Track','Medium on Track'));
        options.add(new SelectOption('On Track','On Track'));
        options.add(new SelectOption('Not Applicable','Not Applicable')); 
        
        return options;
     }
     
      
}//End of class