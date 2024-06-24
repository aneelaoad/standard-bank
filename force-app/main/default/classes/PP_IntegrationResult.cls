/**
 * @description       : 
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : 
 * @last modified on  : 08-16-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
public virtual class PP_IntegrationResult {
   
    
    public final static String SUCCESS = 'Success';
    public final static String ERROR = 'Error';
    public final static String FAILED = 'Failed';

    @AuraEnabled public String resultStatus;
    @AuraEnabled public String resultMessage;  
    private HttpResponse resultResponse;

    /**
     * @description       : Constructor, used to assign the SUCCESS value to the AuraEnabled resultStatus attribute
     * @author            : Peter Guest
     * @group             : CloudSmiths
     * @last modified on  : 08-16-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public PP_IntegrationResult() {
        this.resultStatus = SUCCESS;
        this.resultMessage = '';
    }

    /**
    * @description 
    * @author Peter Guest | 27-07-2023 
    * @param response 
    **/
    public void setResponse(HttpResponse response) {
        this.resultResponse = response;
    }

    /**
    * @description 
    * @author Peter Guest | 27-07-2023 
    * @return String 
    **/
    public String getBody() {
        return this.resultResponse.getBody();
    }

    /**
    * @description 
    * @author Peter Guest | 27-07-2023 
    * @param headerKey 
    * @return String 
    **/
    public String getHeader(String headerKey) {
        return resultResponse.getHeader(headerKey);
    }

    /**
    * @description 
    * @author Peter Guest | 27-07-2023 
    * @return Integer 
    **/
    public Integer getStatusCode() {
        return resultResponse.getStatusCode();
    }

    /**
     * @description       : This method will return the true or false according to the results
     * @author            : Peter Guest
     * @group             : CloudSmiths
     * @return            : Boolean
     * @last modified on  : 08-16-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public Boolean isSuccess() {
        return (this.resultStatus == SUCCESS);
    }
}