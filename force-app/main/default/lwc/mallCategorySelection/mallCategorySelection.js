import { LightningElement, api, track, wire } from "lwc";
import initialization from "@salesforce/apex/MallDataService.initialization";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";
import DEFAULT_MALL_LANGUAGE_ISO from "@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO";
import { mallStateName, getUserState } from "c/sbgUserStateUtils";
import { MessageContext, publish } from "lightning/messageService";
import USER_MALLSTATE_CHANGED_EVT from "@salesforce/messageChannel/UserMallStateChanged__c";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";

const DEFAULT_SEGMENT_NAME = "Business";
const DEFAULT_CATEGORY_NAME = "All";
const DEFAULT_CATEGORY_LINK_CLASS = "nav-item";
const MALL_CATEGORY_SELECTION_HELPER_TEXT = "Select a minimum of 1";

export default class MallCategorySelection extends LightningElement {
  @api enable = false;
  @track hasSelectionError = false;
  segments = [];
  @track selectedSegment = {
    label: DEFAULT_SEGMENT_NAME,
    value: DEFAULT_SEGMENT_NAME,
    labeloutput: DEFAULT_SEGMENT_NAME
  };
  categories = [];
  @track selectedCategory = {
    label: DEFAULT_CATEGORY_NAME,
    value: DEFAULT_CATEGORY_NAME,
    labeloutput: DEFAULT_CATEGORY_NAME,
    categoryLinkClass: DEFAULT_CATEGORY_LINK_CLASS,
    selected: false
  };
  @track categoryOptions;
  @track segmentOptions;
  categoriesIcon = sbgVisualAssets + "/Category_Select_Icon.svg";
  showPopUp = false;
  error = undefined;
  connectedCallBackRunOnce = false;
  @wire(MessageContext)
  messageContext;
  @api isCatalogue = false;
  isCatalogueFilters = true;
  catalogueSelectorHelperText = MALL_CATEGORY_SELECTION_HELPER_TEXT;
  //maintains the overall state of the user and application
  mallStateConfig = {
    mallUserSelectedCountry: "",
    mallUserSelectedLanguage: "",
    selectedSegmentNames: [],
    selectedSegmentIds: [],
    selectedCategoryIds: [],
    selectedCategoryNames: []
  };

  connectedCallback() {
    window.addEventListener("closeDropdowns", () => {
      let dropdowns = this.template.querySelectorAll(
        ".dropdown [aria-expanded]"
      );
      dropdowns.forEach((item) => {
        item.setAttribute("aria-expanded", false);
      });
    });
    if (!this.connectedCallBackRunOnce) {
      this.init();
    }
  }

  /* Init function for the mall home page */
  async init() {
    let mallStateConfig = {
      ...this.mallStateConfig
    };
    let mallCollection = {};
    try {
      let selectedSegmentName = DEFAULT_SEGMENT_NAME.toLocaleLowerCase();
      let selectedCategoryName = getUserState(
        mallStateName.selectedCategoryName
      )
        ? getUserState(mallStateName.selectedCategoryName)
        : DEFAULT_CATEGORY_NAME;
      mallStateConfig.selectedSegmentNames = [selectedSegmentName];
      mallStateConfig.selectedCategoryNames = [selectedCategoryName];
      mallStateConfig.mallUserSelectedCountry = getUserState(
        mallStateName.mallUserSelectedCountry,
        DEFAULT_MALL_COUNTRY
      );
      mallStateConfig.mallUserSelectedLanguage = getUserState(
        mallStateName.mallUserSelectedLanguageISOCode,
        DEFAULT_MALL_LANGUAGE_ISO
      );

      this.mallStateConfig = {
        ...mallStateConfig
      };
      mallCollection = await initialization({
        mallContext: JSON.stringify(this.mallStateConfig)
      });
      this.segments = mallCollection.segments;
      this.processSegmentInfo(this.segments);
      this.categories = mallCollection.categories;
      this.processCategoriesInfo(this.categories);
      for (let row = 0; row < this.segments.length; row++) {
        if (
          this.segments[row].name.toLocaleLowerCase() ==
          selectedSegmentName.toLocaleLowerCase()
        ) {
          this.selectedSegment = {
            label: this.segments[row].name,
            value: this.segments[row].id,
            labeloutput: this.segments[row].title
          };
          this.segments[row];
          break;
        }
      }
      publish(
        this.messageContext,
        USER_MALLSTATE_CHANGED_EVT,
        this.mallStateConfig
      );
      this.connectedCallBackRunOnce = true;
    } catch (error) {
      this.error = error;
    }
  }

  processSegmentInfo(segments) {
    if (!segments) {
      this.segments = [];
      this.segmentOptions = {};
      return;
    }
    this.segments = [...segments];
    this.segmentOptions = this.getTaggingOptions([...segments]);
    this.mallStateConfig.selectedSegmentIds = segments.map(
      (segment) => segment.id
    );
    this.mallStateConfig.selectedSegmentNames = segments.map(
      (segment) => segment.name
    );
    this.segmentOptions.push({
      label: DEFAULT_SEGMENT_NAME,
      value: DEFAULT_SEGMENT_NAME,
      labeloutput: DEFAULT_SEGMENT_NAME
    });
  }

  processCategoriesInfo(categories) {
    if (!categories) {
      this.categories = [];
      this.categoryOptions = {};
      return;
    }
    let categoryOptions = this.getTaggingOptions([...categories]);
    let defaultCategoryOption = {
      label: DEFAULT_CATEGORY_NAME,
      value: DEFAULT_CATEGORY_NAME,
      labeloutput: DEFAULT_CATEGORY_NAME,
      categoryLinkClass: `${DEFAULT_CATEGORY_LINK_CLASS} category-link-selected`,
      selected: true
    };
    this.categoryOptions = [defaultCategoryOption, ...categoryOptions];
    this.selectedCategory = defaultCategoryOption;
    this.mallStateConfig.selectedCategoryIds = categories.map(
      (category) => category.id
    );
    this.mallStateConfig.selectedCategoryNames = categories.map(
      (category) => category.name
    );
  }

  setTagIds(tags) {
    let tagIds = [];
    tagIds = tags.map((denormalizedTag) => {
      return denormalizedTag.id;
    });
    return tagIds;
  }

  getTaggingOptions(tags) {
    return tags.map((DenormalizedTag) => {
      return {
        label: DenormalizedTag.name,
        value: DenormalizedTag.id,
        labeloutput: DenormalizedTag.title,
        selected: false
      };
    });
  }

  toggleDropdown(event) {
    event.stopPropagation();
    let selector;
    if (event.target.classList.contains("[aria-expanded]")) {
      selector = event.target;
    } else {
      selector = event.target.closest("[aria-expanded]");
    }
    if (selector) {
      let state =
        selector.getAttribute("aria-expanded") === "true" ? true : false;
      this.triggerCloseDropdowns();
      selector.setAttribute("aria-expanded", !state);
    }
  }

  triggerCloseDropdowns() {
    window.dispatchEvent(new CustomEvent("closeDropdowns"));
  }

  setCategory(event) {
    event.stopPropagation();
    let selectedCategoryFound = false;
    this.setShowHideCategoryPopup(event);
    for (let row = 0; row < this.categories.length; row++) {
      if (this.categories[row].id == event.currentTarget.dataset.value) {
        this.selectedCategory = {
          label: this.categories[row].name,
          value: this.categories[row].id,
          labeloutput: this.categories[row].title,
          categoryLinkClass: `${DEFAULT_CATEGORY_LINK_CLASS} category-link-selected`,
          selected: true
        };
        selectedCategoryFound = true;
        break;
      }
    }
    if (!selectedCategoryFound) {
      this.selectedCategory = {
        label: DEFAULT_CATEGORY_NAME,
        value: DEFAULT_CATEGORY_NAME,
        labeloutput: DEFAULT_CATEGORY_NAME,
        categoryLinkClass: DEFAULT_CATEGORY_LINK_CLASS,
        selected: true
      };
    }
    window.dispatchEvent(new CustomEvent("closeDropdowns"));
    let mallStateConfig = {};
    let selectedSegmentValue = [this.selectedSegment.value];
    let selectedCategoryValue = [];
    if (
      !selectedCategoryFound &&
      this.selectedCategory.label == DEFAULT_CATEGORY_NAME
    ) {
      selectedCategoryValue = this.categories.map((category) => category.id);
    } else {
      selectedCategoryValue = [this.selectedCategory.value];
    }
    mallStateConfig.mallUserSelectedCountry = getUserState(
      mallStateName.mallUserSelectedCountry,
      DEFAULT_MALL_COUNTRY
    );
    mallStateConfig.mallUserSelectedLanguage = getUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      DEFAULT_MALL_LANGUAGE_ISO
    );
    mallStateConfig.selectedSegmentIds = selectedSegmentValue;
    mallStateConfig.selectedCategoryIds = selectedCategoryValue;
    mallStateConfig.selectedCategoryNames = [this.selectedCategory.label];
    publish(this.messageContext, USER_MALLSTATE_CHANGED_EVT, mallStateConfig);
  }

  selectMultipleCategories() {
    let mallStateConfig = {};
    let selectedSegmentValue = [this.selectedSegment.value];
    mallStateConfig.mallUserSelectedCountry = getUserState(
      mallStateName.mallUserSelectedCountry,
      DEFAULT_MALL_COUNTRY
    );
    mallStateConfig.mallUserSelectedLanguage = getUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      DEFAULT_MALL_LANGUAGE_ISO
    );
    mallStateConfig.selectedSegmentIds = selectedSegmentValue;
    mallStateConfig.selectedCategoryIds = [
      ...this.mallStateConfig.selectedCategoryIds
    ];
    mallStateConfig.selectedCategoryNames = [
      ...this.mallStateConfig.selectedCategoryNames
    ];
    publish(this.messageContext, USER_MALLSTATE_CHANGED_EVT, mallStateConfig);
  }

  handleCategorySelection(event) {
    event.preventDefault();
    event.stopPropagation();
    let value = event.currentTarget.dataset.value;
    let selectedCategoryIds = [];
    let selectedCategoryNames = [];
    let categoryOptions = [...this.categoryOptions];
    if (value == DEFAULT_CATEGORY_NAME) {
      for (let row = 0; row < categoryOptions.length; row++) {
        if (categoryOptions[row].label == DEFAULT_CATEGORY_NAME) {
          categoryOptions[row].selected = true;
          categoryOptions[
            row
          ].categoryLinkClass = `${DEFAULT_CATEGORY_LINK_CLASS} category-link-selected`;
        } else {
          categoryOptions[row].selected = false;
          categoryOptions[
            row
          ].categoryLinkClass = `${DEFAULT_CATEGORY_LINK_CLASS}`;
          selectedCategoryIds.push(categoryOptions[row].value);
          selectedCategoryNames.push(categoryOptions[row].label);
        }
      }
    } else {
      for (let row = 0; row < categoryOptions.length; row++) {
        if (categoryOptions[row].value == value) {
          categoryOptions[row].selected = !categoryOptions[row].selected;
          categoryOptions[
            row
          ].categoryLinkClass = `${DEFAULT_CATEGORY_LINK_CLASS} category-link-selected`;
        }
        if (categoryOptions[row].label == DEFAULT_CATEGORY_NAME) {
          categoryOptions[row].selected = false;
        }
        if (categoryOptions[row].selected) {
          selectedCategoryIds.push(categoryOptions[row].value);
          selectedCategoryNames.push(categoryOptions[row].label);
        }
      }
    }
    if (selectedCategoryIds.length <= 0) {
      this.hasSelectionError = true;
      return;
    }
    this.hasSelectionError = false;
    this.categoryOptions = [...categoryOptions];
    this.mallStateConfig.selectedCategoryIds = [...selectedCategoryIds];
    this.mallStateConfig.selectedCategoryNames = [...selectedCategoryNames];
  }

  handleApplySelection(event) {
    event.preventDefault();
    event.stopPropagation();
    if (this.hasSelectionError) {
      return;
    }
    this.selectMultipleCategories();
    this.setShowHideCategoryPopup(event);
    window.dispatchEvent(new CustomEvent("closeDropdowns"));
  }

  setShowHideCategoryPopup(event) {
    this.toggleDropdown(event);
  }

  removeSelection(event) {
    let value = event.target.dataset.value;
    let selectedCategoryIds = [];
    let selectedCategoryNames = [];
    let categoryOptions = [...this.categoryOptions];
    if (value) {
      for (let row = 0; row < categoryOptions.length; row++) {
        if (
          categoryOptions[row].value == value &&
          categoryOptions[row].value != DEFAULT_CATEGORY_NAME
        ) {
          categoryOptions[row].selected = false;
        } else if (categoryOptions[row].selected) {
          selectedCategoryIds.push(categoryOptions[row].value);
          selectedCategoryNames.push(categoryOptions[row].label);
        }
      }
      if (selectedCategoryIds.length <= 0) {
        this.hasSelectionError = true;
        return;
      }
      this.hasSelectionError = false;
      this.categoryOptions = [...categoryOptions];
      this.mallStateConfig.selectedCategoryIds = [...selectedCategoryIds];
      this.mallStateConfig.selectedCategoryNames = [...selectedCategoryNames];
      this.selectMultipleCategories();
    }
  }
}