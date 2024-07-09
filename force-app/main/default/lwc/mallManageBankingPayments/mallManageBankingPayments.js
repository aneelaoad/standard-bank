import { LightningElement } from 'lwc';
import mallHomeManagePayments from "@salesforce/resourceUrl/mallHomeManagePayments";

export default class MallManageBankingPayments extends LightningElement {

    phoneImage = mallHomeManagePayments+'/manage_payment-phone.png';
    appleIcn = mallHomeManagePayments+'/apple_icn.png';
    playStoreIcn = mallHomeManagePayments+'/playstore_icn.png';
    huaweiIcn = mallHomeManagePayments+'/huawei_icn.png';

}