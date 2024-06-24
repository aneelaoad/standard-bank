import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";
import { loadScript } from 'lightning/platformResourceLoader';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
import triangle from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import screenbannerimg from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import screenbannerimg2 from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import productsData from '@salesforce/resourceUrl/PBP_ZA_ProductData';
import StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import PBP_ZA_productscreen_Business_Account_that from '@salesforce/label/c.PBP_ZA_productscreen_Business_Account_that';
import PBP_ZA_productScreen_Purchase_Stock from '@salesforce/label/c.PBP_ZA_productScreen_Purchase_Stock';
import PBP_ZA_ProductScreen_Save_Towards from '@salesforce/label/c.PBP_ZA_ProductScreen_Save_Towards';
import PBP_ZA_AcceptCardPayments from '@salesforce/label/c.PBP_ZA_AcceptCardPayments';
import PBP_ZA_ProductScreen_Receive_Notifications from '@salesforce/label/c.PBP_ZA_ProductScreen_Receive_Notifications';
import PBP_ZA_ProductScreen_View_Statements from '@salesforce/label/c.PBP_ZA_ProductScreen_View_Statements';
import PBP_ZA_DepositCashAtYourNearestCarsh from '@salesforce/label/c.PBP_ZA_DepositCashAtYourNearestCarsh';
import PBP_ZA_BankAnywhere from '@salesforce/label/c.PBP_ZA_BankAnywhere';
import PBP_ZA_ProductScreen_Get_Dedicated_Buisness from '@salesforce/label/c.PBP_ZA_ProductScreen_Get_Dedicated_Buisness';
import PBP_ZA_ProductScreen_Save_Transactional from '@salesforce/label/c.PBP_ZA_ProductScreen_Save_Transactional';
import PBP_ZA_ProductScreen_See_General from '@salesforce/label/c.PBP_ZA_ProductScreen_See_General';
import PBP_ZA_PayforPurchases from '@salesforce/label/c.PBP_ZA_PayforPurchases';
import PBP_ZA_ProductScreen_Through_A_Secure from '@salesforce/label/c.PBP_ZA_ProductScreen_Through_A_Secure';
import PBP_ZA_ProductScreen_Tap_To_Pay from '@salesforce/label/c.PBP_ZA_ProductScreen_Tap_To_Pay';
import PBP_ZA_BuySafelyOnline from '@salesforce/label/c.PBP_ZA_BuySafelyOnline';
import PBP_ZA_ProductScreen_Activate_Or_Disabled from '@salesforce/label/c.PBP_ZA_ProductScreen_Activate_Or_Disabled';
import PBP_ZA_ProductScreen_What_You_Get_For_Free from '@salesforce/label/c.PBP_ZA_ProductScreen_What_You_Get_For_Free';
import PBP_ZA_ProductScreen_Debit_Card from '@salesforce/label/c.PBP_ZA_ProductScreen_Debit_Card';
import PBP_ZA_ProductScreen_Inter_Account from '@salesforce/label/c.PBP_ZA_ProductScreen_Inter_Account';
import PBP_ZA_ProductScreen_View_Statements_Of_Up from '@salesforce/label/c.PBP_ZA_ProductScreen_View_Statements_Of_Up';
import PBP_ZA_ProductScreen_Emailed_Statements from '@salesforce/label/c.PBP_ZA_ProductScreen_Emailed_Statements';
import PBP_ZA_ProductScreen_Schedule_Transfer from '@salesforce/label/c.PBP_ZA_ProductScreen_Schedule_Transfer';
import PBP_ZA_ProductScreen_Verify_Standard_Bank from '@salesforce/label/c.PBP_ZA_ProductScreen_Verify_Standard_Bank';
import PBP_ZA_ProductScreen_Reverse from '@salesforce/label/c.PBP_ZA_ProductScreen_Reverse';
import PBP_ZA_SIGNUPforPermission from '@salesforce/label/c.PBP_ZA_SIGNUPforPermission';
import PBP_ZA_ProductScreen_Save from '@salesforce/label/c.PBP_ZA_ProductScreen_Save';
import PBP_ZA_ProductScreen_MarketLink from '@salesforce/label/c.PBP_ZA_ProductScreen_MarketLink';
import PBP_ZA_ProductScreen_Pay_As_You from '@salesforce/label/c.PBP_ZA_ProductScreen_Pay_As_You';
import PBP_ZA_ProductScreen_Monthly_Fee from '@salesforce/label/c.PBP_ZA_ProductScreen_Monthly_Fee';
import PBP_ZA_AcceptCardPaymentspocket from '@salesforce/label/c.PBP_ZA_AcceptCardPaymentspocket';
import PBP_ZA_SeePricing from '@salesforce/label/c.PBP_ZA_SeePricing';
import PBP_ZA_ProductScreen_MyMoBiz from '@salesforce/label/c.PBP_ZA_ProductScreen_MyMoBiz';
import PBP_ZA_ProductScreen_OpenURL from '@salesforce/label/c.PBP_ZA_ProductScreen_OpenURL';
import PBP_ZA_ProductScreen_Your_Business from '@salesforce/label/c.PBP_ZA_ProductScreen_Your_Business';
import PBP_ZA_ProductScreen_WhatYou_Need from '@salesforce/label/c.PBP_ZA_ProductScreen_WhatYou_Need';
import PBP_ZA_ProductScreen_Id_Document from '@salesforce/label/c.PBP_ZA_ProductScreen_Id_Document';
import PBP_ZA_ProductScreen_Proof_Of_Address from '@salesforce/label/c.PBP_ZA_ProductScreen_Proof_Of_Address';
import PBP_ZA_ProductScreen_Company_Registration from '@salesforce/label/c.PBP_ZA_ProductScreen_Company_Registration';
import PBP_ZA_ProductScreen_To_Apply from '@salesforce/label/c.PBP_ZA_ProductScreen_To_Apply';
import PBP_ZA_ProductScreen_Click_On from '@salesforce/label/c.PBP_ZA_ProductScreen_Click_On';
import PBP_ZA_ApplyNow from '@salesforce/label/c.PBP_ZA_ApplyNow';
import PBP_ZA_ButtonAndLeave from '@salesforce/label/c.PBP_ZA_ButtonAndLeave';
import PBP_ZA_ProductScreen_Visit from '@salesforce/label/c.PBP_ZA_ProductScreen_Visit';
import PBP_ZA_ProductScreen_NearestBranch_UrL from '@salesforce/label/c.PBP_ZA_ProductScreen_NearestBranch_UrL';
import PBP_ZA_ProductScreen_What_You_Get from '@salesforce/label/c.PBP_ZA_ProductScreen_What_You_Get';
import PBP_ZA_productscreen_Card_Features from '@salesforce/label/c.PBP_ZA_productscreen_Card_Features';
import PBP_ZA_productscreen_What_It_Costs from '@salesforce/label/c.PBP_ZA_productscreen_What_It_Costs';
import PBP_ZA_productScreen_How_To_Get_It from '@salesforce/label/c.PBP_ZA_productScreen_How_To_Get_It';
import PBP_ZA_ProductScreen_Accept from '@salesforce/label/c.PBP_ZA_ProductScreen_Accept';
import PBP_ZA_PocketBiz from '@salesforce/label/c.PBP_ZA_PocketBiz';
import PBP_ZA_ProductScreen_Bank from '@salesforce/label/c.PBP_ZA_ProductScreen_Bank';
import PBP_ZA_ProductScreen_Banking_App from '@salesforce/label/c.PBP_ZA_ProductScreen_Banking_App';
import PBP_ZA_ProductScreen_Or from '@salesforce/label/c.PBP_ZA_ProductScreen_Or';
import PBP_ZA_ProductScreen_Internet_Banking from '@salesforce/label/c.PBP_ZA_ProductScreen_Internet_Banking';
import PBP_ZA_ProductScreen_At_No_Additional from '@salesforce/label/c.PBP_ZA_ProductScreen_At_No_Additional';
import PBP_ZA_ProductScreen_See2023_PricingGuide from '@salesforce/label/c.PBP_ZA_ProductScreen_See2023_PricingGuide';
import PBP_ZA_Covid from '@salesforce/label/c.PBP_ZA_Covid';
import PBP_ZA_siteUrl from '@salesforce/label/c.PBP_ZA_siteURL';
export default class Pbp_comp_product_business_details_page extends NavigationMixin(LightningElement) {
    triangle = triangle + '/assets/images/triangle.png';
    isEventFired;
    adobePageTag = {
        pageName: "business :products and services:bank with us:business bank accounts:see all accounts:",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: " ",
        dataIntentbreadcrumb:"Navigational",
        dataScopebreadcrumb:"breadcrumb",
        dataIntenttab:"tab",
        dataScopeproductinfo:"product info",
        applyButtonText: " ",
        compareButtonText: " ",
        dataScopebutton:" product detail card",
        dataIntentbutton:"Informational",
        buttononetext:"",
        buttontwotext:"",
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
    label={
        PBP_ZA_productscreen_Business_Account_that,
        PBP_ZA_productScreen_Purchase_Stock,
        PBP_ZA_Covid,
        PBP_ZA_ProductScreen_Save_Towards,
        PBP_ZA_AcceptCardPayments,
        PBP_ZA_ProductScreen_Receive_Notifications,
        PBP_ZA_ProductScreen_View_Statements,
        PBP_ZA_DepositCashAtYourNearestCarsh,
        PBP_ZA_BankAnywhere,
        PBP_ZA_ProductScreen_Get_Dedicated_Buisness,
        PBP_ZA_ProductScreen_Save_Transactional,
        PBP_ZA_ProductScreen_See_General,
        PBP_ZA_PayforPurchases,
        PBP_ZA_ProductScreen_Through_A_Secure,
        PBP_ZA_ProductScreen_Tap_To_Pay,
        PBP_ZA_BuySafelyOnline,
        PBP_ZA_ProductScreen_Activate_Or_Disabled,
        PBP_ZA_ProductScreen_What_You_Get_For_Free,
        PBP_ZA_ProductScreen_Debit_Card,
        PBP_ZA_ProductScreen_Inter_Account,
        PBP_ZA_ProductScreen_View_Statements_Of_Up,
        PBP_ZA_ProductScreen_Emailed_Statements,
        PBP_ZA_ProductScreen_Schedule_Transfer,
        PBP_ZA_ProductScreen_Verify_Standard_Bank,
        PBP_ZA_ProductScreen_Reverse,
        PBP_ZA_SIGNUPforPermission,
        PBP_ZA_ProductScreen_Save,
        PBP_ZA_ProductScreen_MarketLink,
        PBP_ZA_ProductScreen_Pay_As_You,
        PBP_ZA_ProductScreen_Monthly_Fee,
        PBP_ZA_AcceptCardPaymentspocket,
        PBP_ZA_SeePricing,
        PBP_ZA_ProductScreen_MyMoBiz,
        PBP_ZA_ProductScreen_OpenURL,
        PBP_ZA_ProductScreen_Your_Business,
        PBP_ZA_ProductScreen_WhatYou_Need,
        PBP_ZA_ProductScreen_Id_Document,
        PBP_ZA_ProductScreen_Proof_Of_Address,
        PBP_ZA_ProductScreen_Company_Registration,
        PBP_ZA_ProductScreen_To_Apply,
        PBP_ZA_ProductScreen_Click_On,
        PBP_ZA_ApplyNow,
        PBP_ZA_ButtonAndLeave,
        PBP_ZA_ProductScreen_Visit,
        PBP_ZA_ProductScreen_NearestBranch_UrL,
        PBP_ZA_ProductScreen_What_You_Get,
        PBP_ZA_productscreen_Card_Features,
        PBP_ZA_productscreen_What_It_Costs,
        PBP_ZA_productScreen_How_To_Get_It,
        PBP_ZA_ProductScreen_Accept,
        PBP_ZA_PocketBiz,
        PBP_ZA_ProductScreen_Bank,
        PBP_ZA_ProductScreen_Banking_App,
        PBP_ZA_ProductScreen_Or,
        PBP_ZA_ProductScreen_Internet_Banking,
        PBP_ZA_ProductScreen_At_No_Additional,
        PBP_ZA_ProductScreen_See2023_PricingGuide,
        StandardBankUrl
    }
    transactionalTc = StandardBankUrl + '/static_file/South%20Africa/PDF/Business%20Ts%20and%20Cs/Business_Transaction_Accounts_T&Cs.pdf';
    businessGneralTc = StandardBankUrl + '/static_file/South%20Africa/PDF/Business%20Ts%20and%20Cs/Business%20General%20Terms%20and%20Conditions.pdf';
    growYourMoney = StandardBankUrl + '/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/our-accounts/marketlink';
    myMobizPrice = StandardBankUrl + '/static_file/South%20Africa/PDF/Business%20Pricing/2022/MyMoBiz_Account_Pricing_Guide_2022.pdf';
    businessBankAccounts = StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts/mymobizao#/';
    branchLocator = StandardBankUrl + '/southafrica/personal/branch-locator';
    ProductScreenURL=StandardBankUrl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/mobile-app-banking';
    ProductScreen_Internet_Banking = StandardBankUrl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/onlinebanking';
    ProductScreen_Accept= StandardBankUrl +'/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions/pocketbiz';
    ProductScreen_Save = StandardBankUrl + '/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/our-accounts/marketlink';
    productToShow = "4648"; 
    pricingOptToOpen = null;
    product = null; 
    testMessage = '';
    isButtonOneURL = false;
    isButtonTwoURL = false;
    buttonOneURL = null;
    buttonTwoURL = null;
    isMobileDevice = false;
    isTabDevice=false;
    isWebDevice=false;
    count;
    callingadobeevent(event){
        window.fireButtonClickEvent(this, event);
    }
    constructor() {
        super();
        if (window.matchMedia("(max-width: 427px)").matches) {
            this.isMobileDevice = true
            this.count='1';
        }
        else if(window.matchMedia("(max-width: 991px)").matches && window.matchMedia("(min-width: 427px)").matches){
            this.isTabDevice= true
            this.count='2';
        }
        else if(window.matchMedia("(min-width: 992px)").matches){
            this.isWebDevice = true
            this.count='3';
        }
    }
    tabClick(e) {
        const allTabs = this.template.querySelectorAll('.slds-tabs_default__item');
        allTabs.forEach((elm, idx) => {
            elm.classList.remove("slds-is-active");
        });
        e.currentTarget.classList.add('slds-is-active');
        var element = e.currentTarget.firstChild.id;

        var selectedelementarea = element.substr(0, element.indexOf('_'));;
        const tabview = this.template.querySelectorAll('.slds-tabs_default__content');
        tabview.forEach((elm, idx) => {
            elm.classList.remove("slds-show");
            elm.classList.add("slds-hide");
        });
        this.template.querySelector(`.${selectedelementarea}`).classList.remove("slds-hide");
        this.template.querySelector(`.${selectedelementarea}`).classList.add("slds-show");
    }
    buttonClick(event) {
        window.fireButtonClickEvent(this, event);
        event.preventDefault();
        let buttonOneSelected = false;
        if (event.target.dataset.id == 'buttonOne') {
            buttonOneSelected = true;
        }
        let intPage = "";
        if (buttonOneSelected) {
            intPage = this.product.buttonOneInternalPage;
        } else {
            intPage = this.product.buttonTwoInternalPage;
        }
        if (typeof intPage === "string" && intPage.trim().length > 0) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: intPage
                },
                state: {
                    prodId: this.productToShow,
                    prOpt: this.pricingOptToOpen
                }
            });
        } else {
        }
   }
    handleNavigateTo(event) {
        // prevent default navigation by href
        event.preventDefault();
        const name = event.target.name;
        if (this.breadCrumbsMap[name]) {
            window.location.assign(this.breadCrumbsMap[name]);
        }
    }
    connectedCallback() {
       this.readProductsData();
       this.adobePageTag.pageName=this.adobePageTag.pageName+this.product.name;
       this.adobePageTag.dataScope=this.product.name;
       this.adobePageTag.buttononetext=this.product.name+ " | "+this.product.buttonOneText+" button click";
       this.adobePageTag.buttontwotext=this.product.name+ " | "+this.product.buttonTwoText+" button click";

        loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName); 
            }
        }) 
            .catch(error => {
            });

    }
    readProductsData() {
        let request = new XMLHttpRequest();
        request.open("GET", productsData + '/' + this.productToShow + '.json', false);
        request.send(null);
        let jsonProducts = JSON.parse(request.responseText);
        //Go through all products to find the one that we need to display
        for (let i = 0; i < jsonProducts.product.length; i++) {
            if (jsonProducts.product[i].id == this.productToShow) {
                if (this.pricingOptToOpen == null) {
                    // if pricing option to open = null, then select first product found
                    this.product = jsonProducts.product[i];
                    break;
                } else {
                    //otherwise select product that matches pricing option
                    if (jsonProducts.product[i].pricingOption == this.pricingOptToOpen) {
                        this.product = jsonProducts.product[i];
                        break;
                    }
                }
             }
        }
        if (this.product != null) {  
                if (this.count === '2') {
                    this.isTabDevice = true
                       this.product.bannerImage2 = screenbannerimg2 + this.product.bannerImage2;
                       this.setupBreadcrumbs();
                       this.setupProductBenefits();
                       this.setupProductTabs();
                       this.setupButtons();
                   }
                   else if(this.count === '1'){
                   this.isMobileDevice = true
                   this.product.bannerImage = screenbannerimg + this.product.bannerImage;
                   this.setupBreadcrumbs();
                   this.setupProductBenefits();
                   this.setupProductTabs();
                   this.setupButtons();
                   }
                   else if(this.count === '3'){
                    this.isWebDevice = true
                       this.product.bannerImage = screenbannerimg + this.product.bannerImage;
                       this.setupBreadcrumbs();
                       this.setupProductBenefits();
                       this.setupProductTabs();
                       this.setupButtons();
                   }
        }
    }
    setupButtons() {
        let extURL = "";   
        extURL = this.product.buttonOneExtURL;
        if (typeof extURL === "string" && extURL.trim().length > 0) {
            this.isButtonOneURL = true;
            this.buttonOneURL = extURL;
        }
        extURL = this.product.buttonTwoExtURL;
        if (typeof extURL === "string" && extURL.trim().length > 0) {
            this.isButtonTwoURL = true;
            this.buttonTwoURL = extURL;
        }
    }
    setupBreadcrumbs() {
        for (let index = 0; index < this.product.breadcrumbs.length; index++) {
            
            if (this.product.breadcrumbs[index].linkUrl != null) {
                this.product.breadcrumbs[index].linkAvailable = true;
                this.product.breadcrumbs[index].isHome =false;
            }
            if(index===0){
                this.product.breadcrumbs[index].linkUrl =  PBP_ZA_siteUrl+'/southafrica/business';
                this.product.breadcrumbs[index].isHome =true;
            }

        }
    }
    setupProductBenefits() {
        for (let index = 0; index < this.product.benefit.length; index++) {
            this.product.benefit[index].benefitIcon = triangle + this.product.benefit[index].benefitIcon;
            if (this.product.benefit[index].background == "primary") {
                this.product.benefit[index].primaryBackground = true;
            } else {
                this.product.benefit[index].primaryBackground = false;
            }   
        }

    }
    setupProductTabs() {
        for (let index = 0; index < this.product.tab.length; index++) {
            //set unique tab id, tab controls, area id for each tab
            this.product.tab[index].tabId = "tab-default-" + (index + 1) + "__item";
            this.product.tab[index].controls = "tab-default-" + (index + 1);
            this.product.tab[index].areaId = "tab-default-" + (index + 1);
            if (index == 0) {
                // set first tab as active/visible
                this.product.tab[index].active = true;
                this.product.tab[index].areaClass = this.product.tab[index].areaId + " slds-tabs_default__content slds-show";   
            } else {
                this.product.tab[index].active = false;
                this.product.tab[index].areaClass = this.product.tab[index].areaId + " slds-tabs_default__content slds-hide";
            }
            for (let i = 0; i < this.product.tab[index].line.length; i++) {
                this.product.tab[index].line[i].id = "tab-" + (index + 1) + "line" + (i + 1);
                if (this.product.tab[index].line[i].type == "list") {
                    this.product.tab[index].line[i].listType = true;
                }
                if (this.product.tab[index].line[i].type == "standaloneLink") {
                    this.product.tab[index].line[i].linkType = true;
                }
                if (this.product.tab[index].line[i].type == "title") {
                    this.product.tab[index].line[i].titleType = true;
                }
                if (this.product.tab[index].line[i].type == "info") {
                    this.product.tab[index].line[i].infoType = true;
                }
                for (let j = 0; j < this.product.tab[index].line[i].text.length; j++) {
                    if (this.product.tab[index].line[i].text[j].linkUrl != null) {
                        this.product.tab[index].line[i].text[j].linkText = true;
                    }
                }
                
            }
        }
    }
    //read parameters passed to the page via URL params
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          //assign prodId param value to productToShow if it passed in, otherwise keep defaul productToShow value.
          this.productToShow = this.urlStateParameters.prodId || this.productToShow;
          //assign prOpt param value to 'pricing to open', it can be null (in such case first product will be selected)
          this.pricingOptToOpen = this.urlStateParameters.prOpt;
        }
    }
}