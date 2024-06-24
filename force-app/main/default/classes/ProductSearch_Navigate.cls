/**************************************************************************************
	@Last Modified By   : Dzianisik Maksim
	@Last Modified on   : May 2022
	@description        : SFP-12697 Added ability to use redirect logic in console apps
**************************************************************************************/
public class ProductSearch_Navigate {
    static final Set<String> lightningThemes = new Set<String> {
        'Theme4d', 
        'Theme4t',
        'Theme4u'
    };
    
    public PageReference redirect() {
        Map<String,String> paramMap = ApexPages.currentPage().getParameters();

        String newURL = '/apex/';
        
        String theme = UserInfo.getUiThemeDisplayed();
        if (lightningThemes.contains(theme)) {
            newURL = newURL + 'ProductSearchPageSLDS?';
        } 
        else {
            newURL = newURL + 'ProductSearchPage?';
        }
        
        Integer i = 0;
        system.debug('>>>paramMap>>>' + paramMap);
        for (String pars: paramMap.keyset()) {
            if (i != 0) { newURL += '&';}
            System.debug('+++++' + pars + '=' + paramMap.get(pars));
            if (pars != 'save_new' && pars != 'sfdc.override') {
                newURL += pars + '=' +  paramMap.get(pars);
            }
            i++;
        }
        system.debug('>>>newURL>>>' + newURL);
        return new PageReference(newURL);
    }
}