/**
 * DOMAIN Class for the Estimated Revenue Schedule object
 * <br/>SGPRT-1937
 *
 * @author Youssef Ibrahim yibrahim@deloittece.com
 * @date August 2020
 */
public with sharing class DMN_EstimatedRevenueSchedule {
    public static final String OBJ_NAME = Estimated_Revenue_Schedule__c.SObjectType.getDescribe().getName();
    public static final String RT_ESR_ADVISORY = 'Estimated_Revenue_Schedule_Advisory';
    public static final String RT_ESR_NII_NIR = 'Estimated_Revenue_Schedule_Fees_and_Margin';
    public static final String RT_ESR_NIR = 'Estimated_Revenue_Schedule_Fees';
}