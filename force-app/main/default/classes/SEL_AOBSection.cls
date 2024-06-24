/**
 * Section Selector Layer
 * 
 * @author Salesforce
 *
 * @date Oct 29th 2021
 */
public class SEL_AOBSection extends fflib_SObjectSelector {
    private static Set<String> FIELDS=new Set<String>{'id','Name' ,'AOB_Title__c','AOB_smallDeviceColumns__c' ,'AOB_mediumDeviceColumns__c', 'AOB_largeDeviceColumns__c', 'AOB_Rank__c','AOB_Language__c'};
	
    /**
     * getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_ScreenSection__c.Name,
                AOB_ScreenSection__c.Id,
                AOB_ScreenSection__c.AOB_Title__c,
                AOB_ScreenSection__c.AOB_smallDeviceColumns__c,
                AOB_ScreenSection__c.AOB_mediumDeviceColumns__c,
                AOB_ScreenSection__c.AOB_largeDeviceColumns__c,
                AOB_ScreenSection__c.AOB_Rank__c,
                AOB_ScreenSection__c.AOB_Language__c
        };
    }

    /**
     * selectById
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AOB_ScreenSection__c.sObjectType;
    }

	/**
	 * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
	 * @return SEL_AOBSection
	 */
	public static SEL_AOBSection newInstance() {
		return(SEL_AOBSection) ORG_Application.selector.newInstance(AOB_ScreenSection__c.SObjectType);
	}
    /**
     * Select without conditions
     *
     * @return List<AOB_ScreenSection__c>
     */
    public List<AOB_ScreenSection__c> selectWithoutCondition() {
        return (List<AOB_ScreenSection__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    
    /**
     * Select by section and language
     *
     * @return List<AOB_ScreenSection__c>
     */
    public List<AOB_ScreenSection__c> selectSectionsByScreenName(String screenName, String language) {
        fflib_QueryFactory sectionQueryFactory = newQueryFactory(false, false, false);
		sectionQueryFactory.setCondition('AOB_Screen__r.Name = :screenName and AOB_Screen__r.AOB_Language__c = :language');
		sectionQueryFactory.selectFields(FIELDS);  
        sectionQueryFactory.addOrdering('AOB_Rank__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return Database.query(sectionQueryFactory.toSOQL());
        
    }
    
}