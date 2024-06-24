import { LightningElement, api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { navigateToRecordPage } from 'c/mallNavigation';


export default class SbgHorizontalLinkTileList extends NavigationMixin(LightningElement) {
    getIconWithUrl = (icon) => {
        const iconWithFullPath = icon;
        return iconWithFullPath;
    };

    @api insights;
    @api sectionHeading;
    navigateToRecordPage = navigateToRecordPage.bind(this);
    

    tileClick(event) {
        event.preventDefault();
        const kId = event.currentTarget.dataset.key;
        this.navigateToRecordPage(kId);
    }
}