/**
 * @description Builder class for Resourcing__c object
 *
 * @author Konrad Bruszewski
 * @date June 2021
 */
@IsTest
public with sharing class BLD_Resourcing extends ABS_ObjectBuilderBase {
    private static final String DEFAULT_INITIATIVE  = 'Leave';
    private static final String DEFAULT_DESCRIPTION = 'Holiday';
    private static final String OPPORTUNITY_TYPE    = 'Opportunity';

    private Date thisWeekFriday {
        get {
            if (thisWeekFriday == null) {
                thisWeekFriday = getThisWeekFridayDate();
            }
            return thisWeekFriday;
        }
        set;
    }

    private Id defaultOpportunityId {
        get {
            if (defaultOpportunityId == null) {
                defaultOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
            }
            return defaultOpportunityId;
        }
        set;
    }

    public BLD_Resourcing() {
        this(getNewUnitOfWork());
    }

    public BLD_Resourcing(fflib_SObjectUnitOfWork workUnit) {
        super(Resourcing__c.SObjectType, workUnit);
    }

    public BLD_Resourcing(Resourcing__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    public BLD_Resourcing compoundKey(String compoundKey) {
        return(BLD_Resourcing) setField(Resourcing__c.Compound_Key__c, compoundKey);
    }

    public BLD_Resourcing description(String description) {
        return(BLD_Resourcing) setField(Resourcing__c.Description__c, description);
    }

    public BLD_Resourcing id() {
        return(BLD_Resourcing) setField(Resourcing__c.Id, fflib_IDGenerator.generate(Resourcing__c.SObjectType));
    }

    public BLD_Resourcing intensityForecast(String intensityForecast) {
        return(BLD_Resourcing) setField(Resourcing__c.Intensity_Forecast__c, intensityForecast);
    }

    public BLD_Resourcing name(String name) {
        return(BLD_Resourcing) setField(Resourcing__c.Name, name);
    }

    public BLD_Resourcing opportunityId(Id opportunityId) {
        return(BLD_Resourcing) setField(Resourcing__c.Opportunity__c, opportunityId);
    }

    public BLD_Resourcing opportunity(BLD_Opportunity bldOpportunity) {
        return(BLD_Resourcing) setRelation(Resourcing__c.Opportunity__c, bldOpportunity);
    }

    public BLD_Resourcing ownerId(Id ownerId) {
        return(BLD_Resourcing) setField(Resourcing__c.OwnerId, ownerId);
    }

    public BLD_Resourcing resourceId(Id resourceId) {
        return(BLD_Resourcing) setField(Resourcing__c.Resource__c, resourceId);
    }

    public BLD_Resourcing resource(BLD_USER bldUser) {
        return(BLD_Resourcing) setRelation(Resourcing__c.Resource__c, bldUser);
    }

    public BLD_Resourcing useResourcingType(String resourcingType) {
        return (BLD_Resourcing) setField(Resourcing__c.Resourcing_Type__c, resourcingType);
    }

    public BLD_Resourcing timeSpent(Decimal timeSpent) {
        return(BLD_Resourcing) setField(Resourcing__c.Time_Spent__c, timeSpent);
    }

    public BLD_Resourcing weekEndDate(Date weekEnd) {
        return(BLD_Resourcing) setField(Resourcing__c.Week_End_Date__c, weekEnd);
    }

    public BLD_Resourcing setDefaultData(String resourcingType) {
        weekEndDate(thisWeekFriday)
            .timeSpent((Math.random() * 168).intValue())
            .resourceId(UserInfo.getUserId())
            .useResourcingType(resourcingType);

        if (resourcingType == OPPORTUNITY_TYPE) {
            opportunityId(defaultOpportunityId)
                .intensityForecast('Inactive');
        } else if (resourcingType != OPPORTUNITY_TYPE) {
            description(DEFAULT_DESCRIPTION);
        }
        return this;
    }

    private Date getThisWeekFridayDate() {
        Datetime today = Datetime.now();
        String weekday = today.format('u');
        Integer daysUntilFriday = 5 - Integer.valueOf(weekday);
        return Date.newInstance(today.year(), today.month(), today.day()).addDays(daysUntilFriday);
    }
}