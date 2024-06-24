import { api } from "lwc";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import getApplicationParticipants from "@salesforce/apex/CIB_CTRL_ApplicationParticipant.getApplicationParticipants";

export default class Cib_comp_certifyingOfficerDetails extends Cib_comp_baseSectionScreen {
  @api sectionId;
  @api recordId;

  options = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];

  get CIB_IsCertOfficialRelatedParty__c() {
    return String(this.applicationRecord?.CIB_IsCertOfficialRelatedParty__c);
  }

  onchange(event) {
    this.applicationRecord.CIB_IsCertOfficialRelatedParty__c =
      event.target.value === "true" ? true : false;
  }

  async connectedCallback() {
    super.connectedCallback();
    const responce = await getApplicationParticipants({
      applicationId: this.recordId,
      recordTypeName: null
    });
    this.allParticipants = responce.map((participant) => ({
      label: participant.Name + " - " + participant.RecordType.Name,
      value: participant.Id
    }));
  }

  collectValues() {
    let data = super.collectValues();
    data.CIB_IsCertOfficialRelatedParty__c =
      this.applicationRecord.CIB_IsCertOfficialRelatedParty__c;
    return data;
  }
}