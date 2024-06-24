/**
 * Service Class for PP_PartnerApplication__c sObject
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
public with sharing class PP_SRV_PartnerApplication implements IService {
    /**
     * @description  : IService Instance
     *
     * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
     * @return IService
     * @date July 2021
     */
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
     * @description  : IService Interface
     *
     * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
     * @date July 2021
     */
    public interface IService {
        /**
         * @description Create Partner Application
         *
         * @param newPartnerApplications with filled fields
         * @param uow - unit of work used to register new Partner Application
         * @return returns the partner application id
         **/
        String savePartnerApplication(List<PP_PartnerApplication__c> newPartnerships, fflib_ISObjectUnitOfWork uow);

        /**
         * @description Initialise the OTP settings and validations
         * @param string relatedRecordId
         * @return SRV_OTP.Response wrapper class
         * @author - Areeba Khan
         **/
        SRV_OTP.Response initialiseOTP(Id relatedRecordId);

        /**
         * Validate an OTP code
         * @author - Areeba Khan
         * @param  String inputCode
         * @param String relatedRecordId
         * @return SRV_OTP.Response wrapper class
         **/
        SRV_OTP.Response validateOTPCode(String inputCode, String relatedRecordId);
    }

    /**
     * @description Create Partner Application
     *
     * @param newPartnerApplications with filled fields
     * @param uow - unit of work used to register new Partner Application
     * @return returns the partner application id
     **/
    public string savePartnerApplication(List<PP_PartnerApplication__c> newPartnerApplications, fflib_ISObjectUnitOfWork uow) {
        for (PP_PartnerApplication__c partnerApplication : newPartnerApplications) {
            uow.registerNew(partnerApplication);
        }
        uow.commitWork();
        return newPartnerApplications.get(0).id;
    }

    /**
     * @description Initialise the OTP settings and validations
     * @param string relatedRecordId
     * @return SRV_OTP.Response wrapper class
     * @author - Areeba Khan
     **/
    public SRV_OTP.Response initialiseOTP(string relatedRecordId) {
        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', relatedRecordId);
        return service.requestCode();
    }

    /**
     * Validate an OTP code
     * @author - Areeba Khan
     * @param  String inputCode
     * @param String relatedRecordId
     * @return SRV_OTP.Response wrapper class
     **/
    public SRV_OTP.Response validateOTPCode(String inputCode, String relatedRecordId) {
        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', relatedRecordId);
        return service.validateCode(inputCode);
    }
}