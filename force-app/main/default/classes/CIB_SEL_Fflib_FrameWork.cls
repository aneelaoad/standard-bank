/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_SEL_Fflib_FrameWork
@ Description       : This class provides methods to perform DML operations using the fflib framework.
                      It includes methods to update, insert, and delete records.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP
***************************************************************************************/
public without sharing class CIB_SEL_Fflib_FrameWork { // Note change name to CIB_SRV_Fflib_FrameWork
  /**
   * @description       : This method updates a list of SObjects using the fflib framework.
   * @param sObjectTypes : A list of Schema.SObjectType objects.
   * @param sObjectList  : A list of SObjects to update.
   * @return List<Sobject>            : The updated list of SObjects.
   **/
  public static List<Sobject> updatefflibFrameWorkList(
    List<Schema.SObjectType> sObjectTypes,
    List<Sobject> sObjectList
  ) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(sObjectTypes);
    if (sObjectList.size() > 0) {
      for (Sobject obj : sObjectList) {
        uow.registerDirty(obj);
      }
    }
    uow.commitWork();
    return sObjectList;
  }

  /**
   * @description       : This method updates a single SObject using the fflib framework.
   * @param sObjectTypes : A list of Schema.SObjectType objects.
   * @param sObjectObj  : The SObject to update.
   * @return Sobject           : The updated SObject.
   **/
  public static Sobject updatefflibFrameWork(
    List<Schema.SObjectType> sObjectTypes,
    Sobject sObjectObj
  ) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(sObjectTypes);
    uow.registerDirty(sObjectObj);
    uow.commitWork();
    return sObjectObj;
  }

  /**
   * @description       : This method inserts a list of SObjects using the fflib framework.
   * @param sObjectTypes : A list of Schema.SObjectType objects.
   * @param sObjectList  : A list of SObjects to insert.
   * @return List<Sobject> : The inserted list of SObjects.
   **/
  public static List<Sobject> insertfflibFrameWorkList(
    List<Schema.SObjectType> sObjectTypes,
    List<Sobject> sObjectList
  ) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(sObjectTypes);
    if (sObjectList.size() > 0) {
      for (Sobject obj : sObjectList) {
        uow.registerNew(obj);
      }
    }
    uow.commitWork();
    return sObjectList;
  }

  /**
   * @description       : This method inserts a single SObject using the fflib framework.
   * @param sObjectTypes : A list of Schema.SObjectType objects.
   * @param sObjectObj  : The SObject to insert.
   * @return Sobject : The inserted SObject.
   **/
  public static Sobject insertfflibFrameWork(
    List<Schema.SObjectType> sObjectTypes,
    Sobject sObjectObj
  ) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(sObjectTypes);
    uow.registerNew(sObjectObj);
    uow.commitWork();
    return sObjectObj;
  }

  /**
   * @description       : This method deletes a list of SObjects using the fflib framework.
   * @param sObjectTypes : A list of Schema.SObjectType objects.
   * @param sObjectList  : A list of SObjects to delete.
  
   **/
  public static void deletefflibFrameWorkList(
    List<Schema.SObjectType> sObjectTypes,
    List<Sobject> sObjectList
  ) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(sObjectTypes);
    if (sObjectList.size() > 0) {
      for (Sobject obj : sObjectList) {
        uow.registerDeleted(obj);
      }
    }
    uow.commitWork();
  }

  /**
   * @description       : This method deletes a single SObject using the fflib framework.
   * @param sObjectTypes : A list of Schema.SObjectType objects.
   * @param sObjectObj  : The SObject to delete.
  
   **/
  public static void deletefflibFrameWork(
    List<Schema.SObjectType> sObjectTypes,
    Sobject sObjectObj
  ) {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(sObjectTypes);
    uow.registerDeleted(sObjectObj);
    uow.commitWork();
  }
}