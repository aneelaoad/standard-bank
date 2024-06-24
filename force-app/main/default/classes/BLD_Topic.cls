/**
 * Builder class for Topic__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date March 2020
 */
@IsTest
public without sharing class BLD_Topic extends ABS_ObjectBuilderBase {

    public BLD_Topic() {
        this(getNewUnitOfWork());
    }

    public BLD_Topic(fflib_SObjectUnitOfWork workUnit) {
        super(Topic__c.SObjectType, workUnit);
    }

}