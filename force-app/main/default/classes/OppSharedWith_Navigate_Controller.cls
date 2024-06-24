public with sharing class OppSharedWith_Navigate_Controller {
    
    public OppSharedWith_Navigate_Controller() {}
    
    public PageReference navigateToPage(){
        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        String uiTheme = ApexPages.currentPage().getParameters().get('uiTheme');  
        PageReference pageRef = new PageReference('/apex/Opportunity_Visibility?Id=' + oppId + '&uiTheme=' + uiTheme);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}