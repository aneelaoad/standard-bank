import { LightningElement, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import notifyIDV from "@salesforce/apex/AOB_CTRL_WFR.callNotifyIDV";
import cancelIDV from "@salesforce/apex/AOB_CTRL_WFR.cancelIDV";
import orchestrateIDV from "@salesforce/apex/AOB_CTRL_WFR.getWFRUrl";
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import { NavigationMixin } from "lightning/navigation";
import getWFRDetails from "@salesforce/apex/AOB_CTRL_WFR.getWFRDetails";
import callIDVStatus from "@salesforce/apex/AOB_CTRL_WFR.callGetIDVStatus";
import getWFRRetryIndicator from "@salesforce/apex/AOB_CTRL_WFR.getWFRRetryIndicator";
import getWFRStatusIdNumberFromVerificationByAppId from "@salesforce/apex/AOB_CTRL_WFR.getWFRStatusIdNumberFromVerificationByAppId";
import wfrRetry from "@salesforce/apex/AOB_CTRL_WFR.incrementWfrRetryReturn";
import setWFRStatus from "@salesforce/apex/AOB_CTRL_WFR.setWFRStatus";
import setApplicationStep from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationStep';
import { getErrorMessage } from "c/aob_comp_utils";
import { showToast } from "c/aob_comp_utils";
import { FlowNavigationNextEvent } from "lightning/flowSupport";
import AOB_ThemeOverrides from "@salesforce/resourceUrl/AOB_ThemeOverrides";
import PBP_ThemeOverrides from "@salesforce/resourceUrl/PBP_ThemeOverrides";
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
import getApplicantDataForAdobe from '@salesforce/apex/AOB_CTRL_FormCreator.getApplicantDataForAdobe';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import fetchRetryCounter from "@salesforce/apex/AOB_CTRL_WFR.fetchRetryCounter";

const WFR_VERIFICATION_PASSED = "Verification Passed";
const WFR_VERIFICATION_FAILED = "Verification Failed";
const WFR_IN_PROGRESS = "In Progress";
const WFR_COMPLETE = "Completed by customer";
const SUCCESS = "SUCCESS";
const FAILED = "FAILED";
const SESSIONTIMEOUT = "Session expired";
const CANCELLED = "CANCELLED";

export default class Aob_comp_wfrIdentifii extends NavigationMixin(LightningElement) {

    @api availableActions = [];
    @api teams = ["Self Assisted"];
    label = {};
    blueInfoIcon = AOB_ThemeOverrides + "/assets/images/info_icon_blue.svg";
    tickImage = AOB_ThemeOverrides + "/assets/images/tick_image.svg";
    Camera = AOB_ThemeOverrides  + '/assets/images/Camera.png';
    passport = AOB_ThemeOverrides  + '/assets/images/passport.png';
    info_icon = AOB_ThemeOverrides  + '/assets/images/info_icon.svg'
    @api applicationId;
    @api pageName;
    @api navigate;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api productName;
    showCallMeBackConfirmedPopup;
    idNumber;
    correlationId;
    adobeformName;
    subTitleCombo;
    showContactBackPopUp;
    showErrorPopup;
    failing;
    isLoading;
    errorContent;
    retry;
    wfrFailReason;
    wfrStatusUpdated;
    wiredRecords;
    VerificationCount;
    /* Params from Url */
    message = null;
    status = null;
    isreloaded = false;
    cameraEnabled = true;
    //error check while loading styles from AOB_themeOverrides Resource
    loadAobStyle;
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
    showVerificationUnavailablePopup;
   
    showPassedWfrScreen;
    showFailedWfrScreen;
    showSessionTimeOutWfrScreen;
    showRetriesExceededScreen;
    showCancelledWfrScreen;
    retryIDV;
    wfrStatus;
    wfrRetries;
    adobePageTag;
    adobeDataTextContinue;
    adobeDataScopeApp;
    //Adobe Tagging 
    isEventFired;
    siteErrorCode;
    application = {
        applicationProduct: " ",
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "Application: ",
        applicationStep: "step 17",
        applicationStart: true,
        applicationComplete: false,
    }
    userInfo = {
        bpguid: "",
        encryptedUsername: ""
    }
    /*
     *@desc  Initiation method
     *@desc  gets the customers Id  number to be sent in API calls
     */
    constructor() {
        super();
        this.isMobileDevice = window.matchMedia("only screen and (max-width: 576px)").matches;
        this.isTabDevice = window.matchMedia("only screen and (min-width: 812px) and (max-width:920px").matches;
    }

    connectedCallback() {
        Promise.all([
            loadScript(this, FireAdobeEvents),
            loadStyle(this, PBP_ThemeOverrides + '/style.css')
        ]).then(() => {
        });
        getApplicantDataForAdobe({
            'applicationId': this.applicationId
        }).then(result => {
            let Response = JSON.parse(result);
            this.userInfo.encryptedUsername = Response['customerEmail'];
            this.userInfo.bpguid = Response['customerGUID'];
            this.userInfo.bpguid = this.userInfo.bpguid.split('-').join('');
            this.userInfo.bpguid = this.userInfo.bpguid.toUpperCase();
            window.fireUserInfoEvent(this, this.userInfo);
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.technicalerror = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorMessage);
        });
        this.productName = this.productName.toLowerCase();
        this.adobePageTag = 'business:' + 'products and services:bank with us:business bank accounts: ' + this.productName + " account origination  " + this.adobeDataScope + " almost done";
        this.adobeDataScopeApp = this.productName + ' application';
        this.adobeDataTextContinue = 'you \'re almost done |  continue button click';
        window.fireScreenLoadEvent(this, this.adobePageTag);
        this.application.applicationID = this.applicationId;
        this.application.applicationName = this.application.applicationName + this.productName + ' business account';
        this.application.applicationProduct = this.productName + ' business account';
        window.fireFormStartEvent(this, this.application);
        this.subTitleCombo = this.label.AOB_WFR_SubRedirect1 + " " + this.label.AOB_WFR_SubRedirect2;
        setApplicationStep({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
            this.failing = false;
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorMessage);
        });
        this.isLoading = true;
        getWFRStatusIdNumberFromVerificationByAppId({
            applicationId: this.applicationId,
            getIdNumber: true
        }).then((result) => {
            if (result) {
                this.idNumber = result.aob_identityNumber__c;
                this.wfrStatus = result.AOB_TECH_WFRStatus__c;
                this.wfrRetries = result.AOB_WFR_Retry_Number__c;
                this.processWFRStatus();
                this.isLoading = false;
            }
        }).catch((error) => {
            this.isLoading = false;
            this.failing = true;
            this.errorContent = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorContent);

        });
    }
      handleResultChange(event) {
        this.label = event.detail;
    }

    /*
     *@desc  gets current page reference url state params
     */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    /*
     *@desc  gets configured retry counter set by admin
     */
    @wire(fetchRetryCounter)
    wiredRecs(value) {
        this.wiredRecords = value.data;
    }

    /*
     *@desc  checks media device and shows camera not available popup
    */
    @wire(wfrRetry, { applicationId: '$applicationId' })
    wiredCameraCheck(value) {
        this.VerificationCount = value.data;
        if (this.VerificationCount === 0) {
            try {
                navigator.mediaDevices.getUserMedia({ video: true, audio: false })
                    .then(result => {
                        this.cameraEnabled = true;
                    })
                    .catch((err) => {
                        this.cameraEnabled = false;
                    });
            } catch (error) {
                this.isLoading = false;
                window.fireErrorEvent(this, error);

            }
        }
    }


    /*
     *@desc  sets js variables from url params
     */
    setParametersBasedOnUrl() {
        this.message = this.urlStateParameters.message || null;
        this.status = this.urlStateParameters.status || null;
        if (this.status) {
            this.showPopupBasedOnStatus();
            this.removeUrlParams();
        }
    }

    /*
     *@desc  remove url params
     */
    removeUrlParams() {
        var currURL = window.location.href;
        var beforeQueryString = currURL.split("?")[0];
        window.history.pushState('object', document.title, beforeQueryString);
    }

    /*
     *@desc  shows the right popup based on url param value
     */
    showPopupBasedOnStatus() {
        switch (this.status) {
            case SUCCESS:
                this.callnotifyIDV();
                break;
            case FAILED:
                this.updateWFRStatus(this.status);
                if (this.message == SESSIONTIMEOUT) {
                    this.isLoading = false;
                    this.showSessionTimeOutWfrScreen = true;
                    this.showCancelledWfrScreen = false;
                    this.showFailedWfrScreen = false;
                    this.siteErrorCode = 'business error | ' + this.message;
                    window.fireErrorEvent(this, this.siteErrorCode);
                } else {
                    this.isLoading = false;
                    this.showFailedWfrScreen = true;
                    this.retryIDV = true;
                    this.showCancelledWfrScreen = false;
                    this.siteErrorCode = 'business error | ' + this.message;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }
                break;
            case CANCELLED:
                this.updateWFRStatus(this.status);
                this.isLoading = false;
                this.showCancelledWfrScreen = true;
                this.siteErrorCode = 'business error | ' + this.status;
                window.fireErrorEvent(this, this.siteErrorCode);
        }
    }

    handleCloseCMPopup(event) {
        this.cameraEnabled = true;
        this.siteErrorCode = 'Client side | camera not found';
        window.fireErrorEvent(this, this.siteErrorCode);
    }

    /*
    *@desc  In case of Errors, calls API to create a lead
    */
    createLead(leadReason) {
        createExternalLead({
            applicationId: this.applicationId,
            leadReason: leadReason
        }).then((result) => {
            this.isLoading = false;
        }).catch((error) => {
            this.isLoading = false;
            this.showVerificationUnavailablePopup = true;
            this.siteErrorCode = 'business error | verification unavailable';
            window.fireErrorEvent(this, this.siteErrorCode);
        });
    }

    /*
     *@desc  Handler to close Error popup
     */
    handleClosePopup() {
        this.showErrorPopup = false;
    }

    /*
     *@desc  Handler to show call me back popup
     */
    showCallmeBackPopup() {
        let leadReason = 'Customer clicked call me back';
        this.createLead(leadReason);
        this.showCallMeBackConfirmedPopup = true;
    }

    /*
     *@desc Notifies BPM of successful liveness capture
     *      First check to see if BPM has not already responded with an outcome (wfr_status -> Verification Success/Failed)
     *      Also wait for 5min before calling this function, because BPM might have responses with an outome already
     *      If not, then trigger notifyIDV to extend the 45minute wait time for iidentifii
     */
    callnotifyIDV() {
        this.isLoading = true;
        getWFRDetails({
            applicationId: this.applicationId
        }).then((result) => {
            this.wfrStatus = result.AOB_WFR_Status__c;
            if (this.wfrStatus == WFR_VERIFICATION_PASSED || this.wfrStatus == WFR_VERIFICATION_FAILED) {
                this.processWFRStatus();
            }
            this.correlationId = result.Correlation_ID__c;
            notifyIDV({
                applicationId: this.applicationId,
                correlationId: this.correlationId
            }).then((result) => {
                if ((result.statusCode = 200)) {
                    if (this.availableActions.find(action => action === this.constants.NEXT)) {
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
                    }
                } else {
                    this.showFailedWfrScreen = true;
                    this.retryIDV = false;
                    this.showCancelledWfrScreen = false;
                    window.fireErrorEvent(this, result);

                }
            });
        }).catch((error) => {
            this.failing = true;
            this.errorContent = getErrorMessage.call(this, error);
            window.fireErrorCodeEvent(this, this.errorContent);
        });
    }

    /*
     *@desc  In case customer has an existing IDV session, gets its correlation Id and cancels it
     */
    getIDVStatus() {
        callIDVStatus({
            idNumber: this.idNumber,
            applicationId: this.applicationId
        })
            .then((result) => {
                this.correlationId = result.onlineIdVerificationGetStatusRs.correlationId;
                this.cancelExistingIDVProcess();
            })
            .catch((error) => {
                this.showVerificationUnavailablePopup = true;
                this.siteErrorCode = 'business error | verification unavailable';
                window.fireErrorEvent(this, this.siteErrorCode);
            });
    }

    /*
     *@desc  Step 1 of the process, returns unique Id to start the IDV process (SFP-9120)
     */
    redirectToIdentifii(event) {
        this.cameraEnabled = true;
        if (event) window.fireButtonClickEvent(this, event);
        this.isLoading = true;
        orchestrateIDV({
            idNumber: this.idNumber,
            clientReference: "",
            applicationId: this.applicationId
        }).then((result) => {
            this.WFRurl = result;
            if (result !== "Error" && result !== "Error409") {
                this.correlationId = result.correlationId;
                window.open(this.WFRurl, "_self");
            } else if (result == "Error409") {
                this.getIDVStatus();
            } else if (result == "Error") {
                this.isLoading = false;
                this.showVerificationUnavailablePopup = true;
                this.siteErrorCode = 'business error | verification unavailable';
                window.fireErrorEvent(this, this.siteErrorCode);
            }
        }).catch((error) => {
            this.isLoading = false;
            this.showVerificationUnavailablePopup = true;
            this.siteErrorCode = 'business error | verification unavailable';
            window.fireErrorEvent(this, this.siteErrorCode);
        });

    }

    /*
     *@desc  if there is an existing process, calls notifyIdv API to cancel it to allow customer to start over
     */
    cancelExistingIDVProcess() {
        cancelIDV({
            correlationId: this.correlationId,
            applicationId: this.applicationId
        })
            .then((result) => {
                this.redirectToIdentifii();
            })
            .catch((error) => {
                this.failing = true;
                this.errorContent = getErrorMessage.call(this, error);
                window.fireErrorEvent(this, this.errorContent);
            });
    }

    /**
     * @description process unsuccessful WFR
     */
    handleRetry() {
        this.isLoading = true;
        wfrRetry({
            applicationId: this.applicationId
        }).then((result) => {
            var retryNumCount = result;
            if (retryNumCount > this.wiredRecords) {
                this.isLoading = false;
                this.showRetriesExceededScreen = true;
                this.showCancelledWfrScreen = false;
                this.siteErrorCode = 'business error | verification Retries exceeded';
                window.fireErrorEvent(this, this.siteErrorCode);
            } else {
                this.showVerificationUnavailablePopup = false;
                this.retry = true;
                this.isLoading = true;
                this.redirectToIdentifii();
            }
        }).catch((error) => {
            this.failing = true;
            showToast.call(this, error);
        });
    }

    /**
    * @description based on the WFR Status on the Application, execute next steps
    */
    processWFRStatus() {
        switch (this.wfrStatus) {
            case WFR_VERIFICATION_PASSED:
                this.isLoading = false;
                this.wfrStatusUpdated = true;
                break;
            case WFR_COMPLETE:
                this.isLoading = false;
                break;
            case WFR_VERIFICATION_FAILED:
                this.isLoading = false;
                this.showFailedWfrScreen = true;
                this.wfrStatusUpdated = true;
                this.siteErrorCode = 'business error | verification failed';
                window.fireErrorEvent(this, this.siteErrorCode);
                getWFRRetryIndicator({
                    applicationId: this.applicationId
                }).then((result) => {
                    if (result) {
                        this.retryIDV = result;
                    } else {
                        this.createLead(WFR_VERIFICATION_FAILED);
                    }
                }).catch((error) => {
                    this.failing = true;
                    this.errorContent = getErrorMessage.call(this, error);
                    window.fireErrorEvent(this, this.errorContent);
                });
                break;
            case WFR_IN_PROGRESS:
                break;
        }
    }

    /**
     * @description updates the WFR Status on the Application
     */
    updateWFRStatus(wfrStatusNew) {
        setWFRStatus({
            applicationId: this.applicationId,
            wfrStatus: wfrStatusNew
        }).then((result) => {
        }).catch((error) => {
            this.failing = true;
            showToast.call(this, error);
            window.fireErrorEvent(this, error);

        });
    }
}