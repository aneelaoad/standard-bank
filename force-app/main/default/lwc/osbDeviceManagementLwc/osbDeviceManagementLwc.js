import { LightningElement, api, wire } from 'lwc';
import isUserLoggedIn from '@salesforce/apex/OSB_DeviceManagement_CTRL.isUserLoggedIn';
import getDeviceList from '@salesforce/apex/OSB_DeviceManagement_CTRL.getDeviceDetails';
import deleteDevices from '@salesforce/apex/OSB_DeviceManagement_CTRL.deleteDevices';
import { NavigationMixin } from 'lightning/navigation';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import { refreshApex } from '@salesforce/apex';
import flagContact from '@salesforce/apex/OSB_NewDeviceModal_CTRL.flagContact';
const linkedMFA = 'Device Linked to MFA';
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
            .catch((result) => {
                this.userlogged = false;
            });
    }

    handleRemoveAllDevices(event) {
        this.removeAllDevices = false;
        let allDeviceAuthIdList = this.allDeviceAuthIdList;
        if (allDeviceAuthIdList.length > 0) {
            this.removeAllDevices = true;
            this.devicesToDeleteList = allDeviceAuthIdList;
        } else {
            this.removeAllDevices = false;
        }
    }

    handleDeleteAllDevices(event) {
        this.allDevicesRemoved = false;
        let optionSelected = event.detail;
        let devicesToDeleteList = this.devicesToDeleteList;

        if ((optionSelected === 'YES') & (devicesToDeleteList.length > 0)) {
            deleteDevices({ authHandleList: devicesToDeleteList }).then(
                (response) => {
                    let responseList = response;

                    if (responseList[0].statusCodeString === '4000') {
                        window.scrollTo(0, 0);
                        this.loading = true;
                        setTimeout(function () {
                            this.loading = false;
                        }, 3000);
                        this.allDevicesRemoved = true;
                        this.toastMessage =
                            'The devices have been successfully removed. Please wait for the page to reload.';

                        let flagSiteFeature = false;
                        flagContact({
                            flagValue: linkedMFA,
                            addFlag: flagSiteFeature
                        });

                        this.updateMFA();
                    } else {
                        window.scrollTo(0, 0);
                        this.unexpectedError = true;
                    }
                }
            );
        }
        if (optionSelected === 'NO') {
            const selectedEvent = new CustomEvent('closepopupevent', {
                detail: event.target.innerText
            });
            this.dispatchEvent(selectedEvent);
        }
        this.removeAllDevices = false;
    }

    closeToast(event) {
        this.showMessageToast = false;
    }

    handleDeleteDevice(event) {
        event.preventDefault();
        let devicesToDeleteList = event.detail;
        this.deviceRemoved = false;
        let numOfDevices = this.noOfAuthenticators - devicesToDeleteList.length;
        deleteDevices({ authHandleList: devicesToDeleteList }).then(
            (response) => {
                let responseList = response;

                if (responseList[0].statusCodeString === '4000') {
                    window.scrollTo(0, 0);
                    this.loading = true;
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

    handleMFAModal(event) {
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

    handleMFADevice(event) {
        this.deviceUpdate = true;
        this.updateMFA();
    }

    handleAddDevice(event) {
        event.preventDefault();
        let noOfAuthenticators = this.noOfAuthenticators;
        if (noOfAuthenticators < 32) {
            this.openModal = false;
            let cmpTarget = this.openModal;
            if (cmpTarget === false) {
                let cmpTarget = (this.openModal = true);
                cmpTarget?.classList?.add('slds-fade-in-open');
                document.body.style.overflow = 'hidden';
            } else {
                this.openModal = false;
            }
        } else {
            this.cantAddDevice = true;
        }
    }
}