import { LightningElement, wire } from 'lwc';
import getInsights from '@salesforce/apex/OSB_InsightsHub_CTRL.getInsights';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import OSB_Images_Two from '@salesforce/resourceUrl/OSB_Images_Two';

export default class osbInsightsTabLwc extends LightningElement {
    ReadMore = OSB_Images_Two + '/ReadMoreArrow.svg';

    displayLeadership;
    displaySolutions;

    @wire(getInsights)
    wiredInsights({ error, data }) {
        if (data) {
            let articles = JSON.parse(JSON.stringify(data));
            articles = articles['KnowledgeList'];

            let ourLeadership = [];
            for (let j = 0; j < articles.length; j++) {
                if (articles[j].Is_Thought_Leadership__c) {
                    ourLeadership.push(articles[j]);
                }
            }
            this.displayLeadership = ourLeadership;

            let ourSolutions = [];
            for (let i = 0; i < 6; i++) {
                if (!articles[i].Is_Thought_Leadership__c) {
                    ourSolutions.push(articles[i]);
                }
            }
            this.displaySolutions = ourSolutions;
        } else if (error) {
            this.error = error;
        }
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }
}