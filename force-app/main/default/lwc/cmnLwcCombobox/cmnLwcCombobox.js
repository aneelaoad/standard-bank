import { LightningElement, api } from 'lwc';

const LABEL_COMPLETE_FIELD = 'Complete this field.';
const LABEL_CHOOSE_VALID_VALUE = 'Select an option from the picklist or remove the search term.';

export default class CmnLwcCombobox extends LightningElement {
    @api isDisabled;
    @api isRequired;
    @api labelText;
    @api recordOptions;
    @api helptext;
    @api valueFieldApi;
    @api labelFieldApi;
    @api descriptionFieldApi;
    @api selectedValue;
    @api icon;
    @api placeholder;
    @api params;
    @api showError;

    isListBox = false;
    selectedOption;
    options;
    inputOptions;
    errorMessage;
    skipFocusLogic = false;
    initialRender = true;
    
    get shownSelectedIcon() {
        return !!this.icon && this.shownSelectedLabel;
    }

    get comboboxClasses() {
        return 'slds-combobox__form-element slds-input-has-icon ' + (this.shownSelectedIcon ? 'slds-input-has-icon_left-right' : 'slds-input-has-icon_right');
    }

    get formElementClasses() {
        return 'slds-form-element__control ' + (this.isDisabled ? 'cmn-disabled' : 'cmn-active');
    }

    get inputClasses() {
        return 'slds-input slds-combobox__input ' + (this.shownSelectedLabel ? 'cmn-hide' : '');
    }

    get shownSelectedLabel() {
        return !!this.selectedValue;
    }

    connectedCallback() {
        this.inputOptions = this.recordOptions.map(item => this.initOption(item));
        const sel = this.inputOptions.find(item => item.selected);
        let result = (sel && !this.showError) ? sel : {
            label: '',
            value: ''
        };
        this.initCombobox(result);
    }

    renderedCallback() {
        if (this.showError && this.initialRender) {
            this.validateField(false);
        }
        this.initialRender = false;
    }

    // HANDLERS:
    onEventHandler(event) {
        const key = event.keyCode;
        switch(true) {
            case (event.type === 'focus'):
                this.onFocusHandler(event);
                break;
            case (event.type === 'click'):
                if (event.target && event.target.tagName === 'INPUT') {
                    this.showHideListbox(!this.isListBox); 
                }
                break;
            case (event.type === 'focusout'):
                this.onFocusoutHandler(event);
                break;
            case (event.type === 'input'):
                this.onInputHandler(event);
                break;
            case (event.type === 'keydown' && key === 27): //ESC
                this.showHideListbox(false);
                break;
            case (event.type === 'keydown' && ((key === 32) || (key === 13))): // ENTER:
                if (event.target && event.target.tagName === 'INPUT') {
                    this.showHideListbox(!this.isListBox);
                } else {
                    this.enterOption(event);
                }
                break;
            case (event.type === 'keydown' && ((key === 38) || (key === 40))): // ARROW UP/DOWN:
                this.focusOption(event, key === 40);
                break;
            default:
        }
    }

    onFocusHandler(event) {
        if (this.selectedOption && this.selectedOption.label != event.target.value && !this.skipFocusLogic) {
            this.initCombobox({
                label: event.target.value,
                value: event.target.value
            });
            
        }
        this.skipFocusLogic = false;
    }

    onFocusoutHandler(event) {
        const relatedTarget = event.relatedTarget ? event.relatedTarget.closest('.slds-form-element__control') : null;
        const target = event.currentTarget ? event.currentTarget.closest('.slds-form-element__control') : null;
        const relatedTargetId = relatedTarget ? relatedTarget.id : null;
        const targetId = target ? target.id : null;
        if (relatedTargetId === null || targetId === null || relatedTargetId !== targetId) {
            this.showHideListbox(false);
            this.validateField(relatedTarget != null);
        }
    }

    onInputHandler(event) {
        let foundValue = this.inputOptions.find(element => element.label == event.target.value);
        let selectedValue = foundValue ? foundValue.value : event.target.value;
        this.initCombobox({
            type: event.type,
            label: event.target.value,
            value: selectedValue
        });
        this.showHideListbox(this.options.length !== 0);
    }

    onClickOptionHandler(event) {
        const isValueChaged = event.currentTarget.dataset.value !== this.selectedOption.value;
        this.showHideListbox(false, true);
        this.initCombobox({
            type: event.type,
            label: event.currentTarget.dataset.label,
            value: event.currentTarget.dataset.value
        });
        this.validateField(false);
    }

    onFocusOptionHandler(event) {
        this.template.querySelector('input').setAttribute(
            'aria-activedescendant', 
            event.target.querySelector('.slds-listbox__option').id
        );
    }

    onEventCloseHandler(event) {
        this.initCombobox({
            type: event.type,
            label: '',
            value: ''
        });
        this.showHideListbox(true);
        this.skipFocusLogic = true;
        this.template.querySelector('input').focus();
    }

    // HELPERS:
    showHideListbox(isVisible, leaveFocus) {
        this.isListBox  = isVisible;
        if (!isVisible && leaveFocus) {
            this.template.querySelector('input').focus();
        }
        this.template
            .querySelector('div.slds-combobox')
            .setAttribute('aria-expanded', isVisible);
        if (!isVisible) {
            this.hideFocusedOption();
        }
    }

    hideFocusedOption() {
        this.template.querySelector('input').removeAttribute(
            'aria-activedescendant'
        );
    }

    initCombobox(params) {
        this.options = this.setOptions(params);
        this.selectedOption = this.setSelectedOption(params);
        let sel;
        if (this.selectedOption && this.selectedOption.value) {
            sel = this.inputOptions.find(item => item.value === this.selectedOption.value);
        }
        this.selectedValue = sel ? sel.value : '';
    }

    focusOption(event, down) {
        event.preventDefault();
        this.showHideListbox(true);
        const options = this.template.querySelectorAll('ul.slds-listbox li');
        const isOptionFocused = this.template.activeElement && this.template.activeElement.classList.contains('slds-listbox__item');
        switch(true) {
            case (isOptionFocused && down):
                event.target.nextSibling && event.target.nextSibling.focus();
                break;
            case (isOptionFocused && !down):
                event.target.previousSibling && event.target.previousSibling.focus();
                break;
            case (!isOptionFocused && down):
                if (options.length > 0) {
                    options[0] && options[0].focus();
                }
                break;
            default:
                if (options.length > 0) {
                    options[options.length - 1] && options[options.length - 1].focus();
                }
                break;
        }
    }

    enterOption(event) {
        const node = this.template.activeElement;
        const isValueChanged = node.dataset.value !== this.selectedOption.value;
        this.showHideListbox(false, true);
        this.initCombobox({
            type: event.type,
            label: node.dataset.label,
            value: node.dataset.value
        });
        this.validateField(false);
    }

    setOptions(params) {
        params = params || {};
        let result;
        switch(true) {
            case (params.type === 'focus' || params.type === 'click' || params.type === 'keydown'):
                result = this.getOptionsWithSelectedItem(params.value);
                break;
            case (params.type === 'input'):
                result = this.getOptionsFilteredByInput(params.label);
                break;
            default:
                result = this.inputOptions;
        }
        return result;
    }

    setSelectedOption(params) {
        return {...params};
    }

    getOptionsWithSelectedItem() {
        return this.inputOptions
        .map((item) => {
            const element = {...item};
            element.selected = element.value === this.selectedValue;
            return element;
        });
    }

    getOptionsFilteredByInput(inputValue) {
        return this.inputOptions
            .map((item) => {
                const element = {...item};
                element.selected = false;
                return element;
            })
            .filter((item) => 
            item.label.toLowerCase().indexOf(inputValue.toLowerCase()) !== -1 ||
            (item.description && item.description.toLowerCase().indexOf(inputValue.toLowerCase()) !== -1));
    }

    initOption(option) {
        return {
            selected: option[this.valueFieldApi] === this.selectedValue,
            label: option[this.labelFieldApi],
            value: option[this.valueFieldApi],
            description: this.descriptionFieldApi ? option[this.descriptionFieldApi] : '',
            optionClass: 'slds-media slds-listbox__option slds-listbox__option_entity ' +
                (this.descriptionFieldApi ? 'slds-listbox__option_has-meta' : 'slds-media_center')
        };
    }

    validateField(withFocus) {
        let isValid = false;
        switch(true) {
            case (this.isRequired && !this.isPopulated()):
                this.setError(LABEL_COMPLETE_FIELD, withFocus);
                break;
            case (!this.isCorrectOption()):
                this.setError(LABEL_CHOOSE_VALID_VALUE, withFocus);
                break;
            default:
                this.setError(null, withFocus);
                isValid = true;
        }
        return isValid;
    }
 
    isCorrectOption() {
        let selOpt = this.inputOptions
            .some((item) => item.value === this.selectedOption.value);
        
        return (this.inputOptions.length === 0 && this.inputData.inputType === 'COMBOBOX') || selOpt;
    }

    isPopulated() {
        return !!this.selectedOption.value;
    }

    setError(message, withFocus) {
        this.errorMessage = message;
        if (message) {
            this.template
                .querySelector('.slds-form-element')
                .classList.add('slds-has-error');
                if (withFocus) {
                    this.template.querySelector('.slds-combobox__input') && this.template.querySelector('.slds-combobox__input').focus();
                }
        } else {
            this.template
                .querySelector('.slds-form-element')
                .classList.remove('slds-has-error');
        }
    }
}