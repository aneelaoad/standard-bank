import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import OSB_Images_Two from '@salesforce/resourceUrl/OSB_Images_Two';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbProfileAndDeviceSettingsLwc extends NavigationMixin(LightningElement) {
    ReadMore = OSB_Images_Two + '/ReadMoreArrow.svg';

    selectedNavItem = "DeviceManagement";


    myBreadcrumbs = [
   
        { label: 'Profiles And Settings', name: 'EditProfile', id: 'ProfilesAndSettings' },
        { label: 'Edit Profile', name: 'EditProfile', id: 'editProfile' },
        { label: 'Device Management', name: 'DeviceManagement', id: 'DeviceManagement' },
    ];

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    handleNavigateTo(event) {  
        event.preventDefault();    
        const selectedItem = event.currentTarget.dataset.tabName;

        this.selectedNavItem = selectedItem;

        
        if (selectedItem === "Home") {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                },
            });
        }


    }


    get selectedNavItemEditProfile() {
        return this.selectedNavItem === "EditProfile";
    }

    get selectedNavItemDeviceManagement() {
        return this.selectedNavItem === "DeviceManagement";
    }

    notifyAnalytics(tabName) {
        this.template.querySelector("c-message-service").publish({
            key: "OSBNavigationEvent",

            value: {
                "pageUrl": tabName,
                "isSinglePageApp": true
            }
        });
    }

    setTab(tabName) {
        this.selectedNavItem = tabName;
    }



 

}