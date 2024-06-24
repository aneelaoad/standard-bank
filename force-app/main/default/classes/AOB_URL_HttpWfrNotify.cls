/**
 * @description The REST Web Service to update the WFR Status on the verification object related to Application AND to notify BPM .
 *
 * @author Narendra Teja
 *
 * @date May 2023
 */
@RestResource(UrlMapping='/v1/wfrNotify/*')
/*
 * @description RESTAPI class for WFR Notify 
 */
global with sharing class AOB_URL_HttpWfrNotify {
  public static final String SERVICE_NAME = AOB_API_HttpWfrNotify.class.getName();
  /**
   * @description post method for update application service (inbound)
   */
  @HttpPatch
  global static void updateApplication() {
    CMN_FACTORY_WebserviceManager.processInboundService(SERVICE_NAME);
  }
}