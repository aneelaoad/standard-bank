import { LightningElement, api, track } from "lwc";
import { setPaginationFlag } from "c/mallPaginationComponent";
import MALL_NEXT_BUTTON_LABEL from "@salesforce/label/c.MALL_NEXT_BUTTON_LABEL";
import MALL_PREV_BUTTON_LABEL from "@salesforce/label/c.MALL_PREV_BUTTON_LABEL";
import IS_GUEST from "@salesforce/user/isGuest";
import { NavigationMixin } from "lightning/navigation";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import benefitsIcons from "@salesforce/resourceUrl/mallBenefits";

const MOCK_OBJECT = [
  {
    type: "Something",
    coverImage: {
      imageUrl: "",
      description: "test description",
      button: {
        url: "/test",
        label: "read more",
        title: "read more"
      }
    },
    list: [
      {
        id: "1",
        title: "test",
        description: "test",
        url: "test"
      },
      {
        id: "2",
        title: "test",
        description: "test",
        url: "test"
      }
    ]
  }
];
const COVER_IMAGE_TYPE = "cover-image-description";
const BACKGROUND_COLOUR_CLASS = "background-wrapper";
const SCROLLBTNS_DEFAULT_CLASS = "scroll-toggles";
const TITLE_FIRST_PARAGRAPH = "Why the best way forward is with us";
export default class mallBenefitsList extends NavigationMixin(
  LightningElement
) {

    // Simangaliso Start
    titleFirstParagraph = TITLE_FIRST_PARAGRAPH;
    benefitsIconScales = benefitsIcons+"/mallBenefits/icons/icn_bulb.png";
    //Simangaliso End
  @api set collection(collection) {
    if (this.mockEnabled) {
      collection = MOCK_OBJECT;
    }
    if (collection && collection.length > 0) {
      this.setContent(collection);
      this.collectionList = collection;
    }
  }

  get collection() {
    return this.collectionList;
  }

  @track collectionList = [];
  @api mockEnabled = false;
  @api backgroundClass = BACKGROUND_COLOUR_CLASS;
  @track offeringType;
  @track coverImage;
  @track modal;
  @track button;
  @track list;
  showCoverButton = false;
  @api isSuccessStory;
  @api isOfferingDetail = false;
  @track isShowModal = false;
  isGuestUser;
  selectedItem;
  isSolutions = false;
  @api isGuideLine = false;
  @api isBusinessEventItem = false;
  @api enableModal = false;

  coverImageClass = COVER_IMAGE_TYPE;
  navigateToWebPage = navigateToWebPage.bind(this);
  setContent(collection) {
    collection.map((item) => {
      this.offeringType = item.type;
      this.coverImage = item.coverImage;
      this.modal = item.modal;
      this.button = item.button;
      if (this.button && this.button.title) {
        this.showCoverButton = true;
      }

      if (this.showCoverButton) {
        this.coverImageClass = COVER_IMAGE_TYPE + " button-variant";
      }

      if (this.offeringType == "Solutions") {
        this.isSolutions = true;
      }
      this.list = item.list;
    });
  }

  productRangeWrapperCssClass = "background-wrapper";
  boundSetPaginationFlag = setPaginationFlag.bind(this);
  showShopSliderArrows;
  shopSliderScrollBtnsCLassList = "";
  nextButtonLabel = MALL_NEXT_BUTTON_LABEL;
  prevButtonLabel = MALL_PREV_BUTTON_LABEL;

  connectedCallback() {
    this.isGuestUser = IS_GUEST;
  }

  renderedCallback() {
    let layoutItems = this.template.querySelectorAll("lightning-layout-item");
    const container = "list-track";

    if (this.boundSetPaginationFlag(layoutItems, container)) {
      this.shopSliderScrollBtnsCLassList = `${SCROLLBTNS_DEFAULT_CLASS} show-scrollBtns`;
    } else {
      this.shopSliderScrollBtnsCLassList = `${SCROLLBTNS_DEFAULT_CLASS}`;
    }

    window.addEventListener("resize", () => {
      if (this.boundSetPaginationFlag(layoutItems, container)) {
        this.shopSliderScrollBtnsCLassList = `${SCROLLBTNS_DEFAULT_CLASS} show-scrollBtns`;
      } else {
        this.shopSliderScrollBtnsCLassList = `${SCROLLBTNS_DEFAULT_CLASS}`;
      }
    });
  }

  shopSliderScroll(event) {
    let maxScrollLeft = 0;
    let content = this.template.querySelector('[data-slider-id="slider"]');
    let filterCategoryContainer = this.template.querySelectorAll(".list-track");
    filterCategoryContainer.forEach((filter) => {
      maxScrollLeft += filter.scrollLeft;
    });

    if (event.type === "mousedown") {
      if (event.target.classList.contains("scroll-button_next")) {
        if (window.innerWidth > 768) {
          content.scrollLeft += 576;
        } else {
          content.scrollLeft += 300;
        }
        this.enableScroll = true;

        event.preventDefault();
      }
      if (event.target.classList.contains("scroll-button_prev")) {
        if (window.innerWidth > 768) {
          content.scrollLeft -= 576;
        } else {
          content.scrollLeft -= 300;
        }
        if (content.scrollLeft == 0) {
          this.leftDisabled = true;
        }
        this.enableScroll = true;
        event.preventDefault();
      }
    }
  }

  showModalBox(event) {
    this.selectedItem = event.detail.selectedItem;
    this.isShowModal = true;
  }

  hideModalBox() {
    this.isShowModal = false;
  }

  handleModalButtonClick(event) {
    const buttonName = event.currentTarget.dataset.button;
    const callback = event.currentTarget.dataset.callback;
    const detail = this.selectedItem;
    this.executeModalButtonClickEvent(buttonName, detail, callback);
  }

  executeModalButtonClickEvent(buttonName, detail, callback) {
    const executeModalEvent = new CustomEvent("modalbuttonclick", {
      detail: {
        record: detail,
        buttonName: buttonName,
        callback: callback
      }
    });
    this.dispatchEvent(executeModalEvent);
  }

  goToSolutionsCatalogue(event) {
    event.preventDefault();
    event.stopPropagation();
    let link = getBaseUrl() + "/mall/s/solutions-catalogue";
    this.navigateToWebPage(link);
  }
}