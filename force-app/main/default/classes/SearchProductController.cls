/**
 * @description Controller for ProductSeachCmp  [SFP-15261]
 *
 * @author Atul Sharma
 * @date Aug 2022
 */
public with sharing class SearchProductController {
    public static User loginUser;
    private static final String AREA_PRODUCT_SEARCH = 'Product Search';
    private final static Map<String,String[]> divisionMap = new Map<String,String[]>{'Insurance' => new List<String>{'Insurance'}, 
                                                                      'BCC' => new List<String>{'Business and Commercial Banking'}, 
                                                                      'CIB' => new List<String>{'Investment Banking','Transactional Products and Services','Vehicle and Asset Finance','Global Markets', 'Risk Intelligence','Energy & Sustainability'}
                                                               };
	     
    
	/**
     * @description Returns CIB related Products from Product2 object used on search operation on custom lwc component     
     * 	 
	 * @return product2[]
     * */
    @AuraEnabled(cacheable=true)
    public static product2[] getProductList() {
		try {
            product2[] products = new List<product2>();
        	loginUser = SEL_Users.newInstance().selectById(new Set<Id>{Userinfo.getUserId()})[0];
            if(String.isNotBlank(loginUser.User_CIB_Global_Area__c)){
            	products = getProducts();    
            }
            return products;
        }catch (Exception e) {
            SRV_Logger.newInstance().log(e, AREA_PRODUCT_SEARCH, SearchProductController.class.getName());
            return null;
        }
    }
    
    /**    
     * @description Inserts related SB Products from Product2 records
	 * @return product2[]
	 *
     * @param products  Type: Product2[]
	 * @param oppId     Type: String
	 * @param clientId  Type: String
     *
     * */
	@AuraEnabled
    public static string saveSbProductList(Product2[] products, String oppId, String clientId) {  
        try {
            Sb_Product__c[] sbproducts = new List<Sb_Product__c>();
            Map<String,String> mp = getSettings();
            String rtName;
			Sb_Product__c sb;
            for (Product2 p :products) {   				                             
				rtName = mp.get(p.Name+'-'+p.Product_Division__c);
                if (p.Name == null || rtName == null) { continue; }				
				sb = setSbProduct(p, clientId, oppId, rtName);                                
                sbproducts.add(sb);
            }
            insert sbproducts;
            return 'success';
        } catch (Exception e) {            
            return 'error: ' + e.getMessage();
        }
    }    
    
    /**
     * @description: return list of product2 as par login user-division
     * 	 
	 * @return product2[]
     * */
    private static product2[] getProducts(){     
        Product2[] products = new List<product2>();
        List<String> userDivs= getDivisionsToFilter();
        if(userDivs.size()>0){
            products = SEL_Products2.newInstance().selectCIBRelatedProducts2(userDivs);    
        }
        return products;
    }
    
    /**
     * @description: Returns list of user-divisions to be used for Product2 filter
     * 	 
	 * @return product2[]
     * */
    private static String[] getDivisionsToFilter(){        
        List<String> userDivs = new List<String>();
        if(loginUser.User_CIB_Global_Area__c.startsWith('CIB')){
            loginUser.User_CIB_Global_Area__c ='CIB';
        }
        if(divisionMap.containsKey(loginUser.User_CIB_Global_Area__c)){
			userDivs =   divisionMap.get(loginUser.User_CIB_Global_Area__c);       
        }
        return userDivs;
    }  	 	 	
	private static Sb_Product__c setSbProduct(Product2 p, String clientId, String oppId, String rtName) {
		Sb_Product__c sb = new Sb_Product__c();
		
        sb                                  = getSbProduct(p);
        sb.Client__c                        = clientId;
        sb.Opportunity__c                   = oppId;
        sb.RecordTypeId                     = getRecordTypeId(rtName);
        sb.total_revenue_amount__c          = 0; 
        sb.Current_Year_CommB_Revenue__c    = 0;
        sb.Current_Year_Fees__c             = 0;
        sb.Total_Fees__c                    = 0;
        sb.Total_Margin__c                  = 0;
        sb.Term_Tenor__c                    = 1;
        return sb;
	}
	
    private static Id getRecordTypeId(String rtName) {
        Schema.DescribeSObjectResult des = Schema.SObjectType.SB_Product__c;    
        Id rtId = des.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        return rtId;
    }
    private static Sb_Product__c getSbProduct(product2 p2) {
        Sb_Product__c sb = new Sb_Product__c();

        sb.Product2__c              = p2.Id;
        sb.SA_Product__c			= p2.Name;
        sb.Product_Division__c      = p2.Product_Division__c;        
        sb.Grand_Parent_Product__c  = p2.Grand_Parent_Product__c;
        sb.Parent_Product__c        = p2.Parent_Product__c;        
        return sb;
    }

    private static Map<String,String> getSettings() {
        Map<String, String> mp = new Map<String, String>();
        for (ProductSearch__c m : ProductSearch__c.getAll().values()) {
            mp.put(m.Product__c+'-'+m.Product_Division__c, m.Product_Record_Type__c);
        }
        return mp;
    }
}