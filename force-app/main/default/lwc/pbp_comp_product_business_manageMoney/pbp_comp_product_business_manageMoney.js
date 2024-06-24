import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import owlcarousel from '@salesforce/resourceUrl/owlcarousel';
import business from '@salesforce/label/c.PBP_ZA_DoBusiness';
import saftey from '@salesforce/label/c.PBP_ZA_Saftey';
import once from '@salesforce/label/c.PBP_ZA_Onceyou';
import itsimportant from '@salesforce/label/c.PBP_ZA_ItsImportant';
import easy from '@salesforce/label/c.PBP_ZA_EasyWays';
import businessonline from '@salesforce/label/c.PBP_ZA_BusinessOnline';
import online from '@salesforce/label/c.PBP_ZA_Online';
import mobile from '@salesforce/label/c.PBP_ZA_MobileApp';
import cellphone from '@salesforce/label/c.PBP_ZA_CellPhone';
import telephone from '@salesforce/label/c.PBP_ZA_TelePhone';
import atm from '@salesforce/label/c.PBP_ZA_ATM';
import safeways from '@salesforce/label/c.PBP_ZA_SafeWays';
import blumobi from '@salesforce/label/c.PBP_ZA_BluMobi'
import pocket from '@salesforce/label/c.PBP_ZA_PocketBiz';
import snap from '@salesforce/label/c.PBP_ZA_SnapScan';
import autolink from '@salesforce/label/c.PBP_ZA_AutoLink';
import autoswitch from '@salesforce/label/c.PBP_ZA_AutoSwitch';
import masterpass from '@salesforce/label/c.PBP_ZA_Masterpass';
import security from '@salesforce/label/c.PBP_ZA_SecurityCentre';
import yourcard from '@salesforce/label/c.PBP_ZA_KeepingYourCardSafe';
import protect from '@salesforce/label/c.PBP_ZA_ProtectYourSelf';
import weare from '@salesforce/label/c.PBP_ZA_WeARECommitted';
import phishing from '@salesforce/label/c.PBP_ZA_Phishing';
import howdo from '@salesforce/label/c.PBP_ZA_HowToDoOnline';
import stay from '@salesforce/label/c.PBP_ZA_StayInformed';
import standardbankurl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import businessstandardbankurl from '@salesforce/label/c.PBP_ZA_BusinessonlineStandardbankUrl';

export default class Pbp_comp_product_business_manageMoney extends LightningElement {
    label = {
        
        business,
        saftey,
        once,
        itsimportant,
        easy,
        businessonline,
        online,
        mobile,
        cellphone,
        telephone,
        atm,
        safeways,
         pocket,
        blumobi,
        snap,
        autolink,
        autoswitch,
        masterpass,
        security,
        yourcard,
        protect,
        weare,
        phishing,
        howdo,
        stay,
        standardbankurl,
        businessstandardbankurl,
      
    }
    isEventFired;
    adobePageTag = {

        dataId: "link_content",
        dataIntent: "content links",
        dataScope: " Easy ways to bank",
       businessonlinelink: businessonline +" link click",
       onlinelink: online +" link click",
       mobilelink: mobile +" link click",
       cellphonelink: cellphone +" link click",
       telephonelink: telephone +" link click",
       atmlink: atm +" link click",
       pocketlink: pocket +" link click",
       snaplink: snap +" link click",
       autolinklink: autolink +" link click",
       autoswitchlink: autoswitch +" link click",
       masterpasslink: masterpass +" link click",
       yourcardlink: yourcard +" link click",
       protectlink: protect +" link click",
       wearelink: weare +" link click",
       phishinglink: phishing +" link click",
       howdolink: howdo +" link click",
       staylink: stay +" link click",
    };
    pocketBizUrl = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions/pocketbiz';
    snapscanUrl = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions/snapscan';
    autolinkUrl = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions/autolink';
    MasterPassUrl = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions/masterpass';
    autoswitchurl = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions/autoswitch';
    yourcardsafeurl = standardbankurl + '/southafrica/personal/products-and-services/bank-with-us/bank-accounts/managing-your-account/keeping-your-card-safe';
    cardfraudurl = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/card-fraud';
    banksafelyurl = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely';
    scamurl = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/scams';
    safelyonlineurl = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/shop-safely-online';
    myupdatesUrl = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/myupdates';
    onlinebankurl = standardbankurl + '/southafrica/personal/products-and-services/ways-to-bank/self-service-banking/onlinebanking';
    mobileappbankingurl = standardbankurl + '/southafrica/personal/products-and-services/ways-to-bank/self-service-banking/mobile-app-banking';
    cellphonebankingurl = standardbankurl + '/southafrica/personal/products-and-services/ways-to-bank/self-service-banking/cellphone-banking';
    speechbankingurl = standardbankurl + '/southafrica/personal/products-and-services/ways-to-bank/self-service-banking/telephone-and-speech-banking';
    atmbankingurl = standardbankurl + '/southafrica/personal/products-and-services/ways-to-bank/self-service-banking/atm-banking';
    isMobileDevice = false;
    initialRender = false;
    callingadobeevent(event){
        window.fireButtonClickEvent(this, event);
    }
    constructor() {
        super();
        if (window.matchMedia("(max-width: 427px)").matches) {
            this.isMobileDevice = true
        }
    }
    renderedCallback() {
        if (this.initialRender) {
            this.initialRender = true;
        }
        loadScript(this, owlcarousel + '/jquery.min.js')
            .then(e => {
                loadStyle(this, owlcarousel + '/owl.carousel.min.css');
                loadStyle(this, owlcarousel + '/owl.theme.default.min.css');
                loadScript(this, owlcarousel + '/owl.carousel.min.js')
                    .then(() => {
                        const carousel = this.template.querySelector('div[class="bs_carousel owl-theme owl-carousel offering-owl" ]');
                        window.$(carousel).owlCarousel({
                            autoplay: false,
                            loop: true,
                            nav: false,
                            navText: [
                                "<i class='fa fa-caret-left'></i>",
                                "<i class='fa fa-caret-right'></i>"
                            ],
                            dots: true,
                            autoHeight: true,
                            lazyLoad: false,
                            center: true,
                            responsive: {
                                0: {
                                    items: 1,    
                                },
                                768: {
                                    items: 2,    
                                },
                                1024: {
                                    items: 3,
                                }
                            }
                        })
                    }
                    )
            }
            )
    }
}