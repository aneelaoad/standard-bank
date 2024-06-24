import { LightningElement } from 'lwc';

export default class AcmQuestionsAndAnswers extends LightningElement {

        isInternal = false;
        isExternal = false;

        optionA = true;
        optionB;
        optionC;
        optionD;

          selectedA(){
            this.optionA = true;
            this.optionB = false;
            this.optionC = false;
            this.optionD = false;
            this.template.querySelector('.itemA').classList.add('active');
            this.template.querySelector('.itemB').classList.remove('active');
            this.template.querySelector('.itemC').classList.remove('active');
            this.template.querySelector('.itemD').classList.remove('active');
            return this.optionA;
          }

          selectedB(){
            this.optionA = false;
            this.optionB = true;
            this.optionC = false;
            this.optionD = false;
            this.template.querySelector('.itemA').classList.remove('active');
            this.template.querySelector('.itemB').classList.add('active');
            this.template.querySelector('.itemC').classList.remove('active');
            this.template.querySelector('.itemD').classList.remove('active');
            return this.optionB;
          }
          

          selectedC(){
            this.optionA = false;
            this.optionB = false;
            this.optionC = true;
            this.optionD = false;
            this.template.querySelector('.itemA').classList.remove('active');
            this.template.querySelector('.itemB').classList.remove('active');
            this.template.querySelector('.itemC').classList.add('active');
            this.template.querySelector('.itemD').classList.remove('active');
            return this.optionC;
          }

          selectedD(){
            this.optionA = false;
            this.optionB = false;
            this.optionC = false;
            this.optionD = true;
            this.template.querySelector('.itemA').classList.remove('active');
            this.template.querySelector('.itemB').classList.remove('active');
            this.template.querySelector('.itemC').classList.remove('active');
            this.template.querySelector('.itemD').classList.add('active');
            return this.optionD;
          }

          connectedCallback() {
            if (window.location.pathname.indexOf('internalapimarketplace')> 0){
              this.isInternal = true;
            } else {
              this.isExternal = true;
            }
          }


        }