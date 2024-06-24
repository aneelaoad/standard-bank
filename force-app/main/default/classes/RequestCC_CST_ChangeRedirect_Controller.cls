/**
 * Created by tsobota on 13.08.2018.
 */

public without sharing class RequestCC_CST_ChangeRedirect_Controller {
    public Boolean isLightning {get;set;}

    public RequestCC_CST_ChangeRedirect_Controller() {
        isLightning = (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u');
    }

    public PageReference redirect(){
        PageReference pageReference;
        if(isLightning) {
            String parentId = ApexPages.currentPage().getParameters().get('c__recordId');
            pageReference = new PageReference('/lightning/cmp/c__CR_Container?c__recordId=' + parentId);
            pageReference.setRedirect(true);
        }
        return pageReference;
    }

    public PageReference goBackToClient() {
        PageReference pageReference;
        String parentId = ApexPages.currentPage().getParameters().get('c__recordId');
        pageReference = new PageReference('/'+ parentId);
        pageReference.setRedirect(true);
        return pageReference;
    }
}