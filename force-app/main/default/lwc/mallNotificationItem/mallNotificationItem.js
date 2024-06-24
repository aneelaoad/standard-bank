import { LightningElement, api, track } from "lwc";
import updateNotifications from "@salesforce/apex/MallNotificationsController.updateNotifications";
import { NavigationMixin } from 'lightning/navigation';
import { navigateToWebPage } from 'c/mallNavigation';

export default class MallNotificationItem extends NavigationMixin(LightningElement) {
  @api id;
  @api notificationid;
  @api type;
  @api message;
  @api read;
  @api url;
  @api lastModified;

  @api description;

  clearButtonLabel = "Clear";
  undoButtonLabel = "Undo";
  navigateToWebPage = navigateToWebPage.bind(this);

  timer = null;
  setToClear = false;

  triggerUndo = false;

  isCleared = false;
  seconds;
  @track countDown = this.count + " seconds.";
  get count() {
    return (this.seconds = 5);
  }

  set count(value) {
    this.countDown = value + " seconds.";
  }

  get dateStamp() {
    if (this.lastModified !== null) {
      return this.normaliseDateMessage(this.lastModified);
    }
  }

  triggerClearNotification() {
    this.setToClear = true;
    this.startCountdown(this.count);
  }

  toggleUndo() {
    this.triggerUndo = true;
    this.count = null;
    this.setToClear = false;
    clearTimeout(this.timer);
  }

  normaliseDateMessage(date) {
    return Date.parse(date);
  }

  notificationClick(event) {
    event.preventDefault();
    const type = event.target
      .closest(".notification")
      .getAttribute("data-type");
    this.setNotificationAsRead();
    this.navigateToWebPage(this.url);
  }

  startCountdown(seconds) {
    let countVal = seconds;
    this.timer = setInterval(() => {
      if (this.triggerUndo) {
        this.triggerUndo = false;
        clearInterval(this.timer);
        return;
      }
      --countVal;
      this.template
        .querySelector(".notification-clearing > p")
        .setAttribute("data-count", countVal);
      this.count = countVal;

      if (countVal === 0) {
        this.isCleared = true;
        clearInterval(this.timer);
        this.setNotificationAsSeen();
      }
    }, 1000);
  }

  setNotificationAsRead() {
    this.updateNotificationReadStatus([this.notificationid]);
  }

  setNotificationAsSeen() {
    this.updateNotificationSeenStatus([this.notificationid]);
  }

  async updateNotificationReadStatus(notificationIds) {
    try {
      let jsonBody = '{"notificationIds": ' + '["' + notificationIds.join('", "') + '"]' + ', "read": "true"}';
      let updated = await updateNotifications({jsonBody: jsonBody});
      this.dispatchEvent(new CustomEvent('notificationsupdated', {detail: jsonBody} ));

    }catch(error) {
      this.error = error;
    }
  }

  //update seen will be used as clear notification as we don't have delete notifications api available
  async updateNotificationSeenStatus(notificationIds) {
    try {
      let jsonBody = '{"notificationIds": ' + '["' + notificationIds.join('", "') + '"]' + ', "read": "true"}';
      let updated = await updateNotifications({jsonBody: jsonBody});
      jsonBody = '{"notificationIds": ' + '["' + notificationIds.join('", "') + '"]' + ', "read": "false", "seen": "true"}';
      updated = await updateNotifications({jsonBody: jsonBody});
      this.dispatchEvent(new CustomEvent('notificationsupdated', {detail: jsonBody}));
    }catch(error) {
      this.error = error;
    }
  }
}