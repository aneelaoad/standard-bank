import { LightningElement, track } from "lwc";
import getSavedDashboardWidgetConfigurations from "@salesforce/apex/MallDashboardConfigCtrl.getSavedDashboardWidgetConfigurations";
import getConfiguredDashboardWidgets from "@salesforce/apex/MallDashboardConfigCtrl.getConfiguredDashboardWidgets";
import saveDashboardWidgetConfigurations from "@salesforce/apex/MallDashboardConfigCtrl.saveDashboardWidgetConfigurations";
import loggedInUser from "@salesforce/user/Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const MALL_CONFIGURE_LABEL = "Configure";
const MALL_EDIT_WIDGETS_HEADING = "Edit widgets";
const MALL_EDIT_WIDGETS_BUTTON_LABEL = "Save";
const MALL_HEADER = "Widgets";
const MALL_WIDGETS_INFORMATION_HEADER = "Discover widgets";
const MALL_WIDGETS_INFORMATION_MESSAGE =
  "Widgets are essential tools for providing real-time information and shortcuts. You can easily enable, sign up for, or remove them";
const MALL_WIDGETS_CONFIGURE_HEADER =
  "Choose up to 6 widgets by selecting and adding from the available options:";

export default class MallDashboard extends LightningElement {
  @track showModal = false;
  error;
  showWeather = false;
  showAccountDetails = false;
  showWorldClock = false;
  showNews = false;
  showExchange = false;
  actionLists;
  @track widgets = [];
  widgetAllSelectionChecked = false;
  heading = MALL_HEADER;
  infoHeader = MALL_WIDGETS_INFORMATION_HEADER;
  infoText = MALL_WIDGETS_INFORMATION_MESSAGE;
  widgetConfigureModalHeader = MALL_WIDGETS_CONFIGURE_HEADER;

  configureLabel = MALL_CONFIGURE_LABEL;
  configureIcon =
    "/sfsites/c/resource/sbgIcons/NAVIGATIONVIEWS/icn_settings_outline.svg";

  editWidgetHeading = MALL_EDIT_WIDGETS_HEADING;
  editWidgetsSaveBy = MALL_EDIT_WIDGETS_BUTTON_LABEL;

  connectedCallback() {
    this.init();
  }

  async init() {
    try {
      let allSelectedTiles = await getSavedDashboardWidgetConfigurations();
      for (let row = 0; row < allSelectedTiles.length; row++) {
        if (allSelectedTiles[row].Name === "BCB_PLATFORM_WEATHER") {
          this.showWeather = true;
        }
        if (allSelectedTiles[row].Name === "BCB_PLATFORM_GET_NEWS") {
          this.showNews = true;
        }
        if (allSelectedTiles[row].Name === "BCB_PLATFORM_CURRENCY_EXCHANGE_RATE") {
          this.showExchange = true;
        }
        if (allSelectedTiles[row].Name === "BCB_PLATFORM_WORLD_CLOCK") {
          this.showWorldClock = true;
        }
        if (allSelectedTiles[row].Name === "BCB_PLATFORM_ACCOUNT_DETAILS") {
          this.showAccountDetails = true;
        }
      }
    } catch (error) {
      this.error = error;
    }
  }

  handleOpenModal() {
    this.showModal = true;
    this.template.querySelector("c-mall-modal").open();
  }

  handleClose() {
    this.showModal = false;
    this.template.querySelector("c-mall-modal").close();
  }

  //This is not used
  // handleSave() {
  //   this.template.querySelector("c-mall-dashboard-configure").handleSave();
  // }

  handleCancel() {
    this.handleClose();
    //TODO :: Nick - This should dispatch an event to tell the dashboard to refresh the widget list. location.reload() is bad UX
    window.location.reload();
  }

  handleWidgetsActive() {}

  async handleConfigureActive() {
    this.handleOpenModal();
    await this.initDashboardConfig();
  }

  async initDashboardConfig() {
    try {
      let allAvailableWidgets = await getConfiguredDashboardWidgets();
      let allSelectedWidgets = await getSavedDashboardWidgetConfigurations();
      let allSelectedWidgetNames = [];
      for (let i = 0; i < allSelectedWidgets.length; i++) {
        allSelectedWidgetNames.push(allSelectedWidgets[i].Name);
      }
      let widgets = [];
      for (let row = 0; row < allAvailableWidgets.length; row++) {
        let widget = {};
        widget.id = allAvailableWidgets[row].Id;
        widget.position = allAvailableWidgets[row].Position__c;
        widget.image = allAvailableWidgets[row].Image_Url__c;
        widget.description = allAvailableWidgets[row].Label;
        widget.name = allAvailableWidgets[row].Label;
        widget.isSelected = allSelectedWidgetNames.includes(widget.name);
        widgets.push(widget);
      }
      this.widgets = [...widgets];
    } catch (error) {
      this.error = error;
    }
  }

  setSelectedWidgets(event) {
    event.preventDefault();
    event.stopPropagation();
    let widgets = [...this.widgets];

    for (let row = 0; row < widgets.length; row++) {
      if (widgets[row].id === event.currentTarget.dataset.id) {
        widgets[row].isSelected = !widgets[row].isSelected;
        break;
      }
    }
    this.widgets = [...widgets];
  }

  setSelectAllWidgets() {
    this.widgetAllSelectionChecked = !this.widgetAllSelectionChecked;
    let widgets = [];
    for (let row = 0; row < this.widgets.length; row++) {
      let widget = {};
      widget = {
        ...this.widgets[row]
      };
      widget.isSelected = this.widgetAllSelectionChecked;
      widgets.push(widget);
    }
    this.widgets = [...widgets];
  }

  async handleSaveWidgets() {
    let tilesToBeSaved = [];
    for (let row = 0; row < this.widgets.length; row++) {
      if (this.widgets[row].isSelected) {
        let tileToBeSaved = {};
        tileToBeSaved.Name = this.widgets[row].name;
        tileToBeSaved.Position__c = row + 1;
        tileToBeSaved.User__c = loggedInUser;
        tilesToBeSaved.push(tileToBeSaved);
      }
    }
    if (tilesToBeSaved) {
      try {
        await saveDashboardWidgetConfigurations({
          widgets: tilesToBeSaved
        });
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Saved successfully!",
            variant: "success"
          })
        );
        this.handleCancel();
      } catch (error) {
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error saving",
            message: error.message,
            variant: "error"
          })
        );
      }
    }
  }

  showToast(message, variant, title) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}