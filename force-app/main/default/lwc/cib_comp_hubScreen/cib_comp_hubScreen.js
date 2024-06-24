import { api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import getApplicatinSections from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicatinSections";
import { loadScript } from "lightning/platformResourceLoader";
import getSessionId from "@salesforce/apex/CIB_CTRL_ApplicationZipFileDownload.getSessionId";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { refreshApex } from "@salesforce/apex";
export default class Cib_comp_hubScreen extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  libInitialized = false;
  @track sessionId;
  @track error;
  @api recordId;
  @api sectionId;
  @track sections = [];
  _wiredSections;
  @track showToDo = false;
  subscription = {};
  @api channelName = "/event/CIB_Application_Section__e";
  questionIcon = MAU_ThemeOverrides + "/assets/images/questionIcon.png";
  @track assistanceModal = false;
  @track assistanceRequestInputVariables = [];
  @track _isRendered = false;

  connectedCallback() {
    super.connectedCallback();
    this.getSessionId();
  }

  get loading() {
    return !this.isLoaded;
  }

  get hasSubmitted() {
    return this.submittedSections.length > 0;
  }

  get hasTodo() {
    return this.inProgressSections.length > 0;
  }

  get hasCompleted() {
    return this.completedSections.length > 0;
  }

  get isSubmittedDisabled() {
    return this.sections.some(
      (section) =>
        section.Status__c !== "Submitted" && section.Status__c !== "Completed"
    );
  }

  get company() {
    return this.applicationRecord.CIB_BAI_CompanyRegisteredName__c;
  }

  get notificationComponent() {
    return this.template.querySelector('[data-id="notificationComp"]');
  }

  get inProgressSections() {
    return this.sections.filter(
      (section) => !["Submitted", "Completed"].includes(section.Status__c)
    );
  }

  get submittedSections() {
    return this.sections.filter((section) => section.Status__c === "Submitted");
  }

  get completedSections() {
    return this.sections.filter((section) => section.Status__c === "Completed");
  }

  @wire(getApplicatinSections, {
    recordId: "$recordId"
  })
  wiredRecord(wiredSectionData) {
    this._wiredSections = wiredSectionData;
    const { error, data } = wiredSectionData;
    if (data) {
      this.sections = [...data].sort((a, b) => a.Order__c - b.Order__c);
      // this.isLoaded = true;
    } else if (error) {
      this.handleError(error);
    }
  }

  navigateToSection(event) {
    let sectionId = event.detail;
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "sectionId",
      sectionId
    );
    this.dispatchEvent(attributeChangeEvent);

    if (this.availableActions.find((action) => action === "NEXT")) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }

  async handleSubmitAll() {
    await this.updateSectionRecord("Submitted");
    super.navigateToNextScreen();
  }
  navigateToBack() {
    super.navigateToPreviousScreen();
  }

  async getSessionId() {
    try {
      const data = await getSessionId();
      this.sessionId = data;
      this.error = undefined;
      loadScript(this, MAU_ThemeOverrides + "/assets/js/cometd/cometd.js").then(
        () => {
          this.initializecometd();
        }
      );
    } catch (error) {
      this.handleError(error);
      this.sessionId = undefined;
    }
  }

  initializecometd() {
    let self = this;
    if (this.libInitialized) {
      return;
    }
    this.libInitialized = true;
    let cometdlib = new window.org.cometd.CometD();
    let url =
      window.location.protocol +
      "//" +
      window.location.hostname +
      "/cometd/58.0/";
    cometdlib.configure({
      url,
      requestHeaders: { Authorization: "OAuth " + this.sessionId },
      appendMessageTypeToURL: false,
      logLevel: "error"
    });

    cometdlib.websocketEnabled = false;

    cometdlib.handshake(function (status) {
      if (status.successful) {
        cometdlib.subscribe(self.channelName, function (message) {
          const id = message.data.payload.ApplicationId__c;
          if (self.applicationRecord.Id === id) {
            refreshApex(self._wiredSections);
            self.notificationComponent.refreshNotifications();
          }
        });
      } else {
        this.handleError("Unable to connect to notification server");
      }
    });
  }

  requestAssistance() {
    this.assistanceRequestInputVariables = [
      {
        name: "recordId",
        type: "String",
        value: this.recordId
      }
    ];
    this.assistanceModal = true;
  }
  closeAssistanceRequest() {
    this.assistanceModal = false;
  }
  handleFlowStatusChange(event) {
    if (event.detail.status === "FINISHED") {
      this.assistanceModal = false;
    }
  }
}