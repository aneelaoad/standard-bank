/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_editCerificationPartificpants
@ Description       : This class is used to manage the edit cerification partificpants screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
import { api, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import APPLICATION_PARTICIPANT from "@salesforce/schema/Application_Participant__c";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";

export default class Cib_comp_editCerificationPartificpants extends NavigationMixin(
  Cib_comp_ApplicationParticipantMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;
  @track certRecordTypeId;

  helpIcon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";

  RECORD_TYPE = null;

  @wire(getObjectInfo, { objectApiName: APPLICATION_PARTICIPANT })
  Function({ error, data }) {
    if (data) {
      let objArray = data.recordTypeInfos;
      for (let i in objArray) {
        if (objArray[i].name === "Certification Official") {
          this.certRecordTypeId = objArray[i].recordTypeId;
          if (this.participants.length > 0) {
            this._onParticipantsLoaded(this.participants);
          }
          break;
        }
      }
    }
  }

  onParticipantsLoaded() {
    if (this.certRecordTypeId) {
      this._onParticipantsLoaded(this.participants);
    } else {
      this.isLoaded = false;
    }
  }

  _onParticipantsLoaded(participants) {
    this.participants = participants
      .filter(
        (participant) =>
          participant.IsCertifyingOfficial__c ||
          participant.RecordTypeId === this.certRecordTypeId
      )
      .map((participant) => {
        if (!participant.IsCertifyingOfficial__c) {
          participant.IsDeletable = true;
        }
        return participant;
      });
    this.isLoaded = true;
  }

  collectValues(participant) {
    return {
      IsCertifyingOfficial__c: participant.IsCertifyingOfficial__c,
      RecordTypeId: participant.IsCertifyingOfficial__c
        ? undefined
        : this.certRecordTypeId
    };
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