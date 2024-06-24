/**
* Controller class for OSB_Maintenance Visualforce page
*
* @author Wayde Fagan (wayde.fagan@tetrad.co.za)
* @date December 2020
*
**/
public class OSB_Maintenance_CTRL {
    public static final String resourceNameImage = 'OSB_ServiceDownImage';
    public static final String resourceNameLogo = 'OSB_ServiceDownLogo';
    
    /**
    * Creates a base64 for the static resource
    *
    * @return String base64 for the resource
    **/
    public String getImageName() {
        List<StaticResource> resourceList = [SELECT Id, Body
                                             FROM StaticResource
                                             WHERE Name = :resourceNameImage];       
        return EncodingUtil.base64Encode(resourceList[0].Body); 
    }
    
    /**
    * Creates a base64 for the static resource
    *
    * @return String base64 for the resource
    **/
    public String getImageLogo() {
        List<StaticResource> resourceList = [SELECT Id, Body
                                             FROM StaticResource
                                             WHERE Name = :resourceNameLogo];
        return EncodingUtil.base64Encode(resourceList[0].Body);
    }
}