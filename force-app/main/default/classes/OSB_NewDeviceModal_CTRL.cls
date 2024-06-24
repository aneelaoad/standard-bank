/**
 * @description This is the server side controller class for NewDeviceModal aura component
 *
 * @author Rasmi Panthangi (rasmi.panthangi@tetrad.co.za)
 * @date April 2021
 *
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Update to the flagContact method for flagging contacts
 *
 */
public without sharing class OSB_NewDeviceModal_CTRL {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('OSB_NewDeviceModal_CTRL');
    public static final String MFA_UPDATED_SUCCESS = 'not_showing';
    public static final String MFA_UPDATED_FAILURE = 'not_updated';

    /**
     * @description Checks if the current user is login to community
     *
     * @return Boolean
     **/
    @AuraEnabled(Cacheable=true)
    public static Boolean isUserLoggedIn() {
        LOGGER.info(
            'OSB_NewDeviceModal_CTRL : isUserLoggedIn Returns logged in user details'
        );
        return UTL_User.isLoggedInUser();
    }

    /**
     * @description Gets the qrcode details for the user to register for MFA.
     *
     * @return Map<String, String>
     **/
    @AuraEnabled
    public static Map<String, String> getQrCodeDetails() {
        LOGGER.info(
            'OSB_NewDeviceModal_CTRL : getQrCodeDetails Returns QR code for user to scan'
        );
        Map<String, String> registrationHeaders2Values = new Map<String, String>();
        if (Test.isRunningTest()) {
            String mockBody = '{\n' + ' "qrImage": "TestQrImage"\n' + '}';
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
                mockBody
            );
            registrationHeaders2Values.put(
                'qrImage',
                (String) responseMap.get('qrImage')
            );
        } else {
            registrationHeaders2Values = OSB_SRV_NoknokIntegration.newInstance()
                .getNoknokQrCode();
        }
        LOGGER.info(
            'OSB_NewDeviceModal_CTRL : Get QR Code Details ==>' +
            registrationHeaders2Values
        );
        return registrationHeaders2Values;
    }

    /**
     * @description Gets the status of the MFA registration.
     * @param oobStatusHandle String
     * @return Map<String, String>
     **/
    @AuraEnabled
    public static Map<String, String> getStatusofRegistration(
        String oobStatusHandle
    ) {
        LOGGER.info(
            'OSB_NewDeviceModal_CTRL : getStatusofRegistration Returns status of MFA Registration'
        );
        Map<String, String> statusHeaders2values = new Map<String, String>();
        if (Test.isRunningTest()) {
            String mockBody =
                '{\n' +
                '"statusCode": 4000,\n' +
                '"id": "gY1uhDsIKcDkzD5PFBg2Cg",\n' +
                '"additionalInfo": {\n' +
                '"device": {\n' +
                '"id": "MTCxZKm8Ybet4RExKx7UxF2X76di0csyf1zIR4uGKx8",\n' +
                '"type": "android",\n' +
                '"info": "HMD+Global",\n' +
                '"model": "Nokia+8.1",\n' +
                '"os": "android 10",\n' +
                '"manufacturer": "HMD+Global"\n' +
                '},\n' +
                '"authenticatorsResult": [\n' +
                '{\n' +
                '"handle": "' +
                OSB_NewDeviceModal_CTRL_TEST.OOB_STATUS_HANDLE +
                '"\n' +
                '}\n' +
                ']\n' +
                '}\n' +
                '}';
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
                mockBody
            );
            Map<String, Object> additionalInfo = (Map<String, Object>) responseMap.get(
                'additionalInfo'
            );
            List<Object> authResultList = (List<Object>) additionalInfo.get(
                'authenticatorsResult'
            );
            Map<String, Object> handleMap = (Map<String, Object>) authResultList[0];
            statusHeaders2values.put(
                'handle',
                (String) handleMap.get('handle')
            );
        } else {
            statusHeaders2values = OSB_SRV_NoknokIntegration.newInstance()
                .getRegistrationStatus(oobStatusHandle);
        }
        LOGGER.info(
            'OSB_NewDeviceModal_CTRL : Get Status Of Registration ==>' +
            statusHeaders2values
        );
        return statusHeaders2values;
    }

    /**
     * @description Updates the user contact in the org if they don't want to be prompted to register for MFA on dashboard everytime they login
     * @param flagValue String
     * @param addFlag Boolean
     *
     * @return String
     **/
    @AuraEnabled
    public static String flagContact(String flagValue, Boolean addFlag) {
        LOGGER.info(
            'OSB_NewDeviceModal_CTRL : flagContact Returns status of Contact being flagged'
        );
        Contact userContact = new Contact();
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try {
            if (UTL_User.isLoggedInUser()) {
                userContact = SEL_Contacts.newInstance()
                    .selectByUserId(new Set<Id>{ UserInfo.getUserId() })[0];
            }
            List<String> siteFeatures = new List<String>();
            Set<String> setManageFeature = new Set<String>();
            if (userContact.Manage_Site_Features__c != null) {
                siteFeatures = userContact.Manage_Site_Features__c.split(';');
                setManageFeature.addAll(siteFeatures);
                if (addFlag == true) {
                    setManageFeature.add(flagValue);
                } else {
                    setManageFeature.remove(flagValue);
                }
            } else {
                if (addFlag == true) {
                    setManageFeature.add(flagValue);
                }
            }

            List<String> updatedArrManageFeature = new List<String>(
                setManageFeature
            );
            userContact.Manage_Site_Features__c = string.join(
                updatedArrManageFeature,
                ';'
            );
            uow.registerDirty(userContact);
            uow.commitWork();
        } catch (Exception e) {
            OSB_SRV_ActionFailureHandler.newInstance()
                .handleError(e, OSB_NewDeviceModal_CTRL.class.getName());
            LOGGER.error(
                'OSB_NewDeviceModal_CTRL : flagContact  Exception logged: ',
                e
            );
            return MFA_UPDATED_FAILURE;
        }
        LOGGER.info(
            'OSB_NewDeviceModal_CTRL : flagContact Successful updates to Contact being flagged'
        );
        return MFA_UPDATED_SUCCESS;
    }
}