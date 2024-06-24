/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_selectExistingParticipants
@ Description       : This class is used to manage the select existing participants screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
import { api, track } from "lwc";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";

export default class Cib_comp_selectExistingParticipants extends Cib_comp_ApplicationParticipantMixin(
  Cib_comp_baseSectionScreen
) {
  @api sectionId;
  @api recordId;
  @track participants = [];
  @track searchTerm = "";

  RECORD_TYPE = null;

  options = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];

  get selectedCount() {
    return (
      this.participants.filter((p) => p.IsCertifyingOfficial__c).length || 0
    );
  }

  get displayParticipants() {
    if (this.searchTerm) {
      return this.participants.filter((p) =>
        p.Name.toLowerCase().includes(this.searchTerm.toLowerCase())
      );
    }
    return this.participants;
  }

  handleSearch(event) {
    this.searchTerm = event.target.value;
  }

  onchange(event) {
    this.participants = this.participants.map((p) => {
      if (p.Id === event.target.dataset.id) {
        p.IsCertifyingOfficial__c = event.target.checked;
      }
      return p;
    });
  }

  collectValues(participant) {
    return { IsCertifyingOfficial__c: participant.IsCertifyingOfficial__c };
  }

  navigateToNextScreen() {
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "sectionId",
      this.sectionId
    );
    this.dispatchEvent(attributeChangeEvent);

    if (this.availableActions.find((action) => action === "NEXT")) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }

  navigateToPreviousScreen() {
    const attributeChangeEvent = new FlowAttributeChangeEvent("sectionId", "");
    this.dispatchEvent(attributeChangeEvent);

    if (this.availableActions.find((action) => action === "NEXT")) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }
}