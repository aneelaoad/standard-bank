/**
 * Field Selector Layer
 * 
 * @author Salesforce
 *
 * @date Oct 29th 2021
 */
public with sharing class SEL_AOBProductContent extends fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{'Id', 'AOB_Product__c','AOB_Description__c','AOB_HelpText__c','AOB_sequence__c','AOB_ContentType__c'};
	
    /**
     * getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_ProductAOContent__c.Name,
                AOB_ProductAOContent__c.Id,
                AOB_ProductAOContent__c.AOB_Product__c,
                AOB_ProductAOContent__c.AOB_Description__c,
                AOB_ProductAOContent__c.AOB_HelpText__c,
                AOB_ProductAOContent__c.AOB_sequence__c,
                AOB_ProductAOContent__c.AOB_ContentType__c
        };
    }

    /**
     * selectById
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AOB_ProductAOContent__c.sObjectType;
    }

	/**
	 * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
	 * @return SEL_Accounts
	 */
	public static SEL_AOBProductContent newInstance() {
		return(SEL_AOBProductContent) ORG_Application.selector.newInstance(AOB_ProductAOContent__c.SObjectType);
	}
    /**
     * Select without conditions
     *
     * @return List<AOB_ProductAOContent__c>
     */
    public List<AOB_ProductAOContent__c> selectWithoutCondition() {
        return (List<AOB_ProductAOContent__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    
    /**
     * Select by section
     * @param relatedProductIds Set<Id>
     * @param hasbpId Boolean
     * @return List<AOB_ProductAOContent__c>
     */
    public List<AOB_ProductAOContent__c> selectContentByProduct(Set<Id> relatedProductIds,boolean hasbpId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(hasbpId){
			fieldQueryFactory.setCondition('AOB_Product__c In :relatedProductIds AND (AOB_ShowIFBPID__c=true OR (AOB_ShowIFBPID__c=false AND AOB_ShowIFNOBPID__c =false))');
        }
        else{ 
			fieldQueryFactory.setCondition('AOB_Product__c In :relatedProductIds AND (AOB_ShowIFNOBPID__c=true OR (AOB_ShowIFBPID__c=false AND AOB_ShowIFNOBPID__c =false))');
        }
		fieldQueryFactory.selectFields(fields);  

        return Database.query(fieldQueryFactory.toSOQL());
        
    }
    
}