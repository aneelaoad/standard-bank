import { LightningElement, api } from 'lwc';
import getImageURL from '@salesforce/apex/OSB_SolutionCaseImage.getImageURL';
import OSB_Logo from '@salesforce/resourceUrl/OSB_logoBadge';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbShortCutCard extends LightningElement {
    @api solutionid;
    @api title;
    @api applicationowner;
    @api image;
    @api isshortcut;
    @api shortcutname;
    @api shortcutcategory;
    @api shortcuturl;
    @api addbuttontype;
    buttonDisable;
    @api
    get disableButton() {
        return this.buttonDisable;
    }

    set disableButton(value) {
        this.buttonDisable = value;
    }

    categoryAvailable;

    SBlogo = OSB_Logo;
    thirdParty;
    iconImage;
    error;
    solTM;
    solutionTile = true;
    shortcutTile = false;
    addButton = true;
    shortcutCardValue;
    shortcutCardId;

    renderedCallback() {
        addAnalyticsInteractions(this.template);
        if (!this.isshortcut) {
            if (this.applicationowner === '3rd Party') {
                this.thirdParty = true;
                let imageUrl = this.image;
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
            this.shortcutCardValue = 'Manage Shortcuts| ' + this.title + ' shortcut card clicked';
            this.shortcutCardId = 'nav_manage_' + this.title + '_shortcuts';
        }
        
        if (this.shortcutcategory) {
            this.categoryAvailable = true;
        } else {
            this.categoryAvailable = false;
        }
    }

    selectedSolution() {
        const solution = new CustomEvent('chosensolution', {
            detail: {
                title: this.title,
                id: this.solutionid,
                icon: this.iconImage
            }
        });

        this.dispatchEvent(solution);
    }

    addShortcut() {
        const shortcut = new CustomEvent('addshortcut', {
            detail: {
                name: this.shortcutname,
                shortcutsolutionid: this.solutionid,
                shortcutredirecturl: this.shortcuturl
            }
        });

        this.dispatchEvent(shortcut);
        this.addbuttontype = false;
    }

    removeShortcut() {
        const shortcut = new CustomEvent('removeshortcut', {
            detail: {
                name: this.shortcutname,
                shortcutsolutionid: this.solutionid,
                shortcutredirecturl: this.shortcuturl
            }
        });

        this.dispatchEvent(shortcut);
        this.addbuttontype = true;
    }
}