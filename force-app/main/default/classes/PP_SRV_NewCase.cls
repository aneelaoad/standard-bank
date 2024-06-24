/**
* Service class handling Case creation for Partner Portal
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
public with sharing class PP_SRV_NewCase implements IService {
    
     /**
     * New Instance of Class
     *
     * 
     * @return list of IService
     */
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }
    
     /**
     * IService Interface
     *
     * 
     * @return list of IService
     */
     public interface IService {
        /**
        * Inserts New Cases
        * 
        * @param newCases
        * @param uow
        */
        void saveCases(List<Case> newCases, fflib_ISObjectUnitOfWork uow);
    }
    
     /**
     * Inserts a Case
     *
     * @param newCases with filled fields
     * @param uow - unit of work used to register new cases
     */
    public void saveCases(List<Case> newCases, fflib_ISObjectUnitOfWork uow) {
        for(Case newCase : newCases) {
            uow.registerNew(newCase);
        }
        uow.commitWork();
    }
    
}