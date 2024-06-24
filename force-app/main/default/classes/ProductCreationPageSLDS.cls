/*************************************************************************\
@ Author        : Manoj Gupta
@ Date          : 20/09/2016
@ Description   : US:1426 Controller for ProductCreation Page

@ Author        : Marko Dvečko
@ Date          : 04/01/2017
@ Description   : 
We need to add save and new button that will go again to search product 
page. State diagram is:

ProductSearch_Navigate:
if isLightning 
state := ProductSearchPageSLDS
else 
state := ProductSearchPage

ProductSearchPage:      
if next 
state := StandardProductCreation

StandardProductCreation:
if saveAndNew 
state := ProductSearchPage

ProductSearchPageSLDS:
if next 
state := ProductCreationPageSLDS

ProductCreationPageSLDS:
if saveAndNew 
state := ProductSearchPageSLDS
if cancel
state := ProductSearchPageSLDS

@author Maksim Dzianisik
@date August 2021
@description added unescapeHtml4() method for picklist values

@author Maksim Dzianisik
@date October 2021
@description SFP-5352 Added functionality for pre populating Product_Lead_Source__c for Insurance Products
****************************************************************************/

@SuppressWarnings('PMD.ExcessivePublicCount')
public  with sharing class ProductCreationPageSLDS {
    
    public SB_Product__c prod {get;set;}
    public Opportunity opp    {get;set;}
    public String rt {get;set;}
    public String gpp {get;set;}
    public SB_Product__c prodobj{get;set;}
    public map<String,Schema.DisplayType> fieldnames{get;set;} 
    public String rtDevName {get;set;}
    public String grandpp {get;set;}
    public String parentp {get;set;}
    public String product {get;set;}
    public String productDiv {get;set;}
    private static final String INSURANCE = 'Insurance';
    
    /**
* @param controller ApexPages.StandardController
* @description constructor
*/
    public ProductCreationPageSLDS(ApexPages.StandardController controller) {
        prod= (SB_Product__c)controller.getRecord();
        Product_Fields__c prodFieldsId = Product_Fields__c.getInstance('productIds'); 
        Schema.DescribeSObjectResult d = Schema.SObjectType.SB_Product__c;       
        
        if (ApexPages.currentPage().getParameters().containsKey(prodFieldsId.Opportunity_Id__c+'_lkid') 
            && ((ApexPages.currentPage().getParameters().get(prodFieldsId.Opportunity_Id__c+'_lkid') != null) 
                && (ApexPages.currentPage().getParameters().get(prodFieldsId.Opportunity_Id__c+'_lkid') != ''))) {
                    prod.Opportunity__c = ApexPages.currentPage().getParameters().get(prodFieldsId.Opportunity_Id__c+'_lkid');
                }
        if (ApexPages.currentPage().getParameters().containsKey(prodFieldsId.Account_Id__c+'_lkid') 
            && ((ApexPages.currentPage().getParameters().get(prodFieldsId.Account_Id__c+'_lkid') != null) 
                && (ApexPages.currentPage().getParameters().get(prodFieldsId.Account_Id__c+'_lkid') != ''))) {
                    prod.Client__c = ApexPages.currentPage().getParameters().get(prodFieldsId.Account_Id__c+'_lkid');
                }
        
        
        if ((ApexPages.currentPage().getParameters().get('RecordType') != null) 
            && (ApexPages.currentPage().getParameters().get('RecordType') != '')) {
                prod.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            }
        
        RecordType rtname = [SELECT DeveloperName FROM RecordType WHERE SObjectType = 'SB_Product__c' and Id =: ApexPages.currentPage().getParameters().get('RecordType')];
        rtDevName = rtname.DeveloperName;
        
        if(rtDevName == INSURANCE) {
            String tempValue = getInsuranceLeadSource(prod.Opportunity__c);
            if (tempValue != '') {
                prod.Product_Lead_Source__c = tempValue;
            }
        }
        
        if ((ApexPages.currentPage().getParameters().get(prodFieldsId.Grand_Parent_Product_Id__c) != null) 
            && (ApexPages.currentPage().getParameters().get(prodFieldsId.Grand_Parent_Product_Id__c) != '')) {
                Grandpp = ApexPages.currentPage().getParameters().get(prodFieldsId.Grand_Parent_Product_Id__c);
                prod.Grand_Parent_Product__c = Grandpp.replace('+',' ').unescapeHtml4();
            }
        
        if ((ApexPages.currentPage().getParameters().get(prodFieldsId.Product_Division_Id__c) != null) 
            && (ApexPages.currentPage().getParameters().get(prodFieldsId.Product_Division_Id__c) != '')) {
                ProductDiv = ApexPages.currentPage().getParameters().get(prodFieldsId.Product_Division_Id__c);
                prod.Product_Division__c = ProductDiv.replace('+',' ');
            }
        
        if ((ApexPages.currentPage().getParameters().get(prodFieldsId.Parent_Product_Id__c) != null) 
            && (ApexPages.currentPage().getParameters().get(prodFieldsId.Parent_Product_Id__c) != '')) {
                Parentp = (ApexPages.currentPage().getParameters().get(prodFieldsId.Parent_Product_Id__c));
                prod.Parent_Product__c = Parentp.replace('+',' ').unescapeHtml4();
            }
        
        if ((ApexPages.currentPage().getParameters().get(prodFieldsId.Product_Id__c ) != null) 
            && (ApexPages.currentPage().getParameters().get(prodFieldsId.Product_Id__c ) != '')) {
                Product = ApexPages.currentPage().getParameters().get(prodFieldsId.Product_Id__c );
                prod.SA_Product__c = Product.replace('+',' ').unescapeHtml4();
            }
        //SFP-10156 : Getting the default picklist value from the Schema
        if(rtDevName == DMN_SB_Product.RT_TPS2022 || rtDevName == DMN_SB_Product.RT_TRANSACTIONAL_2014) { 
            String strPicklistDefaultvalue;
            Schema.DescribeFieldResult SchemaOfSBProducts = SB_Product__c.Product_Revenue_Type__c.getDescribe();
            List <Schema.PicklistEntry> List_pickVals = SchemaOfSBProducts.getPicklistValues();        
            for (Schema.PicklistEntry pv: List_pickVals) {
                if (pv.isDefaultValue()) {
                    strPicklistDefaultvalue = pv.getValue();
                    prod.Product_Revenue_Type__c = strPicklistDefaultvalue;
                }    
            }
        }
        //SFP-10156 : End
    }
    
    /**
* @return PageReference
* @description save product
*/
    public PageReference save() {
        try {
            insert prod;
        } 
        catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        PageReference redirectSuccess = new ApexPages.StandardController(prod).view();
        return redirectSuccess;
        
    }
    
    //public PageReference saveAndNew() {
    //    try {
    //        insert prod;
    //    }
    //    catch (System.DMLException e) {
    //        ApexPages.addMessages(e);
    //        return null;
    //    }
    //    return new PageReference('/apex/ProductSearchPageSLDS?oppId=' + prod.Opportunity__c);
    //}
    
    /**
* @return PageReference
* @description redirect to the Opportunity
*/
    public PageReference cancel() {
        return new PageReference('/apex/ProductSearchPageSLDS?oppId=' + prod.Opportunity__c); 
    }
    
    /**
* @param oppId OpportunityId
* @description returns first created Product_Lead_Source__c Insurance Product value
* @return String
*/
    private String getInsuranceLeadSource(Id oppId) {
        String result = '';
        Set<Id> ids = new Set<Id>{oppId};
            String orderField = 'CreatedDate';
        String additionalCond = 'AND Product_Lead_Source__c != NULL';
        SEL_Products products = new SEL_Products();
        
        
        List<SB_Product__c> tempProducts = products.selectByOppIdRecordTypeProductLeadSource(
            ids,
            INSURANCE,
            additionalCond,
            orderField,
            fflib_QueryFactory.SortOrder.ASCENDING,
            true
        );
        
        if(tempProducts.size() > 0) {
            result = tempProducts[0].Product_Lead_Source__c;
        }
        
        return result;
    }
}