import { LightningElement, api, track, wire } from "lwc";
import getQuickLinks from "@salesforce/apex/MallQuickLinksController.getQuickLinks";
import updateQuickLinks from "@salesforce/apex/MallQuickLinksController.updateQuickLinks";
import deleteQuickLinks from "@salesforce/apex/MallQuickLinksController.deleteQuickLinks";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import { NavigationMixin } from "lightning/navigation";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { addSearchAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { CurrentPageReference } from "lightning/navigation";
const MALL_NO_SERVICE_MESSAGE =
  "Your dashboard appears to be empty. Elevate your experience by configuring Quick links and setting up your dashboard";
const MALL_BROWSE_SERVICES = "Browse services";
const MALL_SORT_BY_LABEL = "Sort by";
const MALL_CONFIGURE_LABEL = "Configure";
const MALL_QUICKLINKS_HEADING = "Quick links";
const MALL_CONFIGURE_QUICKLINKS_MODAL_HEADING = "Configure quick links";
const MALL_CONFIGURE_ALL_CHECKBOX_LABLE = "All";
const MALL_CONFIGURE_QUICKLINKS_HELPER_TEXT =
  "Add quick links for efficient access from your dashboard.";
const MALL_CONFIGURE_QUICKLINKS_SEARCH_PLACEHOLDER = "Search...";
const MALL_CONFIGURE_QUICKLINKS_SEARCH_LABEL = "Search (Services, quick links)";
const MALL_CONFIGURE_QUICKLINKS_SELECTION_ERROR =
  "Ensure you've selected at least one Quick Link to populate your dashboard.";
const MALL_CONFIGURE_QUICKLINKS_SEARCH_NO_SERVICES_MESSAGE =
  "There are no matching services to your term. Please adjust your search.";
const MALL_QUICK_LINKS_INFORMATION_HEADER = "Discover quick links";
const MALL_QUICK_LINKS_INFORMATION_MESSAGE =
  "We've pre-selected some default quick links for you. Feel free to explore these options or select the configure button to add your own.";
export default class MallQuicklinks extends NavigationMixin(LightningElement) {
  navigateToWebPage = navigateToWebPage.bind(this);

  hasQuicklinksRegistered = true;
  noServicesMessage = MALL_NO_SERVICE_MESSAGE;
  browseServicesLabel = MALL_BROWSE_SERVICES;
  heading = MALL_QUICKLINKS_HEADING;
  configureHeading = MALL_CONFIGURE_QUICKLINKS_MODAL_HEADING;
  noSearchResults = MALL_CONFIGURE_QUICKLINKS_SEARCH_NO_SERVICES_MESSAGE;
  infoText = MALL_QUICK_LINKS_INFORMATION_MESSAGE;
  infoHeader = MALL_QUICK_LINKS_INFORMATION_HEADER;

  isSortDropdownOpen = false;
  isShowModal = false;
  showAllCheckbox = true;
  isSelectionInvalid = false;
  showSpinner = false;
  isSearchEmpty = false;

  sortList = [
    {
      id: "sort1",
      name: "A-Z",
      isActive: true
    },
    {
      id: "sort2",
      name: "Z-A"
    }
  ];

  sortByLabel = MALL_SORT_BY_LABEL;
  sortByIcon = "/sfsites/c/resource/sbgIcons/NAVIGATION/icn_arrow_swop.svg";
  configureAllCheckboxLable = MALL_CONFIGURE_ALL_CHECKBOX_LABLE;

  configureLabel = MALL_CONFIGURE_LABEL;
  configureIcon =
    "/sfsites/c/resource/sbgIcons/NAVIGATIONVIEWS/icn_settings_outline.svg";

  configureQuicklinksSearchLabel = MALL_CONFIGURE_QUICKLINKS_SEARCH_LABEL;
  configureQuicklinksSearchPlaceholder =
    MALL_CONFIGURE_QUICKLINKS_SEARCH_PLACEHOLDER;
  configureQuicklinksHelperText = MALL_CONFIGURE_QUICKLINKS_HELPER_TEXT;
  configureQuicklinksSelectionError = MALL_CONFIGURE_QUICKLINKS_SELECTION_ERROR;

  @track allServices = [];
  @track displayServices;
  @track userSavedLinks;
  @track configuredLinks = [];
  allLinkIds = [];
  @track displayedLinkIds = [];
  searchTerm = "";
  @track modalServices;
  pageType;
  error;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.pageType = currentPageReference.type;
    }
  }

  get getSortIcon() {
    return this.sortByIcon
      ? this.setAsBackgroundImageByUrl(this.sortByIcon)
      : "";
  }

  get isDisabled() {
    return !this.hasQuicklinksRegistered;
  }

  renderedCallback() {
    addAnalyticsInteractions(this.template);
  }

  toggleDropdown(event, state) {
    let selector;
    if (event && event.target) {
      if (event.target.getAttribute("[aria-expanded]")) {
        selector = event.target;
      } else {
        selector = event.target.closest("[aria-expanded]");
      }

      let state = selector.getAttribute("aria-expanded") === "true";

      this.triggerCloseDropdowns();

      window.dropdownIntentToOpen = !state;

      selector.setAttribute("aria-expanded", !state);
    }

    return !state;
  }

  triggerCloseDropdowns() {
    window.dispatchEvent(new CustomEvent("closeFilters"));
  }

  showModalBox(event) {
    this.isShowModal = true;
  }

  hideModalBox() {
    this.isShowModal = false;
    this.resetModalServices();
  }

  resetModalServices() {
    this.modalServices.forEach((item) => {
      if (item.collection) {
        item.collection.forEach((link) => {
          link.modalChecked = link.userSaved;
        });
      }
    });
  }

  connectedCallback() {
    if (!window.closeFiltersListener) {
      window.addEventListener("closeFilters", () => {
        window.closeFiltersListener = true;
        let dropdowns = this.template.querySelectorAll(
          ".dropdown.filter [aria-expanded]"
        );

        dropdowns.forEach((item) => {
          item.setAttribute("aria-expanded", false);
        });
      });
    }

    this.getQuickLinksInfo();
  }

  async getQuickLinksInfo() {
    try {
      let result = await getQuickLinks();
      this.allServices = [...result];
      let services = [...result];
      this.modalServices = result.filter((item) => {
        return item.collection;
      });
      this.resetModalServices();

      services.forEach((element) => 
        {
          let links = [];
          if (element.collection) {
            links = element.collection.filter((quickLink) => {
              this.allLinkIds.push(quickLink.id);
              quickLink.formattedIcon = this.setAsBackgroundImageByUrl(
                quickLink.icon
              );
              if (quickLink.userSaved) {
                this.configuredLinks.push(quickLink.id);
              }
              return quickLink.userSaved;
            });
          }
          element.savedLinks = links;
        }
      );

      this.hasQuicklinksRegistered = (services.length > 0);
      this.displayServices = this.formatDisplayQuickLinks([...services]);
    } catch(error) {
      this.error = error;
    }
  }

  formatDisplayQuickLinks(services) {
    let formattedDisplayService = {};
    let allCollection = [];
    let allSavedLinks = [];
    if(services && services.length > 0 ) {
      services.forEach((element) => {
        let links = [];
        if (element.collection) {
          links = element.collection.filter((quickLink) => {
            quickLink.formattedIcon = this.setAsBackgroundImageByUrl(
              quickLink.icon
            );
            if (quickLink.userSaved) {
            }
            return quickLink.userSaved;
          });
        }
        element.savedLinks = links;
        if(element.collection) {
          allCollection = [...allCollection, ...element.collection];
        }
        if(element.savedLinks) {
          allSavedLinks = [...allSavedLinks, ...element.savedLinks];
        }
      });
      formattedDisplayService = {...services[0]};
      formattedDisplayService.collection = [...allCollection];
      formattedDisplayService.savedLinks = [...allSavedLinks];
    }
    return [formattedDisplayService];
  }

  sortQuicklinks(event) {
    let sortType = event.currentTarget.dataset.value == "Z-A" ? "desc" : "asc";
    if(this.displayServices && this.displayServices.length > 0) {
      let formttedService = this.displayServices[0];
      let  sortedQuickLinks= this.sortData(
        "title",
        sortType,
        formttedService.savedLinks,
        "String"
      );
      formttedService.savedLinks = [...sortedQuickLinks];
      this.displayServices = [formttedService];
    }
  }

  get collection() {
    return this.displayServices;
  }

  openSortByDropdown(event) {
    this.isSortDropdownOpen = !this.isSortDropdownOpen;
  }

  openQuicklinksConfiguration() {
    this.triggerCloseDropdowns();
    this.showModalBox();
  }

  handleAllCheckboxSelection(event) {
    if (event.currentTarget.checked) {
      this.configguredLinks = [];
      this.configuredLinks = [...this.allLinkIds];
      this.modalServices.forEach((item) => {
        item.collection.forEach((link) => {
          link.modalChecked = true;
        });
      });
    } else {
      this.configuredLinks = [];
      this.modalServices.forEach((item) => {
        item.collection.forEach((link) => {
          link.modalChecked = false;
        });
      });
    }
    this.validationCheck();
  }

  handleCheckboxSelection(event) {
    if (!this.configuredLinks.includes(event.currentTarget.dataset.linkid)) {
      this.configuredLinks.push(event.currentTarget.dataset.linkid);
    } else {
      const index = this.configuredLinks.indexOf(
        event.currentTarget.dataset.linkid
      );
      if (index > -1) {
        this.configuredLinks.splice(index, 1);
      }
    }
    this.modalServices.forEach((item) => {
      item.collection.forEach((link) => {
        if (link.id == event.currentTarget.dataset.linkid) {
          link.modalChecked = event.target.checked;
        }
      });
    });

    this.validationCheck();
  }

  validationCheck() {
    this.isSelectionInvalid = this.configuredLinks.length < 1;
  }

  handleApply() {
    this.isShowModal = !this.isShowModal;
    this.showSpinner = !this.showSpinner;
    updateQuickLinks({ linkIds: this.configuredLinks })
      .then((result) => {
        this.showToast("Success!", "Your Links have been saved!!", "success");
        this.getQuickLinksInfo();
        this.showSpinner = !this.showSpinner;
      })
      .catch((error) => {
        this.showToast("Something went wrong!", error.message, "error");
        this.showSpinner = !this.showSpinner;
      });
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  setAsBackgroundImageByUrl(url) {
    return `background-image: url('${url}');`;
  }

  handleSearch(event) {
    this.searchTerm = event.target.value;
    this.isSearchEmpty = false;

    if (this.searchTerm) {
      this.modalServices = [];
      this.showAllCheckbox = false;
      this.allServices.forEach((service) => {
        if (!!service.collection) {
          if (
            service.title.toLowerCase().includes(this.searchTerm.toLowerCase())
          ) {
            this.modalServices.push(service);
          } else {
            for (let i = 0; i < service.collection.length; i++) {
              if (
                service.collection[i].title
                  .toLowerCase()
                  .includes(this.searchTerm.toLowerCase())
              ) {
                this.modalServices.push(service);
                break;
              }
            }
          }
        }
      });
    } else {
      this.showAllCheckbox = true;
      this.modalServices = this.allServices.filter((item) => {
        return item.collection;
      });
    }
    !this.modalServices.length ? (this.isSearchEmpty = true) : false;

    addSearchAnalyticsInteractions(
      this.modalServices.length,
      "All",
      this.searchTerm,
      this.pageType
    );
  }

  sortData(fieldName, sortDirection, array, type) {
    let sortResult = [...array];
    let parser = (v) => v;
    if (type === "date" || type === "datetime") {
      parser = (v) => v && new Date(v);
    }
    let sortMult = sortDirection === "asc" ? 1 : -1;
    array = sortResult.sort((a, b) => {
      let a1 = parser(a[fieldName]),
        b1 = parser(b[fieldName]);
      let r1 = a1 < b1,
        r2 = a1 === b1;
      return r2 ? 0 : r1 ? -sortMult : sortMult;
    });
    return array;
  }

  handleRemoveLink(event) {
    let linkid = event.detail;
    if (!this.checkRemoveValidations(linkid)) {
      const index = this.configuredLinks.indexOf(linkid);
      if (index > -1) {
        this.configuredLinks.splice(index, 1);
      }
      this.showSpinner = !this.showSpinner;
      deleteQuickLinks({ linkIds: [linkid]})
        .then((result) => {
          this.showToast("Success!", "Link removed successfully!", "success");
          this.getQuickLinksInfo();
          this.updateModalServices();
          this.showSpinner = !this.showSpinner;
        })
        .catch((error) => {
          this.showToast("Something went wrong!", error.message, "error");
          this.showSpinner = !this.showSpinner;
        });
    }
  }

  checkRemoveValidations(linkId) {
    let fireValidation = false;
    this.displayServices.forEach((service) => {
      if (service.collection) {
        let savedQuicklinks = service.collection.filter((link) => {
          return link.userSaved;
        });
        if (savedQuicklinks.length == 1 && savedQuicklinks[0].id == linkId) {
          this.showToast(
            "Link cannot be removed!",
            "selecting one quick link for a service is mandatory!",
            "error"
          );
          fireValidation = true;
          return;
        }
      }
    });
    return fireValidation;
  }

  updateModalServices() {
    this.modalServices.forEach((item) => {
      item.collection.forEach((link) => {
        link.modalChecked = this.configuredLinks.includes(link.id);
      });
    });
  }

  handleBrowseServices() {
    let homePage = getBaseUrl() + "/mall/s/";
    this.navigateToWebPage(homePage);
  }
}