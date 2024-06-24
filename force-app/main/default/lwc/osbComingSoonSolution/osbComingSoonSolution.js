import { LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getSolutions from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutionShowcase';
import getImageURL from '@salesforce/apex/OSB_SolutionCaseImage.getImageURL';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images_Two';

export default class osbComingSoonSolution extends LightningElement {
    userId = Id;
    solIntro;
    solTitle;
    ComingSoonSolutionsRequest = false;
    solOwner = false;
    ComingSoonImage;
    ImagePlaceholder= OSB_Images;
    isLoading = true;

    @wire(getSolutions, ({userId : '$userId'}))
    getSolutions({ error, data}){
        if(data){       
            let mySolutions = JSON.parse(JSON.stringify(data)) ;
            let comingsoonSolutions = [];
            for(let i=0; i < mySolutions.length; i++){
                if(mySolutions[i].Is_coming_soon__c){
                    comingsoonSolutions.push(mySolutions[i]);
                }
            }
            if(comingsoonSolutions.length){
                let randNum = Math.floor(Math.random() * comingsoonSolutions.length);
                this.comingSolution = comingsoonSolutions[randNum];
                this.solTitle = this.comingSolution.Title;
                let imageUrl = this.comingSolution.Image__c;
                getImageURL({url: imageUrl})
                .then(data => {
                    if(data){
                      this.ComingSoonImage = data;
                    }
                })
                .catch(error => {
                    this.error = error;
                })
                this.solIntro = this.comingSolution.Introduction__c;
                if( this.comingSolution.Application_Owner__c === '3rd Party'){
                    this.solOwner = true;
                }else{
                    this.solOwner = false;
                }
                this.isLoading = false;
                this.ComingSoonSolutionsRequest = true;
            } else{
                this.ComingSoonSolutionsRequest = false;
            }            
        }else if(error){
            this.error = error;
        }
    }
}