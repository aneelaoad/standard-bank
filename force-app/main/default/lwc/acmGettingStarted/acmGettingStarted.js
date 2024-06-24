import { LightningElement, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/GettingStarted';

export default class AcmGettingStarted extends LightningElement {
    @api title;
    @api subtext;
    
    imageSearch = Assets + '/getting-started-icons/search.png';
    imageRegister = Assets + '/getting-started-icons/login.png';
    imageSubscribe = Assets + '/getting-started-icons/email.png';
    imagePlay = Assets + '/getting-started-icons/play_circle_filled.png';
    imageBuild = Assets + '/getting-started-icons/build.png';
}