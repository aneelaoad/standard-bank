import { LightningElement, wire, api } from 'lwc';
import getProviderSolutionShowcase from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getProviderSolutionShowcase';
import getProviderSpaces from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getProviderSpaces';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import getInsights from '@salesforce/apex/OSB_InsightsHub_CTRL.getInsights';
import OSB_Logo from '@salesforce/resourceUrl/OSB_logoBadge';
import Id from '@salesforce/user/Id';

export default class OsbProviderSolutionsPage extends LightningElement {

    @api providername;
    @api solutionid;
    @api providerid;
    @api providertitle;
    showInsights = false;
    showComingSoon = false;
    displayProvider = [];
    displayProviderSolutions = [];
    displayProviderInsight;
    displayProviderComingSoonSolutions = [];
    SBlogo = OSB_Logo;
    providerLogo;
    providerInsightSolution;
    isLoading;
    userId = Id;


    @wire(getProviderSpaces, { providerId: '$providerid' })
    getProviderSpace({ error, data }) {

        if (data) {
            let articles = JSON.parse(JSON.stringify(data));
            let provider = [];
            for (let j = 0; j < articles.length; j++) {
                provider.push(articles[j]);
            }
            this.displayProvider = provider;

        } else if (error) {
            this.error = error;
        }

    }


    @wire(getProviderSolutionShowcase, { providerId: '$providerid', userId: '$userId' })
    getSolutions({ error, data }) {
        this.isLoading = true;
        if (data) {
            let articles = JSON.parse(JSON.stringify(data));           
            let providerSolutions = [];
            let providerComingSoonSolutions = [];
            this.isLoading = false;
            for (let j = 0; j < articles.length; j++) {
                if (!articles[j].Is_coming_soon__c) {
                    providerSolutions.push(articles[j]);
                } else {
                    providerComingSoonSolutions.push(articles[j]);
                }
            }

            this.displayProviderSolutions = providerSolutions.sort((a, b) => { return (a.Title > b.Title ? 1 : -1); });

            this.displayProviderComingSoonSolutions = providerComingSoonSolutions;

            if (this.displayProviderComingSoonSolutions.length) {
                this.showComingSoon = true;
            } else {
                this.showComingSoon = false;

            }
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
    }

    @wire(getInsights)
    wiredInsights({ error, data }) {

        if (data) {
            let articles = JSON.parse(JSON.stringify(data));
            articles = articles.KnowledgeList;
            let providerInsights = [];
            for (let k = 0; k < articles.length; k++) {
                if ( articles[k].Provider_Knowledge_Article__c === this.providerid) {
                    providerInsights.push(articles[k]);
                }
            }
            this.displayProviderInsight = providerInsights;
            if (this.displayProviderInsight.length) {
                this.showInsights = true;

            } else {
                this.showInsights = false;
            }

        } else if (error) {
            this.error = error;
        }
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }
}