global without sharing class Generate_Estimated_Rev_Schedule {
    @InvocableMethod(Label='Generate Estimated Revenue Schedule')
    global static void generateEstimatedReveSch(List<genERSReq> ersReq) {
        String grandParent;

        set<id> productIDSet = new set<id>();
        set<id> advisoryProdsSet = new set<id>();
        set<id> UpdatedProds = new set<id>();

        for (genERSReq request : ersReq ) {
            productIDSet.add(request.prodID);
        }
        list<SB_Product__c> sb_rec;
        List<Estimated_Revenue_Schedule__c> doomedERS;
        System.debug('We are being invoked ' + productIDSet.size());
        if (productIDSet.size() > 0) {
            sb_rec = [SELECT id, EstRevSch_Updated__c, Grand_Parent_Product__c, CurrencyISOCode, Fee_Amount__c,
                      Billing_Start_Date__c, Billing_End_Date__c, Fee_Frequency__c, Risk_Weighted_Value__c
                      FROM SB_Product__c
                      WHERE id in :productIDSet AND Grand_Parent_Product__c = 'Advisory Fees' ]; //AND EstRevSch_Updated__c = false];
            if (sb_rec != null) {
                for (SB_Product__c prodrec : sb_rec) {
                    advisoryProdsSet.add(prodrec.id);
                    if (prodrec.EstRevSch_Updated__c == false) {
                        UpdatedProds.add(prodrec.id);
                    }
                }
            }
            doomedERS = new List<Estimated_Revenue_Schedule__c>(
                [SELECT Name FROM Estimated_Revenue_Schedule__c WHERE Product__c IN :UpdatedProds]);
            if (doomedERS != null) {
                try {
                    delete doomedERS;
                    computeEstimatedRevenueSchedule(sb_rec);
                    //update sb_rec;
                } catch (DmlException e) {
                    System.debug('There is an error in deletion of ERS records');
                }
            }
        }

        return;
    }

    public static void computeEstimatedRevenueSchedule(List<SB_Product__c> productList) {
        //id sb_product.id = sb_product.id;
        date fDate;
        List<Estimated_Revenue_Schedule__c> estRevList = new List<Estimated_Revenue_Schedule__c>();
        List<SB_Product__c> updateProductList = new List<SB_Product__c>();
        for (SB_Product__c sb_product : productList) {
            switch on sb_product.Fee_Frequency__c {
                when 'Once off' {
                    Estimated_Revenue_Schedule__c ers = new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                                          Estimated_Revenue_Date__c=sb_product.Billing_Start_Date__c,
                                                                                          Product__c=sb_product.id,
                                                                                          Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                                          CurrencyISOCode=sb_product.CurrencyISOCode);
                    if (sb_product.EstRevSch_Updated__c == false) {
                        estRevList.add(ers);
                    }
                    sb_product.Current_Year_Fees__c=0;
                    if (sb_product.Billing_Start_Date__c.year() == Date.today().year()) {
                        sb_product.Current_Year_Fees__c=sb_product.Fee_Amount__c;
                    }
                    sb_product.Total_Fees__c=sb_product.Fee_Amount__c;
                    sb_product.EstRevSch_Updated__c=false;
                    //updateProductList.add(sb_product);
                }
                when 'Monthly' {
                    system.debug('It is monthly');
                    integer numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                    fDate = sb_product.Billing_Start_Date__c;
                    if (sb_product.EstRevSch_Updated__c == false) {
                        for (integer i = 1; i <= numberOfMonths; i++) {
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                             Estimated_Revenue_Date__c=fDate,
                                                                             Product__c=sb_product.id,
                                                                             Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                             CurrencyISOCode=sb_product.CurrencyISOCode));
                            fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                        }
                        system.debug(fDate + ' fDate sb_product.Billing_End_Date__c ' + sb_product.Billing_End_Date__c);
                        if ((fDate <= sb_product.Billing_End_Date__c) || (fDate.day() > sb_product.Billing_End_Date__c.day())) {
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                             Estimated_Revenue_Date__c=sb_product.Billing_End_Date__c,
                                                                             Product__c=sb_product.id,
                                                                             Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                             CurrencyISOCode=sb_product.CurrencyISOCode));
                        }
                    }
                }
                when 'Quarterly' {
                    integer numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                    fDate = sb_product.Billing_Start_Date__c;
                    //List<Estimated_Revenue_Schedule__c> ersList = new List<Estimated_Revenue_Schedule__c>();
                    for (integer i = 0; i <= numberOfMonths; i=i+3) {
                        fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                        estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                         Estimated_Revenue_Date__c=fDate,
                                                                         Product__c=sb_product.id,
                                                                         Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                         CurrencyISOCode=sb_product.CurrencyISOCode));
                    }
                    if (fDate < sb_product.Billing_End_Date__c) {
                        estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                         Estimated_Revenue_Date__c=sb_product.Billing_End_Date__c,
                                                                         Product__c=sb_product.id,
                                                                         Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                         CurrencyISOCode=sb_product.CurrencyISOCode));
                    }
                }
                when 'Annual' {
                    integer numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                    fDate = sb_product.Billing_Start_Date__c;
                    //List<Estimated_Revenue_Schedule__c> ersList = new List<Estimated_Revenue_Schedule__c>();
                    for (integer i = 0; i <= numberOfMonths; i=i+12) {
                        fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                        if (fdate <= sb_product.Billing_End_Date__c ) {
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                             Estimated_Revenue_Date__c=fDate,
                                                                             Product__c=sb_product.id,
                                                                             Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                             CurrencyISOCode=sb_product.CurrencyISOCode));
                        }
                    }
                    if (fDate > sb_product.Billing_End_Date__c) {
                        estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                         Estimated_Revenue_Date__c=fdate,
                                                                         Product__c=sb_product.id,
                                                                         Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                         CurrencyISOCode=sb_product.CurrencyISOCode));
                    }
                }
                When 'Bi-annual' {
                    integer numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                    fDate = sb_product.Billing_Start_Date__c;
                    //List<Estimated_Revenue_Schedule__c> ersList = new List<Estimated_Revenue_Schedule__c>();
                    for (integer i = 0; i <= numberOfMonths; i=i+6) {
                        fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                        estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                         Estimated_Revenue_Date__c=fdate,
                                                                         Product__c=sb_product.id,
                                                                         Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                         CurrencyISOCode=sb_product.CurrencyISOCode));
                    }
                    if (fDate < sb_product.Billing_End_Date__c) {
                        estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                                                         Estimated_Revenue_Date__c=sb_product.Billing_End_Date__c,
                                                                         Product__c=sb_product.id,
                                                                         Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c,
                                                                         CurrencyISOCode=sb_product.CurrencyISOCode));
                    }
                }
                when else {
                    // There shouldnt be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement
                    System.debug('There should not be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement');
                } // End when else
            } // End switch on feeFreq
            if (estRevList.size() == 80) {
            insert estRevList;
        }
        }
        if (estRevList.size() > 0) {
            insert estRevList;
        }
        for (SB_Product__c sb_product : productList) {
            sb_product.Current_Year_Fees__c=getCurrentYearFees(sb_product.id);
            sb_product.Total_Fees__c=getTotalFees(sb_product.id);
            sb_product.EstRevSch_Updated__c=false;
            updateProductList.add(sb_product);
            if (updateProductList.size() == 80) {
            update updateProductList;
        }
        }
        if (updateProductList.size() > 0) {
            update updateProductList;
        }

        return;
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

    global class genERSReq {
        @InvocableVariable(label='Billing Start Date' required=true)
        global date billingStartDate;
        @InvocableVariable(label='Billing End Date' required=true)
        global date billingEndDate;
        @InvocableVariable(label='Fee Amount' required=true)
        global double feeAmount;
        @InvocableVariable(label='Fee Frequency' required=true)
        global string feeFrequency;
        @InvocableVariable(label='Risk Weighted Value' required=true)
        global double riskWeightedValue;        
        @InvocableVariable(label='Product ID' required=true)
        global id prodID; 
        @InvocableVariable(label='Estimated Revenue Schedule Updated' required=true)
        global boolean EstRevSch_Updated; 
    }
}