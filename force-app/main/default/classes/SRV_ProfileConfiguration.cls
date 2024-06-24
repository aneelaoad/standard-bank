/**
 * Created by mjaznicki on 11.07.2018.
 */
public without sharing class SRV_ProfileConfiguration {

    private static Map<String, Profile_Configuration__mdt> profileName2Configuration {
        get {
            if (profileName2Configuration == null) {
                profileName2Configuration = new Map<String, Profile_Configuration__mdt>();
                collectData();
            }
            return profileName2Configuration;
        }
        set;
    }

    private static Map<String, Set<String>> profileName2AccessibleComponents {
        get {
            if (profileName2AccessibleComponents == null) {
                profileName2AccessibleComponents = new Map<String, Set<String>>();
                collectData();
            }
            return profileName2AccessibleComponents;
        }
        set;
    }

    public static Boolean checkIfCurrentUserHasAccess(String componentName) {
        String profileName = UTL_Profile.getProfileName(UserInfo.getProfileId());
        Set<String> accessibleComponents = new Set<String>();
        accessibleComponents  = profileName2AccessibleComponents.get(profileName);
        if (accessibleComponents != null) {
           if(accessibleComponents.contains(componentName)){
               return true;
           }
        }
        return false;
    }

    private static void collectData() {
        List<Profile_Configuration__mdt> profileConfiguration = [
                SELECT Profile_Name__c, Accessible_Components__c
                FROM Profile_Configuration__mdt
        ];

        for(Profile_Configuration__mdt pc: profileConfiguration) {
            profileName2Configuration.put(pc.Profile_Name__c, pc);
            Set<String> components = new Set<String>();
            for(String component: pc.Accessible_Components__c.split(',')) {
                components.add(component);
            }
            profileName2AccessibleComponents.put(pc.Profile_Name__c, components);
        }
    }
}