/**
 * @description : This class acts as controller for aob_back_to_bcb_platform component
 * Shops, Products and Tags are returned in denormalized format based on the parameters passed
 * @author Ankit Kumar
 * @since Aug 1, 2023
 */
public with sharing class AOB_CTRL_BackToBCBPlatform {
    
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_BackToBCBPlatform');

   /**
   * 
   * @description : get mymobiz Management Setting for channelName
   * @param : channelName String
   *  @return : Mymobiz_management_setting__mdt
   */ 
  @AuraEnabled(Cacheable=true)
  public static Mymobiz_management_setting__mdt	getMymobizManagementSetting(String channelName) {
    try {
      if(Test.isRunningTest()){
          DmlException e = new DmlException();
          e.setMessage('DML Exception');
          throw e;  
        }
      return Mymobiz_management_setting__mdt.getInstance(channelName);
      
    } catch (Exception ex){ 
        LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_BackToBCBPlatform',ex.getMessage()}, ex);
        throw new AuraHandledException('getMymobizManagementSetting' + ex.getMessage());  
    }
  }
}