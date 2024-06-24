import { LightningElement, api, track } from "lwc";
import getCustomerAccountList from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerAccountList";
import getCustomerDocumentsByAccountNumbers from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerDocumentsByAccountNumbers";
import getCustomerStampedStatementsByAccountNumbers from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerStampedStatementsByAccountNumbers";
import getCustomerPreviousStatementsByAccountNumbers from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerPreviousStatementsByAccountNumbers";
import getCustomerDocumentByUUID from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerDocumentByUUID";
import deleteDocumentDownloaded from "@salesforce/apex/CTRL_MallDocumentManagement.deleteDocumentDownloaded";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import { NavigationMixin } from "lightning/navigation";
import createCaseRecord from "@salesforce/apex/MallCaseManagementUtil.createCaseRecord";
import getUserRecord from "@salesforce/apex/MallCaseManagementUtil.getUserRecord";
import CASE_CONTACT_FIELD from "@salesforce/schema/Case.ContactId";
import CASE_COMMENT_FIELD from "@salesforce/schema/Case.Description";
import CASE_SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import CASE_CASETYPE_FIELD from "@salesforce/schema/Case.Case_Type__c";
import CASE_CASESOURCE_FIELD from "@salesforce/schema/Case.Origin";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import loggedInUserId from "@salesforce/user/Id";

const DEFAULT_CASETYPE = "Customer document";
const DEFAULT_ORIGIN = "BCB Platform";

export default class MallDocumentManagement extends NavigationMixin(
  LightningElement
) {
  user;
  @track documents = [];
  @track statements = [
    {
      isExtendedMonths: true,
      cardHeader: "Previous 24 months",
      cardDate: "15/09/2023",
      isStamped: "Unstamped",
      accountName: "Current business account",
      accountNumber: "435676589"
    }
  ];
  statementsCopy = [
    {
      isExtendedMonths: true,
      cardHeader: "Previous 24 months",
      cardDate: "15/09/2023",
      isStamped: "Unstamped",
      accountName: "Current business account",
      accountNumber: "435676589"
    }
  ];
  @api documentView = false;
  @api statementView = false;
  downloadLabel = "DOWNLOAD SELECTED";
  contactLabel = "CONTACT YOUR BANKER";
  bankerText = "For alternative statements please contact your banker.";
  bankerName = "Sarah Khumalo";
  bankerEmail = "sarah.khumalo@standardbank.co.za";
  bankerCallCentre = "Call centre - 011 111 1111";
  bankerEmailLink = `mailto: ${this.bankerEmail}`;
  additionalComment = "";
  documentsHeader = "Business documents";
  documetnsSubHeader =
    "The following documents are available for download or query.";
  statementsHeader = "Statements";
  statementsSubHeader =
    "Let's get you the statement you need, starting with your profile and account.";
  noAccountHeader = "You did not select an account yet.";
  noAccountSubText = "You need to select a bank account first.";
  documentErrorHeader = "There is a problem loading your request.";
  documentErrorSubText = "Try to reload the page or contact your banker.";
  header;
  subHeader;
  documentList;
  datesSelected = false;
  startDate = "";
  endDate = "";
  downloadActive = false;
  navigateToWebPage = navigateToWebPage.bind(this);
  queryHeading = "Document query";
  queryBtnText = "SUBMIT";
  @track showModal = false;
  modalSubject = "";
  selectedAccountId;
  selectedProfileId;
  @track businessProfiles = [];
  @track businessAccounts = [];
  @track unstampedStatements = [];
  unstampedStatementsLoaded = false;
  showSpinner = false;
  showExtendedSpinner = false;

  datePickersContainer;
  previousStatementsHeader;
  extendedMonthsSpinner;
  error;
  @track errorUnstampedRange = "";
  noAccountSelected = false;
  documentError = false;

  connectedCallback() {
    if (this.documentView) {
      this.header = this.documentsHeader;
      this.subHeader = this.documetnsSubHeader;
      this.documentList = this.documents;
    } else {
      this.header = this.statementsHeader;
      this.subHeader = this.statementsSubHeader;
      this.documentList = this.statements;
    }
    this.getCustomerAccountListDetails();
  }

  renderedCallback() {
    if (this.noAccountSelected === false && this.documentError === false) {
      if (this.statementView) {
        this.datePickersContainer = this.template.querySelector(
          ".date-pickers-container"
        );
        this.previousStatementsHeader =
          this.datePickersContainer.previousElementSibling;
        this.extendedMonthsSpinner = this.template.querySelector(
          ".statements-extended-download"
        );
      }
    }
  }

  handleDateChange(event) {
    let selector = event.target;
    let isValiDateRange = true;
    if (selector.getAttribute("data-name") == "startdate") {
      this.startDate = selector.value;
    } else if (selector.getAttribute("data-name") == "enddate") {
      this.endDate = selector.value;
    }

    if (this.startDate != "" && this.endDate != "") {
      this.datesSelected = true;
      isValiDateRange = this.isValidDateRange(this.startDate, this.endDate);
      if (!isValiDateRange) {
        this.errorUnstampedRange = "Please select a valid date range";
      } else {
        this.errorUnstampedRange = "";
        this.datePickersContainer.style.opacity = "0.35";
        this.previousStatementsHeader.style.opacity = "0.35";
        this.extendedMonthsSpinner.style.display = "block";
        this.showExtendedSpinner = true;
        this.getCustomerPreviousStatementsByAccountNumbersDetails(
          this.selectedAccountId,
          this.startDate,
          this.endDate
        );
      }
    }
  }

  isValidDateRange(startDate, endDate) {
    // Convert the start and end dates to Date objects
    var startDateObj = new Date(startDate);
    var endDateObj = new Date(endDate);

    // Calculate the difference in months
    var monthsDifference =
      (endDateObj.getFullYear() - startDateObj.getFullYear()) * 12 +
      (endDateObj.getMonth() - startDateObj.getMonth());

    // Create a new Date object for the current date
    var currentDate = new Date();

    // Check if the start date is less than the end date, the difference is not more than 24 months,
    // and both dates are not greater than the current date
    return (
      startDateObj < endDateObj &&
      monthsDifference <= 24 &&
      startDateObj <= currentDate &&
      endDateObj <= currentDate
    );
  }

  async handleDownloadDocument(event) {
    let documentUUID = event.target.dataset.documentuuid;
    let selectedBtn = event.target;
    let selectedCard = selectedBtn.closest(".card");
    selectedBtn.classList.toggle("hidden");
    selectedCard.classList.toggle("active");
    try {
      const link = await getCustomerDocumentByUUID({
        documentUUID: documentUUID
      });
      window.open(link, "_blank");
      this.handlePostDocumentDownloadCleanUp(link);
    } catch (error) {
      this.error = error;
    } finally {
      selectedBtn.classList.toggle("hidden");
      selectedCard.classList.toggle("active");
    }
  }

  async handleUnstampedDocumentDownload(event) {
    let documentUUID = event.target.dataset.documentuuid;
    let selectedBtn = event.target;
    let selectedCard = selectedBtn.closest(".previous-statement");
    selectedBtn.classList.toggle("hidden");
    selectedCard.classList.toggle("active");
    try {
      this.showSpinner = true;
      const link = await getCustomerDocumentByUUID({
        documentUUID: documentUUID
      });
      this.showSpinner = false;
      window.open(link, "_blank");
      this.handlePostDocumentDownloadCleanUp(link);
    } catch (error) {
      this.showSpinner = false;
      this.error = error;
    } finally {
      selectedBtn.classList.toggle("hidden");
      selectedCard.classList.toggle("active");
    }
  }

  handlePostDocumentDownloadCleanUp(link) {
    let url = new URL(link);
    let searchParams = url.searchParams;
    const contentVersionId = searchParams.get("ids");
    if (contentVersionId) {
      setTimeout(() => {
        this.deleteContent(contentVersionId);
      }, 200000);
    }
  }

  async deleteContent(contentVersionId) {
    try {
      let status = await deleteDocumentDownloaded({
        contentVersionId: contentVersionId
      });
    } catch (error) {
      this.error = error;
    }
  }

  handleContactBanker(event) {
    event.preventDefault();
    this.navigateToWebPage(getBaseUrl() + "/mall/s/contact-your-banker");
  }

  showQueryModal(event) {
    let selectedQueryBtn = event.target;
    let selectedCardIndex = selectedQueryBtn.getAttribute("data-index");
    for (let i = 0; i < this.documents.length; i++) {
      if (selectedCardIndex == i) {
        this.modalSubject = `${this.documents[i].cardHeader} - document query`;
      }
    }
    this.showModal = true;
  }

  handleCommentChange(event) {
    this.additionalComment = event.target.value;
  }

  closeQueryModal() {
    this.showModal = false;
  }

  submitQuery() {
    const textArea = this.template.querySelector("lightning-textarea");
    let enteredText = textArea.value;
    if (enteredText == "" || enteredText == undefined) {
      textArea.classList.add("slds-has-error");
    } else {
      this.handleSubmitCase();
    }
  }

  handleProfileSelectionChange(message) {
    const profileId = message.detail.profileId;
    const accountId = message.detail.accountId;
    this.selectedAccountId = accountId;
    if (this.businessProfiles && this.businessProfiles.length > 0) {
      for (let row = 0; row < this.businessProfiles.length; row++) {
        if (this.businessProfiles[row].value == profileId) {
          this.selectedProfileId = profileId;
          this.businessAccounts = this.businessProfiles[row].accounts;
          break;
        }
      }
    }
  }

  handleAccountSelectionChange(message) {
    const profileId = message.detail.profileId;
    const accountId = message.detail.accountId;
    this.selectedAccountId = accountId;
    this.selectedProfileId = profileId;
    if (this.documentView) {
      this.getCustomerDocumentsByAccountNumbersDetails(accountId);
    } else if (this.statementView) {
      this.getCustomerStampedStatementsByAccountNumbersDetails(accountId);
    }
  }

  async getCustomerAccountListDetails() {
    try {
      let customerProfileAndAccountListResponse = await getCustomerAccountList();
      let customerAccountListDetails = customerProfileAndAccountListResponse.customerAccountListDetails;
      if(!customerAccountListDetails && customerAccountListDetails.length <=0) {
        return;
      }

      const mapProductVsAccountIds = new Map();
      
      for(let row=0; row < customerAccountListDetails.length; row++) {
        let key = customerAccountListDetails[row]["productName"];
        if(mapProductVsAccountIds.has(key)) {
          let accountIds = mapProductVsAccountIds.get(key);
          accountIds.push(customerAccountListDetails[row]["accountNumber"]);
          mapProductVsAccountIds.set(key, accountIds);
        } else {
          mapProductVsAccountIds.set(key, [customerAccountListDetails[row]["accountNumber"]]);
        }
      }


      let customerProfiles = [];
      for (const key of mapProductVsAccountIds.keys()) {
        let accountIds = mapProductVsAccountIds.get(key);
        let customerAccountProfile = {};
        customerAccountProfile["label"] = key;
        customerAccountProfile["value"] = key;
        customerAccountProfile["labeloutput"] = key
        let customerProfileAccounts = [];
        for (let k = 0; k < accountIds.length; k++) {
          let customerProfileAccount = {};
          customerProfileAccount["label"] = customerAccountProfile["label"] + "-" + accountIds[k];
          customerProfileAccount["value"] = accountIds[k];
          customerProfileAccount["labeloutput"] = customerAccountProfile["labeloutput"] + "-" + accountIds[k];
          customerProfileAccounts.push(customerProfileAccount);
        }
        customerAccountProfile["accounts"] = customerProfileAccounts;
        customerProfiles.push(customerAccountProfile);
      }
      let businessProfiles = [...customerProfiles];
      this.businessProfiles = [...businessProfiles];
      if (this.businessProfiles && this.businessProfiles.length > 0) {
        this.businessAccounts = this.businessProfiles[0].accounts;
      }
      this.customerProfileAndAccountList = [...customerProfiles];
    } catch (error) {
      this.error = error;
    }
  }

  async getCustomerDocumentsByAccountNumbersDetails(accountId) {
    try {
      let customerDocumentsResponse =
        await getCustomerDocumentsByAccountNumbers({
          accountNumbers: [accountId]
        });
      let customerDocuments = customerDocumentsResponse["resultSet"];
      let customerDocResponseFormatted = [];
      for (let row = 0; row < customerDocuments.length; row++) {
        let customerDoc = { ...customerDocuments[row] };
        customerDoc["cardHeader"] = customerDoc.label;
        customerDoc["cardDate"] = customerDoc.documentUploadedDate
          ? this.formatDate(customerDoc.documentUploadedDate)
          : this.formatDate(new Date());
        customerDoc["accountName"] = this.getSelectedProfile(
          this.businessProfiles,
          this.selectedProfileId
        ).labeloutput;
        customerDoc["accountNumber"] = customerDoc.accountNumber;
        customerDoc["accountId"] = customerDoc.accountNumber;
        customerDoc["uid"] = customerDoc.uid;
        customerDocResponseFormatted.push(customerDoc);
      }
      this.documents = [...customerDocResponseFormatted];
      this.documentList = [...this.documents];
    } catch (error) {
      this.error = error;
    }
  }

  async getCustomerStampedStatementsByAccountNumbersDetails(accountId) {
    try {
      let stampedStatementsResponse =
        await getCustomerStampedStatementsByAccountNumbers({
          accountNumbers: [accountId]
        });
      let stampedStatements = stampedStatementsResponse["resultSet"];
      let stampedStatementsResponseFormatted = [];
      for (let row = 0; row < stampedStatements.length; row++) {
        let stampedStatementDoc = { ...stampedStatements[row] };
        stampedStatementDoc["cardHeader"] = stampedStatementDoc.label;
        stampedStatementDoc["cardDate"] =
          stampedStatementDoc.documentUploadedDate
            ? this.formatDate(stampedStatementDoc.documentUploadedDate)
            : this.formatDate(new Date());
        stampedStatementDoc["accountName"] = this.getSelectedProfile(
          this.businessProfiles,
          this.selectedProfileId
        ).labeloutput;
        stampedStatementDoc["accountNumber"] =
          stampedStatementDoc.accountNumber;
        stampedStatementDoc["accountId"] = stampedStatementDoc.accountNumber;
        stampedStatementDoc["uid"] = stampedStatementDoc.uid;
        stampedStatementDoc["isStamped"] = "Stamped";
        stampedStatementDoc["isExtendedMonths"] = false;
        stampedStatementsResponseFormatted.push(stampedStatementDoc);
      }
      this.statements = [
        ...stampedStatementsResponseFormatted,
        ...this.statementsCopy
      ];
      this.documentList = [...this.statements];
    } catch (error) {
      this.error = error;
    }
  }

  async getCustomerPreviousStatementsByAccountNumbersDetails(
    accountId,
    startDate,
    endDate
  ) {
    try {
      this.unstampedStatementsLoaded = false;
      let previousStatetementsResponse =
        await getCustomerPreviousStatementsByAccountNumbers({
          accountNumbers: [accountId],
          startDate: startDate,
          endDate: endDate
        });
      let previousStatetements = previousStatetementsResponse["resultSet"];
      let previousStatetementsResponseFormatted = [];
      let cardDateIdentifiers = [];
      for (let row = 0; row < previousStatetements.length; row++) {
        let cardUniqueLabel = previousStatetements[row].description;
        if (!cardDateIdentifiers.includes(cardUniqueLabel)) {
          let previousStatetementDoc = { ...previousStatetements[row] };
          previousStatetementDoc["cardHeader"] = previousStatetementDoc.label;
          previousStatetementDoc["cardDate"] = cardUniqueLabel;
          previousStatetementDoc["accountNumber"] =
            this.getSelectedProfile(
              this.businessProfiles,
              this.selectedProfileId
            ).labeloutput +
            "-" +
            previousStatetementDoc.accountNumber;
          previousStatetementDoc["accountId"] =
            previousStatetementDoc.accountId;
          previousStatetementDoc["uid"] = previousStatetementDoc.uid;
          previousStatetementDoc["label"] = previousStatetementDoc.label;
          previousStatetementDoc["isStamped"] = "UnStamped";
          cardDateIdentifiers.push(cardUniqueLabel);
          previousStatetementsResponseFormatted.push(previousStatetementDoc);
        }
      }
      this.unstampedStatements = [...previousStatetementsResponseFormatted];
      if (this.unstampedStatements && this.unstampedStatements.length > 0) {
        this.unstampedStatementsLoaded = true;
      }
      this.showExtendedSpinner = false;
      this.datePickersContainer.style.opacity = "1";
      this.previousStatementsHeader.style.opacity = "1";
      this.extendedMonthsSpinner.style.display = "none";
    } catch (error) {
      this.showExtendedSpinner = false;
      this.datePickersContainer.style.opacity = "1";
      this.previousStatementsHeader.style.opacity = "1";
      this.extendedMonthsSpinner.style.display = "none";
      this.error = error;
    }
  }

  formatDate(date) {
    let objectDate = new Date(date);
    let day = objectDate.getDate();
    let month = objectDate.getMonth();
    let year = objectDate.getFullYear();
    return day + "/" + month + "/" + year;
  }

  async handleSubmitCase() {
    const fields = {};
    fields[CASE_COMMENT_FIELD.fieldApiName] = this.additionalComment;
    fields[CASE_CASETYPE_FIELD.fieldApiName] = DEFAULT_CASETYPE;
    fields[CASE_SUBJECT_FIELD.fieldApiName] = this.modalSubject;
    fields[CASE_CASESOURCE_FIELD.fieldApiName] = DEFAULT_ORIGIN;
    try {
      this.user = await getUserRecord({ userId: loggedInUserId });
      fields[CASE_CONTACT_FIELD.fieldApiName] = this.user.ContactId;
      let caseId = await createCaseRecord({ caseRecord: fields });
      if (caseId) {
        this.showToast("Success!", "Case created successfully.", "success");
        this.modalSubject = "";
        this.additionalComment = "";
        this.closeQueryModal();
      } else {
        this.showToast("Failure!", "something went wrong.", "error");
      }
    } catch (error) {
      this.error = error;
      this.showToast("Failure!", error, "error");
    }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  getSelectedProfile(profiles, selectedProfileId) {
    return profiles.find((item) => item.value == selectedProfileId);
  }

  getSelectedAccount(accounts, selectedAccountId) {
    return accounts.find((item) => item.value == selectedAccountId);
  }
}