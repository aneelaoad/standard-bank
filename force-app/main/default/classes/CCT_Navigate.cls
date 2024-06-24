public class CCT_Navigate{
    private final Boolean isLightning;
    
    public CCT_Navigate(){
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
    }
    
    public Boolean getIsLightning() {
        return this.isLightning;
    }

    public Boolean getIsClassic() {
        return !this.isLightning;
    }
    
    private Boolean isPageOriginLightning(Map<String, Object> params) {
        if (params.get('sfdcIFrameHost') != null ||
            params.get('sfdcIFrameOrigin') != null ||
            params.get('isdtp') == 'p1') {      
                return true;
            } else {      
                return false;
            }
    }
    
    public String navigateViewURL{
        get{
    
            Map<String,String> paramMap = ApexPages.currentPage().getParameters();

            String newURL = '/apex/';
            
            if(isLightning){
                newURL = newURL + 'SA_AddCustomClient_UserView_lds?';
            }else{
                newURL = newURL + 'SA_AddCustomClient_UserView?';
            }
            
            Integer i=0;
            
            for(String pars: paramMap.keyset()){
                if(i!=0){ newURL += '&';}
                System.debug('+++++'+pars + '=' +  paramMap.get(pars));
                if(pars != 'save_new' && pars != 'sfdc.override'){
                    newURL += pars + '=' +  paramMap.get(pars);
                    
                }
                i++;
            }
            
            return newURL; 
        }        
        set; 
    }
    
}