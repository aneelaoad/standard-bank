import { LightningElement, track } from 'lwc';
import getAboutUsValuePropositions from '@salesforce/apex/MallAboutUsContainerCtrl.getAboutUsValuePropositions';
import mallBanners from '@salesforce/resourceUrl/mallBanners';
import DEFAULT_MALL_COUNTRY from '@salesforce/label/c.DEFAULT_MALL_COUNTRY';
import DEFAULT_MALL_LANGUAGE_ISO from '@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO';
import { mallStateName, getUserState } from "c/sbgUserStateUtils";
import MALL_ABOUT_US_SECTION_1_TITLE from '@salesforce/label/c.MALL_ABOUT_US_SECTION_1_TITLE';
import MALL_ABOUT_US_SECTION_1_CONTENT from '@salesforce/label/c.MALL_ABOUT_US_SECTION_1_CONTENT';
import MALL_ABOUT_US_SECTION_2_TITLE from '@salesforce/label/c.MALL_ABOUT_US_SECTION_2_TITLE';
import MALL_ABOUT_US_SECTION_2_CONTENT from '@salesforce/label/c.MALL_ABOUT_US_SECTION_2_CONTENT';
import MALL_ABOUT_US_SECTION_3_TITLE from '@salesforce/label/c.MALL_ABOUT_US_SECTION_3_TITLE';
import MALL_ABOUT_US_SECTION_3_CONTENT from '@salesforce/label/c.MALL_ABOUT_US_SECTION_3_CONTENT';
import MALL_ABOUT_US_BANNER_TITLE from '@salesforce/label/c.MALL_ABOUT_US_BANNER_TITLE';
import MALL_ABOUT_US_BANNER_SUBTEXT from '@salesforce/label/c.MALL_ABOUT_US_BANNER_SUBTEXT';

const ABOUT_US_RECORD_TYPE = "About_us";
const MALL_BANNER_IMG = mallBanners + "/about-us-3.jpg";

export default class MallAboutUsContainer extends LightningElement {
    @track titleAbout;
    @track contentAbout;
    @track titleShopper;
    @track contentShopper;
    @track titleSeller;
    @track contentSeller;
    @track valuePropositions = [];
    @track valuePropositionJson;
    @track aboutUsCollection = [];
    @track banner = {};
    @track contentLoaded = false;
    error;

    connectedCallback() {
        this.fetchAboutUsValuePropositions();
        this.processAboutUsSetUp();
        this.processBannerSetup();
    }

    async fetchAboutUsValuePropositions() {
        try {
            let valuePropositions = await getAboutUsValuePropositions();
            if(valuePropositions && valuePropositions.length > 0) {
                valuePropositions = this.sortData("Position__c", "asc", valuePropositions, "number");
                this.processValuePropositions(valuePropositions);
            }
            this.contentLoaded = true;
        } catch(error) {
            this.error = error;
        }
    }
    
    async getAboutUsContent() {
        try {
            let mallStateConfig = {};
            mallStateConfig.mallUserSelectedCountry = getUserState(mallStateName.mallUserSelectedCountry, DEFAULT_MALL_COUNTRY);
            mallStateConfig.mallUserSelectedLanguage = getUserState(mallStateName.mallUserSelectedLanguageISOCode, DEFAULT_MALL_LANGUAGE_ISO);
            let contents = await getContentsByCountryNamesAndRecordTypes({mallContext: JSON.stringify(mallStateConfig), countries: [mallStateConfig.mallUserSelectedCountry] , recordTypes: [ABOUT_US_RECORD_TYPE]});
            let aboutUsCollection = [];
            let banner;
            if(contents && contents.length > 0) {
                contents.forEach(content => {
                    if(content.section == "About us") {
                        aboutUsCollection.push(content);
                    }
                    else if(content.section == "Banner") {
                        banner = content;
                    }
                });
                if(banner) {
                    this.processBannerSetup(banner);
                }
                if(aboutUsCollection && aboutUsCollection.length > 0) {
                    aboutUsCollection = this.sortData("order", "asc", aboutUsCollection, "number");
                    this.aboutUsCollection = [...aboutUsCollection];
                    this.processAboutUsSetUp(this.aboutUsCollection);
                }
                this.contentLoaded = true;
            }
        }catch(error) {
            this.error = error;
        }
    }

    processValuePropositions(valuePropositions) {
        let valuePropositionsFormatted = [];
        if(valuePropositions && valuePropositions.length > 0) {
            for(let row=0; row < valuePropositions.length; row++) {
                let valuePropositionFormatted = {};
                valuePropositionFormatted["id"] = valuePropositions[row].Id;
                valuePropositionFormatted["title"] = valuePropositions[row].Label;
                valuePropositionFormatted["description"] = valuePropositions[row].Description__c;
                valuePropositionFormatted["image"] = valuePropositions[row].Image_Url__c;
                valuePropositionsFormatted.push(valuePropositionFormatted);
            }
            this.valuePropositions = [...valuePropositionsFormatted];
            this.valuePropositionJson = JSON.stringify(this.valuePropositions);
        }
    }

    processAboutUsSetUp() {
        this.titleAbout = MALL_ABOUT_US_SECTION_1_TITLE;
        this.contentAbout = MALL_ABOUT_US_SECTION_1_CONTENT;
        this.titleShopper = MALL_ABOUT_US_SECTION_2_TITLE;
        this.contentShopper = MALL_ABOUT_US_SECTION_2_CONTENT;
        this.titleSeller = MALL_ABOUT_US_SECTION_3_TITLE;
        this.contentSeller = MALL_ABOUT_US_SECTION_3_CONTENT;
    }

    processBannerSetup() {
        let banner = {};
        banner.bannerHeading = "";
        banner.bannerDescription = MALL_ABOUT_US_BANNER_TITLE;
        banner.bannerSubText = MALL_ABOUT_US_BANNER_SUBTEXT;
        banner.bannerAction = "navigateToUrl";
        banner.bannerVariant = "mall";
        banner.bannerButtonLabel = "Apply now";
        banner.bannerDisabled = false;
        banner.bannerButtonTitle = "Apply now";
        banner.bannerWClass = "wAuto";
        banner.bannerShowButton = false;
        banner.bannerImagePath = MALL_BANNER_IMG;
        banner.bannerImagePathTablet = MALL_BANNER_IMG;
        banner.bannerImagePathDesktop = MALL_BANNER_IMG;
        banner.bannerCustomBannerStyles = true;
        banner.bannerCustomBackgroundColour = "#17a8e2"
        banner.bannerApplyColourContrastInversion = true;
        banner.bannerInteractionTextBefore = MALL_ABOUT_US_BANNER_TITLE;
        banner.bannerInteractionScope = "about us";
        banner.bannerInteractionText = "Apply now";
        this.banner = {...banner};
    }

    sortData(fieldName, sortDirection, array, type) {
        let sortResult = [...array];
        let parser = (v) => v;
        if(type==='date' || type==='datetime') {
          parser = (v) => (v && new Date(v));
        }
        let sortMult = sortDirection === 'asc'? 1: -1;
        array = sortResult.sort((a,b) => {
          let a1 = parser(a[fieldName]), b1 = parser(b[fieldName]);
          let r1 = a1 < b1, r2 = a1 === b1;
          return r2? 0: r1? -sortMult: sortMult;
        });
        return array;
    }
}