/*****************************************************************************************************
    @ Func Area     : Client Plan
    @ Author        : Navin Rai
    @ Date          : 09/2013
    @ Test File     : TestClientWalletController.cls
    @ Description   : This controller is used for creating the ClientWalletCP VF componnet which is used in the client wallet section of the client plan.       
******************************************************************************************************/
public with sharing class ClientWalletController {
    public map<string,List<Share_of_Wallet_Product__c>> sowp_map {get;set;}    // map of division with share of wallet products record
     public map<string,Share_Wallet__c> sowp_map_NoProd {get;set;}
    public List<Share_Wallet__c> SOW_list;                                     //List of share of wallet records and related share of wallet products.
    public List<Share_Wallet__c> sow_prods_list {get;set;}
    public List<Share_Wallet__c> sow_list_noprods {get;set;}
    public Client_Plan__c[] cPlan = new Client_Plan__c[1];
    public List<Share_Wallet__c> SOW_master_list = new List<Share_Wallet__c> ();
    public list<String> divisionName {get;set;}
     public list<String> divisionNameWithoutSOWP {get;set;}
    public map<id,Decimal> mapTotalWallet {get;set;}
    public map<id,Decimal> mapTotalBudget {get;set;}
    public map<id,Decimal> mapTotalRevenue {get;set;}
    
    
    /*Variables to sum the client wallet, CIB revenue, budget and percentage of client's Share of Wallet with Standard Bank*/
      
    public Double total_client_wallet {get;set;}
    public Double total_sow_ytd {get;set;}
    public Double total_CIB_Revenue {get;set;}
    public Double total_Budget {get;set;}
    
   
    //Constructor - Custom Comtroller
    public ClientWalletController(){ 
        //Instantiate the collections 
       sowp_map = new map<string,List<Share_of_Wallet_Product__c>>();
       SOW_list = new List<Share_Wallet__c> ();
       sow_prods_list = new List<Share_Wallet__c> ();
       sow_list_noprods = new List<Share_Wallet__c> ();
       
       ClientPlanClass cp = new ClientPlanClass(); 
       cp.snapCurrencyTable(); 
       
       ClientPlanClass.currencyConverter converter = new ClientPlanClass.currencyConverter();
       
       Double tClient_Wallet = 0.0;
       Double tCIB_Rev = 0.0;
       Double tBudget = 0.0;
       Double tClient_Wallet_prod = 0.0;
       Double tCIB_Rev_prod = 0.0;
       Double tBudget_prod = 0.0;
       
       String current_Financial_Year = string.valueof(system.today());
      
       current_Financial_Year = current_Financial_Year.substringBefore('-');
      
       this.cPlan = [Select Id,LastModifiedDate,CurrencyIsoCode, Name,Client_Name__c 
                     from Client_Plan__c 
                     where Client_Name__c =: ApexPages.currentPage().getParameters().get('id')
                     order By LastModifiedDate desc limit 1];
                     
       //Query the sow record as well as it's related products
       sow_list = [SELECT Division__c,Total_Wallet_Size__c, Share_of_Wallet__c, Target_Share__c, Revenue__c, Budget__c, Tech_Number_of_SOW_Products__c,Financial_Year__c,CurrencyIsoCode,
                   (SELECT Product_Subset__c, CurrencyIsoCode,Target_Share__c,Budget__c,Estimated_Total_Wallet_Size__c,Competitors__c,Estimated_Share_of_Wallet__c,
                           Estimated_Standard_Bank_Revenue__c  
                    FROM   Share_of_Wallet_Products__r
                    order by Product_Subset__c)                     
                   FROM   Share_Wallet__c
                   WHERE  client__c = :ApexPages.currentPage().getParameters().get('id')
                   AND    Financial_Year__c = :current_Financial_Year
                   AND    Division__c NOT IN ('Wealth','Business Banking')
                   order by Division__c];
        
        //Collect SOW and SOW product records in respective maps. Key being the SOW division.
        for(Share_Wallet__c s :sow_list){
            
            if(s.Tech_Number_of_SOW_Products__c != 0){
                sow_prods_list.add(s);
                sow_prods_list.sort();
                sowp_map.put(s.Division__c,s.Share_of_Wallet_Products__r);
            }
            else{
                sow_list_noprods.add(s);
                sow_list_noprods.sort();
            }    
        }
        //currency conversion logic for sow records with products
        for(Share_Wallet__c sw :sow_prods_list){
            if(sw.Total_Wallet_Size__c != NULL ){
                tClient_Wallet = converter.convert(Double.valueOf(sw.Total_Wallet_Size__c),String.valueOf(sw.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                sw.Total_Wallet_Size__c = tClient_Wallet; //.divide(1000, 2);
            } 
            
            if(sw.Revenue__c != NULL){
                tCIB_Rev = converter.convert(Double.valueOf(sw.Revenue__c),String.valueOf(sw.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                sw.Revenue__c = tCIB_Rev; //.divide(1000, 2);
            }
            
            if(sw.Budget__c != NULL){
                tBudget = converter.convert(Double.valueOf(sw.Budget__c),String.valueOf(sw.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                sw.Budget__c = tBudget; //.divide(1000, 2);
            }
            
            for(integer i=0; i<=sw.Share_of_Wallet_Products__r.size()-1;i++){
                if(sw.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c != NULL){
                    tClient_Wallet_prod = converter.convert(Double.valueOf(sw.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c),String.valueOf(sw.Share_of_Wallet_Products__r[i].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                    sw.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c = tClient_Wallet_prod ; //.divide(1000, 2);
                }
                    
                if(sw.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c != NULL){
                    tCIB_Rev_prod = converter.convert(Double.valueOf(sw.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c),String.valueOf(sw.Share_of_Wallet_Products__r[i].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                    sw.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c = tCIB_Rev_prod; //.divide(1000, 2);
                }
                
                if(sw.Share_of_Wallet_Products__r[i].Budget__c != NULL){                
                    tBudget_prod = converter.convert(Double.valueOf(sw.Share_of_Wallet_Products__r[i].Budget__c),String.valueOf(sw.Share_of_Wallet_Products__r[i].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                    sw.Share_of_Wallet_Products__r[i].Budget__c = tBudget_prod; //.divide(1000, 2);
                }
                
            }//inner for loop
        }//outer for loop
        
        //currency conversion logic for sow records without products
        for(Share_Wallet__c swp :sow_list_noprods){
            if(swp.Total_Wallet_Size__c != NULL){
                tClient_Wallet = converter.convert(Double.valueOf(swp.Total_Wallet_Size__c),String.valueOf(swp.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                swp.Total_Wallet_Size__c = tClient_Wallet; //.divide(1000, 2);
            }
            
            if(swp.Revenue__c != NULL){
                tCIB_Rev = converter.convert(Double.valueOf(swp.Revenue__c),String.valueOf(swp.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                swp.Revenue__c = tCIB_Rev; //.divide(1000, 2);
            }
            
            if(swp.Budget__c != NULL){
                tBudget = converter.convert(Double.valueOf(swp.Budget__c),String.valueOf(swp.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                swp.Budget__c = tBudget; //.divide(1000, 2);
            }
       }//for loop
        
        //create a SOWP map
        for(Share_Wallet__c s :sow_prods_list){
            sowp_map.put(s.Division__c,s.Share_of_Wallet_Products__r);
            SOW_master_list.add(s);
        }
        
        for(Share_Wallet__c swp :sow_list_noprods){
            SOW_master_list.add(swp);
        }
        
                 
       // Calulate the sums for client wallet, CIB revenue, budget and percentage of total SOW with a particular client
        CalculateTotalSums(SOW_master_list);
            
   }//End of Custom Controller
   
   
   /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public map<String,String> method which stores Division full name as Key and Short name as Value
     * @param :- N/A
     * @return :- String
     **/
     
      public map<String,String> getDivisionMap() {
         
          // Map which stores Division full name as Key and Short name as Value
          map <String,String> mapDivision = new Map < String, String > ();
          
           mapDivision.put('Global Markets' , 'GM ');
           mapDivision.put('Investment Banking' , 'IB ');
           mapDivision.put('Real Estate' , 'RE ');
           mapDivision.put('Transactional Products and Services' , 'TPS ');
         
         return mapDivision;
         
      }
   
   
    //Nitish 
    // For CLient Plan Pdf page
    public ClientWalletController(ApexPages.StandardController controller){ 
        //Instantiate the collections 
       sowp_map = new map<string,List<Share_of_Wallet_Product__c>>();
       sowp_map_NoProd = new map<String,Share_Wallet__c>();
       SOW_list = new List<Share_Wallet__c> ();
       sow_prods_list = new List<Share_Wallet__c> ();
       sow_list_noprods = new List<Share_Wallet__c> ();
       divisionName = new list<String>();
       divisionNameWithoutSOWP = new list<String>();
       mapTotalWallet = new map<Id,Decimal>();
       mapTotalRevenue = new map<Id,Decimal>();
       mapTotalBudget = new map<Id,Decimal>();
       
       ClientPlanClass cp = new ClientPlanClass(); 
       cp.snapCurrencyTable(); 
       
       ClientPlanClass.currencyConverter converter = new ClientPlanClass.currencyConverter();
       
       Decimal tClient_Wallet = 0.0;
       Decimal tCIB_Rev = 0.0;
       Decimal tBudget = 0.0;
       Decimal tClient_Wallet_prod = 0.0;
       Decimal tCIB_Rev_prod = 0.0;
       Decimal tBudget_prod = 0.0;
       
       //NK
       Decimal tWalletSize = 0.0;
       
       String current_Financial_Year = string.valueof(system.today());
      
       current_Financial_Year = current_Financial_Year.substringBefore('-');
      
       this.cPlan = [Select Id,LastModifiedDate,CurrencyIsoCode, Name,Client_Name__c 
                     from Client_Plan__c 
                     where Client_Name__c =: ApexPages.currentPage().getParameters().get('id')
                     order By LastModifiedDate desc limit 1];
                     
       //Query the sow record as well as it's related products
       sow_list = [SELECT Division__c,Total_Wallet_Size__c, Share_of_Wallet__c, Target_Share__c, Revenue__c, Budget__c, Tech_Number_of_SOW_Products__c,Financial_Year__c,CurrencyIsoCode,
                   (SELECT CurrencyIsoCode,Target_Share__c,Budget__c,Product_Subset__c,Estimated_Total_Wallet_Size__c,Estimated_Share_of_Wallet__c,
                           Estimated_Standard_Bank_Revenue__c,Competitors__c ,Share_of_Wallet__r.Division__c,Share_of_Wallet__r.Total_Wallet_Size__c,
                           Share_of_Wallet__r.Share_of_Wallet__c,Share_of_Wallet__r.Target_Share__c,Share_of_Wallet__r.Revenue__c,Share_of_Wallet__r.Budget__c
                    FROM   Share_of_Wallet_Products__r WHERE (Estimated_Standard_Bank_Revenue__c!=null OR
                    											Budget__c!=null OR Estimated_Total_Wallet_Size__c!=null)
                    ORDER BY Product_Subset__c)                     
                   FROM   Share_Wallet__c
                   WHERE  client__c = :ApexPages.currentPage().getParameters().get('id')
                   AND    Financial_Year__c = :current_Financial_Year
                   AND    Division__c NOT IN ('Wealth','Business Banking')
                   ORDER BY Division__c];
        
        //Collect SOW and SOW product records in respective maps. Key being the SOW division.
        for(Share_Wallet__c s :sow_list){
            
            if(s.Tech_Number_of_SOW_Products__c > 0){
                sow_prods_list.add(s);
                sow_prods_list.sort();
                sowp_map.put(s.Division__c,s.Share_of_Wallet_Products__r);
            }
            else{
                sow_list_noprods.add(s);
                sow_list_noprods.sort();
                sowp_map_NoProd.put(s.Division__c,s);
                
            }    
        }
        
        
        //currency conversion logic for sow records with products
        for(Share_Wallet__c sw :sow_prods_list){
            if(sw.Total_Wallet_Size__c != NULL ){
                tClient_Wallet = converter.convert(Double.valueOf(sw.Total_Wallet_Size__c),String.valueOf(sw.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                sw.Total_Wallet_Size__c = tClient_Wallet; //.divide(1000, 2);
                mapTotalWallet.put(sw.Id,tClient_Wallet);
            }
            else{
            System.debug('$$$$$$$$$$' + mapTotalWallet);
             mapTotalWallet.put(sw.Id,0);
            } 
            
            if(sw.Revenue__c != NULL){
                tCIB_Rev = converter.convert(Double.valueOf(sw.Revenue__c),String.valueOf(sw.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                sw.Revenue__c = tCIB_Rev; //.divide(1000, 2);
                mapTotalRevenue.put(sw.Id,tCIB_Rev);
            }
            else{
             mapTotalRevenue.put(sw.Id,0);
            }

            if(sw.Budget__c != NULL){
                tBudget = converter.convert(Double.valueOf(sw.Budget__c),String.valueOf(sw.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                sw.Budget__c = tBudget; //.divide(1000, 2);
                mapTotalBudget.put(sw.Id,tBudget);
            }
            else{
             mapTotalBudget.put(sw.Id,0);
            }
            
            
            for(integer i=0; i<=sw.Share_of_Wallet_Products__r.size()-1;i++){
                if(sw.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c != NULL){
                    tClient_Wallet_prod = converter.convert(Double.valueOf(sw.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c),String.valueOf(sw.Share_of_Wallet_Products__r[i].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                    sw.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c = tClient_Wallet_prod ; //.divide(1000, 2);
                }
                    
                if(sw.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c != NULL){
                    tCIB_Rev_prod = converter.convert(Double.valueOf(sw.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c),String.valueOf(sw.Share_of_Wallet_Products__r[i].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                    sw.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c = tCIB_Rev_prod; //.divide(1000, 2);
                }
                
                if(sw.Share_of_Wallet_Products__r[i].Budget__c != NULL){                
                    tBudget_prod = converter.convert(Double.valueOf(sw.Share_of_Wallet_Products__r[i].Budget__c),String.valueOf(sw.Share_of_Wallet_Products__r[i].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                    sw.Share_of_Wallet_Products__r[i].Budget__c = tBudget_prod; //.divide(1000, 2);
                }
              
               if(sw.Share_of_Wallet_Products__r[i].Share_of_Wallet__r.Total_Wallet_Size__c != NULL){
                  tWalletSize = converter.convert(Double.valueOf(sw.Share_of_Wallet_Products__r[i].Share_of_Wallet__r.Total_Wallet_Size__c),String.valueOf(sw.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                  sw.Share_of_Wallet_Products__r[i].Share_of_Wallet__r.Total_Wallet_Size__c = tWalletSize ;
               }
                
                
            }//inner for loop
        }//outer for loop
        
        //currency conversion logic for sow records without products
        for(Share_Wallet__c swp :sow_list_noprods){
            if(swp.Total_Wallet_Size__c != NULL){
                tClient_Wallet = converter.convert(Double.valueOf(swp.Total_Wallet_Size__c),String.valueOf(swp.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                swp.Total_Wallet_Size__c = tClient_Wallet; //.divide(1000, 2);
            }
            
            if(swp.Revenue__c != NULL){
                tCIB_Rev = converter.convert(Double.valueOf(swp.Revenue__c),String.valueOf(swp.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                swp.Revenue__c = tCIB_Rev; //.divide(1000, 2);
            }
            
            if(swp.Budget__c != NULL){
                tBudget = converter.convert(Double.valueOf(swp.Budget__c),String.valueOf(swp.CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                swp.Budget__c = tBudget; //.divide(1000, 2);
            }
       }//for loop
        
        //create a SOWP map
        for(Share_Wallet__c s :sow_prods_list){
            sowp_map.put(s.Division__c,s.Share_of_Wallet_Products__r);
            SOW_master_list.add(s);
            divisionName.add(s.Division__c);
        }
        
        for(Share_Wallet__c swp :sow_list_noprods){
            SOW_master_list.add(swp);
            sowp_map_NoProd.put(swp.Division__c,swp);
            divisionNameWithoutSOWP.add(swp.Division__c);
        }
        
        divisionName.sort();
        divisionNameWithoutSOWP.sort();
       
                 
       // Calulate the sums for client wallet, CIB revenue, budget and percentage of total SOW with a particular client
        CalculateTotalSums(SOW_master_list);
            
   }//End of Custom Controller
   
   public list<String> getDivisionLst(){
        list<String> divlst = new list<String>();
        
        divlst.add('Global Markets');
        divlst.add('Real Estate');
        divlst.add('Transactional Products and Services');
        divlst.add('Investment Banking');
        
        divlst.sort();
        
        return divlst ;
        
   }
   
   public Map<String,Boolean> getRenderMapSOW(){
        
        Map<String,Boolean> mapSowp = new Map<String,Boolean>();
        
        list<String> templst = getDivisionLst();
        
    for(String str : templst){
        
        if(sowp_map_NoProd.containsKey(str)){
                mapSowp.put(str,true);
        }
        else{
                mapSowp.put(str,false);
         }
        }
     
     return mapSowp ;
        
   }
   
   public Map<String,Boolean> getRenderMapSOWP(){
        
        Map<String,Boolean> mapSowp = new Map<String,Boolean>();
        
    list<String> templst = getDivisionLst();
        
        for(String str : templst){
        
        if(sowp_map.containsKey(str)){
                mapSowp.put(str,true);
        }
        else{
                mapSowp.put(str,false);
         }
        }
        
        return mapSowp ;
        
   }
   
   
   //Calulate the sums for client wallet, CIB revenue, budget and percentage of total SOW of SB with a particular client. 
   public void CalculateTotalSums(List<Share_Wallet__c> sums_list){
       total_sow_ytd       = 0;
       total_client_wallet = 0;
       total_CIB_Revenue   = 0;
       total_Budget        = 0;
       
       Double clientWallet;
       Double CIBRevenue;
       Double Budget;
       
       for(Share_Wallet__c s :sums_list){
         /*if(s.Tech_Number_of_SOW_Products__c > 0){
             for(integer i=0; i<=s.Share_of_Wallet_Products__r.size()-1;i++){
                  if(s.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c != NULL || s.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c != NULL
                     || s.Share_of_Wallet_Products__r[i].Budget__c != NULL){
                     
                      clientWallet = s.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c ;
                      CIBRevenue = s.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c ;
                      Budget = s.Share_of_Wallet_Products__r[i].Budget__c;
                      
                      if(s.Share_of_Wallet_Products__r[i].Estimated_Total_Wallet_Size__c == NULL){
                          clientWallet  = 0;   
                      }
                      if(s.Share_of_Wallet_Products__r[i].Estimated_Standard_Bank_Revenue__c == NULL){
                          CIBRevenue  = 0;   
                      }
                      if(s.Share_of_Wallet_Products__r[i].Budget__c == NULL){
                          Budget = 0;   
                      }
                      
                     //add each value per share of wallet product. 
                     total_client_wallet = total_client_wallet + (Integer)(Decimal)clientWallet;      
                     total_CIB_Revenue   = total_CIB_Revenue + (Integer)(Decimal)CIBRevenue;
                     total_Budget = total_Budget + (Integer)(Decimal)Budget;
                      
                  }//outer if block
              }//inner for loop
          }//outermost if block 
          else{ */
              if(s.Total_Wallet_Size__c != NULL || s.Revenue__c != NULL || s.Budget__c != NULL){
                     
                      clientWallet = s.Total_Wallet_Size__c ;
                      CIBRevenue = s.Revenue__c ;
                      Budget = s.Budget__c;
                      
                      if(s.Total_Wallet_Size__c == NULL){
                          clientWallet  = 0;   
                      }
                      if(s.Revenue__c == NULL){
                          CIBRevenue  = 0;   
                      }
                      if(s.Budget__c == NULL){
                          Budget = 0;   
                      }
                      
                     //add each value per share of wallet product. 
                     total_client_wallet = total_client_wallet + clientWallet;      
                     total_CIB_Revenue   = total_CIB_Revenue + CIBRevenue;
                     total_Budget = total_Budget + Budget;
              }//end of outer if
          //}//else block 
      }//outer for loop
      
          
      
      //calculate % of SOW of SB with a particular client.
      if (total_client_wallet == 0){
           total_sow_ytd = 0;
      }
      else{         
          total_sow_ytd  = (total_CIB_Revenue*100)/total_client_wallet; 
      }  
    }//End of CalculateTotalSums
   
}//End of ClientWalletController class