/**
 * Service class around Entitlement SObject
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		March 2020
 */
public inherited sharing class SRV_Entitlement implements IService {

    private static Entitlement defaultEntitlement;

    /**
    * @description  : IService Instance
    *
    * @return IService
    * @date March 2020
    */
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
    * @description  : IService Interface
    *
    * @date March 2020
    */
    public interface IService {
        /**
        * @description  : Gets Default Entitlement
        * 
        * @date March 2020
        * @return Entitlement
        */
        Entitlement getDefaultEntitlement();
    }
    
    /**
     * Query Default Entitlement
     *
     * @date March 2020
     * @return Entitlement
     **/
    public Entitlement getDefaultEntitlement() {
        if (defaultEntitlement == null) {
            defaultEntitlement = SEL_Entitlement.newInstance().selectByNameWithoutSharing(DMN_Entitlement.DEFAULT_ENTITLEMENT_NAME)[0]; 
        }
        return defaultEntitlement;
    }
}