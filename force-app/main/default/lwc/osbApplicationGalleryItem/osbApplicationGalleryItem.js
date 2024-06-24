import { LightningElement, api } from "lwc";
import OSB_Logo from '@salesforce/resourceUrl/OSB_logoBadge';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import getImageURL from "@salesforce/apex/OSB_SolutionCaseImage.getImageURL";
export default class osbApplicationGalleryItem extends LightningElement {
    SBLogo = OSB_Logo;

    @api title;
    @api content;
    @api shortContent;
    @api link;
    @api linkDirect;
    @api linkLabel;
    @api key;
    @api solutionid;
    @api logo;
    @api largelogo;
    @api dashboard;
    @api modalissolution;
    @api iscomingsoon;
    @api solutionsiteurl;
    @api isOnShowcase;
    @api isOpen = false;
    @api applicationowner;
    @api ssoredirecturl;
    @api urlname;
    @api providerid;
    thirdParty = false;
    imageTest;
    LogoSRC;
    solTM = false;
    tileClick;
    tileLinkName;
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
            this.iconImage = this.SBLogo;
        }
        if(this.title === 'AUTHENTIFI'){
            this.solTM = true;
        }else{
            this.solTM = false;
        }

        this.tileClick = this.title + ' tile selected';
        this.tileLinkName = 'Application Gallery | '+this.title+' Clicked';
    }

    createmodalwindow() {
        this.isOpen = true;
    }

    modalCloseHandler() {
        this.isOpen = false
    }


}