/**
 * @description       : SEL_LoginHistories
 * @author            : Ankit Kumar
 * @last modified on  : 02-27-2023
 * @last modified by  : Ankit Kumar
**/
public without sharing class SEL_LoginHistories extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2023
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            LoginHistory.Id,
            LoginHistory.UserId,
            LoginHistory.LoginTime,
            LoginHistory.Status
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2023
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return LoginHistory.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2023
    * @return SEL_LoginHistories 
    **/
    public static SEL_LoginHistories newInstance() {
        return(SEL_LoginHistories) ORG_Application.selector.newInstance(LoginHistory.SObjectType);
    }

    /**
     * @description Login history by userId
     * @param userIds Set<Id>
     * @param limitCount Integer
     * @return List<LoginHistory> - with query results
     */
    public List<LoginHistory> selectByUserIds(Set<Id> userIds, Integer limitCount) {
        return Database.query(
            newQueryFactory(false, false, true)
            .setCondition('UserId in : userIds')
            .setOrdering('LoginTime', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(limitCount)
            .toSOQL());
    } 
}