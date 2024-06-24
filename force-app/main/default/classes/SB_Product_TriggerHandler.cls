/***
	@ Func Area     	:  SB_Product__c
	@ Author        	:  Unknown
	@ Date          	:  Unknown
	@User Story    	    :  C-00002757 added method to calculate current year fees correctly
	@ Description 	    :  Trigger Handler and contains Estimated Revenue Schedule Code

	@Last Modified By   : Dzianisik Maksim
	@Last Modified on   : Sep. 2021
	@description        : SFP-6290 added logic for Insurance products - calculating Fees & Commission, creating ERS

	@Last Modified By   : Dzianisik Maksim
	@Last Modified on   : Okt. 2021
	@description        : SFP-8154 Fixed Logic for creating ERS for Insurance Products

	@Last Modified By   : Dzianisik Maksim
	@Last Modified on   : May 2022
	@description        : SFP-12591 Added Sync logic for Insurance products and InsurancePolicy object, updated api version
	***/
public with sharing class SB_Product_TriggerHandler {
    private static Map <Id,Double> currentYearFeeMap;
    private static final Id ESR_ADVISORY_RTD = UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME, DMN_EstimatedRevenueSchedule.RT_ESR_ADVISORY);
    private static final Id PRODUCT_INSURANCE_RT = Schema.SObjectType.SB_Product__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
    private static final Id ERS_INSURANCE_RT = Schema.SObjectType.Estimated_Revenue_Schedule__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
    private static final Integer MAXIMUM = 100000;
    private static List<InsurancePolicy> policiesForUpdate;
    private static Set<Id> insProductsForSync = new Set<Id>();

    /**
     * @param workingRecords List<SB_Product__c>
     * @param oldRecords List<SB_Product__c>
     * @param id2NewRecords Map<Id, SB_Product__c>
     * @param triggerEvent System.TriggerOperation
     * @description trigger handler
     */
    public static void handleTrigger(List<SB_Product__c> workingRecords, List<SB_Product__c> oldRecords, Map<Id, SB_Product__c> id2NewRecords, System.TriggerOperation triggerEvent ) {
        Id recordTypeId;

        // declare once
        switch on triggerEvent {
            when AFTER_INSERT {
                currentYearFeeMap = new Map <Id,Double>();
                recordTypeId =Schema.SObjectType.SB_Product__c.getrecordtypeinfosbyname().get('Advisory').getrecordtypeid();
                //= [Select Id From RecordType Where DeveloperName = 'Advisory'].Id;
                //changed because test classes were failing
                calcCurrentYearFees(workingRecords,recordTypeId);
                computeEstimatedRevenueSchedule(workingRecords,recordTypeId);

                ProductTriggerUtility.handleProductAfterInsertTrigger(workingRecords, id2NewRecords);

                new insertCTOPfromCustProdClass().insertCTOP(workingRecords);
            }
            when AFTER_UPDATE {
                currentYearFeeMap = new Map <Id,Double>();
                recordTypeId =Schema.SObjectType.SB_Product__c.getrecordtypeinfosbyname().get('Advisory').getrecordtypeid();
                generateEstimatedReveSch(workingRecords,oldRecords,recordTypeId);
                calcCurrentYearFees(workingRecords,recordTypeId);
                if(policiesForUpdate != null && policiesForUpdate.size() > 0) {
                    new WithoutSharingHelper().updatePolicies();
                }
            }
            when BEFORE_INSERT {
                ProductTriggerUtility.handleProductBeforeInsertTrigger(workingRecords);
                // Otherwise it is a change coming from the LEX page
                // or somewhere
                currentYearFeeMap = new Map <Id,Double>();
                recordTypeId =Schema.SObjectType.SB_Product__c.getrecordtypeinfosbyname().get('Advisory').getrecordtypeid();
                calcCurrentYearFees(workingRecords,recordTypeId);
                for (SB_Product__c sbProduct : workingRecords) {
                    if (sbProduct.recordTypeId == recordTypeId) {
                        //system.debug(sbProduct.EstRevSch_Updated__c + ' insertss our boolean bathong or is it the else part with freq of ' + sbProduct.Fee_Frequency__c);
                        if (((sbProduct.Billing_Start_Date__c != null) && (sbProduct.Billing_End_Date__c !=  null) &&
                                (sbProduct.Fee_Frequency__c !=  null) && (sbProduct.Fee_Amount__c !=  null) &&
                                (sbProduct.Risk_Weighted_Value__c !=  null))
                                ||
                                ((sbProduct.Billing_Start_Date__c != null) && (sbProduct.Billing_End_Date__c ==  null) &&
                                        (sbProduct.Fee_Frequency__c ==  'Once off') && (sbProduct.Fee_Amount__c !=  null) &&
                                        (sbProduct.Risk_Weighted_Value__c !=  null))) {
                            // reset the variable
                            sbProduct.EstRevSch_Updated__c=false;
                            switch on (sbProduct.Fee_Frequency__c) {
                                when 'Once off' {
                                    if(System.TODAY().year() == sbProduct.Billing_Start_Date__c.year()){
                                        sbProduct.Current_Year_Fees__c = sbProduct.Fee_Amount__c;
                                    }else{
                                        sbProduct.Current_Year_Fees__c = 0;
                                    }
                                    sbProduct.Total_Fees__c = sbProduct.Fee_Amount__c;
                                }
                                when 'Monthly' {
                                    computeTheFees(sbProduct,1,triggerEvent);
                                }
                                when 'Quarterly' {
                                    computeTheFees(sbProduct,3,triggerEvent);
                                }
                                when 'Annual' {
                                    computeTheFees(sbProduct,12,triggerEvent);
                                }
                                when 'Bi-annual' {
                                    computeTheFees(sbProduct,6,triggerEvent);
                                }
                                when else {
                                    // There shouldnt be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement
                                    System.debug('There should not be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement');
                                } // End when else
                            }
                        }
                    }else if (sbProduct.RecordTypeId == PRODUCT_INSURANCE_RT) {
                        if(validateInsuranceProduct(sbProduct)) {
                            manageInsFeesAndCommissions(sbProduct);
                        }
                    }
                }
            }
            when BEFORE_UPDATE  {
                currentYearFeeMap = new Map <Id,Double>();
                integer i = 0;
                recordTypeId =Schema.SObjectType.SB_Product__c.getrecordtypeinfosbyname().get('Advisory').getrecordtypeid();
                SB_Product__c sbProduct_old;
                Map<Id, SB_Product__c> id2OldRecords = new Map<Id, SB_Product__c>(oldRecords);
                calcCurrentYearFees(workingRecords,recordTypeId);
                for (SB_Product__c sbProduct : workingRecords) {
                    if (sbProduct.recordTypeId == recordTypeId) {
                        sbProduct_old = oldRecords[i];
                        i = i+1;
                        if ((sbProduct.Billing_Start_Date__c != sbProduct_old.Billing_Start_Date__c) ||
                                (sbProduct.Billing_End_Date__c !=  sbProduct_old.Billing_End_Date__c) ||
                                (sbProduct.Fee_Frequency__c !=  sbProduct_old.Fee_Frequency__c) ||
                                (sbProduct.Fee_Amount__c !=  sbProduct_old.Fee_Amount__c) ||
                                (sbProduct.Risk_Weighted_Value__c !=  sbProduct_old.Risk_Weighted_Value__c)) {
                            // Change on the Product Record itself

                            sbProduct.EstRevSch_Updated__c=false;
                            //SYSTEM.debug(sbProduct.Fee_Frequency__c + ' freq ' + sbProduct.Billing_Start_Date__c + ' start and the end is ' + sbProduct.Billing_End_Date__c);
                            switch on (sbProduct.Fee_Frequency__c) {
                                when 'Once off' {
                                    if(System.TODAY().year() == sbProduct.Billing_Start_Date__c.year()){
                                        sbProduct.Current_Year_Fees__c = sbProduct.Fee_Amount__c;
                                    }else{
                                        sbProduct.Current_Year_Fees__c = 0;
                                    }
                                    sbProduct.Total_Fees__c = sbProduct.Fee_Amount__c;
                                }
                                when 'Monthly' {
                                    computeTheFees(sbProduct,1,triggerEvent);
                                }
                                when 'Quarterly' {
                                    computeTheFees(sbProduct,3,triggerEvent);
                                }
                                when 'Annual' {
                                    computeTheFees(sbProduct,12,triggerEvent);
                                }
                                when 'Bi-annual' {
                                    computeTheFees(sbProduct,6,triggerEvent);
                                }
                                when else {
                                    // There shouldnt be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement
                                    System.debug('There should not be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement');
                                } // End when else
                            }
                        } else {
                            // Otherwise it is a change coming from the LEX page
                            // or somewhere
                            //system.debug(sbProduct.EstRevSch_Updated__c + ' updates our boolean bathong or is it the else part with freq of ' + sbProduct.Fee_Frequency__c);
                            if (((sbProduct.Billing_Start_Date__c != null) && (sbProduct.Billing_End_Date__c !=  null) &&
                                    (sbProduct.Fee_Frequency__c !=  null) && (sbProduct.Fee_Amount__c !=  null) &&
                                    (sbProduct.Risk_Weighted_Value__c !=  null))
                                    ||
                                    ((sbProduct.Billing_Start_Date__c != null) && (sbProduct.Billing_End_Date__c ==  null) &&
                                            (sbProduct.Fee_Frequency__c ==  'Once off') && (sbProduct.Fee_Amount__c !=  null) &&
                                            (sbProduct.Risk_Weighted_Value__c !=  null))) {
                                // reset the variable
                                sbProduct.EstRevSch_Updated__c=true;
                                //system.debug('in here lets go update tione  ' + sbProduct.Fee_Frequency__c);

                            }
                        } // change on product or from lex
                    }else if (sbProduct.RecordTypeId == PRODUCT_INSURANCE_RT) {
                        if(validateInsuranceProduct(sbProduct)) {
                            manageInsFeesAndCommissions(sbProduct);
                        }
                        if(needToBeSynced(id2OldRecords.get(sbProduct.Id), sbProduct)) {
                            insProductsForSync.add(sbProduct.Id);
                        }
                    }
                }
                if(insProductsForSync.size() > 0) {
                    policiesForUpdate = new List<InsurancePolicy>();
                    new WithoutSharingHelper().checkCorrectAccess(id2NewRecords, insProductsForSync);
                }
            }
            when AFTER_DELETE {
                //prevent deletion of sensitive data
            }
            when BEFORE_DELETE {
                new insertCTOPfromCustProdClass().deleteCTOP(oldRecords);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }

    // TODO : All code below here needs to be moved to the appropriate Service Class
    // Compute the fees for the before update/insert triggers
    /**
     * @param sbProduct SB_Product__c
     * @param counter Integer
     * @param triggerEvent System.TriggerOperation
     * @description unknown
     */
    public static void computeTheFees(SB_Product__c sbProduct, integer counter, System.TriggerOperation triggerEvent) {
        Double feeAmount = 0;
        Double currentYearFee = 0;
        Date fDate;
        if (sbProduct.Billing_End_Date__c <> null) {
            // This IF is because it seems in after_update, the trigger runs first before validation rules - DEF-003186
            integer numberOfMonths = sbProduct.Billing_Start_Date__c.monthsBetween(sbProduct.Billing_End_Date__c);
            fDate = sbProduct.Billing_Start_Date__c;
            //List<Estimated_Revenue_Schedule__c> ersList = new List<Estimated_Revenue_Schedule__c>();
            for (integer x = 0; x <= numberOfMonths; x=x+counter) {
                feeAmount = feeAmount + sbProduct.Fee_Amount__c;

                if (currentYearFeeMap.containsKey(sbProduct.Id)) {
                    currentYearFee = currentYearFeeMap.get(sbProduct.Id);
                }

                if(triggerEvent == System.TriggerOperation.BEFORE_INSERT){
                    if (fDate.year() == Date.today().year()) {
                        currentYearFee = currentYearFee + sbProduct.Fee_Amount__c ;
                    }
                }
                //system.debug(numberOfMonths + ' months x is ' + x + ' fdate is ' + fDate + ' current ' + currentYearFee + ' total ' + feeAmount);
                fDate = fDate.addMonths(counter);
            }
            if ((fDate <= sbProduct.Billing_End_Date__c) || (fDate.day() > sbProduct.Billing_End_Date__c.day())) {
                feeAmount = feeAmount + sbProduct.Fee_Amount__c;
                if (currentYearFeeMap.containsKey(sbProduct.Id)){
                    currentYearFee = currentYearFeeMap.get(sbProduct.Id);
                }
                if(triggerEvent == System.TriggerOperation.BEFORE_INSERT){
                    if (fDate.year() == Date.today().year()) {
                        currentYearFee = currentYearFee + sbProduct.Fee_Amount__c ;
                    }
                }
            }

            //system.debug(fDate + ' fDate sbProduct.Billing_End_Date__c ' + sbProduct.Billing_End_Date__c + ' current year ' + currentYearFee
            //+ ' total ' + feeAmount);
            sbProduct.Current_Year_Fees__c = currentYearFee;
            sbProduct.Total_Fees__c = feeAmount;
        } // The If is missing online in repos
        return;
    }

    /**
     * @param workingRecords List of SB_Product__c
     * @param oldRecords List of SB_Product__c
     * @param recordTypeId Advisory RecordType Id
     * @description unknown
     */
    public static void generateEstimatedReveSch(List<SB_Product__c> workingRecords, List<SB_Product__c> oldRecords, Id recordTypeId) {
        Set<Id> productIDSet = new Set<Id>();

        for (SB_Product__c request : workingRecords ) {
            if ((request.RecordTypeId != PRODUCT_INSURANCE_RT && request.EstRevSch_Updated__c == false) ||
                    (request.RecordTypeId == PRODUCT_INSURANCE_RT)) {
                productIDSet.add(request.Id);
            }
        }

        List<Estimated_Revenue_Schedule__c> doomedERS = new List<Estimated_Revenue_Schedule__c>();
        if (productIDSet.size() > 0) {
            Set<Id> validRecordTypeIds = new Set<Id>{
                    ERS_INSURANCE_RT,
                    ESR_ADVISORY_RTD,
                    null
            };
            doomedERS.addAll(
            [
                    SELECT Name
                    FROM Estimated_Revenue_Schedule__c
                    WHERE Product__c IN :productIDSet
                    AND RecordTypeId IN :validRecordTypeIds
            ]);
            try {
                delete doomedERS;
                computeEstimatedRevenueSchedule(workingRecords,recordTypeId);
            } catch (DmlException e) {
                System.debug('There is an error in deletion of ERS records');
            }
        }
        return;
    }

    /**
     * @param workingRecords List of SB_Product__c
     * @param recordTypeId Advisory RecordType Id
     * @description unknown
     */
    public static void computeEstimatedRevenueSchedule(List<SB_Product__c> workingRecords, Id recordTypeId) {
        date fDate;
        integer numberOfMonths = 0;
        List<Estimated_Revenue_Schedule__c> estRevList = new List<Estimated_Revenue_Schedule__c>();
        for (SB_Product__c sb_product : workingRecords) {
            if (sb_product.recordTypeId == recordTypeId) {
                switch on sb_product.Fee_Frequency__c {
                    when 'Once off' {
                        Estimated_Revenue_Schedule__c ers = new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                Estimated_Revenue_Date__c=sb_product.Billing_Start_Date__c,
                                Product__c=sb_product.id,
                                Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                CurrencyISOCode=sb_product.CurrencyISOCode,
                                RecordTypeId = ESR_ADVISORY_RTD,
                                Updated_by_LEX__c = false);
                        if (sb_product.EstRevSch_Updated__c == false) {
                            estRevList.add(ers);
                        }
                    }
                    when 'Monthly' {
                        numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                        fDate = sb_product.Billing_Start_Date__c;
                        if (sb_product.EstRevSch_Updated__c == false) {
                            for (integer i = 1; i <= numberOfMonths; i++) {
                                estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                        Estimated_Revenue_Date__c=fDate,
                                        Product__c=sb_product.id,
                                        Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                        CurrencyISOCode=sb_product.CurrencyISOCode,
                                        RecordTypeId = ESR_ADVISORY_RTD,
                                        Updated_by_LEX__c = false));
                                fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                            }
                            if ((fDate <= sb_product.Billing_End_Date__c) || (fDate.day() > sb_product.Billing_End_Date__c.day())) {
                                estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                        Estimated_Revenue_Date__c=sb_product.Billing_End_Date__c,
                                        Product__c=sb_product.id,
                                        Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                        CurrencyISOCode=sb_product.CurrencyISOCode,
                                        RecordTypeId = ESR_ADVISORY_RTD,
                                        Updated_by_LEX__c = false));
                            }
                        }
                    }
                    when 'Quarterly' {
                        numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                        fDate = sb_product.Billing_Start_Date__c;
                        for (integer i = 0; i <= numberOfMonths; i=i+3) {
                            fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                    Estimated_Revenue_Date__c=fDate,
                                    Product__c=sb_product.id,
                                    Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                    CurrencyISOCode=sb_product.CurrencyISOCode,
                                    RecordTypeId = ESR_ADVISORY_RTD,
                                    Updated_by_LEX__c = false));
                        }
                        if (fDate < sb_product.Billing_End_Date__c) {
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                    Estimated_Revenue_Date__c=sb_product.Billing_End_Date__c,
                                    Product__c=sb_product.id,
                                    Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                    CurrencyISOCode=sb_product.CurrencyISOCode,
                                    RecordTypeId = ESR_ADVISORY_RTD,
                                    Updated_by_LEX__c = false));
                        }
                    }
                    when 'Annual' {
                        numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                        fDate = sb_product.Billing_Start_Date__c;
                        for (integer i = 0; i <= numberOfMonths; i=i+12) {
                            fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                            if (fdate <= sb_product.Billing_End_Date__c ) {
                                estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                        Estimated_Revenue_Date__c=fDate,
                                        Product__c=sb_product.id,
                                        Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                        CurrencyISOCode=sb_product.CurrencyISOCode,
                                        RecordTypeId = ESR_ADVISORY_RTD,
                                        Updated_by_LEX__c = false));
                            }
                        }
                        if (fDate > sb_product.Billing_End_Date__c) {
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                    Estimated_Revenue_Date__c=fdate,
                                    Product__c=sb_product.id,
                                    Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                    CurrencyISOCode=sb_product.CurrencyISOCode,
                                    RecordTypeId = ESR_ADVISORY_RTD,
                                    Updated_by_LEX__c = false));
                        }
                    }
                    When 'Bi-annual' {
                        numberOfMonths = sb_product.Billing_Start_Date__c.monthsBetween(sb_product.Billing_End_Date__c);
                        fDate = sb_product.Billing_Start_Date__c;
                        for (integer i = 0; i <= numberOfMonths; i=i+6) {
                            fDate = sb_product.Billing_Start_Date__c.addMonths(i);
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                    Estimated_Revenue_Date__c=fdate,
                                    Product__c=sb_product.id,
                                    Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                    CurrencyISOCode=sb_product.CurrencyISOCode,
                                    RecordTypeId = ESR_ADVISORY_RTD,
                                    Updated_by_LEX__c = false));
                        }
                        if (fDate < sb_product.Billing_End_Date__c) {
                            estRevList.add(new Estimated_Revenue_Schedule__c(Fee_Amount__c=sb_product.Fee_Amount__c,
                                    Estimated_Revenue_Date__c=sb_product.Billing_End_Date__c,
                                    Product__c=sb_product.id,
                                    Risk_Weighted_Value__c=sb_product.Risk_Weighted_Value__c*sb_product.Fee_Amount__c/100,
                                    CurrencyISOCode=sb_product.CurrencyISOCode,
                                    RecordTypeId = ESR_ADVISORY_RTD,
                                    Updated_by_LEX__c = false));
                        }
                    }
                    when else {
                        // There shouldnt be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement
                        System.debug('There should not be an else, it just means the Fee Frequency picklist has been updated with a new value not catered for in this switch statement');
                    } // End when else
                } // End switch on feeFreq
            } else if(sb_product.RecordTypeId == PRODUCT_INSURANCE_RT && validateInsuranceProduct(sb_product)) {
                manageInsERS(sb_product, estRevList);
            }
        }
        if (estRevList.size() > 0) {
            insert estRevList;
        }

        return;
    }
    //JN: C-00002757 Added Method to calculate current year fees correctly
    /**
     * @param recordList List of SB_Product__c
     * @param recordTypeId Advisory RecordType Id
     * @description unknown
     */
    public static void calcCurrentYearFees(List <SB_Product__c> recordList, Id recordTypeId)
    {
        Set <Id> prodIdSet = new Set <Id>();
        if(recordList.size()>0){
            for(SB_Product__c currentProduct : recordList){
                if(currentProduct.recordTypeId == recordTypeId){
                    prodIdSet.add(currentProduct.id);
                }
            }
        }

        if(prodIdSet.size()>0) {
            integer currentYear = System.today().Year();
            //List < Estimated_Revenue_Schedule__c > returnList = new List < Estimated_Revenue_Schedule__c > ();
            Set<Id> validRecordTypeIds = new Set<Id>{
                    ESR_ADVISORY_RTD,
                    null
            };
            List < Estimated_Revenue_Schedule__c > lstOfSchedule = [
                    SELECT Fee_Amount__c, Estimated_Revenue_Date__c, Product__c
                    FROM Estimated_Revenue_Schedule__c
                    WHERE Product__c IN :prodIdSet
                    AND CALENDAR_YEAR(Estimated_Revenue_Date__c) = :currentYear
                    AND RecordTypeId IN :validRecordTypeIds
            ];

            for (Estimated_Revenue_Schedule__c sch : lstOfSchedule) {
                if (currentYearFeeMap.containsKey(sch.Product__c)) {
                    double fees = currentYearFeeMap.get(sch.Product__c);
                    fees += sch.Fee_Amount__c;
                    currentYearFeeMap.put(sch.Product__c, fees);
                } else {
                    currentYearFeeMap.put(sch.Product__c, sch.Fee_Amount__c);
                }
            }
        }
    }

    /**
     * @param product SB_Product__c
     * @description validate Insurance Product
     * @return Boolean
     */
    private static Boolean validateInsuranceProduct(SB_Product__c product) {
        return (product.Fee_Amount__c != null &&
                product.Fee_Frequency__c != null &&
                product.Inception_Date__c != null &&
                product.Commission_Amount__c != null &&
                product.Commission_Frequency__c != null &&
                (
                    (product.Renewal__c && product.Renewal_Date__c != null) ||
                    (!product.Renewal__c && product.Expiry_Date__c != null)
                )
        );
    }

    /**
     * @param product SB_Product__c
     * @description controller for calculating Fees and Commissions for Insurance product
     */
    private static void manageInsFeesAndCommissions(SB_Product__c product) {
        product.EstRevSch_Updated__c=false;
        Integer feeFrequency = convertFrequencyToNumber(product.Fee_Frequency__c);
        Integer commFrequency = convertFrequencyToNumber(product.Commission_Frequency__c);

        if(product.Fee_Frequency__c == 'Once off') {
            product.Total_Fees__c = product.Fee_Amount__c;
            if(product.Inception_Date__c.year() == System.today().year()) {
                product.Current_Year_Fees__c = product.Fee_Amount__c;
            } else {
                product.Current_Year_Fees__c = 0;
            }
        } else if (feeFrequency < 0) {
            addError(product, true);
        } else {
            calcInsFeesAndComm(product, feeFrequency, true);
        }

        if(product.Commission_Frequency__c == 'Once off') {
            product.Total_Commission__c = product.Commission_Amount__c;
            if(product.Inception_Date__c.year() == System.today().year()) {
                product.Current_Year_Commission__c = product.Total_Commission__c;
            } else {
                product.Current_Year_Commission__c = 0;
            }
        } else if (commFrequency < 0) {
            addError(product, false);
        } else {
            calcInsFeesAndComm(product, commFrequency, false);
        }
    }

    /**
     * @param product SB_Product__c
     * @param counter Integer - converted Frequency
     * @param isFees Boolean - calculate for Fees or not
     * @description handler for calculating Fees and Commissions for Insurance product
     */
    private static void calcInsFeesAndComm(SB_Product__c product, Integer counter, Boolean isFees) {
        Date startDate = product.Inception_Date__c;
        Date tempDate = product.Inception_Date__c;
        Date endDate = product.Renewal__c ? product.Renewal_Date__c : product.Expiry_Date__c;
        Decimal totalFees = 0.0;
        Decimal totalCommission = 0.0;
        Decimal currentYearFees = 0.0;
        Decimal currentYearCommission = 0.0;
        Integer i = 0;

        while (tempDate <= endDate) {
            if(isFees) {
                totalFees += product.Fee_Amount__c;
                if(tempDate.year() == System.today().year()) {
                    currentYearFees += product.Fee_Amount__c;
                }
            }else {
                totalCommission += product.Commission_Amount__c;
                if(tempDate.year() == System.today().year()) {
                    currentYearCommission += product.Commission_Amount__c;
                }
            }
            ++i;
            tempDate = startDate.addMonths(i * counter);
        }

        if(isFees) {
            product.Total_Fees__c = totalFees;
            product.Current_Year_Fees__c = currentYearFees;
        }else {
            product.Total_Commission__c = totalCommission;
            product.Current_Year_Commission__c = currentYearCommission;
        }
    }

    /**
     * @param product SB_Product__c
     * @param estRevList List of ERS
     * @description validation for Frequency picklist value
     */
    private static void manageInsERS(SB_Product__c product, List<Estimated_Revenue_Schedule__c> estRevList) {
        Integer feeFrequency = convertFrequencyToNumber(product.Fee_Frequency__c);
        Integer commFrequency = convertFrequencyToNumber(product.Commission_Frequency__c);

        if(feeFrequency > 0 && commFrequency > 0) {
            generateInsERS(product, feeFrequency, commFrequency, estRevList);
        } else {
            if(feeFrequency < 0) {
                addError(product, true);
            }else {
                addError(product, false);
            }
        }
    }

    /**
     * @param product SB_Product__c
     * @param feeFrequency Integer
     * @param commFrequency Integer
     * @param estRevList List of ERS
     * @description handler for generating new ERS for Insurance product
     */
    private static void generateInsERS(SB_Product__c product, Integer feeFrequency, Integer commFrequency, List<Estimated_Revenue_Schedule__c> estRevList) {
        Date startDate = product.Inception_Date__c;
        Date feeDate = product.Inception_Date__c;
        Date commDate = product.Inception_Date__c;
        Date endDate = product.Renewal__c ? product.Renewal_Date__c : product.Expiry_Date__c;
        Integer f = 1;
        Integer c = 1;

        //create first ERS with both values
        estRevList.add(createERS(product.Fee_Amount__c, product.Commission_Amount__c, startDate, product));

        if (feeFrequency == MAXIMUM || startDate.monthsBetween(endDate) == 0) {
            feeDate = endDate;
        }
        if (commFrequency == MAXIMUM || startDate.monthsBetween(endDate) == 0) {
            commDate = endDate;
        }

        while (feeDate < endDate || commDate < endDate) {
            if(feeFrequency * f < commFrequency * c && feeDate < endDate) {
                //create fee
                feeDate = startDate.addMonths(feeFrequency * f);
                estRevList.add(createERS(product.Fee_Amount__c, 0, feeDate, product));
                ++f;
            } else if (commFrequency * c < feeFrequency * f && commDate < endDate) {
                //create comm
                commDate = startDate.addMonths(commFrequency * c);
                estRevList.add(createERS(0, product.Commission_Amount__c, commDate, product));
                ++c;
            } else if (commFrequency * c == feeFrequency * f) {
                //create ERS with both values
                feeDate = startDate.addMonths(feeFrequency * f);
                commDate = startDate.addMonths(commFrequency * c);
                estRevList.add(createERS(product.Fee_Amount__c, product.Commission_Amount__c, feeDate, product));
                ++f;
                ++c;
            }
            //prevent creating additional ERS over the loop
            if(startDate.addMonths(feeFrequency * f) > endDate && startDate.addMonths(commFrequency * c) > endDate){
                break;
            }
        }
    }

    /**
     * @param feeAmount Decimal
     * @param commAmount Decimal
     * @param eDate Date
     * @param tempProduct SB_Product__c
     * @description creates a new Estimated_Revenue_Schedule__c using incoming params
     * @return new Estimated_Revenue_Schedule__c
     */
    private static Estimated_Revenue_Schedule__c createERS(Decimal feeAmount, Decimal commAmount, Date eDate, SB_Product__c tempProduct) {
        return new Estimated_Revenue_Schedule__c(
                Fee_Amount__c = feeAmount,
                Commission_Amount__c = commAmount,
                Estimated_Revenue_Date__c = eDate,
                Product__c = tempProduct.Id,
                CurrencyIsoCode = tempProduct.CurrencyIsoCode,
                RecordTypeId = ERS_INSURANCE_RT,
                Updated_by_LEX__c = false
        );
    }

    /**
     * @param frequency String
     * @description convert String picklist value to Integer for using it in calculations
     * @return Integer
     */
    private static Integer convertFrequencyToNumber(String frequency) {
        Integer result = -1;
        switch on frequency {
            when 'Once off' {
                result = MAXIMUM;
            }
            when 'Monthly' {
                result = 1;
            }
            when 'Quarterly' {
                result = 3;
            }
            when 'Bi-annual' {
                result = 6;
            }
            when 'Annual' {
                result = 12;
            }
        }
        return result;
    }

    /**
     * @param product SB_Product__c
     * @param isFee error in Fee_Frequency or not
     * @description add error to Product if there is a new value in Frequency picklists
     */
    private static void addError(SB_Product__c product, Boolean isFee) {
        String errorField = '';

        if(isFee) {
            errorField = 'Fee Frequency field (value - ' + product.Fee_Frequency__c + ')';
        }else {
            errorField = 'Commission Frequency field (value - ' + product.Commission_Frequency__c + ')';
        }
        product.addError('Something wrong with ' + errorField + ', the calculation logic doesn\'t know how to work with the value. Please show this error to the System Administrator');
    }

    /**
     * @param oldProduct SB_Product__c
     * @param newProduct SB_Product__c
     *
     * @return Boolean
     * @description check that synced fields were updated
     */
    private static Boolean needToBeSynced(SB_Product__c oldProduct, SB_Product__c newProduct) {
        Boolean result = false;
        result =    newProduct.SA_Product__c != oldProduct.SA_Product__c ||
                    newProduct.Parent_Product__c != oldProduct.Parent_Product__c ||
                    newProduct.Grand_Parent_Product__c != oldProduct.Grand_Parent_Product__c ||
                    newProduct.Opportunity__c != oldProduct.Opportunity__c ||
                    newProduct.Expiry_Date__c != oldProduct.Expiry_Date__c ||
                    newProduct.Renewal_Date__c != oldProduct.Renewal_Date__c ||
                    newProduct.Inception_Date__c != oldProduct.Inception_Date__c ||
                    newProduct.Premium_Amount__c != oldProduct.Premium_Amount__c ||
                    newProduct.Commission_Amount__c != oldProduct.Commission_Amount__c ||
                    newProduct.Fee_Amount__c != oldProduct.Fee_Amount__c ||
                    newProduct.Commission_Frequency__c != oldProduct.Commission_Frequency__c ||
                    newProduct.Fee_Frequency__c != oldProduct.Fee_Frequency__c ||
                    newProduct.Insurer__c != oldProduct.Insurer__c ||
                    newProduct.CurrencyIsoCode != oldProduct.CurrencyIsoCode;

        return result;
    }

    /**
     * @author          Maksim Dzianisik
     * @date            May 2022
     * @description     SFP-12591 Without Sharing class to check ability to update Insurance product if it has linked Insurance Policy records.
     */
    private without sharing class WithoutSharingHelper {
        /**
         * @param id2NewRecords Map<Id, SB_Product__c>
         * @param productsForSync Set<Id>
         * @description check ability to update Insurance product if it has linked Insurance Policy records
         */
        public void checkCorrectAccess(Map<Id, SB_Product__c> id2NewRecords, Set<Id> productsForSync) {
            List<InsurancePolicy> policies = [SELECT Id, NeedSyncWithProduct__c, OwnerId, SB_Product__c FROM InsurancePolicy WHERE SB_Product__c IN : productsForSync];

            if(policies.size() > 0) {
                if(Schema.SObjectType.InsurancePolicy.isUpdateable() && Schema.SObjectType.InsurancePolicy.fields.NeedSyncWithProduct__c.isUpdateable()) {
                    Id userId = UserInfo.getUserId();
                    Map<Id, List<InsurancePolicy>> prodId2Policies = new Map<Id, List<InsurancePolicy>>();
                    Set<Id> failedProductIds = new Set<Id>();

                    for(InsurancePolicy tempPolicy : policies) {
                        if(prodId2Policies.containsKey(tempPolicy.SB_Product__c)) {
                            prodId2Policies.get(tempPolicy.SB_Product__c).add(tempPolicy);
                        }else {
                            prodId2Policies.put(tempPolicy.SB_Product__c, new List<InsurancePolicy>{tempPolicy});
                        }
                    }

                    for(Id prodId : prodId2Policies.keySet()) {
                        List<InsurancePolicy> tempPolicies = prodId2Policies.get(prodId);
                        List<InsurancePolicy> validPolicies = new List<InsurancePolicy>();
                        for(InsurancePolicy policy : tempPolicies) {
                            if(policy.OwnerId != userId) {
                                failedProductIds.add(prodId);
                                validPolicies.clear();
                                break;
                            }else {
                                policy.NeedSyncWithProduct__c = true;
                                validPolicies.add(policy);
                            }
                        }
                        policiesForUpdate.addAll(validPolicies);
                    }

                    if(failedProductIds.size() > 0) {
                        for(Id prodId : failedProductIds) {
                            id2NewRecords.get(prodId).addError(System.Label.InsurancePolisies_owned_by_another_User);
                        }
                    }

                }else {
                    for(Id prodId : productsForSync) {
                        id2NewRecords.get(prodId).addError(System.Label.Invalid_InsurancePolicy_Access);
                    }
                }
            }
        }

        /**
         * @description the method updates checkbooks to run before-save flow on InsurancePolicy object to sync it with updated product
         */
        public void updatePolicies() {
            Database.SaveResult[] updateResult = Database.update(policiesForUpdate, false);
            Map<Id, String> failedRecId2ErrorMessage = new Map<Id, String>();
            String messageBody = '';
            for(Database.SaveResult result : updateResult) {
                if(!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        messageBody = err.getStatusCode() + ': ' + err.getMessage();
                        failedRecId2ErrorMessage.put(result.getId(), messageBody);
                    }
                }
            }

            if(failedRecId2ErrorMessage.size() > 0) {
                String toAddress = UserInfo.getUserEmail();
                String subject = 'Failed update for Insurance Policies';
                String body = '';
                for (Id policyId : failedRecId2ErrorMessage.keySet()) {
                    body += '<b>Insurance Policy Id:</b> '+ policyId + ', <b>ERROR_MESSAGE:</b> ' + failedRecId2ErrorMessage.get(policyId) + '<br/><br/>';
                }

                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
                        UTL_Email.createEmails(subject, body, new List<String> { toAddress })
                };
                Messaging.sendEmail(emails);
            }
        }
    }
}