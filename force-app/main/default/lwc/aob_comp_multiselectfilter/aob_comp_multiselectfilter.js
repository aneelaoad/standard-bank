import { LightningElement, api, track } from 'lwc';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import loadData from '@salesforce/apex/AOB_CTRL_ACPicklist.loadData';
export default class Aob_comp_multiselectfilter extends LightningElement {
  @api teams = ["Self Assisted"];
    label = {};
  @track listOfInputs = {};
  @track conditionalClass = "";
  // elements on child componenet
  @api itemClass;
  @api item;
  // List of all items
  @track options;
  // List of initial items
  @track initOptions;
  // List of selected items
  @track selectedOptions;
  /** this field allows populating of combobox from mriTable */
  @api sapfield = null;
  // populate on item select
  @track _selectedItems = "";
  /** this is the name of the component  */
  @api name = null;
  /*this will hold list of available values*/
  @api values = null;
  /** this is the selected value */
  @api value = null;
  // close icon
  closeMG = AOB_ThemeOverrides + '/assets/images/close_icon.png';
  @api msinputplaceholder = "";
  //Max selected item display
  @api maxselected;
  @api required;
  @api validity = false;
  failing;
  errorMessage;
  /** this is the missing value message */


  @api defaultInputs;

  constructor() {
    super();
  }

  /**
 * This will load combobox list of values from sapfield field
 */
  connectedCallback() {
    loadData({ targetValue: this.sapfield }).then((result) => {
      this.values = result;
      if (this.defaultInputs && this.values) {
        this.listOfInputs = JSON.parse(this.defaultInputs);
        let labels = Object.keys(this.listOfInputs);
        this.values.forEach(v => {
          if (labels.includes(v.AOB_Code__c)) {
            v.Selected = true;
            v.cssClass = " disabled";
            v.defaultValue = this.listOfInputs[v.AOB_Code__c];
          }

        })
      }

      //check if we have values
      if (this.values) {
        this.options = [...this.values];
        this.initOptions = [...this.values];
      }
      // set selected to false
      if (!this.defaultInputs) {
        this.options.forEach(function (v) {
          v.Selected = false;
          v.cssClass = " ";
        })
        // set selected to false
        this.initOptions.forEach(function (v) {
          v.Selected = false;
          v.cssClass = " ";
        })

      }

      //init selectedOptions
      this.selectedOptions = [];
      this.selectedOptions = this.getSelectedItems();
      this.setSelectedItemsLabels();
    }).catch((error => {
      this.failing = true;
      this.errorMessage = getErrorMessage.call(this, error);
      window.fireErrorCodeEvent(this, this.errorMessage);
    }));
  }
    handleResultChange(event) {
        this.label = event.detail;
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
    document.addEventListener("click", function (event) {
      self.closeAllDropDown();
    });
  }

  /**
 * This will handle focus event
 * @param {*} newValue 
 */
  onDropDownClick(evTarg) {
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
    if (this.selectedOptions.length < this.maxselected) {
      this.options.forEach(function (eachItem) {
        if (eachItem.Id == event.detail.item.Id) {
          eachItem.Selected = event.detail.Selected;
          eachItem.cssClass = " disabled";
          eachItem.defaultValue = '';
        }
      });

      // copy selected item to array
      this.selectedOptions = this.getSelectedItems();
      this.setSelectedItemsLabels();
    }
    //checkIfRestNeedsDisabling
    if ((this.selectedOptions.length >= this.maxselected)) {
      this.applyNewCss();
    }
    this.dispatchEvent(new CustomEvent('change', {
      bubbles: false,
      detail: {
        value: event,
        target: this.name,
        maxselect: this.maxselected,
        inputs: JSON.stringify(this.listOfInputs),
        selection: JSON.stringify(this.selectedOptions)
      }
    }));
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
    // set selected to false
    this.initOptions[event.target.dataset.index].Selected = !this.initOptions[event.target.dataset.index].Selected;
    this.initOptions[event.target.dataset.index].cssClass = "";

    if ((this.selectedOptions.length <= this.maxselected)) {
      this.removeNewCss();
    }

    this.selectedOptions = this.getSelectedItems();
    this.setSelectedItemsLabels();

    const evt = new CustomEvent("items", {
      detail: { item: this.item },
    });
    this.dispatchEvent(evt);
    event.stopPropagation();
    if (event.target.dataset.name != "") this.removeAndDispatch(event.target.dataset.code);
  }

  removeAndDispatch(elemName) {
    this.options.forEach(function (eachItem) {
      if (eachItem.AOB_Code__c == elemName) {
        eachItem.defaultValue = '';
        return;
      }
    });
    delete this.listOfInputs[elemName];
    this.dispatchEvent(new CustomEvent('change', {
      bubbles: false,
      detail: {
        value: elemName,
        target: this.name,
        maxselect: this.maxselected,
        inputs: JSON.stringify(this.listOfInputs),
        selection: JSON.stringify(this.selectedOptions)
      }
    }));
  }

  setSelectedItemsLabels() {
    let selecedItems = this.getSelectedItems();

    let selections = "";
    if (selecedItems.length < 1) {
      selections = this.msinputplaceholder;
    } else {
      selections = selecedItems.length + " option(s) selected";
    }

    this._selectedItems = selections;

  }

  handleInput(event) {
    let selectedCode = event.target.dataset.code;
    this.listOfInputs[event.target.dataset.code] = event.target.value;
    this.options.forEach(item => {
      if (item.AOB_Code__c == selectedCode) item.defaultValue = event.target.value;
    });
    this.dispatchEvent(new CustomEvent('change', {
      bubbles: false,
      detail: {
        value: event,
        target: this.name,
        maxselect: this.maxselected,
        inputs: JSON.stringify(this.listOfInputs),
        selection: JSON.stringify(this.selectedOptions)
      }
    }));
  }
}