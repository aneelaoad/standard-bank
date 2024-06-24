/**
 * Selector class for PP_PartnerApplication__c SObject
 * User Story : SFP-4874
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
@SuppressWarnings('PMD')
public inherited sharing class SEL_PartnerApplication extends fflib_SObjectSelector {
    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_PartnerApplication class instance
     */
    public static SEL_PartnerApplication newInstance() {
        return (SEL_PartnerApplication) ORG_Application.selector.newInstance(PP_PartnerApplication__c.SObjectType);
    }

    /**
     * Returns the SObject fields on this sObject
     * @return PP_PartnerApplication__c fields list
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PP_PartnerApplication__c.Id,
            PP_PartnerApplication__c.PP_Account__c,
            PP_PartnerApplication__c.PP_AnnualBusinessTurnover__c,
            PP_PartnerApplication__c.PP_ApplicationStatus__c,
            PP_PartnerApplication__c.PP_AravoDirectLink__c,
            PP_PartnerApplication__c.PP_Capabilities__c,
            PP_PartnerApplication__c.PP_ClientOnDifferentOrg__c,
            PP_PartnerApplication__c.CreatedById,
            PP_PartnerApplication__c.PP_Currency__c,
            PP_PartnerApplication__c.CurrencyIsoCode,
            PP_PartnerApplication__c.PP_DeclinedReason__c,
            PP_PartnerApplication__c.PP_EmailAddress__c,
            PP_PartnerApplication__c.PP_FirstName__c,
            PP_PartnerApplication__c.PP_Identification_Number__c,
            PP_PartnerApplication__c.PP_Industry__c,
            PP_PartnerApplication__c.LastModifiedById,
            PP_PartnerApplication__c.PP_LastName__c,
            PP_PartnerApplication__c.PP_LinkedInProfile__c,
            PP_PartnerApplication__c.PP_Mobile_Number__c,
            PP_PartnerApplication__c.Name,
            PP_PartnerApplication__c.PP_OperatingCountry__c,
            PP_PartnerApplication__c.OwnerId,
            PP_PartnerApplication__c.PP_PartnerID__c,
            PP_PartnerApplication__c.PP_Partnership_Goal__c,
            PP_PartnerApplication__c.PP_PartnershipGoal__c,
            PP_PartnerApplication__c.PP_PartnershipGoalOther__c,
            PP_PartnerApplication__c.PP_PrimaryContact__c,
            PP_PartnerApplication__c.PP_Purge__c,
            PP_PartnerApplication__c.PP_RegistrationNumber__c,
            PP_PartnerApplication__c.PP_SolutionDetails__c,
            PP_PartnerApplication__c.PP_TermsConditionsAccepted__c,
            PP_PartnerApplication__c.PP_Website__c
        };
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * @return PP_PartnerApplication__c object type
     */
    public Schema.SObjectType getSObjectType() {
        return PP_PartnerApplication__c.SObjectType;
    }

    /**
     * Select PP_PartnerApplication__c filtered by Primary Contact ID
     * @param idSet set of Ids of Contact
     *
     * @return list of PP_PartnerApplication__c
     */
    public List<PP_PartnerApplication__c> selectByPrimaryContactId(Set<Id> idSet) {
        return (List<PP_PartnerApplication__c>) Database.query(
            newQueryFactory()
                .selectField('PP_Website__c')
                .selectField('PP_LinkedInProfile__c')
                .selectField('PP_Capabilities__c')
                .setCondition('PP_PrimaryContact__c IN: idSet').toSOQL()
        );
    }

    /**
     * Select PP_PartnerApplication__c filtered by IDs
     * @param idSet set of Ids of PP_PartnerApplication__c
     *
     * @return list of PP_PartnerApplication__c
     */

    public List<PP_PartnerApplication__c> selectById(Set<Id> idSet) {
        return (List<PP_PartnerApplication__c>) Database.query(
            newQueryFactory()
                .selectField('PP_EmailAddress__c')
                .selectField('PP_PrimaryContact__c')
                .selectField('PP_ApplicationStatus__c')
                .setCondition('Id IN: idSet').toSOQL()
        );
    }
    /**
     * Select PP_PartnerApplication__c filtered by IDs
     * @param idSet set of Ids of Contact
     *
     * @return list of PP_PartnerApplication__c
     */

    public List<PP_PartnerApplication__c> selectByEmailPrimaryContactId(Set<String> emails,  String inProgress, String approved) {
        return (List<PP_PartnerApplication__c>) Database.query(
                newQueryFactory()
                    .selectField('PP_PrimaryContact__c')
                    .setCondition('PP_ApplicationStatus__c =: inProgress OR PP_ApplicationStatus__c =: approved')
                    .setCondition('PP_PrimaryContact__r.Email IN: emails')
                    .toSOQL()
        );
    }
}