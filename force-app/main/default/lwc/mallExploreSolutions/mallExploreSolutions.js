import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";

export default class MallExploreSolutions extends NavigationMixin(LightningElement) {
    bankIcon = sbgIcons + "/BUILDINGS/icn_branch.svg";
    borrowIcon = sbgIcons + "/MONEY/icn_card_hand.svg";
    growIcon = sbgIcons + "/DOCUMENTS/icn_document_tax.svg";
    insureIcon = sbgIcons + "/BUILDINGS/icn_building.svg";
    chevronLeft = sbgIcons + "/NAVIGATION/icn_chevron_left.svg";
    chevronRight = sbgIcons + "/NAVIGATION/icn_chevron_right.svg";

    handleNavigate(event) {
        event.preventDefault();
        const label = event.target.dataset.id;
        if (label == "bank") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
        else if (label == "borrow") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
        else if (label == "grow") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Home"
                }
            });
        }
        else if (label == "insure") {
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