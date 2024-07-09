import { LightningElement } from 'lwc';
import icons from "@salesforce/resourceUrl/sbgIcons";
import { NavigationMixin } from "lightning/navigation";

export default class MallFAQSection extends NavigationMixin(LightningElement) {
    chevron = icons + "/NAVIGATION/icn_chevron_down.svg";
    // Fetch all the details element.
    /*details;
    renderedCallback(){
        this.details = this.template.querySelectorAll("tab-content");
    }
    handleDetails(event){
        console.log(details);
        event.preventDefault();
        //console.log(this.template.getElementsByClassName('tab-content'));
        if (event.currentTarget.open == true){
            console.log("open")
        }
        else if (event.currentTarget.open == false){
            console.log("closed");
            
            details.forEach((detail) => {
                detail.open = false;
            });
        }
    }
*/
    handleNavigate(event) {
        event.preventDefault();
        const label = event.target.dataset.id;
        if (label == "view-all") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "FAQ__c"
                }
            });
        }
        else if (label == "sign-up") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Sign_Up__c"
                }
            });
        }
        else if (label == "mall-shops") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                name: "Our_Solutions__c"
                }
            });
        }
    }
}