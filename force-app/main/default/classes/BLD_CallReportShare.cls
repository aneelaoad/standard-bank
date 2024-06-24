/**
 * Builder class for Call_Report__Share SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date February 2021
 */
@IsTest
public without sharing class BLD_CallReportShare extends ABS_ObjectBuilderBase {

    public BLD_CallReportShare() {
        this(getNewUnitOfWork());
    }

    public BLD_CallReportShare(fflib_SObjectUnitOfWork workUnit) {
        super(Call_Report__Share.SObjectType, workUnit);
    }

    public BLD_CallReportShare accessLevel(String accessLevel) {
        return (BLD_CallReportShare) setField(Call_Report__Share.AccessLevel, accessLevel);
    }

    public BLD_CallReportShare rowCause(String rowCause) {
        return (BLD_CallReportShare) setField(Call_Report__Share.RowCause, rowCause);
    }

    public BLD_CallReportShare userOrGroupId(Id userOrGroupId) {
        return (BLD_CallReportShare) setField(Call_Report__Share.UserOrGroupId, userOrGroupId);
    }

}