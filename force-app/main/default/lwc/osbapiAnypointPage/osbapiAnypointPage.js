import { api, LightningElement, wire } from 'lwc';
import getAnypointPage from '@salesforce/apex/OSB_OD_ProductDetails_CTRL.getAnypointPage';
import showdown from '@salesforce/resourceUrl/showdown';
import { loadScript } from 'lightning/platformResourceLoader';

export default class OsbapiAnypointPage extends LightningElement {
    @api recordId;
    @api pageName;

    pageContent;
    isImage;
    image;
    html;

    @wire(getAnypointPage, { recordId: '$recordId', pageName: '$pageName' })
    WiredGetAnypointPage({ data }) {
        if (data) {
            this.pageContent = data;
            this.isImage = this.pageName === 'Banner Image';
            this.image = (this.isImage) ? this.convertLinkToImage(this.pageContent) : '';
            this.convertMarkdownToHtml();
        }
    }

    convertMarkdownToHtml() {
        if (this.pageContent) {
            loadScript(this, showdown).then(() => {
                let converter = new window.showdown.Converter({ tables: true });
                let html = converter.makeHtml(this.pageContent);
                this.html = html;
            });
        }
    }

    convertLinkToImage(data) {
        let tempArr = data.split('(');
        tempArr[1] = tempArr[1].slice(0, -1);
        return tempArr[1];
    }
}