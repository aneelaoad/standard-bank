/**
 * Selector class for Knowledge__ka SObject
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 */
public inherited sharing class SEL_KnowledgeArticles extends fflib_SObjectSelector {

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_KnowledgeArticles newInstance() {
        return (SEL_KnowledgeArticles) ORG_Application.selector
                .include(new Map<SObjectType, Type>{Knowledge__ka.SObjectType => SEL_KnowledgeArticles.class})
                .newInstance(Knowledge__ka.SObjectType);
    }

    public SObjectType getSObjectType() {
        return Knowledge__ka.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Knowledge__ka.Id
        };
    }

    /**
     * Select Knowledge__ka with Votes and Feeds child records, filtered by Knowledge__kav record type
     * @param recordTypesIds set of ids of Knowledge__kav RecordTypeId
     * @param publicationStatus set of String of Knowledge__kav publish status
     * @param exceptionArticleIds set of ids of knowledge exceptions
     * @param persona String of contact persona
     * @param operatingCountries String of contact countries
     *
     * @return list of Knowledge__ka with related child records
     */
    public List<Knowledge__ka> selectWithVotesAndFeedsByVersionRecordTypePersona(Set<Id> recordTypesIds, Set<String> publicationStatus, Set<Id> exceptionArticleIds, String persona,String operatingCountries) {
        
        String knowledgeQuery = 'RecordTypeId IN :recordTypesIds ' +
                'AND PublishStatus IN :publicationStatus ' +
                'AND ((OSB_Persona__c INCLUDES (:persona) ' +
                'AND OSB_Country__c INCLUDES (';

        for (String country : operatingCountries.split(';')) {
            knowledgeQuery += '\'' + country + '\',';
        }
        knowledgeQuery = knowledgeQuery.removeEnd(',') + '))';
        knowledgeQuery += ' OR Id IN :exceptionArticleIds)';
        
        fflib_QueryFactory articleQuery = newQueryFactory(false, false, true)
                .setCondition('Id IN (SELECT KnowledgeArticleId FROM Knowledge__kav WHERE '+knowledgeQuery+')');
        fflib_QueryFactory feedsQuery = articleQuery.subselectQuery('Feeds')
                .selectField('Id')
                .selectField('CreatedById');
        fflib_QueryFactory votesQuery = articleQuery.subselectQuery('Votes')
                .selectField('Type')
                .selectField('CreatedById');
        String query = articleQuery.toSOQL();
        return Database.query(query);
    }


}