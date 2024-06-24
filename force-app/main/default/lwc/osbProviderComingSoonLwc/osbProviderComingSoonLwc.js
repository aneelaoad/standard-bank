import { LightningElement, wire, api } from 'lwc';
import getImageURL from '@salesforce/apex/OSB_SolutionCaseImage.getImageURL';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images_Two';
import getProviderSolutionShowcase from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getProviderSolutionShowcase';
import Id from '@salesforce/user/Id';

export default class OsbProviderComingSoonLwc extends LightningElement {
    
    solIntro;
    solTitle;
    displayProviderComingSoonSolutions = [];
    solOwner = false;
    ComingSoonSolutionsRequest = false;
    ComingSoonImage;
    ImagePlaceholder = OSB_Images;
    isLoading = true;
    @api providerid;
    userId = Id;

    @wire(getProviderSolutionShowcase, { providerId: '$providerid', userId: '$userId' })
    getProviderSolutionShowcase({ error, data }) {
        this.isLoading = true;
        if (data) {
            let articles = JSON.parse(JSON.stringify(data));           
            let providerComingSoonSolutions = [];
            this.isLoading = false;
            for (let j = 0; j < articles.length; j++) {
                if (articles[j].Is_coming_soon__c) {
                    providerComingSoonSolutions.push(articles[j]);
                }              
            }
            this.displayProviderComingSoonSolutions = providerComingSoonSolutions;

            if (this.displayProviderComingSoonSolutions.length) {              
                let randNum = Math.floor(Math.random() * this.displayProviderComingSoonSolutions.length);
                this.comingSolution = this.displayProviderComingSoonSolutions[randNum];
                this.solTitle = this.comingSolution.Title;               
                this.solIntro = this.comingSolution.Introduction__c;
                let imageUrl = this.comingSolution.Image__c;
                getImageURL({ url: imageUrl })
                    .then((data) => {
                        if (data) {
                            this.ComingSoonImage = data;
                        }
                    }).catch((error) => {
                        this.error = error;
                    });
                    if( this.comingSolution.Application_Owner__c === '3rd Party'){
                        this.solOwner = true;
                    }else{
                        this.solOwner = false;
                    }
                this.isLoading = false;
                this.ComingSoonSolutionsRequest = true;
            } else {
                this.ComingSoonSolutionsRequest = false;
            }
        } else if (error) {
            this.error = error;
        }
    }
}