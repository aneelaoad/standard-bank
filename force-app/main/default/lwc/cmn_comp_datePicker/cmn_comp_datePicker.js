import { LightningElement, track, api } from "lwc";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
export default class Cmn_comp_datePicker extends LightningElement {
  calanderIcon = MAU_ThemeOverrides + "/assets/images/calanderIcon.svg";

  @track selectedDate = new Date();
  @track month;
  @track year;
  @track dates;
  @track isDatepickerOpen = false;
  @track dateField;
  @track calenderOpen = false;
  @track yearData;
  @track formattedSelectedDate;

  @api requiredField;
  @api recordId;

  @api get value() {
    return this.selectedDate.toISOString().split("T")[0];
  }
  set value(value) {
    let value_ = value;

    if (!value_) {
      value_ = "";
    }

    this.formattedSelectedDate = this.dateFormatString(value_);
    this.selectedDate = !isNaN(new Date(value_))
      ? new Date(value_)
      : new Date();
    this.formatSelectedDate();
    this.generateCalendar();
  }

  dateFormatString(data) {
    const options = {
      year: "numeric",
      month: "long",
      day: "numeric"
    };

    let date = new Date(data);

    if (!isNaN(date)) {
      date = new Date();
    }

    return date.toLocaleDateString(undefined, options);
  }

  generateYears() {
    const currentYear = new Date().getFullYear();
    const range = (start, stop, step) =>
      Array.from(
        { length: (stop - start) / step + 1 },
        (_, i) => start + i * step
      );
    this.yearData = range(currentYear, currentYear - 50, -1);
  }

  goToday(event) {
    event.stopPropagation();
    this.selectedDate = new Date();
    this.formatSelectedDate();
    this.generateCalendar();
  }

  previousMonth(event) {
    event.stopPropagation();
    this.selectedDate.setMonth(this.selectedDate.getMonth() - 1);
    this.formatSelectedDate();
    this.generateCalendar();
  }

  nextMonth(event) {
    event.stopPropagation();
    this.selectedDate.setMonth(this.selectedDate.getMonth() + 1);
    this.formatSelectedDate();
    this.generateCalendar();
  }

  setSelected(event) {
    const selected = event.target.dataset.date;
    this.selectedDate = new Date(selected);
    this.selectedDate.setFullYear(this.year);
    this.selectedDate.setDate(this.selectedDate.getDate() + 1);
    this.formatSelectedDate();
    const selectedEvent = new CustomEvent("setdate", {
      detail: {
        value: this.formattedSelectedDate
      }
    });
    this.dispatchEvent(selectedEvent);
    this.calenderOpen = false;
  }

  formatSelectedDate() {
    const options = { year: "numeric", month: "long", day: "numeric" };
    this.formattedSelectedDate = this.selectedDate.toLocaleDateString(
      undefined,
      options
    );
    this.month = this.selectedDate.toLocaleString(undefined, { month: "long" });
    this.dateField = this.selectedDate.toLocaleString(undefined, {
      day: "numeric"
    });
    this.year = this.selectedDate.getFullYear();
  }

  formatSelectedDateForC() {
    this.month = this.selectedDate.toLocaleString(undefined, { month: "long" });
    this.dateField = this.selectedDate.toLocaleString(undefined, {
      day: "numeric"
    });
    this.year = this.selectedDate.getFullYear();
  }

  yearChange(event) {
    this.year = event.target.value;
    this.selectedDate = new Date();
    this.selectedDate.setFullYear(event.target.value);
    this.selectedDate.setDate(this.selectedDate.getDate() + 1);
    this.formatSelectedDate();
    this.generateCalendar();
  }

  generateCalendar() {
    this.dates = [];
    this.selectedDate.setFullYear(this.year);
    const firstDayOfMonth = new Date(
      this.selectedDate.getFullYear(),
      this.selectedDate.getMonth(),
      1
    );
    const lastDayOfMonth = new Date(
      this.selectedDate.getFullYear(),
      this.selectedDate.getMonth() + 1,
      0
    );
    const prevMonthLastDay = new Date(
      this.selectedDate.getFullYear(),
      this.selectedDate.getMonth(),
      0
    );
    const daysInMonth = lastDayOfMonth.getDate();
    const startDay = firstDayOfMonth.getDay();
    const endDay = lastDayOfMonth.getDay();

    // Generate dates for previous month

    for (let i = startDay - 1; i >= 0; i--) {
      const date = new Date(
        prevMonthLastDay.getFullYear(),
        prevMonthLastDay.getMonth(),
        prevMonthLastDay.getDate() - i
      );

      this.dates.push({
        formatted: date.toISOString().slice(0, 10),
        text: date.getDate(),
        className: "otherMonth"
      });
    }

    // Generate dates for current month

    for (let i = 1; i <= daysInMonth; i++) {
      const date = new Date(
        this.selectedDate.getFullYear(),
        this.selectedDate.getMonth(),
        i
      );

      this.dates.push({
        formatted: date.toISOString().slice(0, 10),
        text: date.getDate(),
        className:
          date.toDateString() === this.selectedDate.toDateString()
            ? "selected"
            : ""
      });
    }

    // Generate dates for next month

    for (let i = 1; i < 7 - endDay; i++) {
      const date = new Date(
        lastDayOfMonth.getFullYear(),
        lastDayOfMonth.getMonth() + 1,
        i
      );

      this.dates.push({
        formatted: date.toISOString().slice(0, 10),
        text: date.getDate(),
        className: "otherMonth"
      });
    }
  }

  openDatepicker(event) {
    event.stopPropagation();
    this.calenderOpen = true;
    const today = new Date();
    this.selectedDate = today;
    this.formatSelectedDateForC();
    this.generateCalendar();
    this.generateYears();
  }

  handleBlur() {
    this.calenderOpen = false;
  }

  /**
   * This will handle the click event on the combobox
   * @param {*} newValue
   */
  renderedCallback() {
    let self = this;
    this.template
      .querySelector(".ms-input")
      .addEventListener("click", function (event) {
        self.onDropDownClick(event.target);
        event.stopPropagation();
      });
    document.addEventListener("click", function () {
      self.closeAllDropDown();
    });
  }

  /**
   * This will handle focus event
   * @param {*} newValue
   */
  onDropDownClick() {
    let classList = Array.from(
      this.template.querySelectorAll(".ms-picklist-dropdown")
    );
    if (!classList.includes("slds-is-open")) {
      this.closeAllDropDown();
      Array.from(
        this.template.querySelectorAll(".ms-picklist-dropdown")
      ).forEach(function (node) {
        node.classList.add("slds-is-open");
      });
    } else {
      this.closeAllDropDown();
    }
  }

  /**
   * This will handle the blur event
   * @param {*} newValue
   */
  closeAllDropDown() {
    Array.from(this.template.querySelectorAll(".ms-picklist-dropdown")).forEach(
      function (node) {
        node.classList.remove("slds-is-open");
      }
    );
    this.calenderOpen = false;
  }

  preventEvent(event) {
    event.stopPropagation();
  }
}