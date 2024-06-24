/**
 * Controller class for custom components in Insurance Agent Console Home page
 * @author          Dzianisik Maksim
 * @date            Sep 2022
 * @description :   SFP-14444, the controller prepares data for iac_BookOfBusiness and iac_ThisMonthActionItems components
*/

public with sharing class IAC_HomePageController {

    private static final Integer MAXIMUM = 100000;
    private static Id currentUserId = UserInfo.getUserId();
    private static Date currentDate = Date.today();
    private static Date startDate;
    private static Date endDate;
    private static String currentDateStr = String.valueOf(currentDate).substring(0, 10);
    private static String startDateStr = '';
    private static String endDateStr = '';
    private static String dateLiteral = '';
    private static String filter = '';
    private static BookOfBusinessWrapper resultBookOfBusiness = new BookOfBusinessWrapper();
    private static MonthActionItemsWrapper resultMonthActions = new MonthActionItemsWrapper();

    /**
     * @param timeFilter String value from the filter picklist
     * @description preparing data for the component
     * @return BookOfBusinessWrapper
     */
    @AuraEnabled(Cacheable=true)
    public static BookOfBusinessWrapper getBookOfBusiness(String timeFilter) {
        resultBookOfBusiness.actualPremOfPoliciesIncepted = 0.0;
        resultBookOfBusiness.actualPoliciesIncepted = 0;
        resultBookOfBusiness.actualPremOfPoliciesRenewed = 0.0;
        resultBookOfBusiness.actualPoliciesRenewed = 0;
        resultBookOfBusiness.oppConversionRatio = 0;
        filter = timeFilter;

        setUpDates();
        getPoliciesIncepted();
        getPoliciesRenewed();
        getOppConversionRatio();

        return resultBookOfBusiness;
    }

    /**
     * @description preparing data for the component
     * @return MonthActionItemsWrapper
     */
    @AuraEnabled(Cacheable=true)
    public static MonthActionItemsWrapper getMonthActions() {
        resultMonthActions.policiesUpForRenewal = 0;
        resultMonthActions.openClaims = 0;
        resultMonthActions.openOpp = 0;

        getPoliciesUpForRenewal();
        getOpenClaims();
        getOpenOpp();

        return resultMonthActions;
    }

    /**
     * @description set up dates according to the selected filter
     */
    private static void setUpDates() {
        Integer year = currentDate.year();
        Integer month = currentDate.month();
        if (filter == 'MTD') {
            startDate = Date.newInstance(year, month, 1);
            endDate = Date.newInstance(year, month, Date.daysInMonth(year, month));
            startDateStr = String.valueOf(startDate).substring(0, 10);
            endDateStr = String.valueOf(endDate).substring(0, 10);
            dateLiteral = 'THIS_MONTH';
        }else if (filter == 'QTD') {
            startDate = Date.newInstance(year, getQuarterStartMonth(month), 1);
            month = getQuarterEndMonth(month);
            endDate = Date.newInstance(year, month, Date.daysInMonth(year, month));
            startDateStr = String.valueOf(startDate).substring(0, 10);
            endDateStr = String.valueOf(endDate).substring(0, 10);
            dateLiteral = 'THIS_QUARTER';
        }else if (filter == 'YTD') {
            startDate = Date.newInstance(year, 1, 1);
            endDate = Date.newInstance(year, 12, 31);
            startDateStr = String.valueOf(startDate).substring(0, 10);
            endDateStr = String.valueOf(endDate).substring(0, 10);
            dateLiteral = 'THIS_YEAR';
        }
    }

    /**
     * @description select all necessary incepted policies
     */
    private static void getPoliciesIncepted() {
        String soqlPoliciesIncepted = 'SELECT Id, Name, convertCurrency(PremiumAmount), PremiumFrequency, Inception_Date__c,' +
                ' Expiry_Date__c FROM InsurancePolicy WHERE OwnerId = \'' + currentUserId + '\' AND IsActive = TRUE ' +
                'AND Inception_Date__c <= ' + endDateStr + ' AND Expiry_Date__c >= ' + startDateStr;
        List<InsurancePolicy> actualPoliciesIncepted = Database.query(soqlPoliciesIncepted);
        resultBookOfBusiness.actualPoliciesIncepted = actualPoliciesIncepted.size();

        if(actualPoliciesIncepted.size() > 0) {
            getPremiumOfPoliciesIncepted(actualPoliciesIncepted);
        }
    }

    /**
     * @param policies List<InsurancePolicy>
     * @description calculate premium for incepted policies
     */
    private static void getPremiumOfPoliciesIncepted(List<InsurancePolicy> policies) {
        for(InsurancePolicy policy : policies) {
            if(checkRequiredFields(policy, true)) {
                resultBookOfBusiness.actualPremOfPoliciesIncepted += calculateAmount(policy.PremiumFrequency, policy.PremiumAmount, policy.Inception_Date__c, policy.Expiry_Date__c);
            }
        }
        resultBookOfBusiness.actualPremOfPoliciesIncepted = resultBookOfBusiness.actualPremOfPoliciesIncepted.setScale(2,RoundingMode.HALF_UP);
    }

    /**
     * @description select all necessary renewed policies
     */
    private static void getPoliciesRenewed() {
        String soqlPoliciesRenewed = 'SELECT Id, Name, convertCurrency(PremiumAmount), PremiumFrequency, Renewal_Date__c,' +
                ' Expiry_Date__c FROM InsurancePolicy WHERE OwnerId = \'' + currentUserId + '\'  AND IsActive = TRUE' +
                ' AND Renewal_Date__c = ' + dateLiteral + ' AND Date_Renewed__c >= ' + currentDate.year() +
                '-01-01 AND Date_Renewed__c <= ' + currentDateStr;
        List<InsurancePolicy> actualPoliciesRenewed = Database.query(soqlPoliciesRenewed);
        resultBookOfBusiness.actualPoliciesRenewed = actualPoliciesRenewed.size();
        if(actualPoliciesRenewed.size() > 0) {
            getPremiumOfPoliciesRenewed(actualPoliciesRenewed);
        }
    }

    /**
     * @param policies List<InsurancePolicy>
     * @description calculate premium for renewed policies
     */
    private static void getPremiumOfPoliciesRenewed(List<InsurancePolicy> policies) {
        for(InsurancePolicy policy : policies) {
            if(checkRequiredFields(policy, false)) {
                resultBookOfBusiness.actualPremOfPoliciesRenewed += calculateAmount(policy.PremiumFrequency, policy.PremiumAmount, policy.Renewal_Date__c, policy.Expiry_Date__c);
            }
        }
        resultBookOfBusiness.actualPremOfPoliciesRenewed = resultBookOfBusiness.actualPremOfPoliciesRenewed.setScale(2,RoundingMode.HALF_UP);
    }

    /**
     * @param frequency String
     * @param amount Decimal
     * @param policyStart Date
     * @param policyEnd Date
     *
     * @return Decimal
     * @description calculate amount using policy data
     */
    private static Decimal calculateAmount(String frequency, Decimal amount, Date policyStart, Date policyEnd) {
        Decimal result = 0.0;
        Integer shiftRange = convertFrequencyToNumber(frequency);
        Date tempDate = policyStart;
        while(tempDate <= policyEnd) {
            if(tempDate >= startDate && tempDate <= endDate) {
                result += amount;
            }
            tempDate = tempDate.addMonths(shiftRange);
        }
        return result;
    }

    /**
     * @param policy InsurancePolicy
     * @param isIncepted Boolean
     *
     * @return Boolean
     * @description validate required fields for policy
     */
    private static Boolean checkRequiredFields(InsurancePolicy policy, Boolean isIncepted) {
        Boolean result = false;
        if(isIncepted) {
            result = policy.PremiumFrequency != null && policy.PremiumAmount != null && policy.Inception_Date__c != null && policy.Expiry_Date__c != null;
        }else {
            result = policy.PremiumFrequency != null && policy.PremiumAmount != null && policy.Renewal_Date__c != null && policy.Expiry_Date__c != null;
        }
        return result;
    }

    /**
     * @description calculate opportunity conversion ratio
     */
    private static void getOppConversionRatio() {
        String soqlOppConversionNumerator = 'SELECT COUNT() FROM Opportunity WHERE OwnerId = \'' + currentUserId + '\' AND IsClosed = TRUE AND IsWon = TRUE AND ' +
                'Actual_Close_Date__c >= ' + startDateStr + ' AND Actual_Close_Date__c <= ' + currentDateStr;

        Integer oppConversionNumerator = Database.countQuery(soqlOppConversionNumerator);

        if(oppConversionNumerator == 0) {
            resultBookOfBusiness.oppConversionRatio = 0;
        }else {
            String soqlOppConversionDenominator = 'SELECT COUNT() FROM Opportunity WHERE (OwnerId = \'' + currentUserId + '\' AND CreatedDate = ';
            if(filter == 'YTD') {
                soqlOppConversionDenominator += dateLiteral + ')';
            }else {
                soqlOppConversionDenominator += dateLiteral + ') OR (OwnerId = \'' + currentUserId + '\' AND CreatedDate < ' + dateLiteral +
                        ' AND CreatedDate > ' + currentDate.year() + '-01-01T00:00:00Z AND IsClosed = FALSE)';
            }
            Integer oppConversionDenominator = Database.countQuery(soqlOppConversionDenominator);
            if(oppConversionDenominator == 0){
                resultBookOfBusiness.oppConversionRatio = 0;
            }else {
                Decimal tempResult = (Decimal.valueOf(oppConversionNumerator) / Decimal.valueOf(oppConversionDenominator)) * 100;
                resultBookOfBusiness.oppConversionRatio = Integer.valueOf(Math.roundToLong(tempResult));
            }
        }
    }

    /**
     * @description calculate policies up for renewal
     */
    private static void getPoliciesUpForRenewal() {
        Integer result = 0;
        for(InsurancePolicy tempPolicy : [
                SELECT Id, Date_Renewed__c, Renewal_Date__c
                FROM InsurancePolicy
                WHERE OwnerId =: currentUserId AND Renewal_Date__c = THIS_MONTH AND Date_Renewed__c != NULL]) {
            if(tempPolicy.Date_Renewed__c > tempPolicy.Renewal_Date__c) {
                result++;
            }
        }
        resultMonthActions.policiesUpForRenewal = result;
    }

    /**
     * @description select the number of open claims
     */
    private static void getOpenClaims() {
        resultMonthActions.openClaims = [
                SELECT COUNT()
                FROM Claim
                WHERE OwnerId =: currentUserId AND CreatedDate = THIS_YEAR AND IsClosed = FALSE];
    }

    /**
     * @description select the number of open opportunities
     */
    private static void getOpenOpp() {
        resultMonthActions.openOpp = [
                SELECT COUNT()
                FROM Opportunity
                WHERE OwnerId =: currentUserId AND CreatedDate = THIS_YEAR AND IsClosed = FALSE];
    }

    /**
     * @param shiftRange String
     * @description convert String picklist value to Integer for using it in calculations
     * @return Integer
     */
    private static Integer convertFrequencyToNumber(String shiftRange) {
        Integer result;
        switch on shiftRange {
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
            when else {
                throw new AuraHandledException('There is a new Premium Frequency picklist value (' + shiftRange + '), please update the calculation logic!');
            }
        }
        return result;
    }

    /**
     * @param currentMonth Integer
     *
     * @return Integer
     * @description calculate the quarter start month according to the current month
     */
    private static Integer getQuarterStartMonth(Integer currentMonth) {
        Integer result = 0;
        if(currentMonth == 1 || currentMonth == 2 || currentMonth ==3) {
            result = 1;
        }else if (currentMonth == 4 || currentMonth == 5 || currentMonth == 6) {
            result = 4;
        }else if (currentMonth == 7 || currentMonth == 8 || currentMonth == 9) {
            result = 7;
        } else {
            result = 10;
        }
        return result;
    }

    /**
     * @param currentMonth Integer
     *
     * @return Integer
     * @description calculate the quarter end month according to the current month
     */
    private static Integer getQuarterEndMonth(Integer currentMonth) {
        Integer result = 0;
        if(currentMonth == 1 || currentMonth == 2 || currentMonth ==3) {
            result = 3;
        }else if (currentMonth == 4 || currentMonth == 5 || currentMonth == 6) {
            result = 6;
        }else if (currentMonth == 7 || currentMonth == 8 || currentMonth == 9) {
            result = 9;
        } else {
            result = 12;
        }
        return result;
    }

    /**
     * @description wrapper class for the "Book of Business" component
     */
    public class BookOfBusinessWrapper {
        @AuraEnabled
        public Decimal actualPremOfPoliciesIncepted { get; set; }
        @AuraEnabled
        public Integer actualPoliciesIncepted { get; set; }
        @AuraEnabled
        public Decimal actualPremOfPoliciesRenewed { get; set; }
        @AuraEnabled
        public Integer actualPoliciesRenewed { get; set; }
        @AuraEnabled
        public Integer oppConversionRatio { get; set; }
    }

    /**
     * @description wrapper class for the "This Month's Action Item" component
     */
    public class MonthActionItemsWrapper {
        @AuraEnabled
        public Integer policiesUpForRenewal { get; set; }
        @AuraEnabled
        public Integer openClaims { get; set; }
        @AuraEnabled
        public Integer openOpp { get; set; }
    }
}