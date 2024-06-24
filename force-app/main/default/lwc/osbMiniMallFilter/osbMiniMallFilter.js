import { LightningElement, wire, api } from 'lwc';
import Minimall from '@salesforce/resourceUrl/OSB_MiniMall';
import Id from '@salesforce/user/Id';
import { subscribe, MessageContext } from 'lightning/messageService';
import fetchMetaListLwc from '@salesforce/apex/OSB_MiniMallCustomMetadata_CTRL.fetchMetaListLwc';
import PROVIDER_CHANNEL from '@salesforce/messageChannel/Provider_Channel__c';

export default class osbMiniMallFilter extends LightningElement {
    filterLogo = Minimall + '/filterIcon.svg';
    categoryRecords;
    error;
    userId = Id;
    showCategories = true;
    dynamicHeight;
    boxShadowStyling;
    dynamicHeightMobile;
    boxShadowStylingMobile;
    selectedCategories = [];
    selectedCategoriesAsString = '';
    searchValue = '';
    providerId;
    providerid;   
    subscription = null;
    categoryReceived = '';
    showGallery = false;
    showProvider = false;
    noProvider = false;
    @api propertyValue;
    @api title;
    @api providertitle;
    
    @api
    get categorySelected() {
        return this.categoryReceived;
    }

    set categorySelected(value) {
        this.categoryReceived = value;
    }

    @wire(MessageContext)
    messageContext;

    renderedCallback() {
        if (this.categoryRecords) {
            if (this.propertyValue) {              
                this.handleCategorySelection(this.propertyValue);
            } else {
                if (this.categoryReceived) {
                    this.handleCategorySelection(this.categoryReceived);
                }
            }
        }
    }

    @wire(fetchMetaListLwc, { userId: '$userId' })
    categoryHandler(value) {
        this.boxShadowStyling = 'height: 6.5rem';
        const { data, error } = value;
        if (data) {
            this.categoryRecords = data;
            this.dynamicHeight =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
            this.boxShadowStyling =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
            this.dynamicHeightMobile =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
            this.boxShadowStylingMobile =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
            this.AllCategoriesSpinner();
            this.showGallery = true;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.categoryRecords = undefined;
        }
    }

    AllCategoriesSpinner() {
        this.template
            .querySelector('[data-id="CategoriesChevron"]')
            .classList.toggle('open');
        this.template
            .querySelector('[data-id="CategoriesChevronMobile"]')
            .classList.toggle('open');
        this.template
            .querySelector('[data-id="FilterCategoryOptionWrapper"]')
            .classList.toggle('open');
        this.template
            .querySelector('[data-id="FilterCategoryOptionWrapperMobile"]')
            .classList.toggle('open');

        if (!this.showCategories) {
            this.showCategories = true;
            this.boxShadowStyling =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
            this.dynamicHeight =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
            this.dynamicHeightMobile =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
            this.boxShadowStylingMobile =
                'height: ' + (this.categoryRecords.length * 2.5 + 6.5) + 'rem';
        } else {
            this.boxShadowStyling = 'height: 6.5rem';
            this.dynamicHeight = 'height: 6.5rem';
            this.dynamicHeightMobile = 'height: 3.75rem';
            this.boxShadowStylingMobile = 'height: 3.75rem';
            this.showCategories = false;
        }
    }

    handleCheckAll(event) {
        let categoryList = this.selectedCategories;

        let checkboxes = this.template.querySelectorAll(
            `[data-name="categories"]`
        );
        for (let i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
            if (event.target.checked) {
                categoryList.push(checkboxes[i].value);
            } else {
                categoryList.splice(i);
            }
        }

        this.selectedCategories = this.removeDuplicateCategories(categoryList);
        this.selectedCategoriesAsString = this.selectedCategories.join();
        this.categoryselected = this.selectedCategoriesAsString;
    }

    handleCheckbox(event) {
        let categoryList = this.selectedCategories;

        if (event.target.checked) {
            categoryList.push(event.target.value);
        } else {
            let index = this.selectedCategories.indexOf(event.target.value);
            categoryList.splice(index, 1);
        }

        let allCategory = this.template.querySelectorAll(
            '[data-id="checkboxCategory"]'
        );

        if (categoryList.length === this.categoryRecords.length) {
            allCategory[0].checked = true;
        } else {
            allCategory[0].checked = false;
        }

        this.selectedCategories = this.removeDuplicateCategories(categoryList);

        this.selectedCategoriesAsString = this.selectedCategories.join();
        this.categoryselected = this.selectedCategoriesAsString;
    }

    removeDuplicateCategories(categoryArray) {
        return [...new Set(categoryArray)];
    }

    searchForSolutions() {
        let searchInputField = this.template.querySelector(
            `[data-id="searchInput"]`
        );
        let searchInput = searchInputField ? searchInputField.value : '';
        searchInput = searchInput.toLowerCase();
        this.searchValue = searchInput;
    }

    handleCategorySelection(category) {
        let categoryList = [];
        let allCategories = this.template.querySelectorAll(
            '[data-id="checkboxCategory"]'
        );
        let checkboxes = this.template.querySelectorAll(
            `[data-name="categories"]`
        );
        let result = category.includes('All Applications');
        if (result) {
            allCategories[0].checked = true;

            for (let i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = true;
                categoryList.push(checkboxes[i].value);
            }
        } else {
            if (category) {
                for (let i = 0; i < checkboxes.length; i++) {
                    if (checkboxes[i].value === category) {
                        checkboxes[i].checked = true;
                        categoryList.push(checkboxes[i].value);
                    } else {
                        categoryList.splice(i);
                    }
                }
            }
        }

        this.selectedCategories = this.removeDuplicateCategories(categoryList);
        this.selectedCategoriesAsString = this.selectedCategories.join();
        this.categoryReceived = '';
        this.AllCategoriesSpinner();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                PROVIDER_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        this.providerId = message.providerId;
        this.providerTitle = message.providerTitle;
        if(this.providerId = message.providerId){
            this.showProvider = true;
        }
        
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }
}