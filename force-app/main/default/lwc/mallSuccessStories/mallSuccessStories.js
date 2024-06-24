import { LightningElement, api, track, wire } from "lwc";
import getSuccessStoriesByCountryNames from "@salesforce/apex/MallDataService.getSuccessStoriesByCountryNames";
import { mallStateName, getUserState } from "c/sbgUserStateUtils";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";
import DEFAULT_MALL_LANGUAGE_ISO from "@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import MALL_DEFAULT_BUTTON_TITLE from "@salesforce/label/c.MALL_DEFAULT_BUTTON_TITLE";
import { getBaseUrl } from "c/mallNavigation";

export default class MallSuccessStories extends NavigationMixin(
  LightningElement
) {
  storyId;
  @track successStoriesList;
  showItems = false;
  showButtons = false;
  leftDisabled = true;
  isSuccessStory = true;
  rightDisabled = false;
  storiesCollectionObject = {};
  trueVal = false;
  mallDefaultButtonTitle = MALL_DEFAULT_BUTTON_TITLE;

  connectedCallback() {
    this.getSuccessStoriesByCountry();
  }

  async getSuccessStoriesByCountry() {
    try {
      let mallStateConfig = {};
      mallStateConfig.mallUserSelectedCountry = getUserState(
        mallStateName.mallUserSelectedCountry,
        DEFAULT_MALL_COUNTRY
      );
      mallStateConfig.mallUserSelectedLanguage = getUserState(
        mallStateName.mallUserSelectedLanguageISOCode,
        DEFAULT_MALL_LANGUAGE_ISO
      );
      let successStories = await getSuccessStoriesByCountryNames({
        mallContext: JSON.stringify(mallStateConfig),
        countries: [mallStateConfig.mallUserSelectedCountry]
      });

      if (this.storyId) {
        successStories = successStories.filter(
          (successStory) => successStory.id != this.storyId
        );
      }
      this.successStoriesList = [...successStories];
      this.processSuccessStoriesCollection([...this.successStoriesList]);
      if (this.successStoriesList && this.successStoriesList.length > 0) {
        this.showItems = true;
        this.showButtons = this.successStoriesList.length > 5;
      }
    } catch (error) {
      this.error = error;
    }
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

  processSuccessStoriesCollection(stories) {
    let storiesCollectionObject = {};
    storiesCollectionObject.type = this.storyId
      ? "Other success stories"
      : "Success stories";

    if (!stories) {
      storiesCollectionObject.list = [];
      this.storiesCollectionObject = [];
      return;
    }

    storiesCollectionObject.list = stories;
    storiesCollectionObject.list = this.sortData(
      "publishedFrom",
      "asc",
      storiesCollectionObject.list,
      "datetime"
    );
    for (let row = 0; row < storiesCollectionObject.list.length; row++) {
      let storyProcessed = { ...storiesCollectionObject.list[row] };
      storyProcessed.title = storyProcessed.name;
      storyProcessed.hideModal = true;
      storyProcessed.text = storyProcessed.summary;
      storyProcessed.description = storyProcessed.summary;
      storyProcessed.imageUrl = storyProcessed.bannerImageUrl;
      storyProcessed.url = null;
      storyProcessed.readMoreUrl =
        getBaseUrl() + "/mall/s/success-story/" + storyProcessed.id;
      storyProcessed.taggingText = storyProcessed.name + " success story";
      storyProcessed.taggingTypeId = storyProcessed.id;
      storyProcessed.taggingScope = "BCB Platform success stories";
      storiesCollectionObject.list[row] = storyProcessed;
    }
    this.storiesCollectionObject = [storiesCollectionObject];
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.storyId = currentPageReference?.attributes?.recordId;
      if (
        this.successStoriesList &&
        this.successStoriesList.length &&
        this.storyId
      ) {
        this.successStoriesList = this.successStoriesList.filter(
          (successStory) => successStory.id != this.storyId
        );
        if (this.successStoriesList && this.successStoriesList.length > 0) {
          this.processSuccessStoriesCollection([...this.successStoriesList]);
          this.showItems = true;
        }
      }
    }
  }
}