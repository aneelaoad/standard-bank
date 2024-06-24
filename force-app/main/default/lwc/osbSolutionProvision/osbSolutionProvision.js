import { LightningElement, api } from 'lwc';

export default class OsbSolutionProvision extends LightningElement {
    @api title;
    @api listItems;
    @api image = '/RelyDesktop.png';
    @api backgroundColor ='#ffffff';
    @api subtitle;
    @api setClassForImage = ('slds-medium-size--3-of-8', 'slds-small-size--8-of-8',  'slds-large-size--6-of-12');

    renderedCallback(){
        let leftContainer = this.template.querySelector('[data-id="left-column"]');
        let rightContainer = this.template.querySelector('[data-id="right-column"]');
        let list = this.listItems.split('*');
        list.forEach(function (value, i) {
            if(i < list.length /2){
                let element = ('<div class="slds-col slds-m-vertical_large">'+
                                '<p>'+value+'</p>'+
                            '</div>');
                            leftContainer.innerHTML += element;
            }else{
                let element = ('<div class="slds-col slds-m-vertical_large">'+
                                '<p>'+value+'</p>'+
                            '</div>');
                            rightContainer.innerHTML += element;
            }
        });
        this.template.querySelector('[data-id="teaserosb"]').style.backgroundColor = this.backgroundColor;
        this.template.backgroundColor = this.backgroundColor;
        let styleArray = this.setClassForImage.split(',');
        this.template.querySelector('[data-id="image-container"]').classList.add(...styleArray);
    }
}