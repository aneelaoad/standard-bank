import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import ADDR from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import BANNER_TITLE from '@salesforce/label/c.PBP_ZA_ProductBankAccountBannerTitle';
import BANNER_SUB_TITLE from '@salesforce/label/c.PBP_ZA_ProductBankAccountBannerSubtitle';
import BANNER_SUB_TITLE_IMMEDAITELY from '@salesforce/label/c.PBP_ZA_ProductBankAccountBannerImmediatelySubtitle';
import BUTTON from '@salesforce/label/c.PBP_ZA_Product_Bank_Account_Banner_MoreInfo_Button';
import BREADCRUMB_HOME from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Home';
import ourproducts from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Our_Products';
import services from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Services';
import bankwithus from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Bank_with_Us';
import businessbank from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Open_a_BussinessBank';
import businessbankaccounts from '@salesforce/label/c.PBP_ZA_Product_BreadCrumb_Title';
import beingable from '@salesforce/label/c.PBP_ZA_Product_BreadCrumb_Subtitle';
import openingaccount from '@salesforce/label/c.PBP_ZA_Product_OpeningAccount';
import whatareyou from '@salesforce/label/c.PBP_ZA_Product_Bank_Title';
import mymobizplus from '@salesforce/label/c.PBP_ZA_Product_Bank_MymoBiz_Plus_Card_Title';
import simple from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_plus_SubTitle';
import Bundleoffering from '@salesforce/label/c.PBP_ZA_Bundleoffering';
import freedebit from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Plus_Free_Debit_Card_List_Items';
import freeelectronic from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Plus_Free_Electronic_List_Items';
import ATMlist from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Plus_Make_ATM_List_Items';
import freeatmlist from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Plus_Free_ATM_list_Items';
import freeimmediate from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Plus_Free_Immediate_List_Items';
import R from '@salesforce/label/c.PBP_ZA_ProductScreen_Banner_Currency';
import mymobizpluscurrencyrate from '@salesforce/label/c.PBP_ZA_ProductScreen_Banner_CurrencyRate';
import monthlyfee from '@salesforce/label/c.PBP_ZA_ProductScreen_Banner_Monthly_Fee';
import tellmemore from '@salesforce/label/c.PBP_ZA_TellMeMore';
import addtocompare from '@salesforce/label/c.PBP_ZA_AddToCompare';
import applynow from '@salesforce/label/c.PBP_ZA_ApplyNow';
import applyonline from '@salesforce/label/c.PBP_ZA_ProductScreen_Banner_Main_Button_Medium';
import mymobizbusinessaccount from '@salesforce/label/c.PBP_ZA_Product_Bank_MymoBiz_CardTitle';
import simpleafford from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_SubTitle';
import freedebitcard from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Free_Debit_ListItems';
import freemarketlink from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_MarketLink_ListItems';
import acceptcard from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Accept_ListItems';
import dedicated from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Dedicated_ListItems';
import transact from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_Transact_ListItems';
import mymobizcurrencyrate from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_MymoBiz_CurrencyRate';
import businesscurrent from '@salesforce/label/c.PBP_ZA_Product_Tile_Bussiness_CardTitle';
import takeYour from '@salesforce/label/c.PBP_ZA_Product_Bank_Bussiness_Card_SubTitle';
import tailored from '@salesforce/label/c.PBP_ZA_Product_Bank_Bussiness_Card_Tailored_ListItems';
import custompayment from '@salesforce/label/c.PBP_ZA_Product_Bank_Bussiness_Card_Custom_ListItems';
import crossborder from '@salesforce/label/c.PBP_ZA_Product_Bank_Bussiness_Card_Cross_Border_ListItems';
import dedicatedsupport from '@salesforce/label/c.PBP_ZA_Product_Bank_Bussiness_Card_Dedicated_Support_ListItems';
import transactfrombank from '@salesforce/label/c.PBP_ZA_Product_Bank_Bussiness_Card_Transact_24_ListItems';
import currency from '@salesforce/label/c.PBP_ZA_Product_Bank_Bussiness_Card_Currency';
import Bizlaunchaccount from '@salesforce/label/c.PBP_Product_Bank_Bizlaunch_Card_Title';
import givesyou from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Bizlaunch_SubTitle';
import guidance from '@salesforce/label/c.PBP_ZA_Product_BankBizlaunch_Card_Guidance_ListItems';
import freeaccess from '@salesforce/label/c.PBP_ZA_Product_BankBizlaunch_Card_FreeAccess_ListItems';
import specialrates from '@salesforce/label/c.PBP_ZA_Product_BankBizlaunch_Card_SpecialRates_ListItems';
import bizlaunchcurrency from '@salesforce/label/c.PBP_ZA_Product_BankBizlaunch_Card_Currency';
import Attorney from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Attorney_Title';
import ManageClient from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Attorney_SubTitle';
import fullycompliant from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Attorney_FullyCompliant_ListItems';
import earn from '@salesforce/label/c.PBP_Product_bank_Card_Attorney_Earn_ListItems';
import Activate from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Attorney_Activate_ListIitems';
import Attorneycurrency from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Attorney_Currency';
import thirdparty from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_ThirdParty_Title';
import managefunds from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_ThirdParty_SubTitle';
import dedicatedaccount from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_ThirdParty_Dedicated_ListItems';
import multiplerelease from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_ThirdParty_Multiple_ListItems';
import termdeposit from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_ThirdParty_Term_ListItems';
import topnotch from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_ThirdParty_Topnotch_ListItems';
import executes from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Executors_Title';
import manageestates from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Executors_SubTitle';
import legallycompliant from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Executors_Legally_ListItems';
import dedicatedsupported from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Executors_DedicatedSupport_List_Items';
import accuraterecord from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Executors_Accurate_ListItems';
import addupto from '@salesforce/label/c.PBP_ZA_Product_Tile_Card_Product_Compare';
import compare from '@salesforce/label/c.PBP_ZA_Product_Tile_Card_Compare';
import removeall from '@salesforce/label/c.PBP_ZA_Product_Tile_Card_RemoveAll';
import StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import payasyoutransact from '@salesforce/label/c.PBP_ZA_PayAsYouTransact';
import productsvgicon from '@salesforce/label/c.PBP_ZA_Product_svgicon';
import SBLiveUrl from '@salesforce/label/c.PBP_ZA_SBLiveUrl';
import PBP_ZA_siteUrl from '@salesforce/label/c.PBP_ZA_siteURL';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import { loadScript } from 'lightning/platformResourceLoader';

export default class Pbp_comp_product_business_bank_accounts extends NavigationMixin(LightningElement) {
    label = {
        StandardBankUrl,
        PBP_ZA_siteUrl,
        BANNER_TITLE,
        BANNER_SUB_TITLE,
        BANNER_SUB_TITLE_IMMEDAITELY,
        BUTTON,
        BREADCRUMB_HOME,
        BREADCRUMB_HOME,
        ourproducts,
        services,
        bankwithus,
        businessbank,
        businessbankaccounts,
        beingable,
        openingaccount,
        whatareyou,
        mymobizplus,
        simple,
        Bundleoffering,
        freedebit,
        freeelectronic,
        ATMlist,
        freeatmlist,
        freeimmediate,
        R,
        monthlyfee,
        tellmemore,
        addtocompare,
        applynow,
        applyonline,
        mymobizbusinessaccount,
        simpleafford,
        freedebitcard,
        freemarketlink,
        acceptcard,
        dedicated,
        transact,
        businesscurrent,
        takeYour,
        tailored,
        custompayment,
        crossborder,
        dedicatedsupport,
        transactfrombank,
        currency,
        Bizlaunchaccount,
        givesyou,
        guidance,
        freeaccess,
        specialrates,
        bizlaunchcurrency,
        Attorney,
        ManageClient,
        fullycompliant,
        earn,
        Activate,
        Attorneycurrency,
        thirdparty,
        managefunds,
        dedicatedaccount,
        multiplerelease,
        termdeposit,
        topnotch,
        executes,
        manageestates,
        legallycompliant,
        dedicatedsupported,
        accuraterecord,
        addupto,
        compare,
        removeall,
        mymobizpluscurrencyrate,
        mymobizcurrencyrate,
        payasyoutransact,
        productsvgicon

    };
    isEventFired;
   adobePageTag = {
        pageName: "business:Our Products and Services: Bank with us: Business Bank Accounts: see all accounts ",
        dataId: "link_content",
        dataIntent: "informational",
        dataScope: "product card",
        dataIntentbreadcrumb:"Navigational",
        dataScopebreadcrumb:"breadcrumb",
        applyButtonTextmymobizplus:  "mymobiz plus business account | apply online button click",
        applyButtonTextmymobizbusinessaccount:  "mymobiz business account | apply online button click",
        mymobizplustellmemoreButtonText: mymobizplus + " | "+ tellmemore+" button click",
        mymobizbusinessaccounttellmemoreButtonText:mymobizbusinessaccount+" | "+ tellmemore+" button click",
        businesscurrenttellmemoreButtonText:businesscurrent+" | "+ tellmemore+" button click",
        BizlaunchaccounttellmemoreButtonText:Bizlaunchaccount+" | "+ tellmemore+" button click",
        AttorneytellmemoreButtonText:Attorney+" | "+ tellmemore+" button click",
        thirdpartytellmemoreButtonText:thirdparty+" | "+ tellmemore+" button click",
        executestellmemoreButtonText:executes+" | "+ tellmemore+" button click",
        BREADCRUMB_HOMEtext:BREADCRUMB_HOME+" click",
        ourproductsservicestext:ourproducts + services+" click",
        bankwithustext:bankwithus+" click",
        businessbanktext:businessbank+" click",
        removeallButtonText: "mymobiz business account | remove all button click",
        compareButtonText: "mymobiz business account | compare button click",
        siteErrorCode: "",
        application: {
            applicationProduct: "Preapplication",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Preapplication",
            applicationStep: "",
            applicationStart: true,
            applicationComplete: false,
        },
        ecommerce: {
            product:[{
          
            }],
            purchaseID:"",
           
        },
    };
    compareAccountsURL = StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/compare-accounts';
    productListBaseUrl = StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/';
    HomeUrl= PBP_ZA_siteUrl + '/southafrica/business';
    ourproductsandsevicesUrl= StandardBankUrl + '/southafrica/business/products-and-services';
    bankwithusUrl=StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us';
    ProductListUrl=SBLiveUrl + '/southafrica/business/products-and-services/bank-with-us/';


    @api mymobizApplyOnlineLink = this.productListBaseUrl + 'business-bank-accounts/our-accounts/mymobizao#/';
    @api mymobizApplytellMeMoreLink = this.productListBaseUrl + 'business-bank-accounts/mymobiz-plus-account';
    @api currentAccountApplyNowLink = this.ProductListUrl + 'business-bank-accounts/our-accounts/bca ';
    @api currentAccountTellMeMoreLink = this.productListBaseUrl + 'business-bank-accounts/business-current-account';
    @api bizlaunchApplyNowLink = this.ProductListUrl + 'business-bank-accounts/our-accounts/bizlaunch';
    @api bizlaunchTellMeMoreLink = this.productListBaseUrl + 'business-bank-accounts/bizlaunch';
    @api AttorneyTrustApplyNowLink = this.productListBaseUrl + 'business-bank-accounts/our-accounts#';
    @api AttorneyTrustTellMeMoreLink = this.productListBaseUrl + 'attorney-accounts/attorney-trust-account';
    @api FundAccountTellMeMoreLink = this.productListBaseUrl + 'attorney-accounts/third-party-fund-administration';
    @api ExecutorAccountApplyNowLink = this.productListBaseUrl + 'business-bank-accounts/our-accounts#';
    @api ExecutorAccountTellMeMoreLink = this.productListBaseUrl + 'attorney-accounts/executor-current-account';
    gold_credit_card = ADDR + '/assets/images/cards-gold-credit-card.png';
    blue_credit_card = ADDR + '/assets/images/cards-blue-credit-card.png';
    @track productList = [];
    @track productIdList = [];
    productName;
    showCompareSection = false;
    @track customFormModalAttorneyTrust = false;
    @track customFormModalBizLaunch = false;
    @track customFormModalCurrentAcc = false;
    heroBanner = ADDR + '/assets/images/hero_banner.png';
    constructor() {
        super();
        this.isMobileDevice = window.matchMedia("only screen and (max-width: 576px)").matches;
    }

    customShowModalPopupBizLaunch(event) {
        this.customFormModalBizLaunch = true;
        window.fireButtonClickEvent(this, event);
    }
    callingadobeevent(event){
        window.fireButtonClickEvent(this, event);
    }
    customShowModalPopupAttorneyTrust(event) {
        this.customFormModalAttorneyTrust = true;
        window.fireButtonClickEvent(this, event);
    }

    customShowModalPopupCurrentAcc(event) {
        this.customFormModalCurrentAcc = true;
        window.fireButtonClickEvent(this, event);
    }
    customHideModalPopup() {

        this.customFormModal = false;
    }
    genericFieldChange(event) {
        let prodId = event.target.dataset.id;
        let name = event.target.dataset.name;
        if (event.target.checked) {
            this.showCompareSection = true;
            if (this.productList.length !== 3) {
                this.productList.push(name);
                this.productIdList.push(prodId);
            }
        } else {
            this.productList = this.productList.filter(item => item !== name);
            if (this.productList.length === 0) {
                this.showCompareSection = false;
            }
        }
    }
    removeAll(event) {
        window.fireButtonClickEvent(this, event);
        let checkboxes = this.template.querySelectorAll('[type="checkbox"]');
        for (let i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false;
        }
        this.showCompareSection = false;
        this.productList = [];
        this.productIdList = [];
    }
    get productListSize() {
        if (this.productList.length > 1) {
            return true;
        } else {
            return false;
        }
    }
    removeProduct(event) {
        this.productList = this.productList.filter(item => item !== event.currentTarget.dataset.id);       
        let checkboxes = this.template.querySelectorAll('[type="checkbox"]');
        for (let i = 0; i < checkboxes.length; i++) {

            if (checkboxes[i].dataset.name === event.currentTarget.dataset.id) {
                checkboxes[i].checked = false;
            }
        }
        if (this.productList.length === 0) {
            this.showCompareSection = false;
        }
    }   
    connectedCallback() {
          let data = [];
        for(let i=0; i < 1 ; i++){
            data.push({
                category: 'business',
                family: 'transactional',
                quantity: '1',
                sku: 'ZMMB',
                productName: 'mymobiz business account',
                price:'7',
                currencycode:'ZAR'
            },
            {
                category: 'business',
                family: 'transactional',
                quantity: '1',
                sku: 'ZMBP',
                productName: 'mymobiz plus business account',
                price:'155',
                currencycode:'ZAR'
            }
            )
        }
        this.adobePageTag.ecommerce.product = data;
        loadScript(this, FireAdobeEvents).then(() => {
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                window.fireproductViewEvent(this, this.adobePageTag.ecommerce);

               
            }
        })
    }
    renderedCallback() {
        if (this.productList.length === 3) {
            let checkboxes = this.template.querySelectorAll('[type="checkbox"]');
            for (let i = 0; i < checkboxes.length; i++) {
                if (!checkboxes[i].checked) {
                    checkboxes[i].disabled = true;
                }
            }
        } else {
            let checkboxes = this.template.querySelectorAll('[type="checkbox"]');
            for (let i = 0; i < checkboxes.length; i++) {
                if (!checkboxes[i].checked) {
                    checkboxes[i].disabled = false;
                }
            }
        }
    }

    applyOnline(event) {
        let productId = null;
        let pricingOption = null;
        if (event.target.dataset.id === 'myMoBiz') {
            productId = '4648';
            pricingOption = 'ZMMB';
            window.fireButtonClickEvent(this, event);
            let data= [{
                category: 'business',
                family: 'transactional',
                quantity: '1',
                sku: 'ZMMB',
                productName: 'mymobiz business account',
                price:'7',
                currencycode:'ZAR'
            }];
            this.adobePageTag.ecommerce.product = data;

            window.cartAddEvent(this, this.adobePageTag.ecommerce);
        }
        if (event.target.dataset.id === 'myMoBizPlus') {
            productId = '4648';
            pricingOption = 'ZMBP';
            window.fireButtonClickEvent(this, event);
            let data=[{
                category: 'business',
                family: 'transactional',
                quantity: '1',
                sku: 'ZMBP',
                productName: 'mymobiz plus business account',
                price:'155',
                currencycode:'ZAR'
            }];
            this.adobePageTag.ecommerce.product= data;
            window.cartAddEvent(this, this.adobePageTag.ecommerce);
        }
        if (productId != null) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Before_We_Begin__c'
                },
                state: {
                    prodId: productId,
                    prOpt: pricingOption
                }
            });
        }
    }
   
    currentAccountApplyNowLinkclick(event) {
        window.fireButtonClickEvent(this, event);
    }
    currentAccountTellMeMoreLinkclick(event) {
        window.fireButtonClickEvent(this, event);
    }
    bizlaunchTellMeMoreLinkclick(event) {
        window.fireButtonClickEvent(this, event);
    }
    compareProducts(event) {
        window.fireButtonClickEvent(this, event);
        let defaultStr = 'prodee6a491580852610VgnVCM1000008711960aRCRD:[';
        let prodList = this.productIdList.toString();
        let end = ']';
        let concatAll = defaultStr.concat(prodList, end);
        if (this.productIdList) {
            localStorage.setItem('comparison', concatAll);
            sessionStorage.setItem('comparison',concatAll);
        }
    }
    moreinformationclick(event) {
        window.fireButtonClickEvent(this, event);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Business_Preapplication_Page__c'
            }
        });
    }

    navigateToDetailsPage(event) {
        window.fireButtonClickEvent(this, event);
        let productId = null;
        let pricingOption = null;
        if (event.target.dataset.id === 'myMoBiz') {
            productId = '4648';
            pricingOption = 'ZMMB';
        }
        if (event.target.dataset.id === 'myMoBizPlus') {
            productId = '4648';
            pricingOption = 'ZMBP';
        }
        if (productId != null) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'mymobiz_business_account__c'
                },
                state: {
                    prodId: productId,
                    prOpt: pricingOption
                }
            });
        }
    }
}