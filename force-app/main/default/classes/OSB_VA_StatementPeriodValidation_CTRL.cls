/**
 *
 * Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date February 2021
 */
public with sharing class OSB_VA_StatementPeriodValidation_CTRL {

    /**
     * DTO class - input for validateDates method
     */
    public class ValidatePeriodInput {
        @InvocableVariable
        public Date fromDate;
        @InvocableVariable
        public Date toDate;
    }

    /**
     * DTO class - output of validateDates method
     */
    public class ValidatePeriodOutput {
        @InvocableVariable
        public Boolean isValid;
        @InvocableVariable
        public String message;
    }

    /**
     * Method for validating time period formed by the two dates
     *
     * @param inputs - List<ValidatePeriodInput>
     *
     * @return List<ValidatePeriodOutput>
     */
    @InvocableMethod(Label='VA validate dates')
    public static List<ValidatePeriodOutput> validateDates(List<ValidatePeriodInput> inputs) {
        List<ValidatePeriodOutput> result = new List<ValidatePeriodOutput>();
        for(ValidatePeriodInput input: inputs){
            ValidatePeriodOutput output = new ValidatePeriodOutput();
            Integer daysDiff = input.fromDate.daysBetween(input.toDate);
            if (input.fromDate > Date.today()) {
                output.isValid = false;
                output.message = 'The \'to date\' that you have input occurs in the future. You can input a date up to today\'s date';
                result.add(output);
                continue;
            }
            if (input.toDate > Date.today()) {
                output.isValid = false;
                output.message = 'The \'from date date\' that you have input occurs in the future. You can input a date up to today\'s date';
                result.add(output);
                continue;
            }
            if (daysDiff < 0) {
                output.isValid = false;
                output.message = 'Your to date if before your from date. Please input dates in correct order';
                result.add(output);
                continue;
            }
            if (daysDiff >= 180) {
                output.isValid = false;
                output.message = 'You are trying to request statement for period of ' + String.valueOf(daysDiff + 1) +
                        ' days. The maximal period for which statement can be requested is 180 days. Please choose different time period.';
                result.add(output);
                continue;
            }
            output.isValid = true;
            result.add(output);
        }
        return result;
    }
}