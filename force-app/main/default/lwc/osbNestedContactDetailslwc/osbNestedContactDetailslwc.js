import { LightningElement, api } from 'lwc';

export default class OsbNestedContactDetailslwc extends LightningElement {

    @api Heading;
    @api itemCount;
    One = false;
    Two;
    Three;
    Four;
    Five;
    Six;
    Eight;

    @api header;
    @api headerButton;
    @api subTextOne;
    @api contactOne;
    @api contactOneNumber;
    @api contactOneEmail;
    @api Logo1;
    @api TitleOne;

    @api subTextTwo;
    @api contactTwoNumber;
    @api contactTwoEmail;
    @api Logo2;
    @api TitleTwo;

    @api subTextThree;
    @api contactThreeNumber;
    @api contactThreeEmail;
    @api Logo3;
    @api TitleThree;

    @api subTextFour;
    @api contactFourNumber;
    @api contactFourEmail;
    @api Logo4;
    @api TitleFour;

    @api subTextFive;
    @api contactFiveNumber;
    @api contactFiveEmail;
    @api Logo5;
    @api TitleFive;

    @api subTextSix;
    @api contactSixNumber;
    @api contactSixEmail;
    @api Logo6;
    @api TitleSix;

    @api subTextSeven;
    @api contactSevenNumber;
    @api contactSevenEmail;
    @api Logo7;
    @api TitleSeven;

    @api subTextEight;
    @api contactEightNumber;
    @api contactEightEmail;
    @api Logo8;
    @api TitleEight;

    @api headerButtonTwo;
    @api subTextOneofTwo;
    @api contactOneofTwo;
    @api contactOneNumberofTwo;
    @api contactOneEmailofTwo;
    @api Logo1of2;
    @api TitleOneofTwo;
    @api subTextTwoofTwo;
    @api contactTwoNumberofTwo;
    @api contactTwoEmailofTwo;
    @api Logo2of2;
    @api TitleTwoofTwo;
    @api subTextThreeofTwo;
    @api contactThreeNumberofTwo;
    @api contactThreeEmailofTwo;
    @api Logo3of2;
    @api TitleThreeofTwo;
    @api subTextFourofTwo;
    @api contactFourNumberofTwo;
    @api contactFourEmailofTwo;
    @api Logo4of2;
    @api TitleFourofTwo;
    @api subTextFiveofTwo;
    @api contactFiveNumberofTwo;
    @api contactFiveEmailofTwo;
    @api Logo5of2;
    @api TitleFiveofTwo;
    @api subTextSixofTwo;
    @api contactSixNumberofTwo;
    @api contactSixEmailofTwo;
    @api Logo6of2;
    @api TitleSixofTwo;
    @api subTextSevenofTwo;
    @api contactSevenNumberofTwo;
    @api contactSevenEmailofTwo;
    @api subTextEightofTwo;
    @api contactEightNumberofTwo;
    @api contactEightEmailofTwo;
    @api headerButtonThree;
    @api subTextOneofThree;
    @api contactOneofThree;
    @api contactOneNumberofThree;
    @api contactOneEmailofThree;
    @api Logo1of3;
    @api TitleOneofThree;
    @api subTextTwoofThree;
    @api contactTwoNumberofThree;
    @api contactTwoEmailofThree;
    @api Logo2of3;
    @api TitleTwoofThree;
    @api subTextThreeofThree;
    @api contactThreeNumberofThree;
    @api contactThreeEmailofThree;
    @api Logo3of3;
    @api TitleThreeofThree;
    @api subTextFourofThree;
    @api contactFourNumberofThree;
    @api contactFourEmailofThree;
    @api Logo4of3;
    @api TitleFourofThree;
    @api subTextFiveofThree;
    @api contactFiveNumberofThree;
    @api contactFiveEmailofThree;
    @api Logo5of3;
    @api TitleFiveofThree;
    @api subTextSixofThree;
    @api contactSixNumberofThree;
    @api contactSixEmailofThree;
    @api Logo6of3;
    @api TitleSixofThree;
    @api subTextSevenofThree;
    @api contactSevenNumberofThree;
    @api contactSevenEmailofThree;
    @api subTextEightofThree;
    @api contactEightNumberofThree;
    @api contactEightEmailofThree;

    renderedCallback() {
        this.template.querySelectorAll('button').forEach(element => {
            element.addEventListener('click', evt => {
                let panel = element.nextElementSibling;
                if (panel.style.maxHeight) {
                    element.classList.remove('active');
                    panel.style.maxHeight = null;
                } else {
                    element.classList.toggle('active');
                    panel.style.maxHeight = panel.scrollHeight + 'px';
                }
                this.template.querySelectorAll('button').forEach(el => {
                    let pan = el.nextElementSibling;
                    if (el != element) {
                        pan.style.maxHeight = null;
                        el.classList.remove('active');
                    }
                });
            });
        });
    }

    DropDown() {
        if (this.header !== "") {
        } else if (this.itemCount == 1) {
            this.One = true;
        } else if (this.itemCount == 2) {
            this.Two = true;
        } else if (this.itemCount == 3) {
            this.Three = true;
        } else if (this.itemCount == 4) {
            this.Four = true;
        } else if (this.itemCount == 5) {
            this.Five = true;
        } else if (this.itemCount == 6) {
            this.Six = true;
        } else if (this.itemCount == 7) {
            this.Seven = true;
        } else if (this.itemCount == 8) {
            this.Eight = true;
        }
    }
}