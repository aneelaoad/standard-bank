import { api, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import APPLICATION_PARTICIPANT from "@salesforce/schema/Application_Participant__c";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import getApplicationParticipants from "@salesforce/apex/CIB_CTRL_ApplicationParticipant.getApplicationParticipants";
import getApplicationDocuments from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicationDocuments";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import saveApplicationDocuments from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.saveApplicationDocuments";
export default class Cib_comp_matchDocParticipants extends Cib_comp_baseSectionScreen {
  @api recordId;
  @api sectionId;
  @track documents = [];
  @track participants = [];
  @track certRecordTypeId;

  helpIcon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";

  get displayDocuments() {
    return this.documents.filter((itm) => !itm.CertifyingOfficial__c);
  }

  @wire(getObjectInfo, { objectApiName: APPLICATION_PARTICIPANT })
  Function({ data }) {
    if (data) {
      let objArray = data.recordTypeInfos;
      for (let i in objArray) {
        if (objArray[i].name === "Certification Official") {
          this.certRecordTypeId = objArray[i].recordTypeId;
          if (this.isLoaded) {
            this.init();
          }
          break;
        }
      }
    }
  }

  onApplicationLoaded() {
    if (this.certRecordTypeId) {
      this.init();
    }
  }

  async init() {
    let documents = await getApplicationDocuments({
      applicationId: this.recordId
    });
    documents = documents.map((e) => {
      let name = e.Document_Type__c;
      let iconName = "doctype:pdf";
      if (
        (e.Document_Label__c && e.Document_Label__c.endsWith(".png")) ||
        e.Document_Label__c.endsWith(".jpg") ||
        e.Document_Label__c.endsWith(".jpeg")
      ) {
        iconName = "doctype:image";
      }
      if (e.Application_Participant__r && e.Application_Participant__r.Name) {
        name += " - " + e.Application_Participant__r.Name;
      } else if (
        this.applicationRecord.Client__r &&
        this.applicationRecord.Client__r.Name
      ) {
        name += " - " + this.applicationRecord.Client__r.Name;
      } else {
        name += " - Entity Document";
      }
      return {
        ...e,
        _Name: name,
        iconName
      };
    });
    this.documents = documents;
    let participants = await getApplicationParticipants({
      recordTypeName: null,
      applicationId: this.recordId
    });
    this.participants = participants
      .filter(
        (participant) =>
          participant.IsCertifyingOfficial__c ||
          participant.RecordTypeId === this.certRecordTypeId
      )
      .map((participant) => {
        return {
          ...participant,
          documents: documents.filter(
            (document) => document.CertifyingOfficial__c === participant.Id
          )
        };
      });
    this.isLoaded = true;
  }

  handleDragStart(event) {
    event.dataTransfer.setData("type", event.target.dataset.type);
    event.dataTransfer.setData("name", event.target.dataset.name);
    event.dataTransfer.setData("docId", event.target.dataset.id);
    event.dataTransfer.setData("sourceId", event.target.dataset.sourceId);
    event.dataTransfer.setData("index", event.target.dataset.index);
    event.dataTransfer.setData("docIndex", event.target.dataset.docIndex);
  }

  handleDragOver(event) {
    event.preventDefault();
  }

  dragenter(event) {
    event.preventDefault();
  }

  dragleave(event) {
    event.preventDefault();
    event.target.classList.remove("dragover");
  }

  onDataChange(data) {
    this.dispatchEvent(new CustomEvent("change", { detail: data }));
  }

  handleDrop(event) {
    event.target.classList.remove("dragover");
    event.preventDefault();
    event.stopPropagation();

    let incomingType = event.dataTransfer.getData("type");
    let incomingDocId = event.dataTransfer.getData("docId");
    let incomingIndex = +event.dataTransfer.getData("index");
    let incomingDocIndex = +event.dataTransfer.getData("docIndex");
    let comp = event.target;
    let index = +comp.dataset.index;
    let self = this;

    if (incomingType === "sidebar") {
      let tempDocs = JSON.parse(JSON.stringify(this.documents));
      this.documents = tempDocs.map((doc) => {
        if (doc.Id === incomingDocId) {
          doc.CertifyingOfficial__c = event.target.dataset.id;
          let temp = JSON.parse(JSON.stringify(self.participants));
          self.participants = temp.map((participant) => {
            if (participant.Id === event.target.dataset.id) {
              participant.documents.push(doc);
            }
            return participant;
          });
        }
        return doc;
      });
    }
    if (incomingType === "participant") {
      let temp = JSON.parse(JSON.stringify(this.participants));
      let doc = temp[incomingIndex].documents.splice(incomingDocIndex, 1);
      let docs = JSON.parse(JSON.stringify(this.documents));
      this.documents = docs.map((d) => {
        if (d.Id === incomingDocId) {
          d.CertifyingOfficial__c = event.target.dataset.id;
        }
        return d;
      });
      temp[index].documents.push(doc[0]);
      this.participants = temp;
    }
  }

  handleDragover(event) {
    event.preventDefault();
    event.stopPropagation();
  }
  ondragenter(event) {    
    event.preventDefault();
    event.stopPropagation();
    event.target.classList.add("dragover");
  }
  ondragleave(event) {    
    event.preventDefault();
    event.stopPropagation();
    event.target.classList.remove("dragover");
  }

  async updateApplication() {
    return saveApplicationDocuments({
      applicationDocuments: this.documents.map((doc) => {
        return {
          Id: doc.Id,
          CertifyingOfficial__c: doc.CertifyingOfficial__c
        };
      })
    });
  }
}