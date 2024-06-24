/**
* Selector layer class for Report SObject.
* @author Emmanuel Nocks (BlueSky)
* @date August 2020
*/
public with sharing class SEL_Report extends fflib_SObjectSelector{
    /**
    * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    * and inject a mock instead of this class or to switch out this class for a new version.
    * @return SEL_Report
    */
        public static SEL_Report newInstance() {
        return (SEL_Report) ORG_Application.selector.newInstance(Report.SObjectType);
    }
    /**
    * @description get SObject Field List
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Report.DeveloperName,  
            Report.id,
            Report.Name

        };
    }
    /**
    * @description Gets SObject Type
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {

        return Report.SObjectType;
    }
    /**
    * @description Get records by developername
    * @param  devNames Set of string
    * @return List<Report>
    */
    public List<Report> selectByDevName(Set<String> devNames) {

        return (List<Report>) Database.query(
                                            newQueryFactory().
                                                     setCondition('developername IN:devNames')
                                                    .toSOQL());
    }

}