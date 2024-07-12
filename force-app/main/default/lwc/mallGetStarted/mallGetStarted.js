import { LightningElement ,wire} from 'lwc';
import Resources from "@salesforce/resourceUrl/sbgVisualAssets";
import getSolutionLinks from '@salesforce/apex/CTRL_MallSolutions.getSolutionLinks';
import getOfferings from '@salesforce/apex/OfferingsSelector.getContentUnitTranslationsForOfferingsByCategory';

export default class MallGetStarted extends LightningElement {
  
    offeringsData = []

    solutionsData = []

    @wire(getSolutionLinks)
    wiredSolutionLinks({ error, data }) {
        if (data) {
            // this.solutionsData = data;
            //console.log('data : ',JSON.stringify( data));
            this.solutionsData = data.map(solution => ({
                ...solution,
                image: `${Resources}${solution.imageUrl}`
            }));
            //console.log('OUTPUT : ',JSON.stringify( this.solutionsData));

        } else if (error) {
            //console.error('error fetching solution:',error);
        }
    }

    // @wire(getOfferings)
    // wriedOfferings({ error, data }) {
    //     if (data) {
    //     this.offeringsData = data
    //      console.log('offeringsData: ', JSON.stringify(this.offeringsData));

    //     } else if (error) {
    //         console.error('error fetching solution:',error);
    //     }
    // }
}