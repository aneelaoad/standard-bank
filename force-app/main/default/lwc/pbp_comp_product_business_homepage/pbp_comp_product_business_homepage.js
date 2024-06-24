import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import owlcarousel from '@salesforce/resourceUrl/owlcarousel';
import ADDR from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
import IMAGE from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import whatyou from '@salesforce/label/c.PBP_ZA_WhatDoYouNeedToTakeYour';
import business from '@salesforce/label/c.PBP_ZA_BusinessToTheNextLevel';
import explore from '@salesforce/label/c.PBP_ZA_ExploreOurBusinessSolutions';
import tellmemore from '@salesforce/label/c.PBP_ZA_TellMeMore';
import overdraft from '@salesforce/label/c.PBP_ZA_Overdraft';
import revolving from '@salesforce/label/c.PBP_ZA_RevolvingCredit';
import debtor from '@salesforce/label/c.PBP_ZA_Debtor_Finance';
import buisness from '@salesforce/label/c.PBP_ZA_Buisnessloans';
import improve from '@salesforce/label/c.PBP_ZA_WantToImproveYourEmployees';
import financial from '@salesforce/label/c.PBP_ZA_FinancialHealth';
import bringbankingservices from '@salesforce/label/c.PBP_ZA_BringBankingServices';
import buyforex from '@salesforce/label/c.PBP_ZA_BuyForex';
import bridgingfinance from '@salesforce/label/c.PBP_ZA_BridgingFinance';
import bondsandguarantees from '@salesforce/label/c.PBP_ZA_BondsandGuarantees';
import cargoinsurance from '@salesforce/label/c.PBP_ZA_CargoInsurance';
import operatingfleet from '@salesforce/label/c.PBP_ZA_OperatingFleet';
import getyourfleet from '@salesforce/label/c.PBP_ZA_GetYourFleet';
import vehiclefinacing from '@salesforce/label/c.PBP_ZA_VehicleFinancing';
import financeprotection from '@salesforce/label/c.PBP_ZA_FinanceProtection';
import vehicleinsurance from '@salesforce/label/c.PBP_ZA_VehicleInsurance';
import prepaidfleet from '@salesforce/label/c.PBP_ZA_PrepaidFleetCards';
import online from '@salesforce/label/c.PBP_ZA_Online';
import mobile from '@salesforce/label/c.PBP_ZA_MobileApp';
import cellphone from '@salesforce/label/c.PBP_ZA_CellPhone';
import telephone from '@salesforce/label/c.PBP_ZA_TelePhone';
import bizconnect from '@salesforce/label/c.PBP_ZA_Bizconnect';
import connect from '@salesforce/label/c.PBP_ZA_Connect';
import exploreour from '@salesforce/label/c.pbp_za_exploreOurOnlinePortal';
import once from '@salesforce/label/c.pbp_za_once';
import important from '@salesforce/label/c.pbp_za_important';
import free from '@salesforce/label/c.pbp_za_free';
import Whatdoyouneedforyourbusiness from '@salesforce/label/c.PBP_ZA_Whatdoyouneedforyourbusiness';
import BussinessBank from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Open_a_BussinessBank';
import Mybusiness from '@salesforce/label/c.PBP_ZA_Money_for_my_business';
import mymoney from '@salesforce/label/c.PBP_ZA_Grow';
import Insuranceformybusiness from '@salesforce/label/c.PBP_ZA_Insurance_for_my_business';
import financialsolutions from '@salesforce/label/c.PBP_ZA_International_financial_solutions';
import mycustomers from '@salesforce/label/c.PBP_ZA_Payment_solutions_for_my_customers';
import bankingsolutions from '@salesforce/label/c.PBP_ZA_Tailored_business_banking_solutions';
import StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import ExperienceCloudURL from '@salesforce/label/c.PBP_ZA_ExperienceCloudDomain';

export default class Pbp_comp_product_business_homepage extends NavigationMixin(LightningElement) {
    label = {
        whatyou,
        business,
        explore,
        tellmemore,
        overdraft,
        revolving,
        debtor,
        buisness,
        improve,
        financial,
        bringbankingservices,
        buyforex,
        bridgingfinance,
        bondsandguarantees,
        cargoinsurance,
        operatingfleet,
        getyourfleet,
        vehiclefinacing,
        financeprotection,
        vehicleinsurance,
        prepaidfleet,
        online,
        mobile,
        cellphone,
        telephone,
        bizconnect,
        connect,
        exploreour,
        once,
        important,
        free,
        bankingsolutions,
        Whatdoyouneedforyourbusiness,
        BussinessBank,
        Mybusiness,
        mymoney,
        Insuranceformybusiness,
        financialsolutions,
        mycustomers,
        StandardBankUrl,
        ExperienceCloudURL
    }
    isEventFired;
    adobePageTag = {
        pageName: "Business",
        dataId: "link_content",
        dataIntent: "Informational",
        dataScope: "Business Home page",
        cancelButtonText: "mymobiz business account | Business Home page |  cancel button click",
        continueButtonText: "mymobiz business account | Business Home page | continue button click",
        tellmeButtonText: "Bizconnect |  Tell Me More button click",
        datascopeneed: "need goal banner button",
        tellmeButtontextneedgoal: "want to improve your cash flow? | Tell Me More button click",
        tellmeButtontextneedgoalemployees: "want to improve your employees overall financial health? | Tell Me More button click",
        tellmeButtontextneedgoaloperating: "Operating a small or large fleet? | Tell Me More button click",
        overdraftbutton: "want to improve your cash flow? | overdrafts button click",
        revolvingcreditbutton: "want to improve your cash flow? | revolving credit button click",
        debtorfinancebutton: "want to improve your cash flow? | debtor finance button click",
        businessloansbutton: "want to improve your cash flow? | business loans button click",
        buyforexbutton: "want to improve your employees overall financial health? | buy forex button click",
        bridgingfinancebutton: "want to improve your employees overall financial health? | bridging finance button click",
        bondsandguaranteesbutton: "want to improve your employees overall financial health? | bonds and guarantees button click",
        cargoinsurancebutton: "want to improve your employees overall financial health? | cargo insurance button click",
        vehiclefinancingbutton: "Operating a small or large fleet? | vehicle financing button click",
        financeprotectionbutton: "Operating a small or large fleet? | finance protection button click",
        vehicleinsurancebutton: "Operating a small or large fleet? | vehicle insurance button click",
        prepaidfleetcardsbutton: "Operating a small or large fleet? | prepaid fleet cards button click",

        businessbankbutton:BussinessBank+ " button click",
        Mybusinessbutton:Mybusiness+ " button click",
        mymoneybutton:mymoney+ " button click",
        Insuranceformybusinessbutton:Insuranceformybusiness+ " button click",
        financialsolutionsbutton:financialsolutions+ " button click",
        mycustomersbutton:mycustomers+ " button click",

        siteErrorCode: "",
        application: {
            applicationProduct: "Business Home page",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Business Home page",
            applicationStep: "",
            applicationStart: true,
            applicationComplete: false,
        },
    };
    bizconnectlogo = IMAGE + '/assets/images/icon-moving-up.svg';
    logooverdraft = IMAGE + '/assets/images/Overdraft.svg';
    logorevolving = IMAGE + '/assets/images/revolving.svg';
    logodebtor = IMAGE + '/assets/images/debtor.svg';
    logobusiness = IMAGE + '/assets/images/business.svg';
    logobuyforex=IMAGE +'/assets/images/Buy_foreign.svg';
    logobridging=IMAGE +'/assets/images/caluculatoricon.png';
    logocargoinsurance=IMAGE +'/assets/images/ship.png';
    logovehicle=IMAGE +'/assets/images/vehicleicon.png';
    logofinance=IMAGE +'/assets/images/shield.png';
    logovehicleinsurance=IMAGE +'/assets/images/Insure_your_home.svg';
    logoprepaidfleet=IMAGE +'/assets/images/cardicon.png';
    logobondsandguarantees=IMAGE +'/assets/images/anchor.png';

    // bizconnectURL = StandardBankUrl + '/southafrica/business/bizconnect';
    cashFlow= StandardBankUrl +'/southafrica/business/products-and-services/borrow-for-your-needs';
    financialHealth=StandardBankUrl +'/southafrica/business/products-and-services/business-solutions/workplace-solutions/employer-value-banking';
    smallorlargefleet= StandardBankUrl +'/southafrica/business/products-and-services/business-solutions/fleet-management';
   
    initialRender = false;
    icon_aeroplane = ADDR + '/assets/images/International_financial_solutions_icon-aeroplane.png.png';
    icon_card = ADDR + '/assets/images/Business_bank_account_icon-card.png.png';
    icon_helper = ADDR + '/assets/images/Payment_solutions_for_my_customers_icon-helper.png.png';
    icon_wallet = ADDR + '/assets/images/Money_for_my_business_icon-wallet.png.png';
    icons_plant = ADDR + '/assets/images/Grow_my_money_icons-plant.png.png';
    icon_umbrela = ADDR + '/assets/images/Insurance_for_my_business_icon-umbrela.png.png';
    icon_aeroplane_2 = ADDR + '/assets/images/icon-aeroplane.png';
    icon_card_2 = ADDR + '/assets/images/icon-card.png';
    icon_helper_2 = ADDR + '/assets/images/icon-helper.png';
    icon_wallet_2 = ADDR + '/assets/images/icon-wallet.png';
    icons_plant_2 = ADDR + '/assets/images/icons-plant-2.png';
    icon_umbrela_2 = ADDR + '/assets/images/icon-umbrela.png';
    contactsList = [];
    
    connectedCallback() {
        loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                //to fire application start event.
               
                this.adobeAnalyticsPageView();
             
            }
        }) // end
            .catch(error => {
            });
        getCmsData({
            channelName: 'Tetrad_Sprint2',
            contentKey: 'MC2FRXLW7SS5HDZLM3CZVOKYDDLA'

        })
            .then(result => {
                result.forEach(element => {
                });
            })
            .catch(error => {

            });
    }
    handleClick(event) {
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + '/southafrica/business/bizconnect',StandardBankUrl);
    }
    tellmemmorebuttonclick(event) {
        window.fireButtonClickEvent(this, event);
    }
    renderedCallback() {
        if (this.initialRender) { return; }
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
                            loop: true,
                            nav: true,
                           dots: true,
                            autoHeight: true,
                            lazyLoad: false,
                            center: true,
                            responsive: {
                                0: {
                                    items: 1,
                                },

                            }
                        })
                    }
                    )
            }
            )
    }
     navigatetobusinessbank(event){
        window.fireButtonClickEvent(this, event);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'our_accounts__c'
            }
});
    }
    navigatetomoneyforbusiness(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions", StandardBankUrl);
    }
    navigatetogrowmymoney(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/our-accounts", StandardBankUrl);
    }
    navigatetoinsurancebusiness(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/insure-what-matters/small-business-insurance", StandardBankUrl);
    }
    navigatetointernationalsolution(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/bank-with-us/company-cards/our-cards", StandardBankUrl);
    }
    navigatetopaymentsolution(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions", StandardBankUrl);
    }
    navigatetooverdraft(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/business-overdraft", StandardBankUrl);
    }
    navigatetorevolving(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/revolving-credit-plan", StandardBankUrl);
    }
    navigatetodebtor(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/borrow-for-your-needs/specialised-financing", "_blank");
    }
    navigatetobusiness(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/business-term-loan", StandardBankUrl);
    }
    navigatetobuyforex(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/personal/products-and-services/bank-with-us/foreign-exchange", StandardBankUrl);
    }
   navigatetobridgingfinance(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance/bridging-finance",StandardBankUrl);
    }
    navigatetobondsandguarantees(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/insure-what-matters/bonds-and-guarantees", StandardBankUrl);
    }
    navigatetobuyforexcargoinsurance(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/insure-what-matters/marine-insurance-for-cargo-by-air-land-or-sea", StandardBankUrl);
    }
    navigatetovehiclefinance(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance", StandardBankUrl);
    }
    navigatetofinanceprotection(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/insure-what-matters/your-vehicles/vehicle-and-asset-finance-protection", StandardBankUrl);
    }
    navigatetovehicleinsurance(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/insure-what-matters/your-vehicles/vehicle-and-asset-insurance",StandardBankUrl);
    }
    navigatetoprepaidfleet(event){
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/business-solutions/fleet-management/prepaid-fleet-card", StandardBankUrl);
    }
}