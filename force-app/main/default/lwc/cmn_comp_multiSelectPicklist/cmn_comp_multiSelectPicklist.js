import { LightningElement, track, api } from "lwc";
import loadData from "@salesforce/apex/CIB_CTRL_ACPicklist.loadData";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import countryMapping from "./countryMapping";

export default class Cmn_comp_multiSelectPicklist extends LightningElement {
  @track listOfInputs = {};
  @track conditionalClass = "";

  checkboxicon = MAU_ThemeOverrides + "/assets/images/mau_crossicon.svg";
  removeIcon = MAU_ThemeOverrides + "/assets/images/icn_cross_circle.svg";
  crossicon = MAU_ThemeOverrides + "/assets/images/icn_cross_circle.svg";

  
  @api itemClass;
  @api item;
  
  @track options = [];
  
  @track initOptions = [];
  
  @track selectedOptions = [];
  /** this field allows populating of combobox from mriTable */
  @api sapfield = null;
  
  @track _selectedItems = "";
  /** this is the name of the component  */
  @api name = null;
  /*this will hold list of available values*/
  @api values = [];
  /** this is the selected value */
  @track _value = null;

  @track isInvalid = false;
  @track isLoading = true;

  @api get value() {
    return this._value;
  }
  set value(value) {
    this._value = value;
  }

  
  @api msinputplaceholder = "";
  
  @api maxselected;
  @api required;
  @api validity = false;
  @api isCurrency = false;
  @api isCountryPicklist = false;

  failing;
  errorMessage;
  /** this is the missing value message */

  @api defaultInputs;
  @api sObjectName;
  @api sObjectFieldName;

  get displaySelectedOptions() {
    return this.options
      .filter((e) => e.Selected)
      .map((item) => {
        return {
          ...item,
          iconStyle: `
          border-radius: 50px;
          width: 100%;
          height: 100%;
          background-image: url(${item.icon});
          background-repeat: no-repeat;
          background-position: center;
          background-size: cover;
        `
        };
      });
  }

  @api reportValidity() {
    this.isInvalid = false;

    if (this.required && this.displaySelectedOptions.length < 1) {
      this.isInvalid = true;
      return false;
    }

    return true;
  }

  /**
   * This will load combobox list of values from sapfield field
   */
  async connectedCallback() {
    let options = await loadData({
      sObjectName: this.sObjectName,
      sFieldName: this.sObjectFieldName
    });

    this.options = options.map((item, index) => {
      item.id = index;
      item.Selected = (this.value || "").includes(item.value);
      item.cssClass = " disabled";
      item.defaultValue = item.value;

      if (this.isCurrency) {
        let countryCode = item.value.split(" - ")[0].toLowerCase();
        let iconPath =
          MAU_ThemeOverrides +
          "/assets/images/countries/" +
          countryCode +
          ".svg";
        item.icon = iconPath;
      }
      if (this.isCountryPicklist) {
        let countryCode = countryMapping[item.value] || "";
        let iconPath =
          MAU_ThemeOverrides +
          "/assets/images/countries/" +
          countryCode.toLowerCase() +
          ".svg";
        item.icon = iconPath;
      }
      return item;
    });

    this.isLoading = false;
  }

  /**
   * This will handle the click event on the combobox
   * @param {*} newValue
   */
  renderedCallback() {
    let self = this;
    this.template
      .querySelector(".ms-input")
      .addEventListener("click", function (event) {
        self.onDropDownClick(event.target);
        event.stopPropagation();
      });
    document.addEventListener("click", function () {
      self.closeAllDropDown();
    });
  }

  /**
   * This will handle focus event
   * @param {*} newValue
   */
  onDropDownClick() {
    let classList = Array.from(
      this.template.querySelectorAll(".ms-picklist-dropdown")
    );
    if (!classList.includes("slds-is-open")) {
      this.closeAllDropDown();
      Array.from(
        this.template.querySelectorAll(".ms-picklist-dropdown")
      ).forEach(function (node) {
        node.classList.add("slds-is-open");
      });
    } else {
      this.closeAllDropDown();
    }
  }

  /**
   * This will handle the blur event
   * @param {*} newValue
   */
  closeAllDropDown() {
    Array.from(this.template.querySelectorAll(".ms-picklist-dropdown")).forEach(
      function (node) {
        node.classList.remove("slds-is-open");
      }
    );
  }

  /**
   * This will handle selection event
   * @param {*} newValue
   */
  handleItemSelected(event) {
    if ((this._value || "").split(";").length < this.maxselected) {
      this.options = this.options.map(function (eachItem) {
        if (eachItem.value === event.detail.item.value) {
          eachItem.Selected = event.detail.Selected;
          eachItem.cssClass = " disabled";
          eachItem.defaultValue = "";
        }
        return eachItem;
      });
      this.syncValue();
    }
    
    if (this.selectedOptions.length >= this.maxselected) {
      this.applyNewCss();
    }
    this.dispatchEvent(
      new CustomEvent("change", {
        bubbles: false,
        detail: {
          value: event,
          target: this.name,
          maxselect: this.maxselected,
          inputs: JSON.stringify(this.listOfInputs),
          selection: JSON.stringify(this.selectedOptions)
        }
      })
    );
  }

  applyNewCss() {
    this.options.forEach(function (eachItem) {
      eachItem.cssClass = " disabled";
    });
  }

  removeNewCss() {
    this.options.forEach(function (eachItem) {
      eachItem.cssClass = " ";
    });
  }

  /**
   * This will copy selcted item to temp array
   */
  @api
  getSelectedItems() {
    let resArray = new Array();
    this.initOptions.forEach(function (eachItem) {
      if (eachItem.Selected) {
        resArray.push(eachItem);
      }
    });

    return resArray;
  }

  /**
   * This will handle click on close icon
   * @param {*} event
   */
  deleteSelectedInput(event) {
    
    this.initOptions[event.target.dataset.index].Selected =
      !this.initOptions[event.target.dataset.index].Selected;
    this.initOptions[event.target.dataset.index].cssClass = "";

    if (this.selectedOptions.length <= this.maxselected) {
      this.removeNewCss();
    }

    this.selectedOptions = this.getSelectedItems();
    this.setSelectedItemsLabels();

    const evt = new CustomEvent("items", {
      detail: {
        item: this.item
      }
    });
    this.dispatchEvent(evt);
    event.stopPropagation();
    if (event.target.dataset.name !== "")
      this.removeAndDispatch(event.target.dataset.code);
  }

  removeAndDispatch(elemName) {
    this.options = this.options.map((eachItem) => {
      if (eachItem.value === elemName) {
        eachItem.defaultValue = "";
        eachItem.Selected = false;
      }
      return eachItem;
    });
    this.syncValue();
    delete this.listOfInputs[elemName];
    this.dispatchEvent(
      new CustomEvent("change", {
        bubbles: false,
        detail: {
          value: elemName,
          target: this.name,
          maxselect: this.maxselected,
          inputs: JSON.stringify(this.listOfInputs),
          selection: JSON.stringify(this.selectedOptions)
        }
      })
    );
  }

  setSelectedItemsLabels() {
    let selecedItems = this.getSelectedItems();
    let selections = "";
    let labelLength = selecedItems.length;
    if (labelLength < 1) {
      selections = labelLength + " option(s) selected";
    } else {
      selections = labelLength + " option(s) selected";
    }
    if (
      this.sObjectFieldName === "CIB_AT_CurrentAccountCurrencies__c" ||
      this.sObjectFieldName === "CIB_AT_CurrentAccountPlusCurrencies__c"
    ) {
      selections = labelLength + " option(s) selected";
    }

    this._selectedItems = selections;
  }

  handleInput(event) {
    let selectedCode = event.target.dataset.code;
    this.listOfInputs[event.target.dataset.code] = event.target.value;
    this.options.forEach((item) => {
      if (item.value === selectedCode) item.defaultValue = event.target.value;
    });
    this.dispatchEvent(
      new CustomEvent("change", {
        bubbles: false,
        detail: {
          value: event,
          target: this.name,
          maxselect: this.maxselected,
          inputs: JSON.stringify(this.listOfInputs),
          selection: JSON.stringify(this.selectedOptions)
        }
      })
    );
  }

  removeItem(event) {
    event.stopPropagation();
    event.preventDefault();
    this.removeAndDispatch(event.target.dataset.item);
  }

  syncValue() {
    let value = this.options
      .filter((e) => e.Selected)
      .map((item) => item.value)
      .join(";");
    this._value = value;
  }
}