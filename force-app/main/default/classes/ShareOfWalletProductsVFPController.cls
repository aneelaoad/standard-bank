/****************************************************************************************************
//  @ Func Area     : Share of Wallet Products VFP
    @ Author        : Aneske Meiring
    @ Date          : 10/2013
    @ Test File     :   .cls
    @ Description   : This controller is used for creating the SOW Products VFP.

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Mar 1, 2016
    @ Modification Description : US-1177 : adjusting logic using ProductSubsets__c
    
    @ Last Modified By  : Andrei Olteanu
    @ Last Modified On  : Nov 21, 2016
    @ Modification Description : US-1254 : add SLDS styling
******************************************************************************************************/
public class ShareOfWalletProductsVFPController {

 
    //Local Variables
    private static Integer intNUMBER_OF_ROWS = 1;
    public list < shareWalletProduct > shareWalletProductLst {
        get;
        set;
    }
    public list < Share_of_Wallet_Product__c > sowToUpsert {
        get;
        set;
    }
    public String soWId;
    
    public double Sum_ETWS {get;set;}
    public double Sum_ESBR {get;set;}
    public double Sum_Budget {get;set;}
   // public double Sum_PB {get;set;} 
    public Boolean isLightning {get; set;}

    public ShareOfWalletProductsVFPController(ApexPages.StandardController controller) {
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        Sum_ETWS = 0 ;  Sum_ESBR = 0; Sum_Budget =0 ; //Sum_PB=0;
          
        List < Share_Wallet__c > SOWList = New List < Share_Wallet__c > ();
        shareWalletProductLst = new list < shareWalletProduct > ();
       
        soWId = ApexPages.currentPage().getParameters().get('id');

        list < Share_of_Wallet_Product__c > sowProdList = [select Id, Estimated_Share_of_Wallet__c, Estimated_Standard_Bank_Revenue__c,CurrencyIsoCode,Tech_SOWProduct_Unique__c,
                                                                                                            Estimated_Total_Wallet_Size__c,  Product_Subset__c, Share_of_Wallet__r.Name,
                                                                                                            Share_of_Wallet__r.Division__c, Competitors__c, Budget__c, Target_Share__c,Share_of_Wallet__r.CurrencyIsoCode,
                                                                                                            Share_of_Wallet__c from Share_of_Wallet_Product__c Where
                                                                                                            Share_of_Wallet__c = : soWId]; 

        SOWList = [select Id, Division__c,CurrencyIsoCode from Share_Wallet__c where Id = : soWId];
        
        //Custom Setting Data
        Map < string, ProductSubsets__c > ProdSubset_Map = new Map < string, ProductSubsets__c > ();
        ProdSubset_Map = ProductSubsets__c.getall();
        List < String > productStrSet = new list < String > ();
        Map<String,Share_of_Wallet_Product__c> mapProductName = new Map<String,Share_of_Wallet_Product__c>();
        
        
        for (Share_of_Wallet_Product__c sharewp : sowProdList){
            mapProductName.put(sharewp.Product_Subset__c,sharewp);
        }
        
        
        //Checking the List size
        if(ProdSubset_Map.Values().Size() > 0){
        for (ProductSubsets__c psMap: ProdSubset_Map.Values()) {
            if (SOWList[0].Division__c == psMap.Product_Division__c) {
                productStrSet.add(psMap.parent_product__c);
            }
          }
        }
           
        //Check if the ShareofWallet Product list is empty or not
        if (sowProdList.size() == 0 || sowProdList.size() != productStrSet.Size()) {
            intNUMBER_OF_ROWS = productStrSet.size();
            for (Integer i = 0; i < intNUMBER_OF_ROWS; i++) {
                if (!mapProductName.containsKey(productStrSet[i])){
                Share_of_Wallet_Product__c swP = new Share_of_Wallet_Product__c();
                swP.Product_Subset__c = productStrSet[i];
                swP.Share_of_Wallet__c = soWId;
                swp.Tech_SOWProduct_Unique__c = soWId + productStrSet[i];
                swP.CurrencyIsoCode = SOWList[0].CurrencyIsoCode ;
                shareWalletProductLst.add(new shareWalletProduct(swP, productStrSet[i]));
              }
              else{
                 if (mapProductName.containsKey(productStrSet[i])){
                 shareWalletProductLst.add(new shareWalletProduct(mapProductName.get(productStrSet[i]), productStrSet[i]));
                  }
                 }
            }
        }
        
             for (Share_of_Wallet_Product__c swP: sowProdList) {
                   
                   if (sowProdList.size() != 0 && sowProdList.size() == productStrSet.Size()) {
                    shareWalletProductLst.add(new shareWalletProduct(swP, swP.Product_Subset__c));
                   }
                   
                   //shareWalletProductLst.sort();
                  
                   if (sowProdList.size() != 0) { 
                    if (swP.Estimated_Total_Wallet_Size__c != null) 
                        Sum_ETWS   = Sum_ETWS + swP.Estimated_Total_Wallet_Size__c ;
                    if (swP.Estimated_Standard_Bank_Revenue__c != null)   
                        Sum_ESBR  =  Sum_ESBR + swP.Estimated_Standard_Bank_Revenue__c;
                    if (swP.Budget__c != null) 
                        Sum_Budget =  Sum_Budget + swP.Budget__c ;
                    // Sum_PB  =    Sum_PB + swp.Competitors__c;
              
                   }
            }
        
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
    
  //Method to Save Share of Wallet Product
    public pageReference SaveSowProdClose() {
    	 
        sowToUpsert = new list < Share_of_Wallet_Product__c > ();
        if (shareWalletProductLst.size() > 0) {
            for (shareWalletProduct sp: shareWalletProductLst) {
                sowToUpsert.add(sp.sowProd);
            }
        }
        
          try{
          upsert sowToUpsert;
          PageReference pageRef = new PageReference('/' + soWId);
          pageref.setRedirect(true);
          return pageRef;   
          }
          
          Catch(DmlException ex){
          	list < Share_of_Wallet_Product__c > sowProdList = [select Id,CreatedById,CreatedDate,LastModifiedDate,CreatedBy.Name,LastModifiedById from Share_of_Wallet_Product__c Where
                                                                                                                             Share_of_Wallet__c = : soWId ];
                                                                                                                             
          	 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Share of Wallet Product records have already been created by User <b> ' + sowProdList[0].CreatedBy.Name + '</B> at  ' + sowProdList[0].LastModifiedDate + '<br/> Please click on Cancel button to go back to Share of Wallet Page and Click on Manage Share of Wallet button if you want to edit Share of Wallet Products.');
             ApexPages.addMessage(myMsg);
             return null;
          }
          
    }
 
//Method to cancel the Manage Share of Wallet Products and Return to master record
public PageReference Cancel(){

   PageReference pageRef = new PageReference('/' + soWId);
    pageref.setRedirect(true);
    return pageRef;
    
 }
 

    //Wrapper Class
    public class shareWalletProduct {

        
        
        public Share_of_Wallet_Product__c sowProd {
            get;
            set;
        }
        public String product {
            get;
            set;
        }

        public shareWalletProduct(Share_of_Wallet_Product__c sP, String Prod) {
            sowProd = sP;
            product = Prod;
        }
        
        
    }

}