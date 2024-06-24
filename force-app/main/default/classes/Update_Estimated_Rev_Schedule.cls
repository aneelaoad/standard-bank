/**
 * Created by khonology on 14/08/2018.
 */

global without sharing class Update_Estimated_Rev_Schedule {
    @InvocableMethod(Label='Update Estimated Revenue Schedule')
    global static void updateEstimatedRevSch(List<genERSReq> ersReq) {
        System.debug('We are being imvoked');
        for (genERSReq request : ersReq ) {
            id pID = request.prodID;
            computeEstimatedRevenueSchedule(request);

        }
        return;
    }

    public static void computeEstimatedRevenueSchedule(genERSReq request) {
        id pID = request.prodID;

        try {
            SB_Product__c sb_rec = [SELECT id, Current_Year_Fees__c,Total_Fees__c FROM SB_Product__c WHERE id = :pID limit 1];
            sb_rec.Current_Year_Fees__c=getCurrentYearFees(pID);
            sb_rec.Total_Fees__c=getTotalFees(pID);
            sb_rec.EstRevSch_Updated__c=true;
            update sb_rec;
        } catch(Exception e) {
            System.debug('An exception occured in Once off populating Fee Totals');
        }

        return;
    }

    global class genERSReq {
        @InvocableVariable(label='Fee Amount' required=true)
        global double feeAmount;
        @InvocableVariable(label='Product ID' required=true)
        global id prodID;
        @InvocableVariable(label='Fee Frequency' required=true)
        global string feeFrequency;
    }

    //Get Current Year Revenues
    public static double getCurrentYearFees(id recordId)
    {
        double fees = 0;
        integer currentYear = System.today().Year();
        List < Estimated_Revenue_Schedule__c > lstOfSchedule =
        [
                select Fee_Amount__c, Estimated_Revenue_Date__c
                from Estimated_Revenue_Schedule__c
                where Product__c =: recordId
                and CALENDAR_YEAR(Estimated_Revenue_Date__c) =: currentYear
        ];

        for (Estimated_Revenue_Schedule__c sch: lstOfSchedule) {
            fees = fees + sch.Fee_Amount__c;
        }

        return fees;
    }

    //Get Total Revenues
    public static double getTotalFees(id recordId)
    {
        double fees = 0;
        List < Estimated_Revenue_Schedule__c > lstOfSchedule =
        [
                select Fee_Amount__c, Estimated_Revenue_Date__c
                from Estimated_Revenue_Schedule__c
                where Product__c =: recordId
        ];

        for (Estimated_Revenue_Schedule__c sch: lstOfSchedule) {
            fees = fees + sch.Fee_Amount__c;
        }

        return fees;
    }
}