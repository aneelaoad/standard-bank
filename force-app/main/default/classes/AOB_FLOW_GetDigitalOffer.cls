/**
*  Class used to call AOB_API_GetApplicationProcessData API from Flow
*
* @author  Dayakar
*
* @date Jan 25th 2023
* 
* ACTION        DATE       OWNER            COMMENT
* created     25-01-2023   Dayakar          created
*/
public class AOB_FLOW_GetDigitalOffer {

 @InvocableMethod(label='Call Get Digital Offer API')
  public static void callGetDigitalOfferAPI(List<String> appIds) {
      String applicationid=appIds[0];
      Integer responseCode =  AOB_SRV_GetDigital.fetchResponse(appIds[0]);
  }
}