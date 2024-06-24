import {
    LightningElement
} from 'lwc';
import AGGR from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import lt_arrow from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import rt_arrow from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import CreditCardimg from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import SmallBusinessimg from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import owlcarousel from '@salesforce/resourceUrl/owlcarousel';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import offer from '@salesforce/label/c.PBP_ZA_ProductScreen_We';
import ProductScreen from '@salesforce/label/c.PBP_ZA_ProductScreen_Criedt';
import creditcard from '@salesforce/label/c.PBP_ZA_ProductScreen_Criedt_Cards';
import smallBusiness from '@salesforce/label/c.PBP_ZA_ProductScreen_Small_Business'
import weprotect from '@salesforce/label/c.PBP_ZA_ProductScreen_We_Protect';
import tellme from '@salesforce/label/c.PBP_ZA_TellMeMore';
import StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';


export default class Pbp_comp_product_business_we_also_offer extends LightningElement {

    logo2 = AGGR + '/assets/images/MicrosoftTeams-image (1).png';
    logo1 = AGGR + '/assets/images/MicrosoftTeams-image.png';
    LT_ARROW = lt_arrow + '/assets/images/lt-arrow.svg';
    RT_ARROW = rt_arrow + '/assets/images/rt-arrow.svg';
    creditcardimg = CreditCardimg + '/assets/images/SB_Business_Overdraft.png.png';
    smallbusinessimg = SmallBusinessimg + '/assets/images/SB_SnapScan_for_business.png.jpg';
    initialRender = false;
    label = {
        offer,
        ProductScreen,
        creditcard,
        smallBusiness,
        weprotect,
        tellme
    }
    isEventFired;
    adobePageTag = {
        pageName: "business:Home: Our Products & & Services: Bank with us: Business Bank Account: see all accounts ",
        dataId: "link_content",
        dataIntent: "informationall",
        dataScope: "product card",
        applyButtonText: "mymobiz business account |apply online button click",
        tellmemoreButtonText: "mymobiz business account | tell me more button click",
        siteErrorCode: "",
        application: {
            applicationProduct: "Business banking Account",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Business banking Account",
            applicationStep: "",
            applicationStart: true,
            applicationComplete: false,
        },

    };
    TellMeMoreLinkclickcreditcard(event) {
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/company-cards/our-cards', "_blank")


    }
    TellMeMoreLinkclickweprotect(event) {
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + '/southafrica/business/products-and-services/insure-what-matters/small-business-insurance', "_blank")

    }

    connectedCallback() {
        if (this.initialRender) {
            return;
        }
        this.initialRender = true;
        loadScript(this, owlcarousel + '/jquery.min.js')
            .then(e => {
                loadStyle(this, owlcarousel + '/owl.carousel.min.css');
                loadStyle(this, owlcarousel + '/owl.theme.default.min.css');
                loadScript(this, owlcarousel + '/owl.carousel.min.js')
                    .then(() => {
                        const carousel = this.template.querySelector('div[class="owl-carousel owl-theme offering-owl"]');
                        window.$(carousel).owlCarousel({
                            autoplay: 9000,
                            loop: false,
                            margin: 20,
                            nav: false,
                            navText: [
                                "<i class='fa fa-caret-left'></i>",
                                "<i class='fa fa-caret-right'></i>"
                            ],
                            dots: true,
                            autoHeight: false,
                            lazyLoad: false,
                            center: false,
                            responsive: {
                                768: {
                                    items: 2,
                                },
                                320: {
                                    items: 1,
                                }
                            }
                        })
                    })
            })
    }

}