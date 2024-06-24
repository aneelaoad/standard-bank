import { LightningElement, api } from 'lwc';
const API_ID_URL_PARAM = "apiId";
const API_VERSION_ID_URL_PARAM = "versionId";
const API_VERSION_URL_PARAM = "version";
const API_VERSION_CHANGED_EVENT_NAME = "selected-api-version-changed";

export default class AcmApiSubscribeButton extends LightningElement {
  @api label;
  @api pageUrl;
  destinationUrl;

  setMsComponentVars(muleSoftVars){
    let mulesoftVersionEventDetails = {
      apiRecordId: muleSoftVars.parentRecordId,
      apiVersionRecordId: muleSoftVars.recordId,
      apiVersion: muleSoftVars.version,
      destinationUrl: `${this.pageUrl}?${API_ID_URL_PARAM}=${muleSoftVars.parentRecordId}&${API_VERSION_ID_URL_PARAM}=${muleSoftVars.recordId}&${API_VERSION_URL_PARAM}=${muleSoftVars.version}`
    };

    localStorage.setItem("mulesoftCurrentApiSavedDetails", JSON.stringify(mulesoftVersionEventDetails));
    this.destinationUrl = mulesoftVersionEventDetails.destinationUrl; 
  }

  setInitialMsDestination(){ 
    let savedMulesoftDetails = localStorage.getItem("mulesoftCurrentApiSavedDetails");

    if(savedMulesoftDetails){
      savedMulesoftDetails = JSON.parse(savedMulesoftDetails);
      this.destinationUrl = savedMulesoftDetails.destinationUrl;
    } 
  }

  registerEventListener() {
    const that = this;

    function handleApiVersionChange(event) {     
      const payload = JSON.parse(JSON.stringify(event.detail.apiVersion));

      if(payload.parentRecordId && payload.recordId && payload.version){   
        that.setMsComponentVars(payload);
      }    
    }

    return handleApiVersionChange;
  }

  connectedCallback() {
    this.setInitialMsDestination();
    window.addEventListener(API_VERSION_CHANGED_EVENT_NAME, this.registerEventListener());
  }

  disconnectedCallback(){
    window.removeEventListener(
      API_VERSION_CHANGED_EVENT_NAME,
      this.registerEventListener
    );
  }
}