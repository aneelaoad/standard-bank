@IsTest
public without sharing class BLD_DrawDownProfile extends ABS_ObjectBuilderBase {

    public BLD_DrawDownProfile() {
        this(getNewUnitOfWork());
    }

    public BLD_DrawDownProfile(fflib_SObjectUnitOfWork workUnit) {
        super(Draw_Down_Profile__c.SObjectType, workUnit);
    }

    private BLD_DrawDownProfile(Draw_Down_Profile__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    public BLD_DrawDownProfile linkToProduct(BLD_Product prodBld) {
        return (BLD_DrawDownProfile) setRelation(Draw_Down_Profile__c.Product__c, prodBld);
    }

    public BLD_DrawDownProfile funding(Decimal funding) {
        return (BLD_DrawDownProfile) setField(Draw_Down_Profile__c.Funding_Required__c, funding);
    }

    public BLD_DrawDownProfile drawDate(Date drawDate) {
        return (BLD_DrawDownProfile) setField(Draw_Down_Profile__c.Draw_Date__c, drawDate);
    }

    public BLD_DrawDownProfile drawDownNumber(Integer drawNumber) {
        return (BLD_DrawDownProfile) setField(Draw_Down_Profile__c.Draw_Down_Number__c, drawNumber);
    }
}