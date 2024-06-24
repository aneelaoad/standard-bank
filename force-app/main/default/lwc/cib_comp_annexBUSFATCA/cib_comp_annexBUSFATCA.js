import { track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cib_comp_annexBUSFATCA extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api sectionId;
  @api recordId;

  @track updatedValue = {};
  @track isIGAFinalInstitution = false;
  @track buttonClick;
  @track fetchedDetails = {};
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";
  helpicon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";
  @track headerLabel =
    "US persons, inclusive of US entities OR US FATCA for non US entities";
  @track showError = false;
  @track itemList = [
    {
      id: 0
    }
  ];
  @track isUsEntity = false;
  @track isNotUsEntity = false;
  @track isPartnerFinancialInstitution = false;
  @track isForeignFinancialInstitution = false;
  @track isRegisteredFinancialInstitution = false;
  @track showTrusteeDetails = false;
  @track statusOwner = false;
  @track statusExpected = false;
  @track statusEntity = false;
  @track statusFinancial = false;
  @track showStatusType = false;
  @track trusteeEntity = false;
  @track trusteeNonParticipant = false;
  @track trusteeannex = false;
  @track trusteeOwner = false;
  @track trusteeGiin = false;
  @track isUsEntitySelected = false;
  @track isNonUsEntitySelected;
  @track keyIndex = 0;
  checkRegisteredStatus = false;
  trusteeName;
  trustGIIN;
  registeredGIIN;
  fatchaStatusType;

  /**
   * @description : this method used for getting values
   */
  renderedCallback() {
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (
        Number(element.dataset.index) &&
        element.name &&
        this.itemList[Number(element.dataset.index)] &&
        this.itemList[Number(element.dataset.index)][element.name]
      ) {
        element.value =
          this.itemList[Number(element.dataset.index)][element.name];
      }
    });
  }

  /**
   * @description : this method used for getting all the elements
   */
  getAllElements() {
    const elements = [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("input")
    ];
    return elements;
  }

  /**
   * @description : this method used for getting percentages
   */
  getCompetionPercentage() {
    const elements = this.getAllElements();
    const totalFields = elements.length;
    const validFields = elements.reduce((validCount, element) => {
      if (
        (element.checkValidity && element.checkValidity()) ||
        element.value !== null ||
        element.value !== undefined ||
        element.value !== ""
      ) {
        return validCount + 1;
      }
      return validCount;
    }, 0);
    return (validFields / totalFields) * 100;
  }

  /**
   * @description : this method used for changing the fields
   */
  genericFieldChange(event) {
    const fieldName = event.target.dataset.name;
    const fieldValue = event.target.value;
    if (!this.itemList[event.target.dataset.index]) {
      this.itemList[event.target.dataset.index] = {};
    }
    this.itemList[event.target.dataset.index][fieldName] = fieldValue;
  }

  /**
   * @description : this method used for removing error
   */
  removeError(element) {
    element.setCustomValidity("");
    element.reportValidity();
  }

  /**
   * @description : this method used for validating the validations
   */
  validateRecord() {
    let isValid = true;
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      this.removeError(element);
      if (!element.value) {
        element.setCustomValidity("Please enter this field");
        element.reportValidity();
        element.focus();
        isValid = false;
      } else if (!element.reportValidity()) {
        isValid = false;
      }
    });
    return isValid;
  }

  onApplicationLoaded(app) {
    let mauApp = {
      isUSPersonEntity: app.CIB_AB_US_IsUSPersonEntities__c === true,
      fatchaClassification: app.CIB_AB_US_IsFATCAClassification__c || "",
      usPersonEntityDetails: app.CIB_AB_US_USPersonsEntitiesDetails__c
        ? app.CIB_AB_US_USPersonsEntitiesDetails__c
        : null,
      registeredType: app.CIB_AB_NUS_RegisteredFIType__c || "",
      registeredGIIN: app.CIB_AB_NUS_RegisteredFIGIIN__c || "",
      nonGIINType: app.CIB_AB_NUS_NonGIINType__c || "",
      trustName: app.CIB_AB_NUS_TrustName__c || "",
      trustGIIN: app.CIB_AB_NUS_TrustGIIN__c || "",
      fatchStatus: app.CIB_AB_NUS_FATCAStatus__c || "",
      fatchaStatusType: app.CIB_AB_NUS_FATCAStatusType__c || "",
      fatchaType: app.CIB_AB_US_Fatcha_Type__c || ""
    };
    this.fatchaDetails(JSON.stringify(mauApp));
  }

  /**
   * @description : this method used for fetching the records
   */
  fatchaDetails(result) {
    this.fetchedDetails = JSON.parse(result);
    this.updatedValue = JSON.parse(result);
    this.handleFatchaType(this.fetchedDetails);
    this.updateGIINDetails(this.fetchedDetails);
    this.updateTrusteeDetails(this.fetchedDetails);
    this.updateStatusDetails(this.fetchedDetails);
    this.trusteeName = this.fetchedDetails.trustName;
    this.trustGIIN = this.fetchedDetails.trustGIIN;
    this.registeredGIIN = this.fetchedDetails.registeredGIIN;
    this.fatchaStatusType = this.fetchedDetails.fatchaStatusType;
    if (
      this.fetchedDetails.usPersonEntityDetails !== null &&
      this.fetchedDetails.usPersonEntityDetails !== undefined
    ) {
      this.itemList = JSON.parse(this.fetchedDetails.usPersonEntityDetails);
      this.isLoaded = true;
    } else {
      this.itemList = [{ id: 0 }];
      this.isLoaded = true;
    }
  }

  /**
   * @description : this method used for handling fatcha type
   */
  handleFatchaType(item) {
    if (item.fatchaType === "US persons, inclusive of US entities") {
      this.headerLabel = "US persons, inclusive of US entities";
      this.isUsEntity = true;
      this.isUsEntitySelected = true;
      this.isNonUsEntitySelected = false;
    } else if (
      item.fatchaType === "US FATCA classification for all non US entites"
    ) {
      this.headerLabel =
        "Section 1: US FATCA classification for all non US entities";
      this.isNotUsEntity = true;
      this.isUsEntitySelected = false;
      this.isNonUsEntitySelected = true;
    }
  }

  /**
   * @description : this method used for handling checkbox changes
   */
  handleCheckboxChanged(event) {
    let value = event.target.value;
    if (value === "Registered deemed complaint foreign financial institution") {
      this.isIGAFinalInstitution = false;
      this.registeredGIIN = null;
      this.isPartnerFinancialInstitution = false;
      this.isRegisteredFinancialInstitution = true;
      this.isForeignFinancialInstitution = false;
      this.checkRegisteredStatus = true;
    } else if (value === "Participating foreign financial institution") {
      this.isIGAFinalInstitution = false;
      this.registeredGIIN = null;

      this.isPartnerFinancialInstitution = false;
      this.isRegisteredFinancialInstitution = false;
      this.isForeignFinancialInstitution = true;
      this.checkRegisteredStatus = true;
    } else if (value === "IGA partner jurisdiction financial institution") {
      this.isPartnerFinancialInstitution = true;
      this.isRegisteredFinancialInstitution = false;
      this.isForeignFinancialInstitution = false;
      this.isIGAFinalInstitution = true;
      this.checkRegisteredStatus = true;
    }
    let name = event.target.dataset.name;

    this.updatedValue[name] = value;
  }

  /**
   * @description : this method used forhandling entity type selction
   */
  handleEntitySelection(event) {
    const checkboxChecked = event.target.value;
    this.updatedValue = {};
    let name = event.target.dataset.name;
    let checkboxName = event.target.dataset.id;
    if (checkboxName === "US persons, inclusive of US entities") {
      this.isUsEntitySelected = true;
      this.isNonUsEntitySelected = false;
      this.isUsEntity = true;
      this.isNotUsEntity = false;
      this.isPartnerFinancialInstitution = false;
      this.isRegisteredFinancialInstitution = false;
      this.isForeignFinancialInstitution = false;
      this.trusteeGiin = false;
      this.trusteeEntity = false;
      this.trusteeannex = false;
      this.trusteeOwner = false;
      this.trusteeNonParticipant = false;
      this.showStatusType = false;
      this.statusExpected = false;
      this.statusEntity = false;
      this.statusFinancial = false;
      this.statusOwner = false;
      this.trusteeName = "";
      this.trustGIIN = "";
      this.isIGAFinalInstitution = false;
      this.registeredGIIN = "";
      this.showTrusteeDetails = false;
      this.fatchaStatusType = "";
      this.headerLabel = "US persons, inclusive of US entities";
    } else if (
      checkboxName === "US FATCA classification for all non US entites"
    ) {
      this.isNonUsEntitySelected = true;
      this.isUsEntitySelected = false;
      this.isNotUsEntity = true;
      this.isUsEntity = false;
      this.headerLabel =
        "Section 1: US FATCA classification for all non US entities";
      this.itemList = [
        {
          id: 0
        }
      ];
    }
    this.updatedValue[name] = checkboxChecked;
  }

  /**
   * @description : this method used for getting updated values
   */
  updateGIINDetails(item) {
    if (
      item.registeredType === "IGA partner jurisdiction financial institution"
    ) {
      this.isIGAFinalInstitution = true;
      this.isPartnerFinancialInstitution = true;
    } else if (
      item.registeredType ===
      "Registered deemed complaint foreign financial institution"
    ) {
      this.isRegisteredFinancialInstitution = true;
      this.isIGAFinalInstitution = false;
    } else if (
      item.registeredType === "Participating foreign financial institution"
    ) {
      this.isForeignFinancialInstitution = true;
      this.isIGAFinalInstitution = false;
    }
  }

  /**
   * @description : this method used for getting updated values
   */
  updateTrusteeDetails(item) {
    if (
      item.nonGIINType ===
      "The entity is a sponsored financial institution (including a sponsored investment entity or sponsored closely held investment vehicle) and has not yet obtained a GIIN but is sponsored by another entity that has registered as a sponsoring entity"
    ) {
      this.showTrusteeDetails = false;
      this.trusteeGiin = true;
    } else if (
      item.nonGIINType === "Entity is a non-participating financial institution"
    ) {
      this.trusteeNonParticipant = true;
      this.showTrusteeDetails = false;
    } else if (item.nonGIINType === "Entity is a trustee documented trust") {
      this.trusteeEntity = true;
      this.showTrusteeDetails = true;
    } else if (
      item.nonGIINType ===
      "The entity is a certified deemed compliant, or other non-reporting foreign financial institution(including a foreign financial institution deemed compliant under annex II of an IGA)"
    ) {
      this.trusteeannex = true;
      this.showTrusteeDetails = false;
    } else if (
      item.nonGIINType === "Entity is an owner documented financial institution"
    ) {
      this.trusteeOwner = true;
      this.showTrusteeDetails = false;
    }
  }

  /**
   * @description : this method used for input changes
   */
  genericInputChange(event) {
    let value = event.target.value;
    let name = event.target.dataset.name;
    this.updatedValue[name] = value;
    const lightningInput = event.target.closest("lightning-input");
    lightningInput.setCustomValidity("");
  }

  /**
   * @description : this method used for checkbox changes
   */
  handleCheckboxChangedForTrustee(event) {
    let value = event.target.value;
    if (
      value ===
      "The entity is a sponsored financial institution (including a sponsored investment entity or sponsored closely held investment vehicle) and has not yet obtained a GIIN but is sponsored by another entity that has registered as a sponsoring entity"
    ) {
      this.trusteeGiin = true;
      this.trusteeEntity = false;
      this.trusteeannex = false;
      this.trusteeOwner = false;
      this.trusteeNonParticipant = false;
      this.trusteeName = null;
      this.trustGIIN = null;
      this.showTrusteeDetails = false;
    } else if (
      value === "Entity is a non-participating financial institution"
    ) {
      this.showTrusteeDetails = false;
      this.trusteeName = null;
      this.trustGIIN = null;
      this.trusteeGiin = false;
      this.trusteeEntity = false;
      this.trusteeannex = false;
      this.trusteeOwner = false;
      this.trusteeNonParticipant = true;
    } else if (value === "Entity is a trustee documented trust") {
      this.showTrusteeDetails = true;
      this.trusteeGiin = false;
      this.trusteeEntity = true;
      this.trusteeannex = false;
      this.trusteeOwner = false;
      this.trusteeNonParticipant = false;
    } else if (
      value ===
      "The entity is a certified deemed compliant, or other non-reporting foreign financial institution(including a foreign financial institution deemed compliant under annex II of an IGA)"
    ) {
      this.showTrusteeDetails = false;
      this.trusteeName = null;
      this.trustGIIN = null;
      this.trusteeGiin = false;
      this.trusteeEntity = false;
      this.trusteeannex = true;
      this.trusteeOwner = false;
      this.trusteeNonParticipant = false;
    } else if (
      value === "Entity is an owner documented financial institution"
    ) {
      this.showTrusteeDetails = false;
      this.trusteeName = null;
      this.trustGIIN = null;
      this.trusteeGiin = false;
      this.trusteeEntity = false;
      this.trusteeannex = false;
      this.trusteeOwner = true;
      this.trusteeNonParticipant = false;
    }
    let name = event.target.dataset.name;
    this.updatedValue[name] = value;
  }

  /**
   * @description : this method used for adding rows
   */
  addRow() {
    this.isNonUsEntitySelected = false;
    ++this.keyIndex;
    let newItem = [
      {
        id: this.keyIndex
      }
    ];
    this.itemList = this.itemList.concat(newItem);
  }

  /**
   * @description : this method used for removing the multiple rows
   */
  removeRow(event) {
    let itemList = this.itemList;
    itemList.splice(event.target.dataset.index, 1);
    this.itemList = itemList;
  }

  /**
   * @description : this method used for updateStatusDetails onload to get updated values
   */
  updateStatusDetails(item) {
    if (item.fatchStatus === "The entity is an exempt beneficial owner") {
      this.statusOwner = true;
      this.showStatusType = true;
    } else if (
      item.fatchStatus ===
      "The entity is an active non-financial foreign entity (including an expected NFFE)"
    ) {
      this.statusExpected = true;
      this.showStatusType = false;
    } else if (
      item.fatchStatus ===
      "The entity is a passive non-financial foreign entity"
    ) {
      this.statusEntity = true;
      this.showStatusType = false;
    } else if (
      item.fatchStatus ===
      "The entity is a direct reporting non-financial foreign entity"
    ) {
      this.statusFinancial = true;
      this.showStatusType = false;
    }
  }
  /**
   * @description : this method used for handling the checkbox of status
   */
  handleCheckboxChangedForStatus(event) {
    let value = event.target.value;
    if (value === "The entity is an exempt beneficial owner") {
      this.showStatusType = true;
      this.statusExpected = false;
      this.statusEntity = false;
      this.statusFinancial = false;
      this.statusOwner = true;
    } else if (
      value ===
      "The entity is an active non-financial foreign entity (including an expected NFFE)"
    ) {
      this.showStatusType = false;
      this.fatchaStatusType = null;
      this.statusExpected = true;
      this.statusEntity = false;
      this.statusFinancial = false;
      this.statusOwner = false;
    } else if (
      value === "The entity is a passive non-financial foreign entity"
    ) {
      this.showStatusType = false;
      this.fatchaStatusType = null;

      this.statusExpected = false;
      this.statusEntity = true;
      this.statusFinancial = false;
      this.statusOwner = false;
    } else if (
      value === "The entity is a direct reporting non-financial foreign entity"
    ) {
      this.showStatusType = false;
      this.fatchaStatusType = null;

      this.statusExpected = false;
      this.statusEntity = false;
      this.statusFinancial = true;
      this.statusOwner = false;
    }
    let name = event.target.dataset.name;
    this.updatedValue[name] = value;
  }

  collectValues() {
    const app = this.updatedValue;
    if (app.fatchaType === "US FATCA classification for all non US entites") {
      return {
        CIB_AB_US_Fatcha_Type__c: app.fatchaType,
        CIB_AB_US_USPersonsEntitiesDetails__c: null,
        CIB_AB_NUS_RegisteredFIType__c: app.registeredType,
        CIB_AB_NUS_RegisteredFIGIIN__c: app.registeredGIIN,
        CIB_AB_NUS_NonGIINType__c: app.nonGIINType,
        CIB_AB_NUS_TrustName__c: app.trustName,
        CIB_AB_NUS_TrustGIIN__c: app.trustGIIN,
        CIB_AB_NUS_FATCAStatusType__c: app.fatchaStatusType,
        CIB_AB_NUS_FATCAStatus__c: app.fatchStatus
      };
    }
    if (app.fatchaType === "US persons, inclusive of US entities") {
      return {
        CIB_AB_US_Fatcha_Type__c: app.fatchaType,
        CIB_AB_US_USPersonsEntitiesDetails__c: JSON.stringify(this.itemList),
        CIB_AB_NUS_RegisteredFIType__c: null,
        CIB_AB_NUS_RegisteredFIGIIN__c: null,
        CIB_AB_NUS_NonGIINType__c: null,
        CIB_AB_NUS_TrustName__c: null,
        CIB_AB_NUS_TrustGIIN__c: null,
        CIB_AB_NUS_FATCAStatusType__c: null,
        CIB_AB_NUS_FATCAStatus__c: null
      };
    }
    return {
      CIB_AB_US_Fatcha_Type__c: app.fatchaType,
      CIB_AB_US_USPersonsEntitiesDetails__c: JSON.stringify(this.itemList),
      CIB_AB_NUS_RegisteredFIType__c: null,
      CIB_AB_NUS_RegisteredFIGIIN__c: null,
      CIB_AB_NUS_NonGIINType__c: null,
      CIB_AB_NUS_TrustName__c: null,
      CIB_AB_NUS_TrustGIIN__c: null,
      CIB_AB_NUS_FATCAStatusType__c: null,
      CIB_AB_NUS_FATCAStatus__c: null
    };
  }
}