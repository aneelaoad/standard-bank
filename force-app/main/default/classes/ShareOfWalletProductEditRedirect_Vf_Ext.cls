/*****************************************************************************************************\
    @ Func Area     : Share Of Wallet Product
    @ Author        : Nitish Kumar
    @ Date          : 24/10/2013
    @ Test File     : Test Method: 
    @ Description   :  This controller class is used by the VF page "ShareOfWalletProductEditRedirect_Vf".
                      The controller ensures that whenever a user edits an Share of Wallet Product that he
                      return URL is back to the ShareOfWalletProduct Vf page. 
                      This will ensure Stage and product addition evaluation   
    -------------------------------------------------------------------------------------
**/

public class ShareOfWalletProductEditRedirect_Vf_Ext {
    
     private Id sowProdId;
     public Id soWId;
    
     public ShareOfWalletProductEditRedirect_Vf_Ext (ApexPages.StandardController controller) {
        
        //get the sow Product  Id
        sowProdId = controller.getId();
       
        list < Share_of_Wallet_Product__c > sowProdList = [select Id, Share_of_Wallet__r.Id from Share_of_Wallet_Product__c where Id =: sowProdId limit 1 ];
        
        if (!sowProdList.isEmpty())
        soWId = sowProdList[0].Share_of_Wallet__r.Id ;
       
     }
     
     //This method is used in the action property of the VF page "ShareOfWalletProductEdit" and runs
    //on page load. It navigate the user to the ShareOfWalletProduct page 
    public PageReference redirect(){
         
        System.Debug('## >>> Starting redirect <<<');
        
        PageReference pageRef = new PageReference('/apex/ShareOfWalletProducts?id=' + soWId );
        
        System.Debug('## >>> Ending redirect <<<');
        return pageRef;
    }
     

}