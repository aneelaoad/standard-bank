import {
    LightningElement
} from 'lwc';
import pbpTheme from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import owlcarousel from '@salesforce/resourceUrl/owlcarousel';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import offer from '@salesforce/label/c.PBP_ZA_ProductScreen_We';
import businessloans from '@salesforce/label/c.PBP_ZA_ProductScreen_Business_Loans';
import lookingtorise from '@salesforce/label/c.PBP_ZA_LookingToRise';
import vehicle from '@salesforce/label/c.PBP_ZA_ProductScreen_Vehicle'
import needadelivery from '@salesforce/label/c.PBP_ZA_NeedADelivery';
import tellme from '@salesforce/label/c.PBP_ZA_TellMeMore';
import StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';

export default class Pbp_comp_product_business_we_also_offer extends LightningElement {
    isEventFired;
    adobePageTag = {
        pageName: "business :Product and services: Bank With us: mymobiz business account",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: " Mymobiz Business Account",
        cancelButtonText: "mymobiz business account | Business loans |  tell me more button click",
        continueButtonText: "mymobiz business account | Vehicle and asset finance | tell me more button click",

        siteErrorCode: "",
        application: {
            applicationProduct: "Product Business Detail",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Product Business Detail",
            applicationStep: "",
            applicationStart: true,
            applicationComplete: false,
        },
    };

    LT_ARROW = pbpTheme + '/assets/images/lt-arrow.svg';
    RT_ARROW = pbpTheme + '/assets/images/rt-arrow.svg';
    creditcardimg = pbpTheme + '/assets/images/SB_Business_loans.jpg.jpg';
    smallbusinessimg = pbpTheme + '/assets/images/SB_Vehicle_and_asset finance.jpg.jpg';
    initialRender = false;

    label = {
        offer,
        businessloans,
        lookingtorise,
        vehicle,
        needadelivery,
        tellme
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
    businessloans(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl +'/southafrica/business/products-and-services/borrow-for-your-needs',StandardBankUrl)

    }
    vehiclefinance(event){
        window.fireButtonClickEvent(this, event); 
        window.open(StandardBankUrl +'/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance',StandardBankUrl)
    }
}