import { LightningElement, track, wire, api } from "lwc";
import getInsights from "@salesforce/apex/CTRL_Mall_ArticleInsights.getInsights";
import USER_MALLSTATE_CHANGED_EVT from "@salesforce/messageChannel/UserMallStateChanged__c";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import IS_GUEST from "@salesforce/user/isGuest";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import { NavigationMixin } from "lightning/navigation";
import MALL_SIGN_UP_OR_SIGN_IN from "@salesforce/label/c.MALL_SIGN_UP_OR_SIGN_IN";
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import mallInsightImages from "@salesforce/resourceUrl/mallInsightImages";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";

const MALL_INSIGHTS_HEADING = "Insights";
const MALL_INSIGHTS_MIN_READ_TEXT = "min read";
const MALL_INSIGHTS_LIMIT = 5;

export default class MallStateInsights extends NavigationMixin(
  LightningElement
) {
  isGuestUser = true;
  @track insights = [];
  @track topInsight;
  @track secondInsight;
  @track selectedInsight;
  error;
  subscription = null;
  translationsLoaded = false;
  insightsLoaded = false;
  @track isShowModal = false;
  mallStateChangeSubscription = null;
  mallStateConfig;
  navigateToWebPage = navigateToWebPage.bind(this);
  signupurl = getBaseUrl() + "/mall/s/" + "sign-up";
  mallRegisterOrSignIn = MALL_SIGN_UP_OR_SIGN_IN;
  @api richTextContent;
  renderedRichText = "";

  get insightsHeading() {
    return MALL_INSIGHTS_HEADING;
  }
  get minReadText() {
    return MALL_INSIGHTS_MIN_READ_TEXT;
  }

  timerIcon = mallIcons + "/mallInsightTimerIcon.svg";

  @wire(MessageContext)
  messageContext;

  /*subscribe for mall state change event*/
  subscribeToMallStateChangeMessageChannel() {
    if (!this.mallStateChangeSubscription) {
      this.mallStateChangeSubscription = subscribe(
        this.messageContext,
        USER_MALLSTATE_CHANGED_EVT,
        (message) => this.handleMallStateChange(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  /*unsubscribe mall state change event*/
  unsubscribeToMallStateChangeMessageChannel() {
    unsubscribe(this.mallStateChangeSubscription);
    this.mallStateChangeSubscription = null;
  }

  /*Handle Mall State change Event*/
  handleMallStateChange(message) {
    let mallStateConfig = { ...message };
    this.mallStateConfig = { ...mallStateConfig };
    this.getInsightsByCategoryIds();
  }

  showModalBox(event) {
    let insightId;
    if (!event.target.dataset.tileid) {
      insightId = event.target.closest("[data-tileid]").dataset.tileid;
    } else {
      insightId = event.target.dataset.tileid;
    }
    if (this.topInsight.tileId == insightId) {
      this.selectedInsight = this.topInsight;
    } else if (this.secondInsight.tileId == insightId) {
      this.selectedInsight = this.secondInsight;
    } else {
      this.selectedInsight = this.insights.find(
        (insight) => insight.tileId == insightId
      );
    }
    this.isShowModal = true;
  }

  hideModalBox() {
    this.isShowModal = false;
    this.selectedInsight = null;
  }

  connectedCallback() {
    let richTextElement = this.template.querySelector(".rich-text");
    if (richTextElement) {
      this.richTextContent = richTextElement.value;
      let firstParagraphEndIndex = this.richTextContent.indexOf("</p>") + 4;
      let truncatedContent = this.richTextContent.substring(
        0,
        firstParagraphEndIndex
      );
      this.richTextContent = truncatedContent + "...Read more";
    }
    this.isGuestUser = IS_GUEST;
    this.getInsightsByCategoryIds();
    this.subscribeToMallStateChangeMessageChannel();
  }

  renderedCallback() {
    const insightDescriptionsList = this.template.querySelectorAll(
      ".insight-description"
    );
    insightDescriptionsList.forEach((description) => {
      if (description.scrollHeight > description.offsetHeight) {
        description.style.setProperty("--opacity", 1);
      } else {
        description.style.setProperty("--opacity", 0);
      }
    });
    addAnalyticsInteractions(this.template);
  }

  disconnectedCallback() {
    this.unsubscribeToMallStateChangeMessageChannel();
  }

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
    sectionTitle: "MALL_INSIGHTS"
  };

  async getInsightsByCategoryIds() {
  try {
    let insights = await getInsights({country: DEFAULT_MALL_COUNTRY, category: 'Insights'});
    this.processInsightCollection(insights);
  } catch (error) {
    this.error = error;
  }
}

  processInsightCollection(insightsContent) {
    insightsContent = this.sortData(
      "LastPublishedDate",
      "desc",
      insightsContent,
      "datetime"
    );
    let insights = [];
    for (let row = 0; row < insightsContent.length; row++) {
      let insight = {};
      insight["tileId"] = insightsContent[row].Id;
      if(insightsContent[row].Image__c) {
        insight["tileIcon"] = this.processImageUrl(insightsContent[row].Image__c);
      }
      insight["tileTitle"] = insightsContent[row].Title;
      insight["tileText"] = insightsContent[row].Summary;
      insight["tileDescription"] = insightsContent[row].Info__c;
      insight["readTime"] = insightsContent[row].duration;
      let publishDate = insightsContent[row].LastPublishedDate
        ? new Date(insightsContent[row].LastPublishedDate)
        : new Date();
      insight["tileDate"] = `${("0" + publishDate.getDate()).slice(-2)}/${(
        "0" +
        (publishDate.getMonth() + 1)
      ).slice(-2)}/${publishDate.getFullYear()}`;

      if (row < MALL_INSIGHTS_LIMIT) {
        if (row == 0) {
          this.topInsight = insight;
        } else if (row == 1) {
          this.secondInsight = insight;
        } else {
          insights.push(insight);
        }
      } else {
        break;
      }
    }
    this.insights = [...insights];
    this.insightsLoaded = true;
  }

  processImageUrl(imageUrl) {
    let firstSubString = this.substringBetween(imageUrl,'<img', 'img>');
    let secondSubString = this.substringBetween(firstSubString,'src="', '"');
    let link = secondSubString.replaceAll('amp;', '');
    return link;
  }

  substringBetween(str, start, end) {
    return str.substring(str.indexOf(start) + (("src=").length + 1), str.lastIndexOf(end));
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

  handleGoToRegister(event) {
    event.preventDefault();
    event.stopPropagation();
    this.hideModalBox();
    const signupurl = this.signupurl;
    this.navigateToWebPage(signupurl);
  }

mallFirstInsight = mallInsightImages + "/FirstInsight.png";
mallSecondInsight = mallInsightImages + "/SecondInsight.png";
mallThirdInsight = mallInsightImages + "/ThirdInsight.png";
mallFourthInsight = mallInsightImages + "/FourthInsight.png";
}