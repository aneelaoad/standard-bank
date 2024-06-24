/**
* Controller class for MarketgramProduct component,
* used to ineract with articles and scoring 
* <br/>
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date January 2021
*/
public with sharing class OSB_MarketgramProduct_CTRL {
    private static final String ALL_USERS = 'All Users';
    /**
     * Updates knowledge article scoring after user's interaction in OSBMarketgramProduct component
     *
     * @param voteId if it is not null, then method updates existing vote, in other case, it's creating new one
     * @param knowledgeId id of Knowledge__ka that is being scored
     * @param operationType LIKE or DISLIKE
     *
     * @return vote's Id
     */
    @AuraEnabled(Cacheable=false)
    public static String updateScoring(Id voteId, Id knowledgeId, String operationType) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        
        String voteType = operationType == 'LIKE' ? '5' : '1';
        Vote userVote = new Vote(Id = voteId, ParentId = knowledgeId, Type = voteType);
        uow.registerUpsert(userVote);
        uow.commitWork();
		
        return userVote.Id;
    }
}