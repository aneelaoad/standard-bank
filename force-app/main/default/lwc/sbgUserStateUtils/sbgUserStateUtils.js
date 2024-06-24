import { getCookie, putCookie } from "c/cmnCookieUtils";

const mallStateName = {
  mallUserSelectedLanguage: "MallUserSelectedLanguage",
  mallUserSelectedLanguageISOCode: "MallUserSelectedLanguageISOCode",
  mallUserSelectedCountry: "MallUserSelectedCountry",
  selectedSegmentName: "selectedSegmentName",
  selectedCategoryName: "selectedCategoryName"
};

const getUserState = function (stateNameKey, defaultValue) {
  //check session storage
  let stateNameValue = sessionStorage.getItem(stateNameKey);
  if (stateNameValue) {
    return stateNameValue;
  }
  //check cookies
  stateNameValue = getCookie(stateNameKey);
  if (stateNameValue) {
    return stateNameValue;
  }

  return defaultValue;
};

const setUserState = function (key, value) {
  //setItem in sessionstorage
  sessionStorage.setItem(key, value);
  //set cookie;
  putCookie(key, value);
};

export { mallStateName, getUserState, setUserState };