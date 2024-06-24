import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import OSB_Logo from '@salesforce/resourceUrl/OSB_logoBadge';
import {
    interactionClick,
    addAnalyticsInteractions
} from 'c/osbAdobeAnalyticsWrapperLwc';
import getImageURL from '@salesforce/apex/OSB_SolutionCaseImage.getImageURL';
const RequiresMFA = 'Requires MFA';
const SupportShortcut = 'Support Shortcuts';
export default class OsbMyApplicationsTile extends NavigationMixin(
    LightningElement
) {
    SBlogo = OSB_Logo;
    deleteValue;
    ssotitleValue;
    mfarequiredtileValue;
    thirdParty = false;
    solTM = false;
    disabled = false;
    deviceNotRegistered = false;
    mfaRequired = false;
    deviceLinked;
    requiresmfa;
    showPopUp = false;

    @api registeredapps = [];
    @api multiple = false;
    @api title;
    @api logo;
    @api mediumlogo;
    @api url;
    @api solutionid;
    @api empty = false;
    @api applicationowner;
    @api ssoredirecturl;
    @api hasdevices;
    @api valuereceived;
    @api featuremanagement;
    iconImage;

    renderedCallback() {
        addAnalyticsInteractions(this.template);
        if (this.applicationowner === '3rd Party') {
            this.thirdParty = true;
            let imageUrl = this.logo;
            getImageURL({ url: imageUrl })
                .then((data) => {
                    if (data) {
                        this.iconImage = data;
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
        } else {
            this.thirdParty = false;
        }
        if (this.title === 'AUTHENTIFI') {
            this.solTM = true;
        } else {
            this.solTM = false;
        }

        if (this.featuremanagement) {
            if (this.featuremanagement.includes(RequiresMFA)) {
                this.requiresmfa = true;
            } else {
                this.requiresmfa = false;
            }
        }

        this.deleteValue =
            'My Applications | ' + this.title + '| application delete item';
        this.ssotitleValue = 'My Applications | ' + this.title + '  tile ';
        this.mfarequiredtileValue =
            'My Applications | ' + this.title + ' mfa required tile click';
    }

    goToRedirect(event) {
        let tileClassList = event.target.classList.value;
        let boolClassList = tileClassList.includes('deleteIcon');
        if (!boolClassList) {
            window.open(this.ssoredirecturl);
            this.publishToAdobeClick(
                this.ssotitleValue,
                'My Applications',
                'navigational'
            );
        } else {
            if (!this.featuremanagement || !this.featuremanagement.includes(SupportShortcut)) {
                this.removeSolutionAsFavourite();
            } else {
                this.showPopUp = true;
            }
        }
    }

    removeSolutionAsFavourite() {
        this.disabled = true;
        const passEvent = new CustomEvent('appsolutionid', {
            detail: {
                solutionid: this.solutionid
            }
        });
        this.dispatchEvent(passEvent);
    }

    stepUpPerformance(event) {
        let tileClassList = event.target.classList.value;
        let boolClassList = tileClassList.includes('deleteIcon');
        if (!boolClassList) {
            if (!this.hasdevices) {
                this.deviceNotRegistered = true;
            }
        } else {
            if (!this.featuremanagement || !this.featuremanagement.includes(SupportShortcut)) {
                this.removeSolutionAsFavourite();
            } else {
                this.showPopUp = true;
            }
        }
    }

    handleDeviceRegisteration() {
        this.deviceNotRegistered = false;
    }

    handleMFAUpdate(event) {
        this.hasdevices = event.detail;
        const mfaEvent = new CustomEvent('devicemfarefresh', {
            detail: this.hasdevices
        });
        this.dispatchEvent(mfaEvent);
    }

    @api
    handleDeviceUpdateforAll(deviceValue) {
        this.hasdevices = deviceValue;
    }

    publishToAdobeClick(title, scope, intent) {
        let eventValues = {
            name: title,
            intent: intent,
            scope: scope
        };
        interactionClick(eventValues);
    }

    handleCloseEvent(event) {
        this.showPopUp = false;
        if (event.detail === 'YES') {
            const passEvent = new CustomEvent('appsolutionid', {
                detail: {
                    solutionid: this.solutionid,
                    removeShortcuts: true
                }
            });
            this.dispatchEvent(passEvent);
            this.showPopUp = false;
        } else {
            this.showPopUp = false;
        }
    }
}