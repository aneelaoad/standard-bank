import { LightningElement, api } from 'lwc';
import RESOURCE_BASE_PATH from '@salesforce/resourceUrl/ACM_Assets';
export default class AcmApiFilter extends LightningElement {
  @api filterHeading1;
  @api filterHeading2;
  @api filterHeading3;
  @api sbgFilterIcon;

  get iconImage() {
    return RESOURCE_BASE_PATH + this.sbgFilterIcon;
  }

  isModalOpen = false;

  selectedCountry = "";
  selectedSegment = "";
  selectedApiType = "";

  countryMarketOptions = [
    { label: "South Africa", value: "South Africa" },
    { label: "Uganda", value: "Uganda" },
    { label: "Kenya", value: "Kenya" }
  ];

  customerSegmentsOptions = [
    { label: "Corporate", value: "Corporate" },
    { label: "Commercial", value: "Commercial" },
    { label: "Consumer", value: "Consumer" },
    {
      label: "Insurance and Asset management",
      value: "Insurance and Asset management"
    }
  ];

  apiTypesOptions = [
    { label: "Experience", value: "Experience API" },
    { label: "Process", value: "Process API" },
    { label: "System", value: "System API" }
  ];

  openFilterModal() {
    this.isModalOpen = true;
    document.body.classList.add("modal-open");
  }

  closeFilterModal() {
    this.isModalOpen = false;
    document.body.classList.remove("modal-open");
  }

  clearAllFilters() {
    this.selectedCountry = '';
    this.selectedSegment = '';
    this.selectedApiType = '';
}
handleCountryChange(event){
    this.selectedCountry = event.detail.value;
}
handleSegmentChange(event){
    this.selectedSegment = event.detail.value;
}
handleAPIChange(event){
    this.selectedApiType = event.detail.value;
}
applyFilters() {
        let filterCriteria = '';
        if(this.selectedCountry != '' && this.selectedCountry != null){
            filterCriteria = filterCriteria + 'Country - Market:'+this.selectedCountry+';';
        }
        if(this.selectedSegment != '' && this.selectedSegment != null){
            filterCriteria = filterCriteria + 'Segment:'+this.selectedSegment+';';
        }
        if(this.selectedApiType != '' && this.selectedApiType != null){
            filterCriteria = filterCriteria + 'API Type:'+this.selectedApiType;
        }
        if(filterCriteria != ''){
                let url = window.location.origin + window.location.pathname;  
                url = url + '?catalogFilters=' +filterCriteria;
                window.location.href = url;
                this.isModalOpen = false;
                document.body.classList.remove('modal-open');
        }
    }
}