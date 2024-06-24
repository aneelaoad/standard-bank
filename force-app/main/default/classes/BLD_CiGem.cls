/**
 * Builder class for CI_Gem__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest
public without sharing class BLD_CiGem extends ABS_ObjectBuilderBase {

    public BLD_CiGem() {
        this(getNewUnitOfWork());
    }

    public BLD_CiGem(fflib_SObjectUnitOfWork uow) {
        super(CI_Gem__c.SObjectType, uow);
    }

    public BLD_CiGem deleted(Boolean isDeleted) {
        return (BLD_CiGem) setField(CI_Gem__c.Deleted__c, isDeleted);
    }

}