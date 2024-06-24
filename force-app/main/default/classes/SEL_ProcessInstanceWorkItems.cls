/**
 * @description       : SEL_ProcessInstanceWorkItems
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : Ankit Kumar
**/
public without sharing class SEL_ProcessInstanceWorkItems extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            ProcessInstanceWorkItem.Id,
            ProcessInstanceWorkItem.ActorId
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return ProcessInstanceWorkItem.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_Offerings 
    **/
    public static SEL_ProcessInstanceWorkItems newInstance() {
        return(SEL_ProcessInstanceWorkItems) ORG_Application.selector.newInstance(ProcessInstanceWorkItem.SObjectType);
    }

    /**
     * @description select ProcessInstanceWorkItems by custom filter condition
     * @param condition String
     * @return List<ProcessInstanceWorkItem> - with query results
     */
    public List<ProcessInstanceWorkItem> selectByCustomFilterCondition(String condition) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('ProcessInstance.TargetObjectId')
            .selectField('ProcessInstance.SubmittedById')
            .setCondition(condition)
            .toSOQL());
    }
}