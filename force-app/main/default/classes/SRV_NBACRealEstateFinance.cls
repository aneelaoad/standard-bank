/**
 * @description Service class for NBACRealEstateFinance
 *
 * @author      Stane Murhula (stane.murhula@standardbank.co.za)
 * @date        February 2024
 * 
 * @LastModifiedDate 
 * @author 
 * @UserStory 
 * @LastModifiedReason 
 * 
 */

 public with sharing class SRV_NBACRealEstateFinance implements IService {

    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    public interface IService {
        void saveRefData(List<NBAC_Real_Estate_Finance__c> refPayload, Business_Assessment__c baRec, String baId, fflib_ISObjectUnitOfWork uow);
    }

    /**
     * @description saves and updates ref metric and returns void
     * @param refPayload List<NBAC_Real_Estate_Finance__c>
     * @param baRec Business_Assessment__c
     * @param baId String
     * @param uow fflib_ISObjectUnitOfWork
     * 
     */
    public void saveRefData(List<NBAC_Real_Estate_Finance__c> refPayload, Business_Assessment__c baRec, String baId, fflib_ISObjectUnitOfWork uow) {
        List<NBAC_Real_Estate_Finance__c> refDataU = new List<NBAC_Real_Estate_Finance__c>();
        List<NBAC_Real_Estate_Finance__c> refDataI = new List<NBAC_Real_Estate_Finance__c>();   
        
        for (NBAC_Real_Estate_Finance__c ref : refPayload) {
            if (ref.Id != null) {
                refDataU.add(ref);
            } else {
                ref.Business_Assessment__c = baId;
                refDataI.add(ref);
            }
        }

        if (baRec != null) {
            uow.registerDirty(baRec);
        }

        uow.registerDirty(refDataU);
        uow.registerNew(refDataI);
        uow.commitWork();
    }
}