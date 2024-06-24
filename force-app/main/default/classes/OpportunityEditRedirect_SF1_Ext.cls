/*****************************************************************************************************\
    @ Func Area     : Opportunity
    @ Author        : Vaishali Singh
    @ Date          : 13/01/2015
    @ Description   : EN-0443
                      This controller class is used by the VF page "OpportunityEditRedicrect_Vf".
                      The controller ensures that whenever a user edits an opportunity that he
                      return URL is back to the Opportunity's view page. 
                      This will ensure Stage and product addition evaluation   
    -------------------------------------------------------------------------------------
**/
public class OpportunityEditRedirect_SF1_Ext {

    private Id oppId;
    public String editUrl{get;set;}

    public OpportunityEditRedirect_SF1_Ext (ApexPages.StandardController controller) {
        System.Debug('## >>> OpportunityEditRedirect_Vf_Ext <<< run by ' + UserInfo.getName());
        System.Debug('## >>> Starting the constructor <<<');
        editUrl='';
        //get the opportunity Id
        oppId = controller.getId();
        editUrl = '/' + oppId + '/e?retURL=/' + oppId + '&nooverride=1';   
        System.Debug('## >>> Opportunity Id = ' + oppId + ' <<<');
        System.Debug('@@ @@'+editUrl);  
        
    }
   
   
 }