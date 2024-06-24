public with sharing class MallAuthSolutionsCtrl {


    /**
     * @description : getMySolutions
     */

    @AuraEnabled(cacheable=true)
    public static List<MySolution> getMySolutions(){
        List<MySolution> mySolutions = new List<MySolution>();
        try {

            String resourcePath1 = '/sfsites/c/resource/sbgIcons/OTHER/icn_u-counticon.svg';
            String resourcePath2 = '/sfsites/c/resource/sbgIcons/OTHER/icn_bankicon.svg';
            String resourcePath3 = '/sfsites/c/resource/sbgIcons/OTHER/icn_exploreicon.svg';


            mySolutions.add(new MySolution('U-Count rewards', 'You are on tier 2', resourcePath1, 'Reward Points', '45,000','https://ucount.standardbank.co.za/business/', false, true));
            mySolutions.add(new MySolution('Bank', 'Cheque Account:  ****6098', resourcePath2, 'Available Balance', 'R 589,678.00','https://digital-sit.standardbank.co.za/sbsa/landing/backbase/ob4b', false, true));
            mySolutions.add(new MySolution('Explore our solutions', 'Discover Standard Bank', resourcePath3, '', '','/mall/s/solutions-catalogue', true, false));
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return mySolutions;
    }


    /**
     * 
     * @description getCustomerAccountList
     * @return  `MallCustomerAccountListResponse`
     */
    @AuraEnabled
    public static MallCustomerAccountListResponse getCustomerAccountList() {
        try {
            MallCustomerAccountListResponse accountListResponse = CTRL_MallDocumentManagement.getCustomerAccountList();
            return accountListResponse;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallAuthSolutionsCtrl.getCustomerAccountList', e);
        }
    }


    /**
     * 
     * @description getCustomerAccountBalances
     * @return ResponseWrapper
     */
    @AuraEnabled
    public static CTRL_MallAccountBalance.ResponseWrapper getCustomerAccountBalances() {
        try {
            CTRL_MallAccountBalance.ResponseWrapper wrapperResponse = CTRL_MallAccountBalance.getCustomerAccountBalances();
            return wrapperResponse;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallAuthSolutionsCtrl.getCustomerAccountBalances', e);
        }
    }


    /**
     * @description : MySolution class
     */
    public class MySolution {
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String subTitle { get; set; }
        @AuraEnabled
        public String iconUrl { get; set; }
        @AuraEnabled
        public String dataTitle { get; set; }
        @AuraEnabled
        public String dataValue { get; set; }
        @AuraEnabled
        public String redirectUrl { get; set; }
        @AuraEnabled
        public Boolean iconCTA { get; set; }
        @AuraEnabled
        public Boolean buttomCTA { get; set; }
    
        public MySolution(String title, String subTitle, String iconUrl, String dataTitle, String dataValue, String redirectUrl, Boolean iconCTA, Boolean bottomCTA) {
            this.title = title;
            this.subTitle = subTitle;
            this.iconUrl = iconUrl;
            this.dataTitle = dataTitle;
            this.dataValue = dataValue;
            this.redirectUrl = redirectUrl;
            this.iconCTA = iconCTA;
            this.buttomCTA = bottomCTA;
        }
    }
    
   

}