import { LightningElement } from 'lwc';

export default class MallFinancialSummary extends LightningElement {


    activeTab = 'tab-1'; // Default active tab

    handleTabChange(event) {
        this.activeTab = event.target.value;
        console.log(`Active tab changed to: ${this.activeTab}`);
    }

}