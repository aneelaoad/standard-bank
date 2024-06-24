/**
* @description Drawdown Selector Layer class.
*
* @author Wayne Solomon
* @date Feb 2021
*/
public inherited sharing class SEL_DrawdownProfiles extends fflib_SObjectSelector {

    /**
     * getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Draw_Down_Profile__c.Id,
                Draw_Down_Profile__c.Name,
                Draw_Down_Profile__c.Draw_Date__c,
                Draw_Down_Profile__c.Product__c
        };
    }

    /**
     * getSObjectType
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Draw_Down_Profile__c.SObjectType;
    }

    /**
     * newInstance
     * @return SEL_DrawdownProfiles
     */
    public static SEL_DrawdownProfiles newInstance() {
        return(SEL_DrawdownProfiles) ORG_Application.selector.newInstance(Draw_Down_Profile__c.SObjectType);
    }

    /**
     * Get the earliest draw down dates across opportunities
     * <br/>SGPRT-4189
     *
     * @param recIds for the inscope records
     * @return the list od drawdowns
     */
    public List<Draw_Down_Profile__c> selectByIdsAndParentProduct(Set<Id> recIds) {
        return (List<Draw_Down_Profile__c>) Database.query(
                newQueryFactory(false, false, true)
                        .selectField('Product__r.Earliest_Draw_Date_Rollup__c')
                        .setCondition('Product__r.Opportunity__c in :recIds')
                        .toSOQL());
    }
}