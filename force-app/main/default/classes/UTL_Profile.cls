public without sharing class UTL_Profile{
   
    private static Map<String, Id>  profileName2Id; 
    private static Map<Id, String>  profileId2Name;

    public static String getProfileName(Id profileId){
        collectData();

        if(!profileId2Name.containsKey(profileId)){
            throw new ProfilesException('There is no Profile with Id:' + profileId);
        }

        return profileId2Name.get(profileId);
    }

    public static String getProfileId(String profileName){
        collectData();

        if(!profileName2Id.containsKey(profileName)){
            throw new ProfilesException('There is no Profile with Name:' + profileName);
        }

        return profileName2Id.get(profileName);
    }


    private static void collectData(){

        if(profileName2Id != null && profileId2Name != null){
            return;
        }

        profileName2Id = new Map<String, Id>();
        profileId2Name = new Map<Id, String>();

        for(Profile prof : [SELECT Name 
                            FROM Profile]){
            profileName2Id.put(prof.Name, prof.Id);
            profileId2Name.put(prof.Id, prof.Name);
        }
    }

    public class ProfilesException extends Exception {}
}