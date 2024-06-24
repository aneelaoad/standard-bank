import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images';
import getQrCodeDetails from '@salesforce/apex/OSB_NewDeviceModal_CTRL.getQrCodeDetails';
import getStatusofRegistration from '@salesforce/apex/OSB_NewDeviceModal_CTRL.getStatusofRegistration';
import flagContact from '@salesforce/apex/OSB_NewDeviceModal_CTRL.flagContact';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
const hideMFA = 'Hide MFA';
const linkedMFA = 'Device Linked to MFA';
export default class OsbNewDeviceModalLwc extends NavigationMixin(
    LightningElement
) {
    phoneConfirmed = OSB_Images + '/phoneConfirmed.png';
    phoneWithSignInMethods = OSB_Images + '/phoneWithSignInMethods.png';
    appStore = OSB_Images + '/appStore.svg';
    googlePlay = OSB_Images + '/googlePlay.svg';
    linkYourDevice = OSB_Images + '/linkYourDevice.png';
    loader = OSB_Images + '/loader.gif';
    qrReload = OSB_Images + '/qrReload.svg';
    AddDeviceTutorial1 = OSB_Images + '/AddDeviceTutorial1.png';
    AddDeviceTutorial2 = OSB_Images + '/AddDeviceTutorial2.png';
    closeIcon = OSB_Images + '/closeIcon.svg';
    TimerStepCirle = false;
    MobiletimerDisplay = false;
    QRresult;
    qrCodeBase64;
    responseStatusCode;
    responseId;
    waitingForAuth = false;
    timeLeft = 180;
    timerCountdown = '3:00';
    TotalintervalId;
    totalProgress = 180;
    actualProgress = 180;
    timerDisplay = false;
    regintervalId;

    @api isAppInstalled = false;
    @api step1 = false;
    @api deviceAuthenticated = false;
    @api showtutorial = false;
    @api isOpen = false;
    @api imageId;
    @api indashboard;
    @api error = false;
    @api isLoading = false;
    @api qrLoading;
    @api isMobile = false;
    @api isNotMobile = false;
    @api selectedNavItem = 'DeviceManagement';
    @api oobStatusHandle;
    @api deviceInfo;
    @api intervalId = 0;
    @api reloadQr = false;
    @api userContactId;

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    connectedCallback() {
        let userAgent = navigator.userAgent || navigator.vendor || window.opera;
        if (userAgent.match(/Android/i) || userAgent.match(/iPhone/i)) {
            this.isMobile = true;
            this.isNotMobile = false;
        }
        this.step1 = true;
        this.isOpen = true;
        this.reloadQr = true;
        this.isNotMobile = true;
    }

    notNow() {
        if (this.indashboard) {
            this.showtutorial = true;
            this.step1 = false;
            this.isOpen = true;
        } else {
            this.isOpen = false;
            document.body.style.overflow = 'auto';
        }
    }

    goToLinkDevice() {
        this.isAppInstalled = true;
        this.step1 = false;
        this.isOpen = true;
        this.reloadQr = false;
        this.deviceAuthenticated = false;
        this.waitingForAuth = false;
        this.TimerStepCirle = false;
        getQrCodeDetails()
            .then((result) => {
                this.QRresult = result;
                let qrArray = [];
                for (var i in this.QRresult) {
                    qrArray.push([i, this.QRresult[i]]);
                }
                for (let j = 0; j < qrArray.length; j++) {
                    if (qrArray[j][0] === 'qrImage') {
                        this.qrCodeBase64 =
                            'data:image/png;base64,' + qrArray[j][1];
                    }
                    if (qrArray[j][0] === 'oobStatusHandle') {
                        this.oobStatusHandle = qrArray[j][1];
                    }
                }
                this.qrLoading = false;
                this.waitingForAuth = false;
                this.startTimer();
                this.handleRegistration();
            })
            .catch((error) => {
                this.error = error;
                clearInterval(parseInt(this.regintervalId));
                this.template
                    .querySelector('c-osb-text-timer-lwc')
                    .handleStopTimer();
                this.error = true;
                this.waitingForAuth = false;
                this.deviceAuthenticated = false;
            });
    }

    startTimer() {
        this.timerDisplay = true;
    }

    handleRegistration() {
        if (!this.reloadQr) {
            let helper = this;
            let intervalTime = 180;
            this.regintervalId = setInterval(function () {
                intervalTime = intervalTime - 3;
                if (intervalTime === 0) {
                    helper.manageRegistrationStatus('-1');
                    clearInterval(parseInt(this.regintervalId));
                    this.qrCodeBase64 = true;
                    this.waitingForAuth = false;
                    this.TimerStepCirle = false;
                    this.timerDisplay = false;
                    this.MobiletimerDisplay = false;
                    this.reloadQr = true;
                }
                helper.makeRegistrationCallout();
            }, 3000);
            this.intervalId = this.regintervalId;
        }
    }

    makeRegistrationCallout() {
        getStatusofRegistration({ oobStatusHandle: this.oobStatusHandle }).then(
            (result) => {
                let respInfo = result;
                let resArray = [];
                for (var i in respInfo) {
                    resArray.push([i, respInfo[i]]);
                }
                for (let j = 0; j < resArray.length; j++) {
                    if (resArray[j][0] === 'responseStatusCode') {
                        this.responseStatusCode = resArray[j][1];
                    }
                    if (resArray[j][0] === 'responseId') {
                        this.responseId = resArray[j][1];
                    }
                    if (resArray[j][0] === 'deviceInfo') {
                        this.deviceInfo = resArray[j][1];
                    }
                }
                if (this.deviceInfo) {
                    this.manageRegistrationStatus(this.responseStatusCode);
                } else {
                    this.manageRegistrationStatus(this.responseStatusCode);
                }
            }
        );
    }

    manageRegistrationStatus(code) {
        if (code === '4004') {
            return '4004';
        } else if (code === '4005') {
            if (!this.TimerStepCirle) {
                this.template
                    .querySelector('c-osb-text-timer-lwc')
                    .handleRestart();
            }
            this.TimerStepCirle = true;
            this.qrLoading = true;
            this.waitingForAuth = true;
            this.MobiletimerDisplay = true;
        } else if (code === '4000') {
            this.isAppInstalled = false;
            this.deviceAuthenticated = true;
            this.waitingForAuth = false;
            clearInterval(parseInt(this.regintervalId));
            this.template
                .querySelector('c-osb-text-timer-lwc')
                .handleStopTimer();
            let flagSiteFeature = true;
            flagContact({
                flagValue: linkedMFA,
                addFlag: flagSiteFeature
            }).then((data) => {
                flagContact({ flagValue: hideMFA, addFlag: flagSiteFeature });
            });

            const mfaEvent = new CustomEvent('mfadeviceregistered', {
                detail: true
            });

            this.dispatchEvent(mfaEvent);
        } else if (
            code === '4401' ||
            code === '4402' ||
            code === '4404' ||
            code === '4407' ||
            code === '4450'
        ) {
            if (this.deviceAuthenticated) {
                clearInterval(parseInt(this.regintervalId));
                this.template
                    .querySelector('c-osb-text-timer-lwc')
                    .handleStopTimer();
            }
            if (code === '4401') {
                this.reloadQr = true;
                clearInterval(parseInt(this.regintervalId));
                this.template
                    .querySelector('c-osb-text-timer-lwc')
                    .handleStopTimer();
            }
            this.isAppInstalled = false;
            this.deviceAuthenticated = false;
            this.waitingForAuth = false;
            this.error = true;
            return;
        } else if (code === '1') {
            return '1';
        }
    }

    goToStep1() {
        if (this.MobiletimerDisplay || this.timerDisplay) {
            this.template
                .querySelector('c-osb-text-timer-lwc')
                .handleStopTimer();
        }
        this.isAppInstalled = false;
        this.showtutorial = false;
        this.step1 = true;
        this.isOpen = true;
        this.reloadQr = true;
    }

    handleCancel() {
        clearInterval(parseInt(this.regintervalId));
        if (this.MobiletimerDisplay || this.timerDisplay) {
            this.template
                .querySelector('c-osb-text-timer-lwc')
                .handleStopTimer();
        }
        if (this.indashboard) {
            this.showtutorial = true;
            this.isAppInstalled = false;
            this.isOpen = true;
            this.step1 = false;
            this.isOpen = true;
            this.reloadQr = false;
            this.deviceAuthenticated = false;
            this.waitingForAuth = false;
            this.TimerStepCirle = false;
        } else {
            this.isOpen = false;
        }
    }

    reload() {
        let userAgent = navigator.userAgent || navigator.vendor || window.opera;
        this.step1 = true;
        this.isOpen = true;
        this.isAppInstalled = false;
        this.error = false;
    }

    goToHome(){        
        let dontShow = this.template.querySelector(`[data-id="dontshow"]`);
        if(dontShow !== null && dontShow.checked === true ){ 
            let flagSiteFeature = true;
            flagContact({ flagValue: hideMFA, addFlag :  flagSiteFeature });
        }
       this.isOpen= false;
        document.body.style.overflow = "auto";
        if(this.indashboard.toLowerCase() === 'false'){
            this.handleModal();
        }else if(this.indashboard.toLowerCase() === 'true'){
            this.handleModal();
        }
    }

    closeErrorScreen() {
        this.isOpen = false;
        this.handleModal();
    }

    handleTimer(event) {
        this.timeLeft = event.detail;
        if (this.timeLeft === 0) {
            clearInterval(parseInt(this.regintervalId));
            this.template
                .querySelector('c-osb-text-timer-lwc')
                .handleStopTimer();
            if (this.MobiletimerDisplay === false) {
                this.qrCodeBase64 = true;
                this.timerDisplay = false;
                this.MobiletimerDisplay = false;
                this.reloadQr = true;
                this.waitingForAuth = false;
                this.TimerStepCirle = false;
            }
        }
    }

    reloadQrCode() {
        this.isAppInstalled = true;
        this.step1 = false;
        this.isOpen = true;
        this.reloadQr = false;
        this.deviceAuthenticated = false;
        this.waitingForAuth = false;
        this.TimerStepCirle = false;
        this.qrCodeBase64 = false;
        getQrCodeDetails()
            .then((result) => {
                this.QRresult = result;
                let qrArray = [];
                for (let i in this.QRresult) {
                    qrArray.push([i, this.QRresult[i]]);
                }

                for (let j = 0; j < qrArray.length; j++) {
                    if (qrArray[j][0] === 'qrImage') {
                        this.qrCodeBase64 =
                            'data:image/png;base64,' + qrArray[j][1];
                    }
                    if (qrArray[j][0] === 'oobStatusHandle') {
                        this.oobStatusHandle = qrArray[j][1];
                    }
                }
                this.qrLoading = false;
                this.waitingForAuth = false;
                this.startTimer();
                this.handleRegistration();
            })
            .catch((error) => {
                this.error = error;
                this.error = true;
                this.waitingForAuth = false;
                this.deviceAuthenticated = false;
            });
    }

    handleModal() {
        this.dispatchEvent(new CustomEvent('updatedeviceregistered'));
    }
}