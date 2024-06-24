import { NavigationMixin } from "lightning/navigation";
const navigateToPage = function (pageName) {
  this[NavigationMixin.Navigate]({
    type: "comm__namedPage",
    attributes: {
      name: pageName
    }
  });
};

//method for navigating to target external web pages
const navigateToWebPage = function (pageUrl) {
  this[NavigationMixin.GenerateUrl]({
    type: "standard__webPage",
    attributes: {
      url: pageUrl
    }
  }).then((generatedUrl) => {
    window.open(generatedUrl, "_self");
  });
};

//method for navigating to the target salesforce record
const navigateToRecordPage = function (recordId) {
  this[NavigationMixin.Navigate]({
    type: "standard__recordPage",
    attributes: {
      recordId: recordId,
      actionName: "view"
    }
  });
};

const getBaseUrl = function () {
  let baseUrl = new URL(window.location.origin);
  return baseUrl.origin;
};

export { navigateToPage, navigateToWebPage, navigateToRecordPage, getBaseUrl };