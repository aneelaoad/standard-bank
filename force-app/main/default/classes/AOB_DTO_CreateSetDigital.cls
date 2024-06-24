/**
* @description   Wrapper Class for Create Set digital API Body
* @author Dayakar
* @date  15-12-2022 
*/
public class AOB_DTO_CreateSetDigital{
    /**
* @description	used to set information related to the get API
* @param applicationId
* @return get Set digital API request Body
*/
    public static AOB_DTO_SetDigital.Input SetDigitalResponseBody(String applicationId){
        AOB_Application__c applicationRec = [select id,name,AOB_SalesObjectId__c,AOB_inflightData__c from AOB_Application__c where id=:applicationId];
        List<AOB_ApplicationLineItem__c> appliationlineItem=[select id,Details__c,SalesObjectItemId__c,AOB_ProductCode__c,AOB_Status__c from AOB_ApplicationLineItem__c where AOB_Application__c =:applicationId];              
        String preappResponse=AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.PRE_APP_RESPONSE);
        String compdetails=AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.COMPANY_DETAILS);
        String notification=AOB_CTRL_FormCreator.getInflight(applicationId, 'Notifications');
        String persondata=AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.PERSONAL_DETAILS);
        String PreApplication=AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.PRE_APPLICATION);
        String Cardselection=AOB_CTRL_FormCreator.getInflight(applicationId, 'Card Selection');
        
        Map < String, Object > preappResponsemap = (Map < String, object > ) JSON.deserializeUntyped(preappResponse);
        Map < String, Object > cdResponsemap = (Map < String, object > ) JSON.deserializeUntyped(compdetails);
        Map < String, Object > notiResponsemap = (Map < String, object > ) JSON.deserializeUntyped(notification);
        Map < String, Object > pdResponsemap = (Map < String, object > ) JSON.deserializeUntyped(persondata);
        Map < String, Object > PreApplicationmap = (Map < String, object > ) JSON.deserializeUntyped(PreApplication);
        Map < String, Object > CardselectionMap = (Map < String, object > ) JSON.deserializeUntyped(Cardselection);
        
        AOB_DTO_SetDigital inputdata=new  AOB_DTO_SetDigital();
        AOB_DTO_SetDigital.Input inpulist= new AOB_DTO_SetDigital.Input();
        List<object> datalist= new List<object>();   
        inpulist.offerId=applicationRec.AOB_SalesObjectId__c;
        String ItemMyMoBiz;
        String MyMoBizdata;
        AOB_DTO_SetDigital.Items itemdata=new AOB_DTO_SetDigital.Items();
        AOB_DTO_SetDigital.InputTnx tnxdata= new  AOB_DTO_SetDigital.InputTnx();
        AOB_DTO_SetDigital.MyUpdates setmyupdates= new AOB_DTO_SetDigital.MyUpdates();
        for(AOB_ApplicationLineItem__c aoblineItemSnapscan:appliationlineItem){
            if(aoblineItemSnapscan.AOB_ProductCode__c==AOB_Constants.MYMOBIZPRODUCTCODE){
                ItemMyMoBiz=aoblineItemSnapscan.SalesObjectItemId__c;
                MyMoBizdata=aoblineItemSnapscan.Details__c;
            }
        }
        
        itemdata.itemNo='0'+ItemMyMoBiz;
        tnxdata.preferredBranch=(String)cdResponsemap.get('PREFERRED BRANCH');
        if((String)notiResponsemap.get('NotifiedMean')=='EMAIL'){
            setmyupdates.msgType='E';
            setmyupdates.email=(String)cdResponsemap.get('EMAIL ADDRESS');
        }else if((String)notiResponsemap.get('NotifiedMean')=='SMS'){
            
            setmyupdates.msgType='S';
            setmyupdates.cellphone=(String)cdResponsemap.get('CELLPHONE');
        }
        setmyupdates.recipientName=(String)PreApplicationmap.get('Name')+' '+(String)PreApplicationmap.get('Surname');
        tnxdata.myUpdates=setmyupdates;
        itemdata.inputTnx=tnxdata;
        datalist.add(itemdata);
        
        AOB_DTO_SetDigital.Items1 itemdata1=new AOB_DTO_SetDigital.Items1();
        AOB_DTO_SetDigital.InputChequeCard setinputcard=new AOB_DTO_SetDigital.InputChequeCard();
        AOB_DTO_SetDigital.DeliveryDetail  deliverydetails=new AOB_DTO_SetDigital.DeliveryDetail();
        String ItemChequeCard;
        String ChequeCarddata;
        Boolean isChequeCardTaken = false;
        for(AOB_ApplicationLineItem__c aoblineItemSnapscan:appliationlineItem){
            if(aoblineItemSnapscan.AOB_ProductCode__c==AOB_Constants.ZBCH && aoblineItemSnapscan.AOB_Status__c=='Accepted'){
                ItemChequeCard=aoblineItemSnapscan.SalesObjectItemId__c;
                ChequeCarddata=aoblineItemSnapscan.Details__c;
                isChequeCardTaken = true;
                
            }
        }
        Map<String,Object> chequecardmap ;
        Map<String,Object> addressdetailsmap ; 
        String addressdetails;  
        
        if(isChequeCardTaken){
            
            if(!String.isEmpty(ChequeCarddata)){
                chequecardmap= (Map<String,object>)JSON.deserializeUntyped(ChequeCarddata);
                if(chequecardmap.get('addressValue')!=null){
                    addressdetails=Json.serialize(chequecardmap.get('addressValue'));
                }
                if((String)chequecardmap.get('Deliver Address')=='Residential' || (String)chequecardmap.get('Deliver Address')=='Company'){
                    addressdetailsmap= (Map<String,object>)JSON.deserializeUntyped(addressdetails);
                }
            }
            itemdata1.itemNo='0'+ItemChequeCard;
            
            if(CardselectionMap.get('chequeCardSelected')!=null){
                if(Boolean.valueOf(CardselectionMap.get('chequeCardSelected'))==true){
        setinputcard.preferredBranch=(String)cdResponsemap.get('PREFERRED BRANCH');
        setinputcard.cardHolderUUID=(String)preappResponsemap.get('initiatorBPGUID');
        if((String)chequecardmap.get('Delivery method')=='Private Address'){
            deliverydetails.deliveryMethod='F';
            if((String)chequecardmap.get('Deliver Address')=='Residential'){
            deliverydetails.streetNumber=(String)addressdetailsmap.get('UnitNumber');
            deliverydetails.streetName=(String)addressdetailsmap.get('Street');    
            deliverydetails.city=(String)addressdetailsmap.get('city');
            deliverydetails.addr4=(String)addressdetailsmap.get('Complexe');
            deliverydetails.addr3='';
            deliverydetails.postalCode=(String)addressdetailsmap.get('PostalCode');
            deliverydetails.countrycode='ZA';
            deliverydetails.province=(String)addressdetailsmap.get('province');
            deliverydetails.countydistrict=(String)addressdetailsmap.get('suburb');
        }
        else if((String)chequecardmap.get('Deliver Address')=='Company'){
            deliverydetails.streetNumber=(String)addressdetailsmap.get('UnitNumber');
                            deliverydetails.streetName=(String)addressdetailsmap.get('StreetName');   
                            deliverydetails.city=(String)addressdetailsmap.get('city');
                            deliverydetails.addr4=(String)addressdetailsmap.get('Complex');
                            deliverydetails.addr3='';
                            deliverydetails.postalCode=(String)addressdetailsmap.get('PostalCode');
                            deliverydetails.countrycode='ZA';
                            deliverydetails.province=(String)addressdetailsmap.get('PROVINCE');
                            deliverydetails.countydistrict=(String)addressdetailsmap.get('SUBURB');
        }
        else if((String)chequecardmap.get('Deliver Address')=='New'){
            deliverydetails.streetNumber=(String)chequecardmap.get('UnitNumber');
            deliverydetails.streetName=(String)chequecardmap.get('Street');   
            deliverydetails.city=(String)chequecardmap.get('city');
            deliverydetails.addr4=(String)chequecardmap.get('Complexe');
            deliverydetails.addr3='';
            deliverydetails.postalCode=(String)chequecardmap.get('PostalCode');
            deliverydetails.countrycode='ZA';
            deliverydetails.province=(String)chequecardmap.get('province');
            deliverydetails.countydistrict=(String)chequecardmap.get('suburb');
        }
        }else if((String)chequecardmap.get('Delivery method')=='Standard Bank branch'){
            deliverydetails.deliveryMethod='B';
            deliverydetails.deliveryBranch=(String)chequecardmap.get('PREFERRED BRANCH');
        }else{
             deliverydetails.deliveryBranch=(String)chequecardmap.get('PREFERRED BRANCH');
             deliverydetails.deliveryMethod='B';
        }
        
        String deliverybranchname=(String)chequecardmap.get('PREFERRED BRANCH');
        if(!String.isEmpty(deliverybranchname)){
        AOB_ReferencedData__c referencedata=[Select Id,Name,AOB_Code__c,AOB_SapField__c from AOB_ReferencedData__c where AOB_SapField__c = 'BRANCH' and AOB_Code__c =:deliverybranchname];
        deliverydetails.deliveryBranchName=referencedata.Name;
        }
                }
            }
            setinputcard.deliveryDetail=deliverydetails;
            itemdata1.chequeCardDetails=setinputcard;
            datalist.add(itemdata1);
        }
        
        String ItemBusiness;
        String Businessdata;
        Boolean isBuisnessMarketLinkTaken = false;
        AOB_DTO_SetDigital.Items2 itemdatapocketbiz=new AOB_DTO_SetDigital.Items2();
        AOB_DTO_SetDigital.InputSavings setinputsaving= new AOB_DTO_SetDigital.InputSavings();
        for(AOB_ApplicationLineItem__c aoblineItemSnapscan:appliationlineItem){
            if(aoblineItemSnapscan.AOB_ProductCode__c=='4488' && aoblineItemSnapscan.AOB_Status__c=='Accepted'){
                ItemBusiness=aoblineItemSnapscan.SalesObjectItemId__c;
                Businessdata=aoblineItemSnapscan.Details__c;
                isBuisnessMarketLinkTaken = true;
                
            }
        }
        
        itemdatapocketbiz.itemNo='0'+ItemBusiness;
        setinputsaving.preferredBranch=(String)cdResponsemap.get('PREFERRED BRANCH');
        itemdatapocketbiz.inputSavings=setinputsaving;
        if(isBuisnessMarketLinkTaken){
            datalist.add(itemdatapocketbiz);
        }
        
        
        String ItemPocketBiz;
        String pocketbizdata;
        Boolean isPocketbizTaken = false;
        for(AOB_ApplicationLineItem__c aoblineItemSnapscan:appliationlineItem){
            if(aoblineItemSnapscan.AOB_ProductCode__c=='ZPOB' && aoblineItemSnapscan.AOB_Status__c=='Accepted'){
                ItemPocketBiz=aoblineItemSnapscan.SalesObjectItemId__c;
                pocketbizdata=aoblineItemSnapscan.Details__c;
                isPocketbizTaken = true;
                
            }
        }
        AOB_DTO_SetDigital.Items3 itemdata3=new AOB_DTO_SetDigital.Items3();
        AOB_DTO_SetDigital.InputMerchDevice setinputdevice=new  AOB_DTO_SetDigital.InputMerchDevice();
        AOB_DTO_SetDigital.ProdDetails prodata= new AOB_DTO_SetDigital.ProdDetails();
        if(isPocketbizTaken){
        Map<String,Object> pocketbizdatamap;
        if(!String.isEmpty(pocketbizdata)){
        pocketbizdatamap = (Map<String,object>)JSON.deserializeUntyped(pocketbizdata);
        }
            itemdata3.itemNo='0'+ItemPocketBiz;
            AOB_ReferencedData__c aobdes;
            if(pocketbizdatamap !=null){
                String desmesg=(String)pocketbizdatamap.get('merchantCategory');
                if(!String.isEmpty(desmesg)){
                    aobdes=[Select Id,Name,AOB_Code__c,AOB_SapField__c from AOB_ReferencedData__c where AOB_SapField__c = 'MRCHT_CAT' and AOB_Code__c =:desmesg Limit 1];
                }
            }
            if(!String.isEmpty(pocketbizdata)){
                prodata.businessMobileNbr=(String)cdResponsemap.get('CELLPHONE');
                prodata.registrationEmailAddr=(String)PreApplicationmap.get('EmailAddress');
                if(pocketbizdatamap.get('merchantCategory')!=null){
                    prodata.merchantCategoryCode=(String)pocketbizdatamap.get('merchantCategory');
                }
        prodata.serviceDescription=(String)pocketbizdatamap.get('goodsdescribe');
        prodata.acceptAmExpressNum=(String)pocketbizdatamap.get('americanNumber');
        prodata.acceptDinersNum=(String)pocketbizdatamap.get('dinersNumber');
        prodata.numberOfDevices=Integer.valueOf(pocketbizdatamap.get('numberOfDevices'));
        prodata.accountNbr='';  
        prodata.businessTelephoneNbr=(String)cdResponsemap.get('TELEPHONE  NUMBER (OPTIONAL)');
        prodata.acceptRCSNum=(String)pocketbizdatamap.get('rcsNumber');
        prodata.businessEmailAddr=(String)cdResponsemap.get('EMAIL ADDRESS');
        if(aobdes !=null){
        prodata.merchantCategoryDesc=aobdes.Name;
        }
            }
            setinputdevice.prodDetails=prodata;
            itemdata3.merchantDeviceDetails=setinputdevice;
            datalist.add(itemdata3);
        }
        
        AOB_DTO_SetDigital.Items4 itemdata4=new AOB_DTO_SetDigital.Items4();
        AOB_DTO_SetDigital.InputSnapscan inputscandata= new AOB_DTO_SetDigital.InputSnapscan();
        AOB_DTO_SetDigital.snapscanDetails scandata=new AOB_DTO_SetDigital.snapscanDetails();
        
        String Itemsnapscan;
        String SnapScandata;
        Boolean isSnapScanTaken = false;
        for(AOB_ApplicationLineItem__c aoblineItemSnapscan:appliationlineItem){
            if(aoblineItemSnapscan.AOB_ProductCode__c==AOB_Constants.ZPSS && aoblineItemSnapscan.AOB_Status__c=='Accepted'){
                Itemsnapscan=aoblineItemSnapscan.SalesObjectItemId__c;
                SnapScandata=aoblineItemSnapscan.Details__c;
                isSnapScanTaken =true;
            }
        }
        if(isSnapScanTaken){
        Map<String,Object> snapscanmap;
        if(!String.isEmpty(SnapScandata)){
        snapscanmap= (Map<String,object>)JSON.deserializeUntyped(SnapScandata);
        }
            String snapDesmesg;
            if(snapscanmap!=null){
                snapDesmesg=(String)snapscanmap.get('MERCHANT CATEGORY');
            }
        AOB_ReferencedData__c refrenceData;
        if(!String.isEmpty(snapDesmesg)){
         refrenceData=[Select Id,Name,AOB_Code__c,AOB_SapField__c from AOB_ReferencedData__c where AOB_SapField__c = 'MRCHT_CAT' and AOB_Code__c =:snapDesmesg Limit 1];
        }
        itemdata4.itemNo='0'+Itemsnapscan;
            if(!String.isEmpty(SnapScandata)){
        scandata.businessEmail=(String)cdResponsemap.get('EMAIL ADDRESS');
        if(Boolean.valueOf(snapscanmap.get('receiveInStore')==true)){
             scandata.storeType='M';
        }
        else if(Boolean.valueOf(snapscanmap.get('receiveOnline')==true)){
              scandata.storeType='O';
        }
        if(Boolean.valueOf(snapscanmap.get('receiveInStore')==true && Boolean.valueOf(snapscanmap.get('receiveOnline')==true))){
            scandata.storeType='B';
        }
       
        scandata.businessName=(String)PreApplicationmap.get('businessName');
        scandata.authPartner=(String)preappResponsemap.get('initiatorBPGUID');
        scandata.businessServiceDesc=(String)snapscanmap.get('DESCRIBE YOUR GOODS/SERVICES');
        scandata.authPersonCell=(String)PreApplicationmap.get('PhoneNumber');
        if(refrenceData!=null){
        scandata.merchantCategoryDesc=refrenceData.Name;
        }
                if((String)PreApplicationmap.get('businessType')=='SOLE PROPRIETOR'){
                    scandata.legalEntyDesc='SOLE PROPRIETORSHIP';
                }else{
                scandata.legalEntyDesc=(String)PreApplicationmap.get('businessType');
                }
        scandata.authPersonIdNum=(String)PreApplicationmap.get(AOB_Constants.IDNUM);
        scandata.merchantCategoryCode=(String)snapscanmap.get('MERCHANT CATEGORY');
        scandata.authPersonEmail=(String)PreApplicationmap.get('EmailAddress');
        scandata.authPersonName=(String)PreApplicationmap.get('Name')+' '+(String)PreApplicationmap.get('Surname');
            }
            inputscandata.snapscanDetails=scandata;
            itemdata4.snapScanDetails=inputscandata;
            datalist.add(itemdata4);
        }
        inpulist.items=datalist;
        
        return inpulist;
        
    }
    
}