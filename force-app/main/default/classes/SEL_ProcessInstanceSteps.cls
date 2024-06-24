/**
 * @description       : SEL_ProcessInstanceSteps
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_ProcessInstanceSteps extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            ProcessInstanceStep.Id,
            ProcessInstanceStep.Comments,
            ProcessInstanceStep.ProcessInstanceId,
            ProcessInstanceStep.CreatedDate,
            ProcessInstanceStep.StepStatus,
            ProcessInstanceStep.OriginalActorId,
            ProcessInstanceStep.ActorId
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return ProcessInstanceStep.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_Offerings 
    **/
    public static SEL_ProcessInstanceSteps newInstance() {
        return(SEL_ProcessInstanceSteps) ORG_Application.selector.newInstance(ProcessInstanceStep.SObjectType);
    }

    /**
     * @description select ProcessInstanceStep by Target Object Ids
     * @param targetObjectIds Set<Id> - Set of id's to filter through
     * @return List<ProcessInstanceStep> - with query results
     */
    public List<ProcessInstanceStep> selectByTargetObjectId(Set<Id> targetObjectIds) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('ProcessInstance.TargetObjectId')
            .selectField('OriginalActor.Name')
            .selectField('Actor.Name')
            .setCondition(' ProcessInstance.TargetObjectId IN : targetObjectIds')
            .toSOQL());
    }
}