/**
 * @description Builder class for CMN_AccountContactRelationshipDetail SObject
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 */
@IsTest
public class BLD_CMN_AccountContactRelationshipDetail extends ABS_ObjectBuilderBase {
    private static final String ACTIVE_STATUS = 'Active';
    public BLD_CMN_AccountContactRelationshipDetail() {
        this(getNewUnitOfWork());
    }
    
    public BLD_CMN_AccountContactRelationshipDetail(fflib_SObjectUnitOfWork workUnit) {
        super(CMN_Account_Contact_Relationship_Detail__c.SObjectType, workUnit);
    }
    
    public BLD_CMN_AccountContactRelationshipDetail(CMN_Account_Contact_Relationship_Detail__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    protected override void setDefaultData() {
        setField(CMN_Account_Contact_Relationship_Detail__c.Status__c, ACTIVE_STATUS)
            .setField(CMN_Account_Contact_Relationship_Detail__c.Valid_From__c, System.Today())
            .setField(CMN_Account_Contact_Relationship_Detail__c.Valid_To__c, System.Today().addDays(2)); 
    }
    public BLD_CMN_AccountContactRelationshipDetail role(String role){
        return (BLD_CMN_AccountContactRelationshipDetail)setField(CMN_Account_Contact_Relationship_Detail__c.Role__c, role);
    }
    public BLD_CMN_AccountContactRelationshipDetail clientId(Id clientId){
        return (BLD_CMN_AccountContactRelationshipDetail)setField(CMN_Account_Contact_Relationship_Detail__c.Client__c, clientId);
    }
    
    public BLD_CMN_AccountContactRelationshipDetail client(ABS_ObjectBuilderBase clientId){
        return (BLD_CMN_AccountContactRelationshipDetail) setRelation(CMN_Account_Contact_Relationship_Detail__c.Client__c, clientId);
    }
    
    public BLD_CMN_AccountContactRelationshipDetail contactId(Id contactId){
        return (BLD_CMN_AccountContactRelationshipDetail)setField(CMN_Account_Contact_Relationship_Detail__c.Contact__c, contactId);
    }
    public BLD_CMN_AccountContactRelationshipDetail externalIdentifier(String externalIdentifier){
        return (BLD_CMN_AccountContactRelationshipDetail)setField(CMN_Account_Contact_Relationship_Detail__c.ExternalIdentifier__c, externalIdentifier);
    }
    public BLD_CMN_AccountContactRelationshipDetail contact(ABS_ObjectBuilderBase contactId){
        return (BLD_CMN_AccountContactRelationshipDetail) setRelation(CMN_Account_Contact_Relationship_Detail__c.Contact__c, contactId);
    }
}