import { LightningElement, api, track } from "lwc";
import { setPaginationFlag } from "c/mallPaginationComponent";
import MALL_NEXT_BUTTON_LABEL from "@salesforce/label/c.MALL_NEXT_BUTTON_LABEL";
import MALL_PREV_BUTTON_LABEL from "@salesforce/label/c.MALL_PREV_BUTTON_LABEL";
import IS_GUEST from "@salesforce/user/isGuest";
import { NavigationMixin } from "lightning/navigation";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import benefitsIcons from "@salesforce/resourceUrl/mallBenefits";
import SLIDER_DATA from "@salesforce/resourceUrl/mallBenifitsData";

const TITLE_FIRST_PARAGRAPH = "Why the best way forward is with us";
export default class MallSliderParent extends LightningElement {
    // Simangaliso Start
    titleFirstParagraph = TITLE_FIRST_PARAGRAPH;
    benefitsIconBulb = benefitsIcons+"/mallBenefits/icons/icn_bulb.png";
    benefitsIconScales = benefitsIcons+"/mallBenefits/icons/icn_scales.png";
    benefitsIconDocCert = benefitsIcons+"/mallBenefits/icons/icn_document_certificate.png";
    benefitsIconBoxTrack = benefitsIcons+"/mallBenefits/icons/icn_box_track.png";
    benefitsIconArrowLeft = benefitsIcons+"/mallBenefits/icons/icn_chevron_left.png";
    benefitsIconArrowRight = benefitsIcons+"/mallBenefits/icons/icn_chevron_right.png";

    sliderData =[];
    connectedCallback() {
        fetch(SLIDER_DATA)
            .then((response) => response.json())
            .then((data) => {
                /*console.log(JSON.stringify(data));
                let preparedData = [];
                data.forEach((record) => {
                        let row = {imageURL: benefitsIcons + record.imageURL,
                                   imageAlt: record.imageAlt
                            }
                            preparedData.push(row);
                })*/
                this.sliderData = data;
                console.log(JSON.stringify(this.sliderData));
            }
            
        );
    }
}