import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import helpIcon from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import info_imp from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import delete_row_icon from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";

export default class Cib_comp_corporateDirector extends NavigationMixin(
  Cib_comp_ApplicationParticipantMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  keyIndex = 0;
  helpIcon = helpIcon + "/assets/images/helpIcon.svg";
  info_imp = info_imp + "/assets/images/info_imp.svg";
  delete_row_icon = delete_row_icon + "/assets/images/delete_row_icon.svg";

  RECORD_TYPE = "Authorized_Person_Of_Corporate_Director";

  @track director = {
    CIB_Sequence__c: 1
  };

  async connectedCallback() {
    this.isLoaded = false;
    const [director] = await this.getApplicationParticipants(
      "Corporate_Director",
      false
    );
    if (director) {
      this.director = director;
    }
    await super.connectedCallback();
    this.isLoaded = true;
  }

  async updateApplicationRecord() {
    const [responce] = await this.saveApplicationParticipants(
      "Corporate_Director",
      [
        {
          Id: this.director.Id,
          Application__c: this.recordId,
          ...[
            ...this.template.querySelectorAll('[data-type="director"]')
          ].reduce((acc, element) => {
            acc[element.dataset.fieldname] = element.value;
            return acc;
          }, {})
        }
      ]
    );    
    let docContainer = this.template.querySelector(
      "c-cib_comp_documents-container[data-type=\"director\"]"
    );
    if (docContainer) {
      await docContainer.setParticipantId(responce.Id);
    }
    return super.updateApplicationRecord();
  }
}