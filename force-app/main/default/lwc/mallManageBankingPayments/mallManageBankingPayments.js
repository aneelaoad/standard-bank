import { LightningElement , wire} from 'lwc';
import mallHomeManagePayments from "@salesforce/resourceUrl/mallHomeManagePayments";
import getAppStoreLinks from '@salesforce/apex/LinksSelector.getAppStoreLinks';
import getContentUnitTranslations from '@salesforce/apex/LinksSelector.getContentUnitTranslationsForOfferingsByCategory';
import DownloadAppHeading from '@salesforce/label/c.DownloadAppHeading';
import DownloadAppDescription from '@salesforce/label/c.DownloadAppDescription';


export default class MallManageBankingPayments extends LightningElement {



    customLabels = {
        DownloadAppHeading,
        DownloadAppDescription
    };

    phoneImage = mallHomeManagePayments+'/manage_payment-phone.png';
    // appleIcn = mallHomeManagePayments+'/apple_icn.png';
    // googleIcn = mallHomeManagePayments+'/playstore_icn.png';
    // huaweiIcn = mallHomeManagePayments+'/huawei_icn.png';


    iconUrls = {
        apple: `${mallHomeManagePayments}/apple_icn.png`,
        google: `${mallHomeManagePayments}/playstore_icn.png`,
        huawei: `${mallHomeManagePayments}/huawei_icn.png`
    };

    links=[];
    error;

    @wire(getAppStoreLinks)
    wiredLinks({ error, data }) {
        if (data) {
            this.links = data;
            // console.log('links', JSON.stringify( this.links));
          
            this.links = data.map(link => ({
                ...link,
                iconUrl: this.getIconUrl(link.tagName)
            }));
          
           
        } else if (error) {
            this.error = error;
            console.log('error fetching links', this.error);

            this.links = undefined;
        }
    }
    getIconUrl(tagName) {
        switch(tagName.toLowerCase()) {
            case 'apple':
                return this.iconUrls.apple;
            case 'google':
                return this.iconUrls.google;
            case 'huawei':
                return this.iconUrls.huawei;
            default:
                return '';
        }
    }

    @wire(getContentUnitTranslations)
    wiredTranslation({error, data}) {
        if (error) {
            // TODO: Error handling
            console.log('error fetching translation');
        } else if (data) {
            console.log('translations: ', JSON.stringify(data));
        }
    }
}