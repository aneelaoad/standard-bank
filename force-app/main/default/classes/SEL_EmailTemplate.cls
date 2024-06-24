/*****************************************************************************************
 *@Name of the Class: SEL_EmailTemplate
 *@Description      : SFP-30097 Added Methods on EmailTemplate 
 *@Author           : Likhitha Karusala
 *@Created Date     : Feb 2024
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
public without sharing class SEL_EmailTemplate extends fflib_SObjectSelector {

    /**
* @description getSObjectFieldList
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            EmailTemplate.Body,
            EmailTemplate.CreatedById,
            EmailTemplate.Description,
            EmailTemplate.DeveloperName,
            EmailTemplate.FolderId,
            EmailTemplate.HtmlValue,
            EmailTemplate.Id,
            EmailTemplate.IsActive,
            EmailTemplate.markup,
            EmailTemplate.Name,
            EmailTemplate.OwnerId,
            EmailTemplate.Subject,
            EmailTemplate.TemplateStyle,
            EmailTemplate.TemplateType   
        };
    }

    /**
* @description getSObjectType
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EmailTemplate.sObjectType;
    }

    /**
* @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
* and inject a mock instead of this class or to switch out this class for a new version.
    * @author TCK | 06-14-2022 
    * @return SEL_EmailTemplate 
    **/
    public static SEL_EmailTemplate newInstance() {
        return(SEL_EmailTemplate) ORG_Application.selector.newInstance(EmailTemplate.SObjectType);
    }

    /**
    * @description selectByName to query by name    
    * @author Pradeep Kota | 18th Feb 2024 
    * @param name 
    * @return List<EmailTemplate> 
    **/
    public List<EmailTemplate> selectByName(String name) {
        return (List<EmailTemplate>) Database.query(
            newQueryFactory()
            .setCondition('Name =: name')
            .toSOQL());
    }

    /**
    * @description selectByDeveloperName to query list of Email templates by developer name
    * @author Raja Kumar | 23rd March 2023 
    * @param developerName of email template
    * @return List<EmailTemplate> 
    **/
    public List<EmailTemplate> selectByDeveloperName(String developerName) {
        return (List<EmailTemplate>) Database.query(
            newQueryFactory()
            .setCondition('DeveloperName =: developerName')
            .toSOQL());
    }
    
}