import { LightningElement, api, track } from "lwc";
import initialization from "@salesforce/apex/MallDataService.initialization";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";
import DEFAULT_MALL_LANGUAGE_ISO from "@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO";
import { mallStateName, getUserState } from "c/sbgUserStateUtils";

const DEFAULT_SEGMENT_NAME = "Business";
const DEFAULT_CATEGORY_NAME = "All";

export default class MallCategoryFilter extends LightningElement {
  @api selectedCategories = [];
  @api updateSelectedCategories;

  @track categories = [];
  @track validationError = false;
  showFilterList = false;
  error;
  //maintains the overall state of the user and application
  mallStateConfig = {
    mallUserSelectedCountry: "",
    mallUserSelectedLanguage: "",
    selectedSegmentNames: [],
    selectedSegmentIds: [],
    selectedCategoryIds: [],
    selectedCategoryNames: []
  };
  selectedSegment;

  connectedCallback() {
    this.init();
  }

  toggleFilterList() {
    this.showFilterList = !this.showFilterList;

    if (this.showFilterList) {
      document.addEventListener("click", this.handleDocumentClick);
    } else {
      document.removeEventListener("click", this.handleDocumentClick);
    }
  }

  handleDocumentClick(event) {
    const dropdown = this.template.querySelector(".category-dropdown");
    if (!dropdown.contains(event.target)) {
      this.showFilterList = false;
      document.removeEventListener("click", this.handleDocumentClick);
    }
  }

  handleCategoryChange(event) {
    const categoryId = event.target.dataset.id;
    const isChecked = event.target.checked;
     
    if(categoryId == DEFAULT_CATEGORY_NAME) {
      if(isChecked) {
        this.categories = this.categories.map((category) => {
          if (category.id === categoryId) {
            category.checked = isChecked;
            category.selected = isChecked;
          } else {
            category.checked = !isChecked;
            category.selected = isChecked;
          }
          return category;
        });
      }
    } else {
      this.categories = this.categories.map((category) => {
        if (category.id === categoryId) {
          category.checked = isChecked;
          category.selected = isChecked;
        }
        if(category.id == DEFAULT_CATEGORY_NAME) {
          category.checked = false;
          category.selected = false;
        }
        return category;
      });
    }
  }

  applyFilters() {
    const selectedCategories = this.categories.filter(
      (category) => (category.selected && category.id != DEFAULT_CATEGORY_NAME)
    );

    if (selectedCategories.length === 0) {
      this.validationError = true;
    } else {
      this.validationError = false;
      this.updateSelectedCategories(selectedCategories);
      this.updateMallState(selectedCategories);
      this.dispatchEvent(new CustomEvent("filter", { detail : {selectedCategories: selectedCategories, mallStateConfig : this.mallStateConfig }}));
      this.toggleFilterList();
    }
  }

  clearCategory(event) {
    const categoryId = event.currentTarget.dataset.categoryId;
    this.selectedCategories = this.selectedCategories.filter(
      (category) => category.id !== categoryId
    );
    this.updateSelectedCategories(this.selectedCategories);
    this.updateMallState(this.selectedCategories);
    this.dispatchEvent(new CustomEvent("filter", { detail : this.selectedCategories, mallStateConfig : this.mallStateConfig }));
  }

  updateMallState(selectedCategories) {
    this.mallStateConfig.selectedCategoryIds = selectedCategories.map(
      (category) => category.id
    );
    this.mallStateConfig.selectedCategoryNames = selectedCategories.map(
      (category) => category.name
    );
    this.mallStateConfig.selectedSegmentIds = [this.selectedSegment.id];
    this.mallStateConfig.selectedSegmentNames = [this.selectedSegment.id];
    return this.mallStateConfig;
  }

  /* Init function for the mall home page */
  async init() {
    let mallStateConfig = {};
    let mallCollection = {};
    try {
      let selectedSegmentName = DEFAULT_SEGMENT_NAME.toLocaleLowerCase();
      let selectedCategoryName = DEFAULT_CATEGORY_NAME;
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
      let categories = mallCollection.categories;
      if(categories && categories.length > 0) {
        this.processCategoriesInfo(categories);
        this.mallStateConfig.selectedCategoryIds = this.categories.map(
          (category) => category.id
        );
        this.mallStateConfig.selectedCategoryNames = this.categories.map(
          (category) => category.name
        );
        this.selectedCategories = [this.categories[0]];
      }

      for (let row = 0; row < mallCollection.segments.length; row++) {
        if (
          mallCollection.segments[row].name.toLocaleLowerCase() ==
          selectedSegmentName.toLocaleLowerCase()
        ) {
          this.selectedSegment = {
            id: mallCollection.segments[row].id,
            name: mallCollection.segments[row].name,
            label: mallCollection.segments[row].title
          };
          break;
        }
      }
    } catch (error) {
      this.error = error;
    }
  }

  processCategoriesInfo(categories) {
    if (!categories) {
      this.categories = [];
      this.categoryOptions = {};
      return;
    }
    let categoryOptions = this.getCategoryOptions([...categories]);
    let defaultCategoryOption = {
      id: DEFAULT_CATEGORY_NAME,
      name: DEFAULT_CATEGORY_NAME,
      label: DEFAULT_CATEGORY_NAME,
      checked : true,
      selected : true
    };
    this.categories = [defaultCategoryOption, ...categoryOptions];
  }


  getCategoryOptions(tags) {
    return tags.map((DenormalizedTag) => {
      return {
        id: DenormalizedTag.id,
        name: DenormalizedTag.name,
        label: DenormalizedTag.title,
        checked: false,
        selected: false
      };
    });
  }
}