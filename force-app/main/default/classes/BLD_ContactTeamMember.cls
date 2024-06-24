/**
 * Builder class for SA_Contact_Team_Member__c SObject
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		March 2020
 */
@IsTest
public without sharing class BLD_ContactTeamMember extends ABS_ObjectBuilderBase {

    public BLD_ContactTeamMember() {
        this(getNewUnitOfWork());
    }

    public BLD_ContactTeamMember(fflib_SObjectUnitOfWork uow) {
        super(SA_Contact_Team_Member__c.SObjectType, uow);
    }

    public BLD_ContactTeamMember contact(Id contactId) {
        return (BLD_ContactTeamMember) setField(SA_Contact_Team_Member__c.SA_Contact__c, contactId);
    }

    public BLD_ContactTeamMember contact(BLD_Contact contactBld) {
        return (BLD_ContactTeamMember) setRelation(SA_Contact_Team_Member__c.SA_Contact__c, contactBld);
    }

    public BLD_ContactTeamMember primaryContactPerson(Boolean isPrimaryContactPerson) {
        return (BLD_ContactTeamMember) setField(SA_Contact_Team_Member__c.Primary_Contact_Person__c, isPrimaryContactPerson);
    }

    public BLD_ContactTeamMember user(Id userId) {
        return (BLD_ContactTeamMember) setField(SA_Contact_Team_Member__c.SA_User__c, userId);
    }

}