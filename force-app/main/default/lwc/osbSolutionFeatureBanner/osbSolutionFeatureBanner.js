import { LightningElement, api } from 'lwc';

export default class OsbSolutionFeatureBanner extends LightningElement {
    @api image1;
    @api title1;
    @api mainContent1;
    @api image2;
    @api title2;
    @api mainContent2;
    @api image3;
    @api title3;
    @api mainContent3;
    @api image4;
    @api title4;
    @api mainContent4;
    @api backgroundColor;
    @api itemCount;
    @api mainTitle;
    @api showMainTitle = 'true';
    showOne;
    showTwo;
    showThree;
    showFour;
      
    connectedCallback(){
        if(this.itemCount == 1){
            this.showOne = true;
        }else if(this.itemCount == 2){
            this.showOne = true;
            this.showTwo = true;
        }else if(this.itemCount == 3){
            this.showOne = true;
            this.showTwo = true;
            this.showThree = true;
        }else if(this.itemCount == 4){
            this.showOne = true;
            this.showTwo = true;
            this.showThree = true;
            this.showFour = true;
        }
    }

    renderedCallback(){
        this.template.querySelector('[data-id="main-div"]') ? this.template.querySelector('[data-id="main-div"]').style.backgroundColor = this.backgroundColor : '';
        if(this.itemCount == 1){
            this.template.querySelector('[data-id="container-one"]').classList.add('slds-large-size--8-of-8');
        }else if(this.itemCount == 2){
            this.template.querySelector('[data-id="container-two"]').classList.add('slds-large-size--4-of-8');
            this.template.querySelector('[data-id="container-one"]').classList.add('slds-large-size--4-of-8');
        }else if(this.itemCount == 3){
            this.template.querySelector('[data-id="container-three"]').classList.add('slds-large-size--4-of-12');
            this.template.querySelector('[data-id="container-two"]').classList.add('slds-large-size--4-of-12');
            this.template.querySelector('[data-id="container-one"]').classList.add('slds-large-size--4-of-12');
        }else if(this.itemCount == 4){
            this.template.querySelector('[data-id="container-four"]').classList.add('slds-large-size--2-of-8');
            this.template.querySelector('[data-id="container-three"]').classList.add('slds-large-size--2-of-8');
            this.template.querySelector('[data-id="container-two"]').classList.add('slds-large-size--2-of-8');
            this.template.querySelector('[data-id="container-one"]').classList.add('slds-large-size--2-of-8');
        }
    }
}