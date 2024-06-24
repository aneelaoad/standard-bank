import {
    LightningElement,
    api
} from 'lwc';
import {
    FlowNavigationNextEvent
} from 'lightning/flowSupport';
import close from '@salesforce/label/c.AOB_Close';
import SignLegalAgreements from '@salesforce/label/c.AOB_SignLegalAgreements';
import ByClickingSign from '@salesforce/label/c.AOB_ByClickingSign';
import ConfirmThatIHaveRead from '@salesforce/label/c.AOB_ConfirmThatIHaveRead';
import GeneralTermsandconditions from '@salesforce/label/c.AOB_GeneralTermsandconditions';
import Mymobizbusinessaccounttermsandconditions from '@salesforce/label/c.AOB_Mymobiz_business_account_terms_and_conditions';
import MarketlinkTermsAndconditions from '@salesforce/label/c.AOB_MarketlinkTermsAndconditions';
import Snapscantermandconditions from '@salesforce/label/c.AOB_Snapscan_term_and_conditions';
import Pocketbiztermandconditions from '@salesforce/label/c.AOB_Pocketbiz_terms_and_conditions';
import WarrantiesandFAISdisclosures from '@salesforce/label/c.AOB_Warranties_and_FAIS_disclosures';
import Acknowledge from '@salesforce/label/c.Acknowledge';
import Warrant from '@salesforce/label/c.AOB_Warrant';
import Authorised from '@salesforce/label/c.AOB_Authorised';
import AgreementConstitutesorised from '@salesforce/label/c.AOB_Agreement_Constitutes';
import AccountAreSubject from '@salesforce/label/c.AOB_Account_s_Are_Subject';
import TermsAgreement from '@salesforce/label/c.AOB_Terms_Agreement';
import AllInformationProvided from '@salesforce/label/c.AOB_All_Information_Provided';
import Companyisnotindefault from '@salesforce/label/c.AOB_Company_is_not_in_default';
import getAcceptedLineItems from '@salesforce/apex/AOB_CTRL_FormCreator.getAcceptedLineItems';
import getDocumentList from '@salesforce/apex/AOB_Internal_SRV_CreateContract.getDocumentList';
import getDocument from '@salesforce/apex/AOB_Internal_SRV_CreateContract.callStaffAssistGetDocumentAPI';

export default class Aob_internal_comp_termsconditions extends LightningElement {
    url;
    value;
    @api closePopup;
    @api applicationId;
    @api businessmarketlink;
    @api pckbiz;
    @api snapscan;
    @api availableActions = [];
    @api screenName;
    @api appid;
    @api previousScreen;
    @api nextScreen;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api acceptedItems;
    adobeformName;
    mymoBizId;
    marketLinkId;
    pocketBizId;
    snapScanId;
    link;
    isLoaded=false;
    data;
    acceptedProducts;
    key;
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
    label = {
        close,
        SignLegalAgreements,
        ByClickingSign,
        ConfirmThatIHaveRead,
        GeneralTermsandconditions,
        Mymobizbusinessaccounttermsandconditions,
        MarketlinkTermsAndconditions,
        Snapscantermandconditions,
        Pocketbiztermandconditions,
        WarrantiesandFAISdisclosures,
        Acknowledge,
        Warrant,
        Authorised,
        AgreementConstitutesorised,
        AccountAreSubject,
        TermsAgreement,
        AllInformationProvided,
        Companyisnotindefault
    }
    columns = [
        { label: 'Key', fieldName: 'key' },
        { label: 'Value', fieldName: 'value' },
        {
            type: 'button',
            initialWidth: 135,
            typeAttributes: {
                label: 'Show Key',
                name: 'show_key',
                title: 'Click to view the key',
                variant: 'brand'
            }
        }
    ];
    connectedCallback() {
        this.getDocumentListAPI();
        this.fetchAcceptedLineItems();
    }

    fetchAcceptedLineItems() {
        getAcceptedLineItems({
            'appId': this.applicationId
        }).then(result => {
            let response = result;
            if (response) {
                this.acceptedProducts = response;
                response.forEach(item => {
                    if (item.AOB_ProductCode__c == '4648') this.mymoBizId = item.SalesObjectItemId__c;
                    if (item.AOB_ProductCode__c == '4488') this.marketLinkId = item.SalesObjectItemId__c;
                    if (item.AOB_ProductCode__c == 'ZPOB') this.pocketBizId = item.SalesObjectItemId__c;
                    if (item.AOB_ProductCode__c == 'ZPSS') this.snapScanId = item.SalesObjectItemId__c;
                });
            }
        }).catch(error => {
            this.failing = true;
        });
    }

    handleClosePoup(event) {
        this.closePopup = false;
        window.fireButtonClickEvent(this, event);
        const closeModal = new CustomEvent("closepopwindow", {
            detail: this.closePopup
        });
        this.dispatchEvent(closeModal);
    }
    customHideModalPopup() {
        this.isModalOpen = false;
    }

    getDocumentListAPI(){
        getDocumentList({applicationId:this.applicationId})
        .then(data=>{
        this.isLoaded=true;
        if (data) {
            this.data = Object.entries(data).map(([key, value]) => {
                return { key: key, value: value };
            });
            this.error = undefined;
        }
        })
        .catch(error=>{

        });
    }
    handleButtonClick(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.value=event.detail.row.value;
        this.key=row.key;
        this.fetchDocument(row.key);
    }
    fetchDocument(key) {
        this.isLoaded = false;
        getDocument({
            'applicationId': this.applicationId,
            'itemId':key
        }).then(result => {
            this.isLoaded = true;
            
            let pdfData = atob(result);
            let arrayBuffer = new Uint8Array(pdfData.length);
            for (let i = 0; i < pdfData.length; i++) {
                arrayBuffer[i] = pdfData.charCodeAt(i);
            }
            let documentBlob = new Blob([arrayBuffer], { type: 'application/pdf' });
            let fileURL = URL.createObjectURL(documentBlob);
            this.url=fileURL;
            let link = document.createElement('a');
            link.href = fileURL;
            link.download = '.pdf'; 
            link.style.display = 'none';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
        });
    }
    base64ToBlob(base64Data, contentType) {
        const byteCharacters = atob(base64Data);
        const byteArrays = [];

        for (let offset = 0; offset < byteCharacters.length; offset += 512) {
            const slice = byteCharacters.slice(offset, offset + 512);
            const byteNumbers = new Array(slice.length);
            for (let i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }

        return new Blob(byteArrays, { type: contentType });
    }
}