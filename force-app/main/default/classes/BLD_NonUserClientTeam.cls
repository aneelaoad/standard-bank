/**
 * Builder class for Non_User_Client_Team__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_NonUserClientTeam extends ABS_ObjectBuilderBase {

    public BLD_NonUserClientTeam(fflib_SObjectUnitOfWork uow) {
        super(Non_User_Client_Team__c.SObjectType, uow);
    }

    public BLD_NonUserClientTeam contact(BLD_Contact contact) {
        return (BLD_NonUserClientTeam) setRelation(Non_User_Client_Team__c.Contact_Name__c, contact);
    }

    public BLD_NonUserClientTeam client(BLD_Account client) {
        return (BLD_NonUserClientTeam) setRelation(Non_User_Client_Team__c.Client_Name__c, client);
    }

}