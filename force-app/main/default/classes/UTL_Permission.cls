/**
*
* @author Emmanuel Mulea Nocks(BlueSky)
* @date Aug 2021
* @description simplify Field level permission access
*/
public with sharing class UTL_Permission {

    @TestVisible
    private static String exceptionMsg = 'No such column {0} on entity {1} or sObject type {1} is not supported. If you are attempting to use ' +
            'a custom field, be sure to append the __c after the custom field name. ' +
            'Please reference your WSDL or the describe call for the appropriate names.';
    /**
    * get the DescribeFieldResult by objectType and field name
    *@param objectype
    *@param field
    *@return Schema.DescribeFieldResult
    */
    @TestVisible
    private static Schema.DescribeFieldResult fieldResults(String objectype,String field){

        try {
            Map<String, Schema.SObjectType> globalDescript = Schema.getGlobalDescribe();
            Schema.sObjectType objectTypess = globalDescript.get(objectype);
            Schema.DescribeSObjectResult res = objectTypess.getDescribe();
            Map<String, Schema.SObjectField> mapFieldLists = res.fields.getMap();
            Schema.DescribeFieldResult fieldResults = mapFieldLists.get(field).getDescribe();
            return fieldResults;
        }catch(NullPointerException ex){

            throw new UTL_PermissionException(String.format(exceptionMsg,new List<String>{field,objectype}));
        }
        catch(Exception ex){
            throw new UTL_PermissionException(ex.getMessage());
        }
    }
    /**
    * check if the user has edit perm
    *@param objectype
    *@param field
    *@return boolean
    */
    public static boolean hasFieldPermissionEdit(String objectype,String field){

        return fieldResults(objectype,field).isUpdateable();
    }
    /**
    * check if the user has read perm
    *@param objectype
    *@param field
    *@return boolean
    */
    public static boolean hasFieldPermissionRead(String objectype,String field){

        return fieldResults(objectype,field).isAccessible();
    }
    /**
    * check if the user has create perm
    *@param objectype
    *@param field
    *@return boolean
    */
    public static boolean hasFieldPermissionCreate(String objectype,String field){

        return fieldResults(objectype,field).isCreateable();
    }
    /**
    * get the DescribeFieldResult by objectType and field name
    *@param permName
    *@return Set<String>
    */
    public static Set<String> getAllUserIdInPermissionSet(String permName){

        Set<String> assIds = new Set<String>();
        for(PermissionSetAssignment permAss:[SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =: permName]){
            assIds.add(permAss.AssigneeId);
        }
        return assIds;
    }

    public class UTL_PermissionException extends Exception{}
}