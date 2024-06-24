import { LightningElement } from 'lwc';
import mallFSummaryImages from "@salesforce/resourceUrl/MallFSummaryImages";

export default class MallFinancialSummaryBanner extends LightningElement {

    bannerImg = mallFSummaryImages+'/banner_image.png';
    bannerBadge = mallFSummaryImages+'/banner_badge.svg';
}