/**
 * Builder class for Client_Operating_Countries__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_ClientOperatingCountries extends ABS_ObjectBuilderBase {

    private static final String DEF_COUNTRY = 'South Africa';

    public BLD_ClientOperatingCountries(fflib_SObjectUnitOfWork uow) {
        super(Client_Operating_Countries__c.SObjectType, uow);
    }

    protected override void setDefaultData() {
        setField(Client_Operating_Countries__c.Country__c, DEF_COUNTRY);
    }

    public BLD_ClientOperatingCountries cibPresence(Boolean cibPresence) {
        return (BLD_ClientOperatingCountries) setField(Client_Operating_Countries__c.CIB_Presence__c, cibPresence);
    }

    public BLD_ClientOperatingCountries client(BLD_Account accBld) {
        return (BLD_ClientOperatingCountries) setRelation(Client_Operating_Countries__c.Client_Name__c, accBld);
    }

    public BLD_ClientOperatingCountries country(String country) {
        return (BLD_ClientOperatingCountries) setField(Client_Operating_Countries__c.Country__c, country);
    }

    public BLD_ClientOperatingCountries status(String status) {
        return (BLD_ClientOperatingCountries) setField(Client_Operating_Countries__c.Status__c, status);
    }

}