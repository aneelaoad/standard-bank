/*************************************************************************\
    @ Func Area     :     Event Report / Attendees
    @ Author        :     Caro Reinecke
    @ Date          :     24 Jan 2012
    @ Test File     :     EventReportAttendee_test
    @ Description   :     Utility Class that provides Javascript Remoting capabilities to be used to 
                          check user permissions:
                          1) hasModifyAllProfilePermission performs a check for modify all data admin permission 
                             based on the current users profile.
                          2) hasModifyObjectPermission performs a check to see if the current user has modify permission
                             to a specific object.
                          3) hasModifyRecordPermission performs a check to see if the named user has modify access to the named record
                          The hasModifyAllProfilePermission method is used in the VF page CallRep_Att_ChgStatus;
                          
                          
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Last Modified Reason  : 
                                 
****************************************************************************/
global with sharing class CheckPermissions_glbl{

    public CheckPermissions_glbl(ApexPages.StandardSetController controller) {}
  
    public CheckPermissions_glbl(){}
    
    @remoteAction
    global static boolean hasModifyAllProfilePermission(){
        return [Select PermissionsModifyAllData From Profile Where Id=:UserInfo.getProfileId()].PermissionsModifyAllData; 
    }

    @remoteAction
    global static boolean hasModifyObjectPermission(String objectName){
        String queryString = 'SELECT Id FROM '+ objectName +' LIMIT 1';
        Schema.sObjectType soType = Database.query(queryString)[0].getSObjectType();
        Schema.DescribeSObjectResult R = soType.getDescribe();
        return (R.isUpdateable());
    }

    @RemoteAction
    global static boolean hasModifyRecordPermission(String recordId, String userId){
        String objectName = CheckPermissions_glbl.getObjectName(recordId);
        if (objectName == 'Error'){
            return false;
        } else {
        String shareObject = objectName.subString(0,objectName.length()-1) + 'Share';
        String queryString = 'SELECT count() FROM '+shareObject+' WHERE ParentId = \''+recordId+'\' And UserOrGroupId = \''+userId+'\' And (AccessLevel = \'All\' Or AccessLevel = \'Edit\')';
        integer numberOfShares = Database.countquery(queryString);
        return (numberOfShares>0?true:false);
        }
    }
    
    global static string getObjectName(String recordId){
        //get all of the objects from your org
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
       
        //get the prefix of the objects in Ids
        Set<String> objectNameSet = gd.keySet();
        for(String sObjectName : objectNameSet){
            Schema.DescribeSObjectResult r =  gd.get(sObjectName).getDescribe();
            if (r.getKeyPrefix() != null){
                //get the object name for the matching record
                if (r.getKeyPrefix().equals(recordId.subString(0,3))){
                    return r.getLocalName();
                }
            }
        }
        return 'Error';
    }    
}