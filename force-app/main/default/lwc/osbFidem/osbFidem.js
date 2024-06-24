import { LightningElement, wire, track } from 'lwc';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images_Two';
import getCustomURL from '@salesforce/apex/OSB_RequestPage_CTRL.getCustomURL';

export default class OsbFidem extends LightningElement {
    FidemLogo = OSB_Images + '/OSB_Images_Two/Fidem_Request_PageSVG.svg';
    LargeHeadingImage = OSB_Images + '/FidemLargeImage.png';
    LiveAuctionsImage = OSB_Images + '/LiveAuctions.png';
    PrivateTransactionImage = OSB_Images + '/PrivateTransactions.png';
    MarketInsightsImage = OSB_Images + '/MarketSites.png';
    MarketSoundImage = OSB_Images + '/MartketSounding.png';
    PaperworkImage = OSB_Images + '/Paperwork.png';
    NotificationImage = OSB_Images + '/Notifications.png';
    LaptopImage = OSB_Images + '/FidemLaptop.png';
    solutionName = 'Fidem_Registration_Url';
    @track fidemurl;

    @wire(getCustomURL, {solutionName: '$solutionName'})
    getCustomURL({error,data}){
        if(data){
            this.fidemurl =data;
        }
    }
    
}