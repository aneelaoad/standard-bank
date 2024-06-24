/**
 * Builder class for Key_Client_Contact__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_KeyClientContact extends ABS_ObjectBuilderBase {

    public BLD_KeyClientContact(fflib_SObjectUnitOfWork uow) {
        super(Key_Client_Contact__c.SObjectType, uow);
    }

    public BLD_KeyClientContact client(BLD_Account accountBld) {
        return (BLD_KeyClientContact) setRelation(Key_Client_Contact__c.Client__c, accountBld);
    }

    public BLD_KeyClientContact contact(BLD_Contact contactBld) {
        return (BLD_KeyClientContact) setRelation(Key_Client_Contact__c.Contact_Name__c, contactBld);
    }

}