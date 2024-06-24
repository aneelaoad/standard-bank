import {
    LightningElement
} from "lwc";
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import owlcarousel from '@salesforce/resourceUrl/owlcarousel';
import trendsinsights from '@salesforce/label/c.PBP_ZA_TrendsandInsights';
import starting from '@salesforce/label/c.PBP_ZA_Starting';
import getpractical from '@salesforce/label/c.PBP_ZA_GetPractical';
import yourguide from '@salesforce/label/c.PBP_ZA_YourGuide';
import importance from '@salesforce/label/c.PBP_ZA_Importance';
import succesful from '@salesforce/label/c.PBP_ZA_Succesful';
import managing from '@salesforce/label/c.PBP_ZA_ManagingBusiness';
import getexpert from '@salesforce/label/c.PBP_ZA_GetExpert';
import greatleadership from '@salesforce/label/c.PBP_ZA_GreatLeadership';
import marketingtips from '@salesforce/label/c.PBP_ZA_MarketingTips';
import smalltips from '@salesforce/label/c.PBP_ZA_SmallTips';
import growing from '@salesforce/label/c.PBP_ZA_Growing';
import gettips from '@salesforce/label/c.PBP_ZA_GetTips';
import howtoprepare from '@salesforce/label/c.PBP_ZA_HowToPrepare';
import wayswhy from '@salesforce/label/c.PBP_ZA_WaysWhy';
import keepyourbusiness from '@salesforce/label/c.PBP_ZA_KeepYourBusiness';
import standardbankurl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
export default class Pbp_comp_product_business_trends_insights extends LightningElement {
    initialRender = false;
    label = {
        trendsinsights,
        starting,
        getpractical,
        yourguide,
        importance,
        succesful,
        managing,
        getexpert,
        greatleadership,
        marketingtips,
        smalltips,
        growing,
        gettips,
        howtoprepare,
        wayswhy,
        keepyourbusiness,
        standardbankurl
    }
    isEventFired;
    adobePageTag = {

        dataId: "link_content",
        dataIntent: "content links",
        dataScopestarting: starting,
        dataScopemanaging: managing,
        dataScopegrowing: growing,
        yourguidelink: yourguide +" link click",
        importancelink: importance +" link click",
        succesfullink: succesful +" link click",
        greatleadershiplink: greatleadership +" link click",
        marketingtipslink: marketingtips +" link click",
        smalltipslink: smalltips +" link click",
        howtopreparelink: howtoprepare +" link click",
        wayswhylink: wayswhy +" link click",
        keepyourbusinesslink: keepyourbusiness +" link click",
        seemorelink:"see more link click",
    };

    yourguideurl = standardbankurl + '/southafrica/business/bizconnect/help-me-start-my-business/articles/your-guide-to-business-funding';
    importanceurl = standardbankurl + '/southafrica/business/bizconnect/help-me-start-my-business/articles/the-importance-of-targeting-the-right-market';
    succesfulurl = standardbankurl + '/southafrica/business/bizconnect/help-me-start-my-business/articles/successful-start-up-founders-offer-techniques-to-get-your-mindset-right';
    greatleadershipurl = standardbankurl + '/southafrica/business/bizconnect/help-me-manage-my-business/articles/great-leadership-starts-with-serving-your-people';
    marketingtipsurl = standardbankurl + '/southafrica/business/bizconnect/help-me-manage-my-business/guides/5-marketing-tips-for-small-businesses';
    smalltipsurl = standardbankurl + '/southafrica/business/bizconnect/help-me-manage-my-business/guides/smart-tips-to-boost-your-sales-strategies-in-a-challenging-economy';
    howtoprepareurl = standardbankurl + '/southafrica/business/bizconnect/help-me-grow-my-business/articles/how-to-prepare-your-application-to-get-a-business-loan';
    wayswhyurl = standardbankurl + '/southafrica/business/bizconnect/help-me-grow-my-business/articles/3-ways-and-reasons-why-you-should-be-networking-for-business-growth';
    keepyourbusinessurl = standardbankurl + '/southafrica/business/bizconnect/help-me-grow-my-business/articles/keep-your-business-growing-through-innovative-thinking';
    growmybusinessurl = standardbankurl + '/southafrica/business/bizconnect/help-me-grow-my-business';
    managemybusinessurl = standardbankurl + '/southafrica/business/bizconnect/help-me-manage-my-business';
    startmybusinessurl = standardbankurl + '/southafrica/business/bizconnect/help-me-start-my-business';
    callingadobeevent(event){
        window.fireButtonClickEvent(this, event);
    }
    
    renderedCallback() {
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
                        const carousel = this.template.querySelector('div[class="bs_carousel owl-theme owl-carousel offering-owl"]');
                        window.$(carousel).owlCarousel({
                            autoplay: false,
                            loop: false,
                            dots: true,
                            lazyLoad: false,
                            responsive: {
                                0: {
                                    items: 1,
                                    nav: false,
                                    navText: [
                                        "<i class='fa fa-caret-left'></i>",
                                        "<i class='fa fa-caret-right'></i>"
                                    ],
                                    dots: true,
                                    center: true,
                                },
                                768: {
                                    items: 2,
                                    nav: false,
                                    navText: [
                                        "<i class='fa fa-caret-left'></i>",
                                        "<i class='fa fa-caret-right'></i>"
                                    ],
                                    dots: true,
                                },
                                1024: {
                                    items: 3,
                                    nav: true,
                                    dots: true,
                                }
                            }
                        })
                    })
            })
    }
}