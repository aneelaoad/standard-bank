import { LightningElement, track, wire } from 'lwc';
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";
import getMallSubNavigationItems from "@salesforce/apex/CTRL_MallSubNavigationItems.getMallSubNavigationItems";
import {NavigationMixin} from "lightning/navigation";

export default class MallSubNavigationBar extends LightningElement {
    arrowIcon = sbgIcons + '/TECHNOLOGY/icn_arrow_right.svg';

    @track navigationItems = [];
    @track sortedNavigationItems = [];
    

    @wire(getMallSubNavigationItems)
    wiredSubNavigationItems({ error, data }) {
        if (data) {
            this.navigationItems = data.map(item => ({
                ...item,
                iconFullPath: sbgIcons + item.icon
            }));
            this.filterSolutionPageMainCategories();
        } else if (error) {
            this.navigationItems = undefined;
            console.error('Error fetching navigation items: ', error);
        }

    }

    filterSolutionPageMainCategories(){

        const mainNavs = this.navigationItems.filter((item=>{
            return (item.isMain == true && item.availableInSolutionPage == true);
        }));

        mainNavs.forEach(mainNav => {
            
            const subNavs = this.navigationItems.filter((item=>{
                return ((item.orderNumber > mainNav.orderNumber && item.orderNumber <= mainNav.orderNumber + 9) && (item.isMain == false));
            }));

            this.sortedNavigationItems.push({...mainNav, subNavs: subNavs});

        });

        console.log('@@ Sorted Subnavigations:' + JSON.stringify(this.sortedNavigationItems));
    }


    navigateToInternalPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'our_solutions'
            }
        });
    }

 
}