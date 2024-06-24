public without sharing class UTL_Group {
	
	private static Map<String, Id>  groupName2Id{get{
														if(groupName2Id == null){
															collectData();
														}
														return groupName2Id;
													}
												set;
												} 

	private static Map<String, Id>  groupDevName2Id{get{
														if(groupDevName2Id == null){
															collectData();
														}
														return groupDevName2Id;
													}
												set;
												}

    private static Map<Id, String>  groupId2Name{get{
														if(groupId2Name == null){
															collectData();
														}
														return groupId2Name;
													}
												set;
												} 

	private static Map<Id, String>  groupId2DevName{get{
														if(groupId2DevName == null){
															collectData();
														}
														return groupId2DevName;
													}
												set;
												}

    public static String getGroupName(Id groupId){

        if(!groupId2Name.containsKey(groupId)){
            throw new GroupsException('There is no Group with Id:' + groupId);
        }

        return groupId2Name.get(groupId);
    }

    public static String getGroupDevName(Id groupId){

        if(!groupId2DevName.containsKey(groupId)){
            throw new GroupsException('There is no Group with Id:' + groupId);
        }

        return groupId2DevName.get(groupId);
    }

    public static String getGroupId(String groupName){

        if(!groupName2Id.containsKey(groupName)){
            throw new GroupsException('There is no Group with Name:' + groupName);
        }

        return groupName2Id.get(groupName);
    }

    public static String getGroupIdByDevName(String groupDevName){

        if(!groupDevName2Id.containsKey(groupDevName)){
            throw new GroupsException('There is no Group with Developer Name:' + groupDevName);
        }

        return groupDevName2Id.get(groupDevName);
    }


    private static void collectData(){

        groupName2Id 	= new Map<String, Id>();
        groupId2Name 	= new Map<Id, String>();
        groupDevName2Id = new Map<String, Id>();
        groupId2DevName = new Map<Id, String>();

        for(Group grp : [	SELECT Name, DeveloperName 
                       		FROM Group]){
        	if(String.isNotBlank(grp.Name)){
        		groupName2Id.put(grp.Name, grp.Id);
        	}

        	if(String.isNotBlank(grp.DeveloperName)){
        		groupDevName2Id.put(grp.DeveloperName, grp.Id);
        	}
            
            groupId2Name.put(grp.Id, grp.Name);
            groupId2DevName.put(grp.Id, grp.DeveloperName);
        }
    }

    public class GroupsException extends Exception {}

}