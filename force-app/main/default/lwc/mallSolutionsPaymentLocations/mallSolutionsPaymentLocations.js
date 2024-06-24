import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import Resources from "@salesforce/resourceUrl/sbgVisualAssets";
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";

export default class MallSolutionsPaymentLocations extends NavigationMixin(LightningElement) {

    locationImage1 = Resources + "/man-with-credit-card.jpg";
    locationImage2 = Resources + "/hand-holding-a-phone.jpg";
    locationImage3 = Resources + "/card-inserted-into-atm.jpg";
    locationImage4 = Resources + "/girl-with-card-and-phone.jpg";

    chevronLeft = sbgIcons + "/NAVIGATION/icn_chevron_left.svg";
    chevronRight = sbgIcons + "/NAVIGATION/icn_chevron_right.svg";

    handleNavigate(event) {
        event.preventDefault();
        const label = event.target.dataset.id;
        switch (label){
            case "internet-banking":
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                    name: "Home"
                    }
                });
            break;
            case "mobile-app":
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                    name: "Home"
                    }
                });
            break;
            case "atm":
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                    name: "Home"
                    }
                });
            break;
            case "cellphone-banking":
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                    name: "Home"
                    }
                });
            break;
            default:
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                    name: "Home"
                    }
                });
        
        }
        
        
       
    }


}