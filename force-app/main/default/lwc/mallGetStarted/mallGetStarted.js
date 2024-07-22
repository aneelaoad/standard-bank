import { LightningElement, wire } from 'lwc';
import Resources from "@salesforce/resourceUrl/sbgVisualAssets";
import getSolutionLinks from '@salesforce/apex/CTRL_MallSolutions.getSolutionLinks';
// import getOfferings from '@salesforce/apex/OfferingsSelector.getContentUnitTranslationsForOfferingsByCategory';
import getTagOfferingsByCategoryNames from "@salesforce/apex/MallDataService.getTagOfferingsByCategoryNames";


export default class MallGetStarted extends LightningElement {


    solutionsData = []
    offeringsList = []

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




 // ------------------------------
    connectedCallback() {


        getTagOfferingsByCategoryNames()
            .then(result => {
                this.offeringsList = result;
                console.log('Tag Offerings:', this.offeringsList);
                this.offeringsList.forEach(element => {
                    console.log('offering: ', element.name);
                });

            })
            .catch(error => {
                console.error('Error fetching tag offerings:', error);
                // Handle error
            });
    }


}