import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import icons from "@salesforce/resourceUrl/sbgIcons";

export default class MallOurSolutionsProductSelection extends NavigationMixin(LightningElement) {
    arrowSolidDown = icons + '/NAVIGATION/icn_arrow_solid_down.svg';
    handleNavigate(event) {
        event.preventDefault();
        const label = event.target.dataset.id;
        if (label == "open-an-account") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
        else if (label == "receive-payments") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
        else if (label == "borrow-money") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
        else if (label == "save-and-invest") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
       else  if (label == "insure-my-business") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
        else{
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
       
    }

    

}