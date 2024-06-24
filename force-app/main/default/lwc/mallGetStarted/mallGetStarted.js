import { LightningElement ,wire} from 'lwc';
import Resources from "@salesforce/resourceUrl/sbgVisualAssets";
import getSolutionLinks from '@salesforce/apex/MallSolutionsController.getSolutionLinks';

export default class MallGetStarted extends LightningElement {
  


    solutionsData = []

    @wire(getSolutionLinks)
    wiredSolutionLinks({ error, data }) {
        if (data) {
            // this.solutionsData = data;
            console.log('data : ',JSON.stringify( data));
            this.solutionsData = data.map(solution => ({
                ...solution,
                image: `${Resources}${solution.imageUrl}`
            }));
            console.log('OUTPUT : ',JSON.stringify( this.solutionsData));

        } else if (error) {
            console.error('error fetching solution:',error);
        }
    }
}