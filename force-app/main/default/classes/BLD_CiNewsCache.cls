/**
 * Builder class for CI_News_Cache__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest
public with sharing class BLD_CiNewsCache extends ABS_ObjectBuilderBase {

    public BLD_CiNewsCache() {
        this(getNewUnitOfWork());
    }

    public BLD_CiNewsCache(fflib_SObjectUnitOfWork uow) {
        super(CI_News_Cache__c.SObjectType, uow);
    }

}