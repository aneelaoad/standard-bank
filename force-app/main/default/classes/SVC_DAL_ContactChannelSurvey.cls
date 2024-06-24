/**
 * @description Data access layer for the SVC_ContactChannelSurvey__c SObject
 * 
 * @author Accenture
 * @date March 2022
 * 
 **/
public inherited sharing class SVC_DAL_ContactChannelSurvey
{
    public static final String OBJECT_NAME = SVC_ContactChannelSurvey__c.SObjectType.getDescribe().getLocalName();

    /**
     * @description Find the corresponding survey response based on the contact channel id
     * 
     * @param contactChannelId
     * @return SVC_ContactChannelSurvey__c
     * 
     **/
    public static SVC_ContactChannelSurvey__c findSurveyResponseByContactChannelId(String contactChannelId)
    {
        List<SVC_ContactChannelSurvey__c> channelSurveys = [SELECT
            	Id,
            	Name,
            	OwnerId, 
                SVC_AchievedPurpose__c,
                SVC_AgentRating__c,
                SVC_NetPromoterScoreRating__c,
                SVC_SurveyComplete__c
            FROM                
				SVC_ContactChannelSurvey__c
            WHERE
              	SVC_ACContactChannel__c = :contactChannelId
        ];
        return channelSurveys.size() > 0 ? channelSurveys[0] : null;
    }
    
}