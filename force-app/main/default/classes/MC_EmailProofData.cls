/**
 * MC email proof data class
 *
 * @author		Michal Pesko (mpesko@deloittece.com)
 * @date		December 2020
 */
public inherited sharing class MC_EmailProofData {
    private Id campaignId;
    private String campaignType;
    private String userEmail;
    private Id userId;

    /**
    * getter for user Email
    *
    * @param campaignId
    * @param campaignType
    * @param userEmail
    * @param userId
    */
    public MC_EmailProofData(Id campaignId, String campaignType, String userEmail, Id userId){
        this.campaignId = campaignId;
        this.campaignType = campaignType;
        this.userEmail = userEmail;
        this.userId = userId;
    }

    /**
    * getter for CampaignId
    *
    * @return Id CampaignId
    */
    public Id getCampaignId(){
        return campaignId;
    }

    /**
    * getter for CampaignType
    *
    * @return String CampaignType
    */
    public String getCampaignType(){
        return campaignType;
    }

    /**
    * getter for user Email
    *
    * @return String userEmail
    */
    public String getUserEmail(){
        return userEmail;
    }

    /**
    * getter for userId
    *
    * @return Id userId
    */
    public Id getUserId(){
        return userId;
    }
}