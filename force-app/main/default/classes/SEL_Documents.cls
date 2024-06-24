/**
 * Selector class for Documents
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 */
public with sharing class SEL_Documents extends fflib_SObjectSelector {

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_Documents newInstance() {
        return (SEL_Documents) ORG_Application.selector.newInstance(Document.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     */
    public SObjectType getSObjectType() {
        return Document.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Document.Id,
                Document.DeveloperName
        };
    }

    /**
     * Select Documents by Developer Names
     * @param developerNames - - set of searched DeveloperNames
     * @return list of documents
     */
    public List<Document> selectByDeveloperName(Set<String> developerNames) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition('DeveloperName IN :developerNames')
                .toSOQL()
        );
    }
}