import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import owlcarousel from '@salesforce/resourceUrl/owlcarousel';
import Bannerimg from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import { NavigationMixin } from 'lightning/navigation';
import standardbankurl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import Liketoapplyfor from '@salesforce/label/c.PBP_ZA_IwouldLiketoApplyFor';
import needhelp from '@salesforce/label/c.PBP_ZA_NeedHelp';
import GrowMyBusiness from '@salesforce/label/c.PBP_ZA_GrowMyBusiness';
import ImportandExport from '@salesforce/label/c.PBP_ZA_ImportandExport';
import RewardsforMyBusiness from '@salesforce/label/c.PBP_ZA_RewardsforMyBusiness';
import BusinessAccount from '@salesforce/label/c.PBP_ZA_BusinessAccount';
import UcountSBurl from '@salesforce/label/c.PBP_ZA_UcountSBurl';
import pleaseselect from '@salesforce/label/c.AOB_SelectPlaceHolder';
import riseabove from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import PBP_ZA_siteUrl from '@salesforce/label/c.PBP_ZA_siteURL';

export default class Pbp_comp_product_business_homeBanner extends NavigationMixin(LightningElement) {
    initialRender = false;
    Africatrade= riseabove+'/assets/images/34372_MyMo_Biz_B2_website banners_600x300.jpg';
    SB_Business_Banner_image = Bannerimg + '/assets/images/EnterpriseBanking_RiseAboveTheNoise.jpg';
    downarrow = Bannerimg + '/assets/images/downarrow.png';
    bannerdata = [{ 'title': 'Rise above the noise', 'subtitle':'Let us help you start, manage, and grow your business with our innovative business solutions.', 'button': 'TELL ME MORE','image': riseabove+'/assets/images/EnterpriseBanking_RiseAboveTheNoise.jpg'},
    { 'title': 'Africa Trade Barometer Report', 'subtitle': 'Insights and analyses with comprehensive research reports on the state of trade on the African continent.', 'button': 'READ MORE','image': riseabove+'/assets/images/SB_TradeBarometer.jpg' },
    { 'title': 'Get an affordable business account.', 'subtitle': 'Get everything you need to run a successful business, with our MyMoBiz Account', 'button': 'FIND OUT MORE','image': riseabove+'/assets/images/34372_MyMo_Biz_B2_website banners_600x300.jpg' },
    { 'title': 'Your business never sleeps, neither will we', 'subtitle': 'With a Business Overdraft, you never have to wait for working hours to run your business. Get round-the-clock access to funds when you need them.', 'button': 'APPLY ONLINE','image': riseabove+'/assets/images/your_business_neversleeps.jpg' },
    { 'title': 'Need a flexible business loan?', 'subtitle': 'Grow your business with a short-term BizFlex loan and repay as you earn revenue.', 'button': 'TELL ME MORE','image': riseabove+'/assets/images/BizFlex_loan_600x300.jpg' }];
    cancelButtonText;
    @track value;
    standardbankurl
    get selectedoption() {
        return [
            { label: 'MyMoBiz Account', value: 'MyMoBiz Account' },
            { label: 'Business Overdraft', value: 'Business Overdraft' },
            { label: 'Business 32 Day Notice Account', value: 'Business 32 Day Notice Account' },
            { label: 'Business Credit Card', value: 'Business Credit Card' },
            { label: 'Business Term Loan', value: 'Business Term Loan' },
            { label: 'Small Business Insurance', value: 'Small Business Insurance' },
            { label: 'SimplyBlu', value: 'SimplyBlu' },
            { label: 'Point of sale Device', value: 'Point of sale Device' },
        ];
    };
    label = {
        Liketoapplyfor,
        needhelp,
        ImportandExport,
        GrowMyBusiness,
        RewardsforMyBusiness,
        BusinessAccount,
        pleaseselect,
        standardbankurl
    }
    isEventFired;
    adobePageTag = {

        dataId: "Informational",
        dataIntent: "hero banner",
        dataScope: this.bannerdata.title,
        datascopeneedhelp:needhelp,
        dataScopeLiketoapplyfor:Liketoapplyfor,
        GrowMyBusinesslink: GrowMyBusiness +" link click",
        ImportandExportlink: ImportandExport +" link click",
        RewardsforMyBusinesslink: RewardsforMyBusiness +" link click",
        BusinessAccountlink: BusinessAccount +" link click",

    };
    GrowMyBusinessurl = standardbankurl + '/southafrica/business/bizconnect';
    ImportandExporturl = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point';
    RewardsforMyBusinessurl = UcountSBurl + '/business/';
    BusinessAccount= standardbankurl + '/southafrica/business/products-and-services/bank-with-us/switch-your-bank-account';
    handleChange(event) {
        window.fireButtonClickEvent(this, event);
        var selectedvalue = event.target.value;
        if (selectedvalue == 'MyMoBiz Account') {
            window.open(PBP_ZA_siteUrl + "/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/mymobiz-business-account", "_self");
        }
        if (selectedvalue == 'Business Overdraft') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/business-overdraft", standardbankurl);
           
        }
        if (selectedvalue == 'Business 32 Day Notice Account') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/our-accounts/32-day-notice-deposit", standardbankurl);
        }
        if (selectedvalue == 'Business Credit Card') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/bank-with-us/company-cards/our-cards/corporate-credit-card", standardbankurl);
        }
        if (selectedvalue == 'Business Term Loan') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/business-term-loan", standardbankurl);
        }
        if (selectedvalue == 'Small Business Insurance') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/insure-what-matters", standardbankurl);
        }
        if (selectedvalue == 'SimplyBlu') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/business-solutions/specialised/simplyblu", standardbankurl);
        }
        if (selectedvalue == 'Point of sale Device') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions", standardbankurl);
        }
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
                        const carousel = this.template.querySelector('div[class="bs_carousel1 owl-theme owl-carousel offering-owl1"]');

                        window.$(carousel).owlCarousel({
                            loop: true,
                            nav: false,
                            navText: [
                                "<i class='fa fa-caret-left'></i>",
                                "<i class='fa fa-caret-right'></i>"
                            ],
                            dots: true,
                            autoplay: true,
                            autoHeight: true,
                            lazyLoad: false,
                            center: true,
                            responsive: {
                                0: {
                                    items: 1,
                                }
                            }
                        })
                    }
                    )
            }
            )
    }
    callingadobeevent(event){
        window.fireButtonClickEvent(this, event);
    }
    offers(event) {
      
        window.fireButtonClickEvent(this, event);
        
       if (event.target.value === 'Let us help you start, manage, and grow your business with our innovative business solutions.') {
            window.open(standardbankurl + "/southafrica/business/bizconnect/campaigns/rise-above-the-noise", standardbankurl);   
        }


        if (event.target.value ==='Insights and analyses with comprehensive research reports on the state of trade on the African continent.') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/business-solutions/trade-point/trade-barometer", standardbankurl);
          
        }

        if (event.target.value === 'Get everything you need to run a successful business, with our MyMoBiz Account') {
            window.open(PBP_ZA_siteUrl + "/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/mymobiz-business-account", "_self");
           
        }

        if (event.target.value === 'With a Business Overdraft, you never have to wait for working hours to run your business. Get round-the-clock access to funds when you need them.') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/business-overdraft", standardbankurl);
           
        }

        if (event.target.value === 'Grow your business with a short-term BizFlex loan and repay as you earn revenue.') {
            window.open(standardbankurl + "/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/bizflex-loan", standardbankurl);
           
        }
        
    }
}