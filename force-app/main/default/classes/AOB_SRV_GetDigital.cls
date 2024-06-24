/***************************************************************************************
@Author            : Lokesh Bothsa
@Date              : 23 Dec 2022
@Name of the Class : AOB_SRV_GetDigital
@description       : Class used to perform an API call to Get Digital API	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP 27748 
***************************************************************************************/
public without sharing class AOB_SRV_GetDigital{

    public static final String CHECK_CARD='Cheque Card';
    
    /**
    * @description calling to get the response from GetDigotalAPI
    * @param applicationId
    * @return Integer
    */
    public static Integer fetchResponse(String applicationId){
        
        String totalResponse;
        AOB_API_DigitalOffers customerServiceCall = new AOB_API_DigitalOffers(applicationId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_DigitalOffers.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        if(customerServiceCall.getResponseStatusCode() == 200){
            AOB_API_GetDigitalOfferWrapper getOfferWrapper = (AOB_API_GetDigitalOfferWrapper) System.JSON.deserialize(customerServiceCall.getResponseBody(), AOB_API_GetDigitalOfferWrapper.class);
            
            List<AOB_ApplicationLineItem__c> listofApplicationLineitems = [select Id,AOB_Status__c,SalesObjectItemId__c,AOB_ExpiryDate__c,AOB_Product__c,AOB_Application__c,name,Details__c,AOB_ProductCode__c,AOB_Product__r.Name from AOB_ApplicationLineItem__c  where AOB_Application__c=:applicationId];
            
            List<AOB_ApplicationLineItem__c> appLinenitemsins = new List<AOB_ApplicationLineItem__c>();
            
            Set<String> checktheApplineItemRecords= new Set<String>();
            for(AOB_ApplicationLineItem__c aob:listofApplicationLineitems){
                checktheApplineItemRecords.add(aob.AOB_ProductCode__c);
            }
            
            map<string,Id> mapofProdIdvsCode = new map<string,Id>();
            for(product2 prod : [select id,name,ProductCode from product2]){
                if(prod.ProductCode == '4648' || prod.ProductCode == 'ZPSS' || prod.ProductCode== '4488'|| prod.ProductCode=='ZPOB' || prod.ProductCode=='ZBCH'){
                    mapofProdIdvsCode.put(prod.ProductCode , prod.Id);
                }
            }
            
            if(getOfferWrapper.productItems !=null){
                String piItemToUpdate;
                Boolean isAppLineItemFound=false;
                for(AOB_API_GetDigitalOfferWrapper.ProductItem eachpiitem :  getOfferWrapper.productItems){
                    
                    if(eachpiitem.productID == '4648'){ 
                        if(!checktheApplineItemRecords.contains('4648')){
                            String statusDes;
                            if(eachpiitem.itemStatus != null){
                                String initiateData=Json.serialize(eachpiitem.itemStatus);
                                List<object> statusCodeList= (List<object>)System.JSON.deserializeUntyped(initiateData);
                                for(Object itemdata:statusCodeList){
                                    Map<String, Object> m = (Map<String, Object>)itemdata;
                                    if((String)m.get('statusCode')=='E0006' || (String)m.get('statusCode')=='E0007'){                       
                                        statusDes=(String)m.get('statusDesc');
                                    }
                                }
                            }
                            AOB_ApplicationLineItem__c eachaplimymobiz = new AOB_ApplicationLineItem__c();
                            eachaplimymobiz.AOB_Application__c = applicationId;
                            eachaplimymobiz.AOB_Status__c = statusDes;
                            eachaplimymobiz.Name = 'MyMoBiz';
                            eachaplimymobiz.AOB_ExpiryDate__c = Date.valueOf(eachpiitem.expiryDate);
                            eachaplimymobiz.SalesObjectItemId__c =String.valueOf(eachpiitem.itemID); 
                            eachaplimymobiz.AOB_Pricing_Option__c='ZMMB';
                            eachaplimymobiz.AOB_Product__c = mapofProdIdvsCode.get(eachpiitem.productID);             
                            appLinenitemsins.add(eachaplimymobiz);
                        }if(checktheApplineItemRecords.contains('4648')){  
                            isAppLineItemFound=true;
                            piItemToUpdate= String.valueOf(eachpiitem.itemID);                    
                        }
                    }
                    
                    if(eachpiitem.productID == 'ZPOB'){
                        if(!checktheApplineItemRecords.contains('ZPOB')){ 
                            AOB_ApplicationLineItem__c eachaplipck = new AOB_ApplicationLineItem__c(); 
                            String statusDes;
                            if(eachpiitem.itemStatus !=null){
                                String initiateData=Json.serialize(eachpiitem.itemStatus);
                                List<object> statusCodeList= (List<object>)System.JSON.deserializeUntyped(initiateData);
                                for(Object itemdata:statusCodeList){
                                    Map<String, Object> m = (Map<String, Object>)itemdata;
                                    if((String)m.get('statusCode')=='E0006' || (String)m.get('statusCode')=='E0007'){                       
                                        statusDes=(String)m.get('statusDesc');
                                    }
                                }
                            }
                            eachaplipck.AOB_Application__c = applicationId;
                            eachaplipck.AOB_ExpiryDate__c = Date.valueOf(eachpiitem.expiryDate);
                            eachaplipck.SalesObjectItemId__c =String.valueOf(eachpiitem.itemID);
                            eachaplipck.AOB_Product__c = mapofProdIdvsCode.get(eachpiitem.productID);  
                            eachaplipck.AOB_Status__c = statusDes;
                            eachaplipck.Name = 'PocketBiz';
                            eachaplipck.AOB_Pricing_Option__c='ZPBP';
                            appLinenitemsins.add(eachaplipck);                        
                        }                  
                    }
                    else if(eachpiitem.productID == 'ZPSS'){                   
                        if(!checktheApplineItemRecords.contains('ZPSS')){   
                            String statusDes;
                            if(eachpiitem.itemStatus !=null){
                                String initiateData=Json.serialize(eachpiitem.itemStatus);
                                List<object> statusCodeList= (List<object>)System.JSON.deserializeUntyped(initiateData);
                                for(Object itemdata:statusCodeList){
                                    Map<String, Object> m = (Map<String, Object>)itemdata;
                                    if((String)m.get('statusCode')=='E0006' || (String)m.get('statusCode')=='E0007'){                       
                                        statusDes=(String)m.get('statusDesc');
                                    }
                                }   
                            }              
                            AOB_ApplicationLineItem__c eachaplisnap = new AOB_ApplicationLineItem__c();
                            eachaplisnap.AOB_Application__c = applicationId;
                            eachaplisnap.AOB_ExpiryDate__c = Date.valueOf(eachpiitem.expiryDate);
                            eachaplisnap.SalesObjectItemId__c = String.valueOf(eachpiitem.itemID);   
                            eachaplisnap.AOB_Product__c = mapofProdIdvsCode.get(eachpiitem.productID);
                            eachaplisnap.AOB_Status__c = statusDes;
                            eachaplisnap.AOB_Pricing_Option__c='ZPSP';
                            eachaplisnap.Name = 'SnapScan';
                            appLinenitemsins.add(eachaplisnap);
                        }                 
                    }else if(eachpiitem.productID == '4488'){
                        if(!checktheApplineItemRecords.contains('4488')){
                            String statusDes;
                            if(eachpiitem.itemStatus !=null){
                                String initiateData=Json.serialize(eachpiitem.itemStatus);
                                List<object> statusCodeList= (List<object>)System.JSON.deserializeUntyped(initiateData);
                                for(Object itemdata:statusCodeList){
                                    Map<String, Object> m = (Map<String, Object>)itemdata;
                                    if((String)m.get('statusCode')=='E0006' || (String)m.get('statusCode')=='E0007'){                       
                                        statusDes=(String)m.get('statusDesc');
                                    }
                                }
                            }
                            AOB_ApplicationLineItem__c eachapliMarketlink = new AOB_ApplicationLineItem__c();
                            eachapliMarketlink.AOB_Application__c = applicationId;
                            eachapliMarketlink.AOB_Status__c = statusDes;
                            eachapliMarketlink.Name = 'Business MarketLink';
                            eachapliMarketlink.SalesObjectItemId__c = String.valueOf(eachpiitem.itemID);
                            eachapliMarketlink.AOB_ExpiryDate__c = Date.valueOf(eachpiitem.expiryDate);
                            eachapliMarketlink.AOB_Product__c = mapofProdIdvsCode.get(eachpiitem.productID);
                            eachapliMarketlink.AOB_Pricing_Option__c='ZBSM';
                            appLinenitemsins.add(eachapliMarketlink);
                        }                
                    }else if(eachpiitem.productID == 'ZBCH'){      
                        if(!checktheApplineItemRecords.contains('ZBCH')){ 
                            String statusDes;
                            if(eachpiitem.itemStatus !=null){
                                String initiateData=Json.serialize(eachpiitem.itemStatus);
                                List<object> statusCodeList= (List<object>)System.JSON.deserializeUntyped(initiateData);
                                for(Object itemdata:statusCodeList){
                                    Map<String, Object> m = (Map<String, Object>)itemdata;
                                    if((String)m.get('statusCode')=='E0006' || (String)m.get('statusCode')=='E0007'){                       
                                        statusDes=(String)m.get('statusDesc');
                                    }
                                }
                            }
                            AOB_ApplicationLineItem__c eachaplichequecard = new AOB_ApplicationLineItem__c();
                            eachaplichequecard.AOB_Application__c = applicationId;
                            eachaplichequecard.Name = CHECK_CARD;
                            eachaplichequecard.AOB_Status__c = statusDes;
                            eachaplichequecard.SalesObjectItemId__c = String.valueOf(eachpiitem.itemID);
                            eachaplichequecard.AOB_ExpiryDate__c = Date.valueOf(eachpiitem.expiryDate);
                            eachaplichequecard.AOB_Product__c = mapofProdIdvsCode.get(eachpiitem.productID);
                            eachaplichequecard.AOB_Pricing_Option__c='4108';
                            appLinenitemsins.add(eachaplichequecard);
                        }
                        
                    }
                }
                if(isAppLineItemFound){
                    List<AOB_ApplicationLineItem__c> applineItem=[select Id, AOB_ExpiryDate__c,AOB_Application__c from AOB_ApplicationLineItem__c where AOB_Application__c=:applicationId and AOB_ProductCode__c='4648'];
                    applineItem[0].SalesObjectItemId__c =piItemToUpdate; 
                    update applineItem;
                }
            }
            if(!appLinenitemsins.isEmpty()){
                insert appLinenitemsins;            
            }
        }
        return customerServiceCall.getResponseStatusCode();       
    }  
   
}