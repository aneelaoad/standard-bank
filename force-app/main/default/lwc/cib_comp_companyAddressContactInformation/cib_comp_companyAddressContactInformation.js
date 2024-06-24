import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";

export default class Cib_comp_companyAddressContactInformation extends NavigationMixin(
  Cib_comp_ApplicationParticipantMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";
  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";

  RECORD_TYPE = "Contact_Person";

  @track officeNumbers = [];
  @track emailAddresses = [];
  @track urls = [];

  async connectedCallback() {
    super.connectedCallback();
    this.options = await this.getPicklistValues(
      "Application_Participant__c",
      "CIB_CD_ContactSalutation__c"
    );
  }

  getAllElements() {
    return [
      ...this.template.querySelectorAll("[data-fieldname]")
    ];
  }

  onApplicationLoaded(application) {
    let officeNumbers = (
      application.CIB_CD_OfficeNumbersTelephoneNumber__c || ""
    ).split(";");
    let faxNumbers = (application.CIB_CD_OfficeNumbersFaxNumber__c || "").split(
      ";"
    );

    this.officeNumbers = officeNumbers.map((item, index) => {
      return {
        id: index,
        telephoneNumber: item,
        faxNumber: faxNumbers[index]
      };
    });
    if (!this.officeNumbers.length) {
      this.officeNumbers = [
        {
          id: 0,
          telephoneNumber: "",
          faxNumber: ""
        }
      ];
    }

    let emailAddresses = (application.CIB_CD_EmailAddressesMain__c || "").split(
      ";"
    );
    let electroAdvices = (
      application.CIB_CD_EmailAddressesElectroAdvices__c || ""
    ).split(";");

    this.emailAddresses = emailAddresses.map((item, index) => {
      return {
        id: index,
        CIB_CD_EmailAddressesMain__c: item,
        CIB_CD_EmailAddressesElectroAdvices__c: electroAdvices[index]
      };
    });
    if (!this.emailAddresses.length) {
      this.emailAddresses = [
        {
          id: 0,
          CIB_CD_EmailAddressesMain__c: "",
          CIB_CD_EmailAddressesElectroAdvices__c: ""
        }
      ];
    }

    this.urls = (application.CIB_CD_URL_link__c || "").split(";");

    if (!this.urls.length) {
      this.urls = [""];
    }
  }

  onchange(event) {
    if (
      event.target.dataset.fieldname ===
      "CIB_CD_SameTradingAddressAsRegistered__c"
    ) {
      this.applicationRecord = {
        ...this.applicationRecord,
        CIB_CD_SameTradingAddressAsRegistered__c: event.target.checked,
        CIB_CD_TradingAddressCountry__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressCountry__c
          : "",
        CIB_CD_TradingAddressProvince__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressProvince__c
          : "",
        CIB_CD_TradingAddressCity__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressCity__c
          : "",
        CIB_CD_TradingAddressPostalCode__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressPostalCode__c
          : ""
      };
    }
    if (
      event.target.dataset.fieldname ===
      "CIB_CD_HasSameCorrespondAsRegistered__c"
    ) {
      this.applicationRecord = {
        ...this.applicationRecord,
        CIB_CD_HasSameCorrespondAsRegistered__c: event.target.checked,
        CIB_CD_CorrespondAddressCountry__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressCountry__c
          : "",
        CIB_CD_CorrespondAddressProvince__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressProvince__c
          : "",
        CIB_CD_CorrespondAddressCity__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressCity__c
          : "",
        CIB_CD_CorrespondAddressPostalCode__c: event.target.checked
          ? this.applicationRecord.CIB_CD_RegistrationAddressPostalCode__c
          : ""
      };
    }
  }

  addRow(event) {
    if (event.target.dataset.target === "officeNumbers") {
      this.officeNumbers = [
        ...this.officeNumbers,
        {
          id: this.officeNumbers.length - 1,
          telephoneNumber: "",
          faxNumber: ""
        }
      ].map((item, index) => ({ ...item, id: index }));
    }
    if (event.target.dataset.target === "email") {
      this.emailAddresses = [
        ...this.emailAddresses,
        {
          id: this.emailAddresses.length - 1,
          CIB_CD_EmailAddressesMain__c: "",
          CIB_CD_EmailAddressesElectroAdvices__c: ""
        }
      ].map((item, index) => ({ ...item, id: index }));
    }
    if (event.target.dataset.target === "urls") {
      this.urls = [...this.urls, ""];
    }
  }
  removeRow(event) {
    if (event.target.dataset.target === "officeNumbers") {
      this.officeNumbers = this.officeNumbers
        .filter((item, index) => index !== +event.target.dataset.index)
        .map((item, index) => ({ ...item, id: index }));
    }
    if (event.target.dataset.target === "email") {
      this.emailAddresses = this.emailAddresses
        .filter((item, index) => index !== +event.target.dataset.index)
        .map((item, index) => ({ ...item, id: index }));
    }
    if (event.target.dataset.target === "urls") {
      this.urls = this.urls.filter(
        (item, index) => index !== +event.target.dataset.index
      );
    }
  }

  async updateApplicationRecord() {
    const applicationRecord = {
      Id: this.recordId,
      CIB_CD_OfficeNumbersTelephoneNumber__c: [
        ...this.template.querySelectorAll(
          '[data-fieldname="CIB_CD_OfficeNumbersTelephoneNumber__c"]'
        )
      ]
        .reduce((acc, item) => {
          acc.push(item.value);
          return acc;
        }, [])
        .join(";"),
      CIB_CD_OfficeNumbersFaxNumber__c: [
        ...this.template.querySelectorAll(
          '[data-fieldname="CIB_CD_OfficeNumbersFaxNumber__c"]'
        )
      ]
        .reduce((acc, item) => {
          acc.push(item.value);
          return acc;
        }, [])
        .join(";"),
      CIB_CD_EmailAddressesMain__c: [
        ...this.template.querySelectorAll(
          '[data-fieldname="CIB_CD_EmailAddressesMain__c"]'
        )
      ]
        .reduce((acc, item) => {
          acc.push(item.value);
          return acc;
        }, [])
        .join(";"),
      CIB_CD_EmailAddressesElectroAdvices__c: [
        ...this.template.querySelectorAll(
          '[data-fieldname="CIB_CD_EmailAddressesElectroAdvices__c"]'
        )
      ]
        .reduce((acc, item) => {
          acc.push(item.value);
          return acc;
        }, [])
        .join(";"),
      CIB_CD_URL_link__c: [
        ...this.template.querySelectorAll(
          '[data-fieldname="CIB_CD_URL_link__c"]'
        )
      ]
        .reduce((acc, item) => {
          acc.push(item.value);
          return acc;
        }, [])
        .join(";")
    };

    this.template
      .querySelectorAll('[data-type="Application"]')
      .forEach((element) => {
        if (element.type === "checkbox") {
          applicationRecord[element.dataset.fieldname] = element.checked;
        } else {
          applicationRecord[element.dataset.fieldname] = element.value;
        }
      });

    await this.updateApplication(applicationRecord);

    return super.updateApplicationRecord();
  }
}