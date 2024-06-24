/**
 * The class is returning the OneHub community base url
 * <br/>US-3970
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date Mar 2020
 */
public class OSB_RetrieveCommunityUrl {
    @TestVisible
    private static final String KEY_BASE_URL = 'OSB_Base_URL';

    public class CommunityUrlOutput {
        @InvocableVariable(required=true)
        public String sCommunityUrl;        
    }
    
    /**
     * This method returns the Community Url and is being used in OneHub chatbot.
     * <br/>US-3970
     * 
     * @return Community Url and is being used in OneHub chatbot.
     */
    @InvocableMethod(label='Get Community URL')
    public static List<CommunityUrlOutput> getCommunityUrl() {
        List<CommunityUrlOutput> communityUrlOutputList =new List<CommunityUrlOutput>();
        CommunityUrlOutput communityUrlOutput = new CommunityUrlOutput();
        communityUrlOutput.sCommunityUrl = OSB_URLs__c.getAll().get(KEY_BASE_URL).Value__c;
        communityUrlOutputList.add(communityUrlOutput);
        return communityUrlOutputList;
    }
    
}