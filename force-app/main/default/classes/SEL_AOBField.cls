/**
 * Field Selector Layer
 * 
 * @author Salesforce
 *
 * @date Oct 29th 2021
 */
public class SEL_AOBField extends fflib_SObjectSelector {
    private static Set<String> FIELDS=new Set<String>{'id','AOB_MaxSelected__c','AOB_Image__c','AOB_Placeholder__c', 'AOB_section__c','AOB_ParentControllingValue__c', 'AOB_SFField__c' ,'AOB_pattern__c', 'AOB_ErrorMessage__c','AOB_sequence__c' , 'Name', 'AOB_Label__c', 'AOB_Type__c', 'AOB_Required__c', 'AOB_Parent__c', 'AOB_MRITable__c','AOB_HelpText__c', 'AOB_childShowingValue__c','AOB_Language__c','AOB_SFObject__c','AOB_ShowAtScreenLoad__c','AOB_MinLength__c','AOB_MaxLength__c'};
    
    /** 
     * getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_Field__c.Name,
                AOB_Field__c.Id,
                AOB_Field__c.AOB_MaxSelected__c,
                AOB_Field__c.AOB_Image__c,
                AOB_Field__c.AOB_Placeholder__c,
                AOB_Field__c.AOB_section__c,
                AOB_Field__c.AOB_ParentControllingValue__c,
                AOB_Field__c.AOB_SFField__c,
                AOB_Field__c.AOB_pattern__c,
                AOB_Field__c.AOB_ErrorMessage__c,
                AOB_Field__c.AOB_sequence__c,
                AOB_Field__c.AOB_Label__c,
                AOB_Field__c.AOB_Type__c,
                AOB_Field__c.AOB_Required__c,
                AOB_Field__c.AOB_Parent__c,
                AOB_Field__c.AOB_MRITable__c,
                AOB_Field__c.AOB_HelpText__c,
                AOB_Field__c.AOB_childShowingValue__c,                
                AOB_Field__c.AOB_Language__c,
                AOB_Field__c.AOB_SFObject__c,  
                AOB_Field__c.AOB_ShowAtScreenLoad__c,
                AOB_Field__c.AOB_MinLength__c,
                AOB_Field__c.AOB_MaxLength__c
        };
    }

    /**
     * selectById
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AOB_Field__c.sObjectType;
    }

    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_AOBField
     */
    public static SEL_AOBField newInstance() {
        return(SEL_AOBField) ORG_Application.selector.newInstance(AOB_Field__c.SObjectType);
    }
    /**
     * Select without conditions
     *
     * @return List<AOB_Field__c>
     */
    public List<AOB_Field__c> selectWithoutCondition() {
        return (List<AOB_Field__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    
    /**
     * Select by section
     * @param ids Set<Id>
     * @return List<AOB_Field__c>
     */
    public List<AOB_Field__c> selectFieldsBySection(Set<Id> ids) {
        fflib_QueryFactory FieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('AOB_section__c in :ids');
        FieldQueryFactory.selectFields(FIELDS);  
        FieldQueryFactory.addOrdering('AOB_sequence__c', fflib_QueryFactory.SortOrder.ASCENDING);

        return Database.query(FieldQueryFactory.toSOQL());
        
    }
    
    /**
     * Select MRI Tables
     * @param ids Set<Id>
     * @return List<AOB_Field__c>
     */
    public List<AOB_Field__c> selectMRITables(Set<Id> ids) {
        fflib_QueryFactory FieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('AOB_section__c in :ids');
        FieldQueryFactory.selectField('AOB_MRITable__c');  

        return Database.query(FieldQueryFactory.toSOQL());
    }
    
    /**
     * Select MRI Tables by language
     *
     * @return List<AOB_Field__c>
     */
    public List<AOB_Field__c> selectMRITablesByLanguage(Set<Id> ids, String language) {
        fflib_QueryFactory FieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('AOB_section__c in :ids AND AOB_Section__r.AOB_Screen__r.AOB_Language__c = :language');
        FieldQueryFactory.selectField('AOB_MRITable__c');  
        return Database.query(FieldQueryFactory.toSOQL());
    }
}