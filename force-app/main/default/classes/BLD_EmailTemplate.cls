/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description Builder class
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
@IsTest
public  without sharing  class BLD_EmailTemplate extends ABS_ObjectBuilderBase{
    
    public BLD_EmailTemplate() {
        this(getNewUnitOfWork());
    }
    
    public BLD_EmailTemplate(fflib_SObjectUnitOfWork workUnit) {
        super(EmailTemplate.SObjectType, workUnit);
    }
    
    public BLD_EmailTemplate(EmailTemplate sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    protected override void setDefaultData() {
        setField(EmailTemplate.TemplateType,  'Text');
    }
    public BLD_EmailTemplate folderId(ID forlderId) {
        return(BLD_EmailTemplate) setField(EmailTemplate.FolderId, forlderId);
    }
    public BLD_EmailTemplate name(String name) {
        return(BLD_EmailTemplate) setField(EmailTemplate.Name, name).setField(EmailTemplate.developerName, name);
    }
}