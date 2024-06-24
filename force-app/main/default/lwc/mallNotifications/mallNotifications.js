import { LightningElement, track, wire } from "lwc";
import getNotifications from "@salesforce/apex/MallNotificationsController.getNotifications";
import profileName from "@salesforce/schema/User.Profile.Name";
import updateNotifications from "@salesforce/apex/MallNotificationsController.updateNotifications";
import loggedInUserId from "@salesforce/user/Id";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MALL_NOTIFICATION_CUT_OFF_DATE from "@salesforce/label/c.MALL_NOTIFICATION_CUT_OFF_DATE";

const NOTIFICATION_IDS_LIMIT = 50;

export default class MallNotifications extends LightningElement {
  showUnread = false;
  heading = "Notifications";
  hasUnread = false;
  firstRender = false;
  @track notificationList;
  @track notificationListAll = [];
  unreadNotificationList = [];
  clearedNotifications = [];
  notificationCutOffDays = Number(MALL_NOTIFICATION_CUT_OFF_DATE);
  notificationsClassList;
  noNotificationToShow;
  isOpen = false;

  crossImage = sbgVisualAssets + "/sbg-cross.svg";

  @wire(getRecord, { recordId: loggedInUserId, fields: [profileName] })
  loggedInUser;

  get isTenant() {
    if (
      getFieldValue(this.loggedInUser.data, profileName) &&
      getFieldValue(this.loggedInUser.data, profileName).includes("Store")
    )
      return true;
    else return false;
  }

  toggleNotificationsOpen(event) {
    this.isOpen = !this.isOpen;
    event.target.classList.contains("notifications")
      ? event.target.classList.toggle("open")
      : this.template.querySelector(".notifications").classList.toggle("open");
  }

  toggleUnread() {
    this.showUnread = !this.showUnread;
    this.notificationList = this.showUnread
      ? this.unreadNotificationList
      : this.notificationListAll;
    this.noNotificationToShow =
      this.notificationList && this.notificationList.length > 0 ? false : true;
  }

  toggleUnreadVisible() {
    this.template
      .querySelector(".notifications-toggle--container")
      .classList.add("hide-notifications-toggle");
  }

  toggleUndoVisible() {
    this.showUndo = !this.showUndo;
  }

  toggleUndo() {
    this.triggerUndo = !this.triggerUndo;
  }

  triggerClearNotification(event) {
    let notificationTarget = this.getPreviousSibling(
      event.target,
      "c-mall-notification-item"
    );

    notificationTarget.dispatchEvent(new CustomEvent("clear"));
  }

  setClear(event) {
    event.target.setAttribute("data-set-clear", !this.isClear);
  }

  getPreviousSibling(elem, selector) {
    // Get the next sibling element
    let sibling = elem.previousElementSibling;

    // If there's no selector, return the first sibling
    if (!selector) return sibling;

    // If the sibling matches our selector, use it
    // If not, jump to the next sibling and continue the loop
    while (sibling) {
      if (sibling.matches(selector)) return sibling;
      sibling = sibling.previousElementSibling;
    }
  }

  renderedCallback() {
    if (!this.firstRender) {
      this.firstRender = true;
    }
    if (this.noNotificationToShow) {
      this.toggleUnreadVisible();
    }
  }

  connectedCallback() {
    this.getUserNotifications();
    this.clearNotificationsAfterLoading();
  }

  async getUserNotifications() {
    try {
      const notificationList = await getNotifications();
      let denormalizedNotifications = [];
      let unreadNotificationList = [];
      let clearedNotifications = [];
      for (let row = 0; row < notificationList.length; row++) {
        let notification = {};
        notification.id = notificationList[row].id;
        notification.read = notificationList[row].read;
        notification.seen = notificationList[row].seen;
        notification.type = notificationList[row].type;
        notification.url = notificationList[row].url;
        notification.message = notificationList[row].messageTitle;
        notification.lastModified = notificationList[row].lastModified;
        notification.description = notificationList[row].messageBody;
        //unread notifications
        if (!notification.read && !notification.seen) {
          unreadNotificationList.push(notification);
        }
        //cleared notifications
        if (notification.seen && !notification.read) {
          clearedNotifications.push(notification);
        } else {
          denormalizedNotifications.push(notification);
        }
      }
      this.notificationListAll = [...denormalizedNotifications];
      this.notificationList = [...this.notificationListAll];
      this.noNotificationToShow =
        this.notificationList && this.notificationList.length > 0
          ? false
          : true;
      this.unreadNotificationList = [...unreadNotificationList];
      this.clearedNotifications = [...clearedNotifications];

      if (this.unreadNotificationList.length > 0) {
        this.hasUnread = true;
      }
      this.clearNotificationsAfterLoading();
    } catch (error) {
      this.error = error;
    }
  }

  handleNotificationsUpdate(message) {
    const jsonBody = message.detail;
    const updatedNotifications = JSON.parse(jsonBody);
    try {
      this.getUserNotifications();
    } catch (error) {
      this.error = error;
    }
  }

  clearNotificationsAfterLoading() {
    setTimeout(() => {
      this.clearOldNotifications();
    }, 5000);
  }

  //Method to clear notifications by cut off date
  clearOldNotifications() {
    var currentDate = new Date();
    currentDate.setDate(currentDate.getDate() - this.notificationCutOffDays);
    this.clearOldNotificationsByCutOffDate(currentDate);
  }

  //Method to clear all notifications
  clearAllNotifications() {
    var currentDate = new Date();
    this.clearOldNotificationsByCutOffDate(currentDate);
  }

  clearOldNotificationsByCutOffDate(cutOffDate) {
    let notificationIds = [];
    if (this.notificationList && this.notificationList.length > 0) {
      for (let row = 0; row < this.notificationList.length; row++) {
        if (cutOffDate > new Date(this.notificationList[row].lastModified)) {
          notificationIds.push(this.notificationList[row].id);
        }
      }
      if (notificationIds.length > 0) {
        this.updateNotificationSeenStatus(notificationIds);
      }
    }
  }

  async updateNotificationSeenStatus(notificationIds) {
    try {
      let jsonBody = "";
      if (notificationIds.length <= NOTIFICATION_IDS_LIMIT) {
        jsonBody =
          '{"notificationIds": ' +
          '["' +
          notificationIds.join('", "') +
          '"]' +
          ', "read": "true"}';
        let updated = await updateNotifications({ jsonBody: jsonBody });
        jsonBody =
          '{"notificationIds": ' +
          '["' +
          notificationIds.join('", "') +
          '"]' +
          ', "seen": "true", "read": "false"}';
        updated = await updateNotifications({ jsonBody: jsonBody });
      }
      this.getUserNotifications();
    } catch (error) {
      this.error = error;
    }
  }
}