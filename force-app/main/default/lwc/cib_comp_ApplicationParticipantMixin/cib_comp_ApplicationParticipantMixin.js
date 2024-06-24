/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_ApplicationParticipantMixin
@ Description       : This class is used to manage the application participants across different screens.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
import deleteApplicationParticipant from "@salesforce/apex/CIB_CTRL_ApplicationParticipant.deleteApplicationParticipant";
import getApplicationParticipants from "@salesforce/apex/CIB_CTRL_ApplicationParticipant.getApplicationParticipants";
import saveApplicationParticipants from "@salesforce/apex/CIB_CTRL_ApplicationParticipant.saveApplicationParticipants";
import { track } from "lwc";

const Cib_comp_ApplicationParticipantMixin = (superclass) =>
  class extends superclass {
    @track participants = [{ CIB_Sequence__c: 1 }];

    async getApplicationParticipants(recordTypeName, setParticipants = true) {
      try {
        let participants = await getApplicationParticipants({
          recordTypeName: recordTypeName,
          applicationId: this.recordId
        });
        if (participants.length) {
          participants = participants.map((participant, index) => ({
            ...participant,
            CIB_Sequence__c: index + 1
          }));
          if (setParticipants) {
            this.participants = participants;
            this.onParticipantsLoaded(participants);
          }
          this.isLoaded = true;
          return participants;
        }
      } catch (error) {
        this.handleError(error);
      }
      this.isLoaded = true;
      return [];
    }

    async connectedCallback() {
      await this.getApplicationParticipants(this.RECORD_TYPE);
      super.connectedCallback();
    }

    onParticipantsLoaded(participants) {
      participants.forEach((participant) => {
        this.template
          .querySelectorAll(
            "[data-participant-sequence='" + participant.CIB_Sequence__c + "']"
          )
          .forEach((element) => {
            element.value = participant[element.dataset.fieldname];
          });
      });
    }

    normalizeParticipants() {
      this.participants = this.participants.map((participant, index) => {
        participant.CIB_Sequence__c = index + 1;
        return participant;
      });
    }

    addParticipant() {
      this.participants = [
        ...this.participants,
        { CIB_Sequence__c: this.participants.length + 1 }
      ];
      this.normalizeParticipants();
    }

    deleteParticipant(event) {
      const participantsequence = event.target.dataset.participantSequence;
      const participantIndex = this.participants.findIndex(
        (participant) => participant.CIB_Sequence__c === +participantsequence
      );
      const [participant] = this.participants.splice(participantIndex, 1);
      this.deleteApplicationParticipant(participant);
      this.normalizeParticipants();
    }

    async deleteApplicationParticipant(participant) {
      return deleteApplicationParticipant({ participant });
    }

    async saveApplicationParticipants(recordTypeName, participants) {
      return saveApplicationParticipants({
        recordTypeName: recordTypeName,
        participants: participants
      });
    }

    async updateApplicationRecord() {
      const participants = this.participants
        .map((participant) => {
          const item = {
            ...(this.collectValues ? this.collectValues(participant) : {}),
            Id: participant.Id,
            Application__c: this.recordId,
            CIB_Sequence__c: participant.CIB_Sequence__c
          };
          this.template
            .querySelectorAll(
              "[data-participant-sequence='" +
                participant.CIB_Sequence__c +
                "']"
            )
            .forEach((element) => {
              if (element.tag !== "C-CIB_COMP_DOCUMENTS-CONTAINER") {
                if (element.type && element.type.includes("checkbox")) {
                  item[element.dataset.fieldname] = element.checked;
                  return;
                }
                item[element.dataset.fieldname] = element.value;
              }
            });
          return item;
        })
        .filter((e) => {
          for (let key in e) {
            if (
              Object.prototype.hasOwnProperty.call(e, key) &&
              !["Application__c", "Id", "CIB_Sequence__c"].includes(key) &&
              !key.toLowerCase().includes("date") &&
              e[key] !== undefined &&
              e[key] !== null
            ) {
              return true;
            }
          }
          return false;
        });

      if (participants.length === 0) {
        return;
      }

      const responce = await this.saveApplicationParticipants(
        this.RECORD_TYPE,
        participants
      );

      if (this.template.querySelector("c-cib_comp_documents-container")) {
        await Promise.all(
          responce.map((participant) => {
            return this.template
              .querySelector(
                "c-cib_comp_documents-container[data-participant-sequence='" +
                  participant.CIB_Sequence__c +
                  "']"
              )
              .setParticipantId(participant.Id);
          })
        );
      }
    }
  };

export default Cib_comp_ApplicationParticipantMixin;