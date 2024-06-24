/*****************************************************************************************************\
    @ Func Area     : Opportunities, Products (SB_Product__c) & Draw Down Profile

    -------------------------------------------------------------------------------------
    @description      Case#141, This is the controller class for the visualforce page "DrawDownProductRedirect_Vf".
                      The controller / page redirects a user to the draw down page from the
                      product page if:
                        - The product record type is in the custom setting "Draw_Down_Product_Record_Types__c"
                        - The product Grand Parent Product (GPP) pick list value is in the custom setting "Draw_Down_Grand_Parent_Products__c"
                        - There are no Draw Down Profile ralted records currently linked to the
                          specific product.
    @author Rudolf Niehaus
    @date 27/06/2012
                                
******************************************************************************************************/
public with sharing class DrawDownProductRedirect_Vf_Ext {
    private Id productId;
    private Id oppId;
    @TestVisible private list<SB_Product__c> lstProduct;
    @TestVisible private list<Draw_Down_Profile__c> lstDrawDown;
    private Environment_Variable__c settings = null;
    @TestVisible private Integer newProduct;

    /**
     * Method gets the referer URL in order to redirect to opportunity
     *
     * @return
     */
    public String getReferer() {
        return ApexPages.currentPage().getHeaders().get('Referer');
    }

    /**
     * Constructor for controller extension
     *
     * @param stdCon
     */
    public DrawDownProductRedirect_Vf_Ext(ApexPages.StandardController stdCon) {
        //Get the environment values that indictes if this product must adhear to the business rules for draw down's
        this.settings = Environment_Variable__c.getInstance();
        productId = stdCon.getId();
        lstProduct = [select Id, RecordType.Name, Grand_Parent_Product__c, Opportunity__c from SB_product__c where Id = :productId limit 1];
        lstDrawDown = [select Id from Draw_Down_Profile__c where Product__c = :productId];


        System.debug('Current request URL: ' + getReferer());

        //Sets newProduct flag to avoid override if applicable
        if (getReferer() == settings.serverURL__c + '/a0g/e') {
            newProduct = 1;
        } else {
            newProduct = 0;
        }
    }

    /**
     * This method will redirect the user from the product page based on the business rules
     *
     * @return PageReference
     */
    public PageReference redirect() {
        PageReference pageRef = null;

        // If product is not found redirect to standard view to display 'Data not available' message
        if (lstProduct.isEmpty()) {
            pageRef = new PageReference('/' + productId + '?nooverride=1');
            return pageRef;
        }

        String productRecordTypes = settings.Draw_Down_Product_Record_Types__c;
        String gppPickListValues = settings.Draw_Down_Grand_Parent_Products__c;

        //the default is NO overriding and navigate back to the related Opportunity.
        pageRef = new PageReference('/' + lstProduct[0].Opportunity__c + '?nooverride=1');

        //If this product record type and parent product name falls into the rule category, enforce rule.
        if ((productRecordTypes.contains(lstProduct[0].RecordType.Name)) &&
                (gppPickListValues.contains(lstProduct[0].Grand_Parent_Product__c))) {
                //If there are no draw down records for the product enforce the business rules 
                if(lstDrawDown.size() == 0){    
                    pageRef = new PageReference('/apex/DrawDownProfile_Vf?Id=' + productId + '&recs=' + lstDrawDown.size());
                }else{
                    pageRef = new PageReference('/' + productId + '?nooverride=1');
                }
        }else{
                if(newProduct == 0){
                    pageRef = new PageReference('/' + productId + '?nooverride=1');
                }
        }
        
        return pageRef;
     }
}