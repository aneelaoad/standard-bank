/* eslint-disable @lwc/lwc/no-async-operation */
import { api, LightningElement, wire } from 'lwc';
import getApiBaseUrl from '@salesforce/apex/OSB_OD_ApiDetails_CTRL.getApiBaseUrl';

export default class OsbapiBaseUrlDisplay extends LightningElement {
    @api apiId;

    sandboxUrl = '';
    prodUrl = '';

    @wire(getApiBaseUrl, { apiId: '$apiId' })
    WiredGetApiBaseUrl({ data }) {
        if (data) {
            this.setupBaseUrls(data);
        }
    }

    setupBaseUrls(data) {
        data.forEach((element) => {
            if (
                element.acm_pkg__EnvironmentName__c &&
                element.acm_pkg__EnvironmentName__c === 'Sandbox'
            ) {
                this.sandboxUrl = element.acm_pkg__Endpoint__c;
            } else if (
                element.acm_pkg__EnvironmentName__c &&
                element.acm_pkg__EnvironmentName__c === 'PROD'
            ) {
                this.prodUrl = element.acm_pkg__Endpoint__c;
            }
        });
    }

    copySandboxUrl() {
        this.copyToClipboard(this.sandboxUrl);
        this.template
            .querySelector('[data-id="sandbox-tooltip"]')
            .classList.add('active');
        setTimeout(() => {
            this.template
                .querySelector('[data-id="sandbox-tooltip"]')
                .classList.remove('active');
        }, 1500);
    }

    copyProdUrl() {
        this.copyToClipboard(this.prodUrl);
        this.template
            .querySelector('[data-id="prod-tooltip"]')
            .classList.add('active');
        setTimeout(() => {
            this.template
                .querySelector('[data-id="prod-tooltip"]')
                .classList.remove('active');
        }, 1500);
    }

    copyToClipboard = (content) => {
        let tempTextAreaField = document.createElement('textarea');
        tempTextAreaField.style =
            'position:fixed;top:-5rem;height:1px;width:10px;';

        tempTextAreaField.value = content;
        document.body.appendChild(tempTextAreaField);
        tempTextAreaField.select();
        document.execCommand('copy');
        tempTextAreaField.remove();
    };
}