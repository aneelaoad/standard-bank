/**
 * @description       : Builder class for Relationship_Manager__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-23-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   08-09-2021   TCK   Initial Version
**/
@IsTest
public without sharing class BLD_Relationship_Manager extends ABS_ObjectBuilderBase {
    public static final String DEF_NAME = 'testRelationship_Manager';
    private static final String DEF_SALESPERSON = '12345';

    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_Relationship_Manager() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_Relationship_Manager(fflib_SObjectUnitOfWork uow) {
        super(Relationship_Manager__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param sObj 
    * @param workUnit 
    **/
    public BLD_Relationship_Manager(Relationship_Manager__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(Relationship_Manager__c.Name, counter + DEF_NAME + counter)
        .setField(Relationship_Manager__c.Salesperson_Code__c, DEF_SALESPERSON);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param contactId 
    * @return BLD_Relationship_Manager 
    **/
    public BLD_Relationship_Manager contactId(BLD_Contact contactId) {
        return (BLD_Relationship_Manager) setRelation(Relationship_Manager__c.EAP_Contact__c, contactId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param contactId 
    * @return BLD_Relationship_Manager 
    **/
    public BLD_Relationship_Manager contactId(Id contactId) {
        return (BLD_Relationship_Manager) setField(Relationship_Manager__c.EAP_Contact__c, contactId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param userId 
    * @return BLD_Relationship_Manager 
    **/
    public BLD_Relationship_Manager userId(BLD_USER userId) {
        return (BLD_Relationship_Manager) setRelation(Relationship_Manager__c.EAP_User__c, userId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param userId 
    * @return BLD_Relationship_Manager 
    **/
    public BLD_Relationship_Manager userId(Id userId) {
        return (BLD_Relationship_Manager) setField(Relationship_Manager__c.EAP_User__c, userId);
    }

}