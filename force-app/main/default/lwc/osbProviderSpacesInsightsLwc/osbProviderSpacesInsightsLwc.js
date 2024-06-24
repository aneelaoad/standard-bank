import { LightningElement, api } from 'lwc';
import OSB_Col_Icon from '@salesforce/resourceUrl/OSB_col_Icon';
import getImageURL from '@salesforce/apex/OSB_SolutionCaseImage.getImageURL';
export default class OsbProviderSpacesInsightsLwc extends LightningElement {

  
    @api introduction;
    @api title;    
    @api insightsimage;
    @api externalurl;
    @api providername;
    OSB_Col_Icon = OSB_Col_Icon;
    displayProviderInsight = [];
    providerid;
    image;

    renderedCallback() {
        let imageUrl = this.insightsimage;
        getImageURL({ url: imageUrl })
            .then((data) => {
                if (data) {
                    this.image = data;
                }
            })
            .catch((error) => {
                this.error = error;
            });

    }
}