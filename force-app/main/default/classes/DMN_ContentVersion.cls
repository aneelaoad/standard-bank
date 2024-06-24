/**
 * @description DMN_ContentVersion
 */
public with sharing class DMN_ContentVersion {
    /**
     * @description updateDocumentPrivacy
     * @param contentVersions
     */
    public static void updateDocumentPrivacy(List<ContentVersion> contentVersions){
       
        if(!UserInfo.getUserType().equals('Guest')){
            Set<id> ownerIds = new Set<id>();
            
            for(ContentVersion cv: contentVersions){
                ownerIds.add(cv.ownerId);
            }
            List<User> selectedUsers = new SEL_Users().selectByIdWithRoleName(ownerIds);
            Map<Id,User> userMap = new Map<id, User>();
            for(User u : selectedUsers){
                userMap.put(u.Id, u);
            }
            
            if(ownerIds.isEmpty()){return;}
            for(ContentVersion cv: contentVersions){
                user currentOwner = userMap.get(cv.ownerId);
                if(currentOwner.UserRole != null && (currentOwner.UserRole.Name.Contains('Legal'))){
                    cv.SharingPrivacy = 'P';
                }
            }
        }
    }
}