public with sharing class CTRL_MallAuthSolutions {
    /**
     * @description : getMySolutions
     */

     @AuraEnabled(cacheable=true)
     public static List<MySolution> getMySolutions(){
         List<MySolution> mySolutions = new List<MySolution>();
         
         try {
 
             CTRL_MallAccountBalance.ResponseWrapper accountBalanceResponse  = CTRL_MallAccountBalance.getCustomerAccountBalances();
             
             String accountNumber = (accountBalanceResponse != null && accountBalanceResponse.accountBalanceInfo != null) ? accountBalanceResponse.accountBalanceInfo.getFormatedAccountNumber() : '';
             String accountBalance = (accountBalanceResponse.accountBalanceInfo != null && accountBalanceResponse.accountBalanceInfo.response != null) ? accountBalanceResponse.accountBalanceInfo.response.getFormatedBalance() : '';
             
             String resourcePath1 = '/sfsites/c/resource/sbgIcons/OTHER/icn_u-counticon.svg';
             String resourcePath2 = '/sfsites/c/resource/sbgIcons/OTHER/icn_bankicon.svg';
             String resourcePath3 = '/sfsites/c/resource/sbgIcons/OTHER/icn_exploreicon.svg';
 
 
             mySolutions.add(new MySolution('U-Count rewards', 'You are on tier', resourcePath1, 'Reward Points', '45,000','https://ucount.standardbank.co.za/business/','Get Details', false, true));
             mySolutions.add(new MySolution('Bank',accountNumber, resourcePath2, 'Available Balance', accountBalance,'https://digital-sit.standardbank.co.za/sbsa/landing/backbase/ob4b','Transact', false, true));
             mySolutions.add(new MySolution('Explore our solutions', 'Discover Standard Bank', resourcePath3, '', '','/mall/s/our-solutions','', true, false));
             
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
         return mySolutions;
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
         public String btnLabel { get; set; }
         @AuraEnabled
         public Boolean iconCTA { get; set; }
         @AuraEnabled
         public Boolean buttomCTA { get; set; }
     
         public MySolution(String title, String subTitle, String iconUrl, String dataTitle, String dataValue, String redirectUrl, String btnLabel, Boolean iconCTA, Boolean bottomCTA) {
             this.title = title;
             this.subTitle = subTitle;
             this.iconUrl = iconUrl;
             this.dataTitle = dataTitle;
             this.dataValue = dataValue;
             this.redirectUrl = redirectUrl;
             this.btnLabel = btnLabel;
             this.iconCTA = iconCTA;
             this.buttomCTA = bottomCTA;
         }
     }
}