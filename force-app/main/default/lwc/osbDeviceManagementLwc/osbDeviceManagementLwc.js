import { LightningElement, api, wire } from 'lwc';
import isUserLoggedIn from '@salesforce/apex/OSB_DeviceManagement_CTRL.isUserLoggedIn';
import getDeviceList from '@salesforce/apex/OSB_DeviceManagement_CTRL.getDeviceDetails';
import deleteDevices from '@salesforce/apex/OSB_DeviceManagement_CTRL.deleteDevices';
import { NavigationMixin } from 'lightning/navigation';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import { refreshApex } from '@salesforce/apex';
import flagContact from '@salesforce/apex/OSB_NewDeviceModal_CTRL.flagContact';
import sendOutMailOTP from '@salesforce/apex/OSB_OtpManagement_CTRL.sendOutMailOTP';
const linkedMFA = 'Device Linked to MFA';
const addDevice = 'Device Addition';
const removeDevice = 'Device Removal';
const removeAllDevice = 'All Device Removal';
const removeDeviceSuccess = 'Device Removal Successful';
const removeAllDeviceSuccess = 'All Device Removal Successful';
export default class OsbDeviceManagementLwc extends NavigationMixin(
    LightningElement
) {
    @api
    edit = false;

    @api
    toastMessage = '';

    userlogged;

    @api toastType = 'success';

    loading = true;

    @api isPreferred = false;

    @api openModal = false;

    removeDevice = false;

    removeAllDevices = false;

    @api qrTimedOut = false;

    deviceRemoved = false;

    allDevicesRemoved = false;

    @api preferedAuthChanged = false;

    @api unexpectedError = false;

    @api deviceCount;

    @api maxDevicesAllowed = 32;

    @api cantAddDevice = false;

    @api allDeviceAuthIdList = [];

    @api kickinPagination = false;

    @api deviceDetailsList = [];

    optionSelected;

    @api deviceDetailsKeyList = [];

    devicesToDeleteList = [];

    allDeviceAuthList = [];

    blankResponse = false;
    @api authIdToDelete;

    @api noOfAuthenticators = 0;

    @api error;

    refreshDeviceList;

    deviceUpdate = false;

    showOTPModal = false;
    otpReason;
    otpMessage;

    listOfDeviceToDelete;

    dashboardValue = false;

    connectedCallback() {
        this.init();
        this.updateMFA();
    }

    @api noDevicesLinked = false;

    get deviceListNotGreaterThanOne() {
        return this.allDeviceAuthIdList.length > 1;
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    refreshMFAResult;

    @wire(getDeviceList)
    getDeviceList(result) {
        this.refreshMFAResult = result;
        if (result.data) {
            this.loading = false;

            let responseMap = JSON.parse(JSON.stringify(result.data));

            if (Object.entries(responseMap).length != 0) {
                let statusCode = Object.values(responseMap.statusAndIdMap)[0];

                let arrayToStoreKeys = [];
                if (statusCode === '4000') {
                    this.noDevicesLinked = false;
                    delete responseMap.AdditionalDataMap;
                    delete responseMap.statusAndIdMap;
                    for (let key in responseMap) {
                        arrayToStoreKeys.push(key);
                    }
                    if (arrayToStoreKeys.length > 0) {
                        let allDeviceAuthIdList = [];

                        let allDeviceList = [];
                        let responseValues = [];
                        responseValues = Object.values(responseMap);

                        for (let i = 0; i < responseValues.length; i++) {
                            let authMap =
                                responseValues[i]['authenticatorsMap'];

                            let authList = [];
                            authList = Object.values(authMap);

                            if (authList.length > 1) {
                                this.rowSpan = authList.length;
                            }
                            for (let j = 0; j < authList.length; j++) {
                                responseValues[i]['authList'[j]] = [authList][
                                    j
                                ];
                                authList[j]['deviceInfo'] =
                                    responseValues[i]['deviceInfo'];
                                authList[j]['deviceType'] =
                                    responseValues[i]['deviceType'];
                                authList[j]['deviceOs'] =
                                    responseValues[i]['deviceOs'];
                                authList[j]['deviceModel'] = responseValues[i][
                                    'deviceModel'
                                ].replaceAll('+', ' ');
                                authList[j]['deviceManufacturer'] =
                                    responseValues[i]['deviceManufacturer'];
                                authList[j]['deviceId'] =
                                    responseValues[i]['deviceId'];
                                let osTypeAndroid =
                                    responseValues[i].deviceType.includes(
                                        'android'
                                    );
                                authList[j]['osTypeAndroid'] = osTypeAndroid;
                                authList[j]['rowSpan'] = authList.length;
                                allDeviceList.push(authList[j]);
                                allDeviceAuthIdList.push(
                                    authList[j]['authenticatorsHandle']
                                );
                            }
                        }
                        this.allDeviceAuthList = allDeviceList;
                        this.allDeviceAuthIdList = allDeviceAuthIdList;
                        this.noOfAuthenticators = allDeviceList.length;

                        if (allDeviceList.length !== null) {
                            this.kickinPagination = true;
                        }
                        this.deviceDetailsList = responseValues;
                        this.deviceDetailsKeyList = arrayToStoreKeys;
                    }
                } else {
                    this.noDevicesLinked = true;
                }
            }
        } else if (result.error) {
            this.loading = false;
            this.blankResponse = true;
        }
    }

    updateMFA() {
        return refreshApex(this.refreshMFAResult);
    }

    init() {
        window.scrollTo(0, 0);
        let action = isUserLoggedIn;
        action()
            .then((result) => {
                let isLoggedIn = result;
                if (isLoggedIn) {
                    this.userlogged = true;
                }
            })
            .catch(() => {
                this.userlogged = false;
            });
    }

    handleRemoveAllDevices() {
        this.removeAllDevices = false;
        let allDeviceAuthIdList = this.allDeviceAuthIdList;
        if (allDeviceAuthIdList.length > 0) {
            this.removeAllDevices = true;
            this.listOfDeviceToDelete = allDeviceAuthIdList
        } else {
            this.removeAllDevices = false;
        }
    }

    handleDeleteAllDevices(event) {
        this.allDevicesRemoved = false;
        this.removeAllDevices = false;
        let optionSelected = event.detail;
        let devicesToDeleteList = this.listOfDeviceToDelete;
        
        if ((optionSelected === 'YES') & (devicesToDeleteList.length > 0)) {
            this.otpReason = removeAllDevice;
            this.otpMessage = 'Continue to remove device';
            this.showOTPModal = true;
        }
    }

    closeToast() {
        this.showMessageToast = false;
    }

    handleDeleteDevice(event) {
        event.preventDefault();
        let devicesToDeleteList = event.detail;
        this.listOfDeviceToDelete = devicesToDeleteList;
        this.deviceRemoved = false;
        this.otpReason = removeDevice;
        this.otpMessage = 'Continue to remove device';
        this.showOTPModal = true;
    }

    continueToDelete(){
        let devicesToDeleteList = this.listOfDeviceToDelete;
        let numOfDevices = this.noOfAuthenticators - devicesToDeleteList.length;
        this.loading = true;
        deleteDevices({ authHandleList: devicesToDeleteList }).then(
            (response) => {
                let responseList = response;
                if(this.otpReason === removeDevice){
                    sendOutMailOTP({otpReason : removeDeviceSuccess});
                }else if(this.otpReason === removeAllDevice){
                    sendOutMailOTP({otpReason : removeAllDeviceSuccess});
                }
                if (responseList[0].statusCodeString === '4000') {
                    window.scrollTo(0, 0);
                    setTimeout(function () {
                        this.loading = false;
                    }, 3000);
                    this.deviceRemoved = true;
                    this.toastMessage =
                        'The device has been successfully removed. Please wait for the page to reload.';
                    if (numOfDevices === 0) {
                        let flagSiteFeature = false;
                        flagContact({
                            flagValue: linkedMFA,
                            addFlag: flagSiteFeature
                        });
                    }
                    this.updateMFA();
                } else {
                    window.scrollTo(0, 0);
                    this.unexpectedError = true;
                }
            }
        );
    }

    handleMFAModal() {
        if (this.deviceUpdate) {
            this.loading = true;
            setTimeout(function () {
                this.loading = false;
            }, 3000);
        }
        this.openModal = false;
        this.deviceUpdate = false;
        this.updateMFA();
    }

    handleMFADevice() {
        this.deviceUpdate = true;
        this.updateMFA();
    }

    handleAddDevice(event) {
        event.preventDefault();
        let noOfAuthenticators = this.noOfAuthenticators;
        if (noOfAuthenticators < 32) {
            this.otpReason = addDevice;
            this.otpMessage = 'Continue to Add device';
            this.showOTPModal = true;
        } else {
            this.cantAddDevice = true;
        }
    }

    successOTPInitiation(){
        this.showOTPModal = false;
        if(this.otpReason === addDevice){
            this.conitueAddDevice();
        }else{
            this.loading = true;
            this.continueToDelete();
        }
    }

    conitueAddDevice() {
        this.openModal = false;
        let cmpTarget = this.openModal;
        if (cmpTarget === false) {
            let cmpTarget = (this.openModal = true);
            cmpTarget?.classList?.add('slds-fade-in-open');
            document.body.style.overflow = 'hidden';
        } else {
            this.openModal = false;
        }
    }

    cancelOTPInitiation(){
        this.showOTPModal = false;
        this.otpReason = '';
        this.otpMessage = '';
    }
}