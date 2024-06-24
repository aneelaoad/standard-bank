/*************************************************************************\
    @ Author        : Shubham
    @ Date          : 03-July-2014
    @ Description   : This class is used as controller for product search page
                      and have the logic to search the custom setting records
                      for entered string on page.

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015 
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 24, 2015
    @ Modification Description : added sorting by EN-0416: Grand Parent Product products must be sorted by Grand Parent Product
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified On  : Sep 29, 2015
    @ Modification Description : added sorting by EN-0815: Product Division included in the search functionality.Also value pre-populated in the next screen.

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Feb 22, 2016
    @ Modification Description : US-1124 - checking user_cib_global_area__c

    @ Last Modified By  : Maksim Dzianisik
    @ Last Modified On  : Aug 4, 2021
    @description        : SFP-6008 - Added filter logic for Insurance products
    
****************************************************************************/
@SuppressWarnings('PMD.ExcessivePublicCount')
public class ProductSearchPageController {
    
    //variable declaration
    //public boolean prodBool                     {get;set;}
    public Opportunity opp                      {get;set;}
    public SB_Product__c prod                        {get;set;}
    public boolean renderMessage                {get;set;}
    public String productString                 {get;set;}
    public List<prodWrapper> lstProductWrapper  {get;set;}
    public prodWrapper prodSearched             {get;set;}

    private static final String INSURANCE = 'Insurance';
    
    /*********************************************************************************************************************
     Method : ProductSearchPageController
     @param controller ApexPages.StandardController, N/A as it is a constructor
     Description : Constructor of the class usses to initialize opportunity reference and other member variables.    
    ********************************************************************************************************************/
    public ProductSearchPageController(ApexPages.StandardController controller)
    {
        prod= (SB_Product__c)controller.getRecord();
        lstProductWrapper = new List<prodWrapper>();
        renderMessage = false;
        if(ApexPages.currentPage().getParameters().containsKey('oppId')){
            opp = [SELECT id,name,AccountId, StageName, OwnerId, isPrivate, Account.Name, Owner.Name FROM Opportunity WHERE 
                    Id=: ApexPages.currentPage().getParameters().get('oppId')];
        }
        else{
         String   prodId = ApexPages.currentPage().getParameters().get('retURL');
       prodId = prodId.substring(1,16);
        try{
       SB_Product__c product = [select id , Opportunity__c from SB_Product__c where id =: prodId] ;  
         opp = [SELECT id,name,AccountId, StageName, OwnerId, isPrivate, Account.Name, Owner.Name FROM Opportunity WHERE 
                    Id=: product.Opportunity__c];
          }
          Catch(QueryException ex){
            opp = [SELECT id,name,AccountId, StageName, OwnerId, isPrivate, Account.Name, Owner.Name FROM Opportunity WHERE 
                    Id=: prodId];
          }  
        }
    }
    
    /*********************************************************************************************************************
     Method : search
     Input Parameters : N/A
     Description : This method is invoked on click of Search button on Vf page and used to search for the input string in
                   product records in custom settings. Search the string in all fields i.e. Grand Parent product, Parent
                   Product,Product Division and Product field. 
    ********************************************************************************************************************/
    public void search()
    {
        lstProductWrapper = new List<prodWrapper>();
        renderMessage = false;
        if(productString!=null && productString!='' && (productString.length()>2 || Label.productSearchStrings.containsIgnoreCase(productString))){

            List<ProductSearch__c> newProductSearches = ProductSearch__c.getAll().values();
            // per Technical Design of EN-0416 products must be sorted by Grand Parent Product
            List<ProductSearchPageController.GrandParentProductComparable> productSearchesSorted = new List<ProductSearchPageController.GrandParentProductComparable>();
            for (ProductSearch__c p: newProductSearches) {
                productSearchesSorted.add(new ProductSearchPageController.GrandParentProductComparable(p));
            }
            productSearchesSorted.sort();

            final User cUser = [SELECT user_cib_global_area__c, User_Division__c, Profile.Name FROM User WHERE id = :UserInfo.getUserId()];
            final String userGlobalArea = cUser.user_cib_global_area__c;
            if (String.isEmpty(userGlobalArea)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'User CIB Global Area is empty, the search cannot continue');
                ApexPages.addmessage(myMsg);
            }

            for (ProductSearchPageController.GrandParentProductComparable pdSearchInOrder: productSearchesSorted) {
                ProductSearch__c pdSearch = pdSearchInOrder.pdSearch;

                if((pdSearch.Grand_Parent_Product__c!=null && pdSearch.Grand_Parent_Product__c.containsIgnoreCase(productString)) || 
                    (pdSearch.Parent_Product__c!=null && pdSearch.Parent_Product__c.containsIgnoreCase(productString)) || 
                    (pdSearch.Product_Division__c!=null && pdSearch.Product_Division__c.containsIgnoreCase(productString)) ||
                    (pdSearch.Product__c!=null && pdSearch.Product__c.containsIgnoreCase(productString))){

                        
                        // US-1124
                        if ((userGlobalArea.equalsIgnoreCase(DMN_User.CIB_GA_COMMB) && pdSearch.Product_Division__c.equalsIgnoreCase('Business and Commercial Banking'))
                         || (!userGlobalArea.equalsIgnoreCase(DMN_User.CIB_GA_COMMB) && !pdSearch.Product_Division__c.equalsIgnoreCase('Business and Commercial Banking'))) {
                            if(pdSearch.Product_Division__c == INSURANCE) {
                                if(cUser.User_Division__c == INSURANCE || cUser.Profile.Name == 'Business Administrator' || cUser.Profile.Name == 'System Administrator') {
                                    lstProductWrapper.add(new prodWrapper(pdSearch, false));
                                }
                            }else {
                                lstProductWrapper.add(new prodWrapper(pdSearch, false));
                            }
                        }
                }                       
            }
            // Display error message when there are no matching search results 
            if(lstProductWrapper!=null && lstProductWrapper.size()==0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, Label.EnterDifferentValue);
                ApexPages.addmessage(myMsg);
            }
        }
        else{
            renderMessage = true;   // render message on the screen that atleast 3 letters are required to perform search.
        }
    }
    
    /*********************************************************************************************************************
     Method : nextToProductPage
     Input Parameters : N/A
     @return PageReference
     Description : This method is invoked on click of Next button on Vf page and used to redirect to Product Edit Page 
                   when there are no validation errors. If validation fails, error message is displayed on screen.
    ********************************************************************************************************************/
    public pagereference nextToProductPage(){
        PageReference pageRef;
        Integer count=0;
        prodSearched = new prodWrapper();
        for(prodWrapper prdSearch : lstProductWrapper){
            if(prdSearch.checked){
                count++;
                prodSearched = prdSearch;
            }
            if(count>1) {
                break;
            }
        }
        // At least one product should be selected from the results, if not then error.
        if(count==0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, Label.Atleast_One_Record);
            ApexPages.addmessage(myMsg);
        }
        // Only one product should be selected from the results, if more than one then error.
        else if(count>1){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, Label.More_than_one_record_error);
            ApexPages.addmessage(myMsg);
        }
        
        if(apexpages.hasmessages()) {
            return null;
        } else {
            return redirect();
        }
    }
    /*********************************************************************************************************************
     Method : redirect
     Input Parameters : N/A
     @return PageReference
     Description : This method is invoked from next button method to redirect on Product edit page if there are no validation
                   errors. Values should be prepopulated in the edit record. Record type, Grand parent Product, Product Division,Parent Product,
                   Product, Opportunity and Client should be auto-populated. Cancel should return the control back to
                   product search page and save should take the control back to Opportunity detail page.
    ********************************************************************************************************************/
    public PageReference redirect(){
      
      String urlStr = '';
        
        if(opp == null){
         String   prodId = ApexPages.currentPage().getParameters().get('retURL');
       prodId = prodId.substring(1,19);
       SB_Product__c product = [select id , Opportunity__c from SB_Product__c where id =: prodId] ;  
         
         opp = [SELECT id,name,AccountId, StageName, OwnerId, isPrivate, Account.Name, Owner.Name FROM Opportunity WHERE 
                    Id=: product.Opportunity__c];
         
        } 
       
        String retUrlStr='/apex/ProductSearchPage?oppId='+opp.Id;
        String saveURL = '/'+opp.Id;
        
        Product_Fields__c prodFieldsId = Product_Fields__c.getInstance('productIds');       
        Schema.DescribeSObjectResult d = Schema.SObjectType.SB_Product__c;
        if(!Test.isRunningTest()){
            String recordTypeId = d.getRecordTypeInfosByName().get(prodSearched.productSearch.Product_Record_Type__c).getRecordTypeId();
       
            String keyPrefix = d.getKeyPrefix();
        
            // Adding Standard Field Values
            urlStr = urlStr + '/' + keyPrefix + '/e?retURL=' + retUrlStr + '&RecordType=' + recordTypeId + '&saveURL='+ saveURL + 
                 '&save_new_url=' + retUrlStr +'&nooverride=1';
        }
        //Adding Opportunities and Account Lookup
        if(opp.Id!=null){
            urlStr = urlStr + '&' + prodFieldsId.Opportunity_Id__c + '=' + EncodingUtil.urlEncode(opp.Name, 'UTF-8') ;
            urlStr = urlStr + '&' + prodFieldsId.Opportunity_Id__c + '_lkid=' + opp.Id ;
        }
        if(opp.AccountId!=null && opp.Account.Name!=null){
            urlStr = urlStr + '&' + prodFieldsId.Account_Id__c + '=' + EncodingUtil.urlEncode(opp.Account.Name, 'UTF-8') ;
            urlStr = urlStr + '&' + prodFieldsId.Account_Id__c + '_lkid=' + opp.AccountId ;
        }
        
        //Adding Field Values
        if(prodSearched.productSearch.Grand_Parent_Product__c!=null) {
            urlStr = urlStr + '&' + prodFieldsId.Grand_Parent_Product_Id__c + '=' + EncodingUtil.urlEncode(prodSearched.productSearch.Grand_Parent_Product__c, 'UTF-8') ;
        }
        if(prodSearched.productSearch.Parent_Product__c!=null) {
            urlStr = urlStr + '&' + prodFieldsId.Parent_Product_Id__c + '=' + EncodingUtil.urlEncode(prodSearched.productSearch.Parent_Product__c, 'UTF-8') ;
        }
        if(prodSearched.productSearch.Product__c!=null) {
            urlStr = urlStr + '&' + prodFieldsId.Product_Id__c + '=' + EncodingUtil.urlEncode(prodSearched.productSearch.Product__c, 'UTF-8') ;
        }
        if(prodSearched.productSearch.Product_Division__c!=null) {
            urlStr = urlStr + '&' + prodFieldsId.Product_Division_Id__c + '=' + EncodingUtil.urlEncode(prodSearched.productSearch.Product_Division__c, 'UTF-8') ;
        }
        
        // prepare the page reference
        Pagereference pageRef = new PageReference(urlStr);
        pageRef.setRedirect(true);
        return pageRef;
       
    }
    
    // wrapper class to hold the product search results and display checkbox in front of every record.
    /**
     * @description Wrapper class
     */
    public class ProdWrapper
    {
        public ProductSearch__c productSearch { get; set; }
        public Boolean checked { get; set; }
        /**
         * @param pdSearch ProductSearch__c
         * @param checked Boolean
         * @description constructor
         */
        public prodWrapper(ProductSearch__c pdSearch,Boolean checked)
        {
            this.checked=checked;
            this.productSearch=pdSearch;
        }
        /**
         * @description constructor
         */
        public prodWrapper(){
            this.checked=false;
            this.productSearch=new ProductSearch__c();
        }
    }

    /**
     * @description Comparable class for Grand_Parent_Product object
     */
    public class GrandParentProductComparable implements Comparable {
        public ProductSearch__c pdSearch {get; private set;}

        /**
         * @param pdSearch ProductSearch__c
         * @description constructor
         */
        public GrandParentProductComparable(ProductSearch__c pdSearch) {
            this.pdSearch = pdSearch;
        }

        /**
         * @param compareTo Object
         * @return Integer
         * @description compareTo
         */
        public Integer compareTo(Object compareTo) {
            GrandParentProductComparable compareToProd = (GrandParentProductComparable)compareTo;
            if (pdSearch.Grand_Parent_Product__c == compareToProd.pdSearch.Grand_Parent_Product__c) {
                return 0;
            }
            if (pdSearch.Grand_Parent_Product__c > compareToProd.pdSearch.Grand_Parent_Product__c) {
                return 1;
            }
            return -1;
        }
    }
   
}