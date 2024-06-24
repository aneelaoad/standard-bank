/**
 * Selector layer class for DataUsePurpose SObject
 *
 * @author Atul Sharma
 * @date 2023-8-20
 */
public inherited sharing class SEL_DataUsePurposes extends fflib_SObjectSelector {

    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public Schema.SObjectType getSObjectType(){
        return DataUsePurpose.SObjectType;
    }

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
    */
    public static SEL_DataUsePurposes newInstance() {
        return (SEL_DataUsePurposes) ORG_Application.selector.newInstance(DataUsePurpose.SObjectType);
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() { 
        return new List<Schema.SObjectField> {
            DataUsePurpose.Id,
            DataUsePurpose.Name
        };
    }        
    /**
     * @description Returns records where name is param
     *
     * @param name - the Name of DataUsePurpose
     * @return List of DataUsePurpose records
    */
    public Id selectIdByDataUsePurposeName(String name) {
        List<DataUsePurpose> dtPr = (List<DataUsePurpose>) Database.query(
            newQueryFactory()
            	.setCondition('Name = :name')            	
            	.toSOQL()
        );
        if (dtPr != null && dtPr.size() > 0) {
            return dtPr[0].Id;
        } else {
            return null;
        }
    }         
}