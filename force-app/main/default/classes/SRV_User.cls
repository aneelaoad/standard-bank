/**
 * Service Class for User sObject
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date Sept 2021
 */
public with sharing class SRV_User implements IService{

      /**
    * @description  : IService Instance
    *
    * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
    * @return IService
    * @date Sept 2021
    */
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }
    
    /**
    * @description  : IService Interface
    *
    * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
    * @date Sept 2021
    */
    public interface IService {
        /**
        * @description  : Enable Community User
        * @param usr
        * @param uow
        * @param permissionSetNames
        * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
        * @date Sept 2021
        */
        void enableAsCommunityUser(User usr, fflib_ISObjectUnitOfWork uow, List<String> permissionSetNames);
    }

    /**
    * @description  : Enable Community User
    * @param usr
    * @param uow
    * @param permissionSetNames
    * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
    * @date Sept 2021
    */
    public void enableAsCommunityUser(User usr, fflib_ISObjectUnitOfWork uow, List<String> permissionSetNames) {
        uow.registerNew(usr);
        uow.commitWork();
        List<PermissionSetAssignment> psaList = new  List<PermissionSetAssignment>();
        if(permissionSetNames.size() > 0){
            List<Permissionset> psets = [Select Id From Permissionset where Name IN: permissionSetNames];
            for(Permissionset pset : psets){
                PermissionSetAssignment psa = new PermissionSetAssignment
                    (PermissionSetId = pset.Id, AssigneeId = usr.Id); 
                psaList.add(psa);
            }
            insert psaList;    
        }
    }    
}