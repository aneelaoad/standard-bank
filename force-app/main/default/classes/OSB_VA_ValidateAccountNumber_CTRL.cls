/**
 *
 * Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 */
public with sharing class OSB_VA_ValidateAccountNumber_CTRL {

    /**
     * Check if account number length is 13 and if it consists of digits only
     *
     * @param accountNumbers List<String> - account numbers
     *
     * @return List<Boolean>
     */
    @InvocableMethod(Label='VA validate account number')
    public static List<Boolean> validateAccountNumber(List<String> accountNumbers){
        List<Boolean> result = new List<Boolean>();
        for(String accountNumber: accountNumbers){
            if(accountNumber.length() == 13 && accountNumber.isNumeric()){
                result.add(true);
            } else {
                result.add(false);
            }
        }
        return result;
    }
}