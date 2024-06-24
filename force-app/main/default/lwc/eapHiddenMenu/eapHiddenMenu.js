import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 
import basePath from "@salesforce/community/basePath";
import getUserInfo from '@salesforce/apex/EAP_CTRL_ProfilePage.getUserInfo';

export default class EapHiddenMenu extends NavigationMixin(LightningElement) {
    @track user = {};

    @wire(getUserInfo)
    wiredUser({ error, data }) {
        if (data) {
            let userData = data.user;
            this.user = {
                Id: userData.Id,
                Name: userData.Name,
                Img: userData.FullPhotoUrl,
                ClientName: data.clientName
            };

        }
    }

    closeMenu() {
        const closeHiddenMenu = new CustomEvent('close', {});
        this.dispatchEvent(closeHiddenMenu);
    }

    openContact() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Profile__c'
            },
            state: {
                openContact: true
            }
        });
    }

    openTC() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Profile__c'
            },
            state: {
                openTermsConditions: true
            }
        });
    }

    get logoutLink() {
        let sitePrefix = basePath.replace(/\/s$/i, "");
        return sitePrefix + "/secur/logout.jsp";
    }

    /* Swipe */
    xDown = null;                                                        
    yDown = null;                                               

    handleTouchStart(evt) {
        const firstTouch = evt.touches[0];
        this.xDown = firstTouch.clientX;                                      
        this.yDown = firstTouch.clientY;                                      
    };                                                

    handleTouchMove(evt) {
        if ( ! this.xDown || ! this.yDown ) {
            return;
        }

        let xUp = evt.touches[0].clientX;                                    
        let yUp = evt.touches[0].clientY;

        let xDiff = this.xDown - xUp;
        let yDiff = this.yDown - yUp;

        if ( Math.abs( xDiff ) > Math.abs( yDiff ) ) {/*most significant*/
            if ( xDiff > 0 ) {
                /* left swipe */
                this.closeMenu();

            } else {
                /* right swipe */
                this.closeMenu();
            }                       
        }

        /* reset values */
        this.xDown = null;
        this.yDown = null;                                             
    }
}