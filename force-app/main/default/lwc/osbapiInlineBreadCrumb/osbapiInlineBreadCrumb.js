import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import eventChannelDashboard from '@salesforce/messageChannel/osbMenuEvents__c';
import eventChannelHeader from '@salesforce/messageChannel/osbInterCompEvent__c';

export default class OsbapiInlineBreadCrumb extends LightningElement {
    currentPageName = 'OneDeveloper';
    baseLabel = 'Home';

    @wire(MessageContext)
    dashboardMessageContext;
    handleViewChange(event) {
        const payload = {
            ComponentName: 'API marketplace bread crumb',
            Details: {
                tabName: event.target.dataset.id
            }
        };
        publish(this.dashboardMessageContext, eventChannelDashboard, payload);
    }

    @wire(MessageContext)
    headerMessageContext;
    handleNavItemChange(event) {
        const payload = {
            ComponentName: 'API marketplace bread crumb',
            Details: {
                Tab: event.target.dataset.id
            }
        };
        publish(this.headerMessageContext, eventChannelHeader, payload);
    }

    handleTabChange(event) {
        this.handleViewChange(event);
        this.handleNavItemChange(event);
    }
}