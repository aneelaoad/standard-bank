import { LightningElement, wire, api} from 'lwc';
import { ShowToastEvent }             from 'lightning/platformShowToastEvent';

//FetchAncillaryOpportunities
import getAncillaryOpportunities from '@salesforce/apex/NBAC_AncillaryOpportunities_CTRL.getAncillaryOpportunities';

const COLUMNS = [
    {
        label: 'Opportunity Name',
        fieldName: 'oppId',
        hideDefaultActions: 'true',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'oppName' },
            traget: '_blank'
        }
    },
    {
        label: 'Opportunity Id',
        fieldName: 'oppCustomId',
        hideDefaultActions: 'true',
        type: 'text'
    },
    {
        label: 'Client Name',
        fieldName: 'clientId',
        hideDefaultActions: 'true',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'clientName' },
            traget: '_blank'
        }
    },
    {
        label: 'Opportunity Owner',
        fieldName: 'ownerId',
        hideDefaultActions: 'true',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'ownerName' },
            traget: '_blank'
        }
    },
    {
        label: 'Parent Product',
        fieldName: 'Parent_Product__c',
        hideDefaultActions: 'true',
        type: 'text'
    },
    {
        label: 'Estimated Close Date',
        fieldName: 'closeDate',
        hideDefaultActions: 'true',
        type: 'date',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Current Year Revenue',
        fieldName: 'currentYearRevenue',
        hideDefaultActions: 'true',
        type: 'currency'
    },
    {
        label: 'Total Revenue (Amount)',
        fieldName: 'totalReveue',
        hideDefaultActions: 'true',
        type: 'currency'
    },
    {
        label: 'Opportunity Country',
        fieldName: 'oppCountry',
        hideDefaultActions: 'true',
        type: 'text'
    }
];

export default class NBAC_AncillaryOpportunities extends LightningElement {
    @api recordId;
    colums = COLUMNS;
    records;

    @wire(getAncillaryOpportunities, { nbacId: '$recordId' })
    wiredRecords({ error, data }) {
        if (data) {
            this.records = data.map(row => {
                const oppId =  `/lightning/r/${row.Opportunity__r.Id}/view`;
                const oppName = row.Opportunity__r.Name;
                const oppCustomId = row.Opportunity__r.Opportunity_ID__c;
                const clientId =  `/lightning/r/${row.Opportunity__r.Id}/view`;
                const clientName = row.Opportunity__r.Account.Name;
                const closeDate = row.Opportunity__r.CloseDate;
                const ownerId =  `/lightning/r/${row.Opportunity__r.Id}/view`;
                const ownerName = row.Opportunity__r.Owner.Name;
                const currentYearRevenue = row.Opportunity__r.Current_Year_Revenue_Currency__c;
                const totalReveue = row.Opportunity__r.Amount;
                const oppCountry = row.Opportunity__r.Opportunity_Country__c;

                return {...row, oppId, oppCustomId, oppName, clientId, clientName, closeDate, ownerId, ownerName, currentYearRevenue, totalReveue, oppCountry };
            });
        } else if (error) {
            this.showToast('error', 'Error', this.reduceErrors(error));
        }
    }

    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            title   : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
     
        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (error.body.duplicateResults && error.body.duplicateResults.length > 0) {
                        return error.body.duplicateResults.map((e) => e.message);
                    }
    
                    else if (error.body.fieldErrors && error.body.fieldErrors.length > 0 && Array.isArray(error.body.fieldErrors)) {
                        return error.body.fieldErrors.map((e) => e.message);
                    }
    
                    else if (error.body.pageErrors && error.body.pageErrors.length > 0 && Array.isArray(error.body.pageErrors)) {
                        return error.body.pageErrors.map((e) => e.message);
                    }
    
                    else if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }
}