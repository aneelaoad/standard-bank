/**
 * Builder class for Client_Data_Change__c SObject
 *
 * @author Youssef Ibrahim (yibrahim@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_ClientDataChange extends ABS_ObjectBuilderBase {

    public BLD_ClientDataChange(fflib_SObjectUnitOfWork uow) {
        super(Client_Data_Change__c.SObjectType, uow);
    }

    public BLD_ClientDataChange client(BLD_Account clientBld) {
        return(BLD_ClientDataChange) setRelation(Client_Data_Change__c.Client_Name__c, clientBld);
    }

    public BLD_ClientDataChange currentClientCoordinator(Id userId) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.Current_Client_Coordinator__c, userId);
    }

    public BLD_ClientDataChange currentCcbm(Id userId) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.Current_CCBM__c, userId);
    }

    public BLD_ClientDataChange newClientCoordinatorRole(String role) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.New_Client_Coordinator_Role__c, role);
    }

    public BLD_ClientDataChange currentClientCoordinatorRole(String role) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.Current_Client_Coordinator_Role__c, role);
    }

    public BLD_ClientDataChange currentClientCoordinatorNewRole(String role) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.Current_Client_Coordinator_New_Role__c, role);
    }

    public BLD_ClientDataChange newClientCoordinator(Id userId) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.New_Client_Coordinator__c, userId);
    }

    public BLD_ClientDataChange keepCurrentCC(Boolean isKeepCurrentCC) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.Keep_Current_CC__c, isKeepCurrentCC);
    }

    public BLD_ClientDataChange name(String name) {
        return (BLD_ClientDataChange) setField(Client_Data_Change__c.Name, name);
    }
}