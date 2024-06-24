import { LightningElement } from 'lwc';

export default class MallExpiredNotification extends LightningElement {

    handleclose(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}