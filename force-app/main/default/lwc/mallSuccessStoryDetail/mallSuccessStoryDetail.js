import { LightningElement, wire } from 'lwc';
import getSuccessStoriesByIds from '@salesforce/apex/MallDataService.getSuccessStoriesByIds';
import { mallStateName, getUserState } from "c/sbgUserStateUtils";
import DEFAULT_MALL_COUNTRY from '@salesforce/label/c.DEFAULT_MALL_COUNTRY';
import DEFAULT_MALL_LANGUAGE_ISO from '@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO';
import { CurrentPageReference } from "lightning/navigation";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";

const HIDDEN_CLASS = "";
const VISIBLE_CLASS = "active";
const CAROUSEL_CLASS = "carousel-item"
const PAGINATION_CLASS = "pagination-item"

export default class MallSuccessStoryDetail extends LightningElement {

    storyId;
    successStory;
    slides;
    embededVideoURl;
    formattedPublishedDate;
    quotationMark = "data:image/svg+xml,%3Csvg width='40' height='59' viewBox='0 0 27 39' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M13.4801 0C21.3071 0 26.9571 6.04966 26.9569 15.0072C26.9067 28.0219 16.4565 37.2237 1.38062 38.9909C-0.0180623 39.1548 -0.557377 37.3408 0.730632 36.8046C6.51538 34.3964 9.43698 31.3405 9.81435 28.3157C10.0963 26.0559 8.78414 24.0763 7.13652 23.7057C2.86512 22.7447 0.00324639 17.7646 0.00324639 12.6176C0.00324639 5.64908 6.03706 0 13.4801 0Z' fill='url(%23paint0_linear_22637_1389)'/%3E%3Cdefs%3E%3ClinearGradient id='paint0_linear_22637_1389' x1='0.683239' y1='2.44324' x2='33.2755' y2='11.9241' gradientUnits='userSpaceOnUse'%3E%3Cstop stop-color='%23FF681D'/%3E%3Cstop offset='1' stop-color='%23FFB81D'/%3E%3C/linearGradient%3E%3C/defs%3E%3C/svg%3E%0A";

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.storyId = currentPageReference?.attributes?.recordId;
            this.getSuccessStory(this.storyId);
        }
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }

    async getSuccessStory(storyId) {
        try {
			let mallStateConfig = {};
			mallStateConfig.mallUserSelectedCountry = getUserState(mallStateName.mallUserSelectedCountry, DEFAULT_MALL_COUNTRY);
			mallStateConfig.mallUserSelectedLanguage = getUserState(mallStateName.mallUserSelectedLanguageISOCode, DEFAULT_MALL_LANGUAGE_ISO);
			let successStory = await getSuccessStoriesByIds({ mallContext: JSON.stringify(mallStateConfig), successStoryIds: [storyId]});
			if(successStory && successStory.length > 0) {
                this.successStory = successStory[0];
                this.formattedPublishedDate = this.successStory.publishedFrom ? this.formatDate(this.successStory.publishedFrom) : '';
                this.embededVideoURl = this.successStory.videoTestimonyUrl.replace('/watch?v=', '/embed/');
                this.setContentArray(this.successStory.galleryImages);
            }
		} catch (error) {
			this.error = error;
		}
    }

    setContentArray(data) {
        this.slides = data.map((item)=>{
            return {
                image: item
            }
        });
    }

    formatDate(date) {
        let objectDate = new Date(date);
        let day = objectDate.getDate();
        let month = objectDate.getMonth();
        let year = objectDate.getFullYear();
        return (day + '/' + month + '/' + year);
    }
}