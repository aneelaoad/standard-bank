/*************************************************************************\
    @ Author        : jkenny@salesforce.com
    @ Date          : 28/07/2016
    @ Description   : Cloned from ProductSearchPageController; 
                      use with ProductSearchPageSLDS
                      
    @LastmodifiedBy : Manoj Gupta
    @Date           : 23rd September 2016
    @Description    : US:1426 ProductSearch page logic updated                 

    @LastmodifiedBy : Marko Dvečko
    @Date           : 04/01/2017
    @Description    :
    Winter '17 in lightning we cannot get parameters from URL because they 
    are all encoded. sforce.one.navigateToURL is not good option.
    Instread we use PageReference object that redirects to other page.

    @ Last Modified By  : Maksim Dzianisik
    @ Last Modified On  : Aug 4, 2021
    @description        : SFP-6008 - Added filter logic for Insurance products
    
****************************************************************************/
@SuppressWarnings('PMD.ExcessivePublicCount')
public class ProductSearchPageSLDSExtension {
    
    //variable declaration
    public Opportunity opp                      {get;set;}
    public SB_Product__c prod                   {get;set;}
    public boolean renderMessage                {get;set;}
    public String productString                 {get;set;}
    public List<prodWrapper> lstProductWrapper  {get;set;}
    public prodWrapper prodSearched             {get;set;}
    public String rt                            {get;set;}
    public String gpp                           {get;set;}
    public String pp                            {get;set;}
    public String prod1                         {get;set;}
    public String pd                            {get;set;}
    public String urlStr                        {get;set;}
    public Boolean isProductLimit               {get;set;}

    private static final String INSURANCE = 'Insurance';
    
    /*********************************************************************************************************************
     Method : ProductSearchPageSLDSExtension
     @param controller ApexPages.StandardController, N/A as it is a constructor
     Description : Constructor of the class usses to initialize opportunity reference and other member variables.    
    ********************************************************************************************************************/
    public ProductSearchPageSLDSExtension(ApexPages.StandardController controller)
    {
        prod = (SB_Product__c)controller.getRecord();
        lstProductWrapper = new List<prodWrapper>();
        List<String> bccProfileNames = new List<String>{
                DMN_Profile.COMMERCIAL_BANKING_CUSTOM_STD_USER,
                DMN_Profile.COMMERCIAL_BANKING_CUSTOM_STD_USER_MOBILE,
                DMN_Profile.BCC_CUSTOM_STD_USER_MOBILE
                };
        renderMessage = false;
        system.debug('>>>Params>>>'+ApexPages.currentPage().getParameters());
        if (ApexPages.currentPage().getParameters().containsKey('oppId')) {
            opp = [SELECT Id, Name,AccountId,StageName, OwnerId, isPrivate, Account.Name, 
                            Owner.Name, 
                                (SELECT Id 
                                 FROM Products__r) 
                    FROM Opportunity 
                    WHERE Id = :ApexPages.currentPage().getParameters().get('oppId')];
        }
        else {
            String prodId = ApexPages.currentPage().getParameters().get('retURL');
            prodId = prodId.substring(1, 16);
            try {
                SB_Product__c product = [SELECT Id , Opportunity__c 
                                        FROM SB_Product__c 
                                        WHERE Id =: prodId] ;  
                opp = [ SELECT  Id, Name, AccountId,StageName, OwnerId, isPrivate, 
                                Account.Name, Owner.Name, 
                                (SELECT Id 
                                 FROM Products__r) 
                        FROM Opportunity WHERE 
                        Id = :product.Opportunity__c];
            } 
            catch(QueryException ex) {
                opp = [SELECT Id, Name, AccountId, StageName, OwnerId, isPrivate, Account.Name, 
                                Owner.Name, 
                                (SELECT Id 
                                 FROM Products__r) 
                        FROM Opportunity WHERE 
                        Id = :prodId];
            }  
        }

        Set<Id> commbProfiles = new Set<Id>();
        List<Profile> bccProfiles = SEL_Profiles.newInstance().selectByNames(bccProfileNames);
        for(Profile prof : bccProfiles){
            commbProfiles.add(prof.Id);
        }

        isProductLimit = false;                     //no product limit
       
    }

    /**
     * @return PageReference
     * @description returnToOpp
     */
    public PageReference returnToOpp(){
        return new PageReference('/' + opp.Id);
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
        if (productString != null && productString != '' && (productString.length() > 2 || Label.productSearchStrings.containsIgnoreCase(productString))) {
            List<ProductSearch__c> newProductSearches = ProductSearch__c.getAll().values();
            // per Technical Design of EN-0416 products must be sorted by Grand Parent Product
            List<ProductSearchPageSLDSExtension.GrandParentProductComparable> productSearchesSorted = new List<ProductSearchPageSLDSExtension.GrandParentProductComparable>();
            for (ProductSearch__c p: newProductSearches) {
                productSearchesSorted.add(new ProductSearchPageSLDSExtension.GrandParentProductComparable(p));
            }
            productSearchesSorted.sort();

            final User cUser = [SELECT user_cib_global_area__c, User_Division__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            final String userGlobalArea = cUser.user_cib_global_area__c;
            if (String.isEmpty(userGlobalArea)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'User CIB Global Area is empty, the search cannot continue');
                ApexPages.addmessage(myMsg);
            }

            for (ProductSearchPageSLDSExtension.GrandParentProductComparable pdSearchInOrder: productSearchesSorted) {
                ProductSearch__c pdSearch = pdSearchInOrder.pdSearch;

                if ((pdSearch.Grand_Parent_Product__c != null && pdSearch.Grand_Parent_Product__c.containsIgnoreCase(productString)) || 
                    (pdSearch.Parent_Product__c != null && pdSearch.Parent_Product__c.containsIgnoreCase(productString)) || 
                    (pdSearch.Product_Division__c != null && pdSearch.Product_Division__c.containsIgnoreCase(productString)) ||
                    (pdSearch.Product__c != null && pdSearch.Product__c.containsIgnoreCase(productString))) {
                        // US-1124
                        if ((userGlobalArea.equalsIgnoreCase('BCC') && pdSearch.Product_Division__c.equalsIgnoreCase('Business and Commercial Banking'))
                         || (!userGlobalArea.equalsIgnoreCase('BCC') && !pdSearch.Product_Division__c.equalsIgnoreCase('Business and Commercial Banking'))) {
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
            if (lstProductWrapper != null && lstProductWrapper.size() == 0) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, Label.EnterDifferentValue);
                ApexPages.addmessage(myMsg);
            }
        }
        else {
            renderMessage = true;   // render message on the screen that atleast 3 letters are required to perform search.
        }
    }
    
    /*********************************************************************************************************************
     Method : remoteSearch
     @param productString String
     @return List<prodWrapper>
     Description : Same as search() but remote enabled;  takes args and returns vars to client page, no bindings to class
                   vars.  Note that productString is the arg; class var of same name not accessible in remote static
                   method.
    ********************************************************************************************************************/
    @RemoteAction
    public static List<prodWrapper> remoteSearch(String productString)
    {
        List<prodWrapper> lstProductWrapper = new List<prodWrapper>();        
        if(productString != null && productString != '' && (productString.length() > 2 || Label.productSearchStrings.containsIgnoreCase(productString))) {

            List<ProductSearch__c> newProductSearches = ProductSearch__c.getAll().values();
            // per Technical Design of EN-0416 products must be sorted by Grand Parent Product
            List<ProductSearchPageSLDSExtension.GrandParentProductComparable> productSearchesSorted = new List<ProductSearchPageSLDSExtension.GrandParentProductComparable>();
            for (ProductSearch__c p: newProductSearches) {
                productSearchesSorted.add(new ProductSearchPageSLDSExtension.GrandParentProductComparable(p));
            }
            productSearchesSorted.sort();

            final User cUser = [SELECT user_cib_global_area__c, User_Division__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            final String userGlobalArea = cUser.user_cib_global_area__c;
            if (String.isEmpty(userGlobalArea)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'User CIB Global Area is empty, the search cannot continue');
                ApexPages.addmessage(myMsg);
            }

            for (ProductSearchPageSLDSExtension.GrandParentProductComparable pdSearchInOrder: productSearchesSorted) {
                ProductSearch__c pdSearch = pdSearchInOrder.pdSearch;

                if((pdSearch.Grand_Parent_Product__c != null && pdSearch.Grand_Parent_Product__c.containsIgnoreCase(productString)) || 
                    (pdSearch.Parent_Product__c != null && pdSearch.Parent_Product__c.containsIgnoreCase(productString)) || 
                    (pdSearch.Product_Division__c != null && pdSearch.Product_Division__c.containsIgnoreCase(productString)) ||
                    (pdSearch.Product__c != null && pdSearch.Product__c.containsIgnoreCase(productString))) {
                        // US-1124
                        if ((userGlobalArea.equalsIgnoreCase('BCC') && pdSearch.Product_Division__c.equalsIgnoreCase('Business and Commercial Banking'))
                         || (!userGlobalArea.equalsIgnoreCase('BCC') && !pdSearch.Product_Division__c.equalsIgnoreCase('Business and Commercial Banking'))) {
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
            if (lstProductWrapper != null && lstProductWrapper.size() == 0) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, Label.EnterDifferentValue);
                ApexPages.addmessage(myMsg);
            }
            System.Debug(lstProductWrapper);
            System.Debug(JSON.serialize(lstProductWrapper));
            return lstProductWrapper;
        }
        else {
            return new List<prodWrapper>();   // render message on the screen that atleast 3 letters are required to perform search.
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
    public  PageReference redirect() 
    {
        urlStr = '';
        
        if (opp == null) {
            String prodId = ApexPages.currentPage().getParameters().get('retURL');
            prodId = prodId.substring(1, 19);
            SB_Product__c product = [SELECT Id , Opportunity__c FROM SB_Product__c WHERE Id = :prodId] ;  
         
            opp = [SELECT Id, Name, AccountId, StageName, OwnerId, isPrivate, Account.Name, Owner.Name FROM Opportunity WHERE 
                    Id = :product.Opportunity__c];
        } 
       
        system.debug('>>>prodSearched value>>>>'+rt);
        system.debug('>>>prodSearched value>>>>'+gpp);
        system.debug('>>>prodSearched value>>>>'+pp);
        system.debug('>>>prodSearched value>>>>'+prod1);
        system.debug('>>>prodSearched value>>>>'+pd); 
        Product_Fields__c prodFieldsId = Product_Fields__c.getInstance('productIds');       
        Schema.DescribeSObjectResult d = Schema.SObjectType.SB_Product__c;
        if (!Test.isRunningTest()) {
            String recordTypeId = d.getRecordTypeInfosByName().get(rt).getRecordTypeId();
            String keyPrefix = d.getKeyPrefix();
        
            // Adding Standard Field Values
            urlStr = urlStr + '/apex/ProductCreationPageSLDS?RecordType=' + recordTypeId + '&nooverride=1';
        }
        //Adding Opportunities and Account Lookup
        if (opp.Id != null) {
            urlStr = urlStr + '&' + prodFieldsId.Opportunity_Id__c + '=' + EncodingUtil.urlEncode(opp.Name, 'UTF-8') ;
            urlStr = urlStr + '&' + prodFieldsId.Opportunity_Id__c + '_lkid=' + opp.Id ;
        }
        if (opp.AccountId != null && opp.Account.Name != null) {
            urlStr = urlStr + '&' + prodFieldsId.Account_Id__c + '=' + EncodingUtil.urlEncode(opp.Account.Name, 'UTF-8') ;
            urlStr = urlStr + '&' + prodFieldsId.Account_Id__c + '_lkid=' + opp.AccountId ;
        }
        
        //Adding Field Values
        if (gpp != null) {
            urlStr = urlStr + '&' + prodFieldsId.Grand_Parent_Product_Id__c + '=' + EncodingUtil.urlEncode(gpp, 'UTF-8') ;
        }
        if (pp != null) {
            urlStr = urlStr + '&' + prodFieldsId.Parent_Product_Id__c + '=' + EncodingUtil.urlEncode(pp, 'UTF-8') ;
        }
          
        if (prod1 != null) {
            urlStr = urlStr + '&' + prodFieldsId.Product_Id__c + '=' + EncodingUtil.urlEncode(prod1, 'UTF-8') ;
        }
        if (pd != null) {
            urlStr = urlStr + '&' + prodFieldsId.Product_Division_Id__c + '=' + EncodingUtil.urlEncode(pd, 'UTF-8') ;
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
         * @description wrapper
         */
        public prodWrapper(ProductSearch__c pdSearch,Boolean checked)
        {
            this.checked = checked;
            this.productSearch = pdSearch;
        }
        /**
         * @description wrapper
         */
        public prodWrapper() {
            this.checked = false;
            this.productSearch = new ProductSearch__c();
        }
    }

    /**
     * @description Comparable class for Grand_Parent_Product object
     */
    public class GrandParentProductComparable implements Comparable 
    {
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