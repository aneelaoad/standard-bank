/**
 * Builder class for Agenda__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date February 2021
 */
@IsTest
public without sharing class BLD_Agenda extends ABS_ObjectBuilderBase {

    public BLD_Agenda() {
        this(getNewUnitOfWork());
    }

    public BLD_Agenda(fflib_SObjectUnitOfWork workUnit) {
        super(Agenda__c.SObjectType, workUnit);
    }

    public BLD_Agenda eventReport(BLD_CallReport eventReportBuilder) {
        return (BLD_Agenda) setRelation(Agenda__c.Event_Report__c, eventReportBuilder);
    }

    public BLD_Agenda nbacId(Id nbacId) {
        return (BLD_Agenda) setField(Agenda__c.Related_NBAC__c, nbacId);
    }

}