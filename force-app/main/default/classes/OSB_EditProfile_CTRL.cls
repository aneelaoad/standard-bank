/**
 * Controller class for OSBEditProfile component
 * <br/>
 *
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date June 2020
 *
 **/
public with sharing class OSB_EditProfile_CTRL {
    @TestVisible
    private static final String KEY_USER_DETAIL_MAP = 'userDetailMap';
    @TestVisible
    private static final String KEY_PROFILE_PIC_INFO = 'ProfilePicInfo';
    @TestVisible
    private static final String KEY_PROFILE_PIC = 'ProfilePic';
    
    /**
     * Checks if the current user is login to community
     *
     * @return Boolean
     **/
    @AuraEnabled(Cacheable=true)
    public static Boolean isUserLoggedIn() {
        return UTL_User.isLoggedInUser();
    }
    
    
    /**
     * Returns a map of the current user details. Used for the auto populate the form
     *
     * @return Map<String,Map<String, String>>
     **/
    @AuraEnabled
    public static Map<String,Map<String, String>> getUserDetails()
    {
        Map<String,Map<String, String>> userInformationMap = new Map<String,Map<String, String>>();
        try{
            userInformationMap.put(KEY_USER_DETAIL_MAP,OSB_SRV_PingIntegration.newInstance().getUserDetails());
            userInformationMap.put(KEY_PROFILE_PIC_INFO,new Map<String,String>{KEY_PROFILE_PIC => getUserProfilePicURL()});
        }
        catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_EditProfile_CTRL.class.getName());
        }
        return userInformationMap;
    }

    /**
     * Gets the user's profile picture
     *
     * @return String FullPhotoUrl
     **/
    private static String getUserProfilePicURL() {
        return SEL_Users.newInstance().selectById(new Set<Id>{UserInfo.getUserId()})[0].FullPhotoUrl;
    }

    /**
     * Returns a list for the industry picklist on the community
     *
     * @return List<string> options
     **/
    @AuraEnabled(Cacheable=true)
    public static List<String> getIndustryPicklistValues() {
        List<String> options = new List<String>();
        for( Schema.PicklistEntry f : UTL_Picklist.getPicklistValues(Contact.Company_Industry__c)) {
            options.add(f.getValue());
        }
        return options;
    }
    
    /**
     * Retrives the list of phone country codes from Contact
     *
     * @return List<string>
     **/
    @AuraEnabled(Cacheable=true)      
    public static List<string> getCountryCodes()
    {
        List<String> options = new List<String>();
        List<Schema.PicklistEntry> ple = UTL_Picklist.getPicklistValues(Contact.Phone_Country__c);
        for( Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }
        return options;
    }

    /**
     * Updates the ping directory with any changes from the edit profile.
     * Doesn't include the passport or ID number
     * 
     * @param userMap with user details
     *
     **/
    @AuraEnabled(Cacheable=false)
    public static void updateUserProfile(Map <String,String> userMap){
        try{
        	OSB_SRV_PingIntegration.newInstance().updateUserProfile(userMap);
        }
        catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_EditProfile_CTRL.class.getName());
        }
    }

    /**
     * Updates user profile picture
     * Doesn't include the passport or ID number
     * 
     * @param userProfilePicString profile picture
     * @param userId id of the user
     *
     **/
    @AuraEnabled(Cacheable=false)
    public static void updateUserProfilePic(String userProfilePicString, Id userId){
        Blob blobImage = EncodingUtil.base64Decode(userProfilePicString);
        ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(blobImage, 'image/jpg', 'userImage.jpg');
        ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto(null, userId,  fileUpload);
    }
}