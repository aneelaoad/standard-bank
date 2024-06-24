import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import saveQuicklinks from "@salesforce/apex/MallServiceFrontQuicklinksCtrl.saveQuicklinks";
import submitQuickLinksForApproval from "@salesforce/apex/MallServiceFrontQuicklinksCtrl.submitQuickLinksForApproval";
import getQuickLinks from "@salesforce/apex/MallServiceFrontQuicklinksCtrl.getQuickLinks";
import publishQuickLinks from "@salesforce/apex/MallServiceFrontQuicklinksCtrl.publishQuickLinks";
import getApprovalHistoryByLinkIds from "@salesforce/apex/MallServiceFrontQuicklinksCtrl.getApprovalHistoryByLinkIds";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MallServiceFrontQuicklinks extends LightningElement {
    serviceId;
    error;
    showModal = false;
    formTitle = 'Add Quick links';
    formQuickLink = {'name': undefined, 'desktopUrl':undefined,'id':undefined,'serviceId':undefined};
    selectedRowIds;

    @track columnLinks = [
        { label: "Name", fieldName: "name"},
        { label: "Desktop url", fieldName: "desktopUrl"},
        { label: "Online", fieldName: "online"},
        { label: "Status", fieldName: "status"},
    ];
    @track links = [];

    @track columnLinksHistory = [
        {label: 'Step name',fieldName: 'Name',},
        { label: "Date", fieldName: "CreatedDate"},
        { label: "Status", fieldName: "StepStatus"},
        { label: "Assigned To", fieldName: "AssignedTo"},
        { label: "Actual Approver", fieldName: "ActualApprover"},
        {label: 'Comments',fieldName: 'Comments', type: "richText", wrapText: true},
    ];
    @track linksHistory = [];
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.serviceId = currentPageReference?.attributes?.recordId;
        }
    }

    @track selectedIcon = 'standard:account';

    connectedCallback(){
        this.resetQuickLinkForm();
        let quickLinkInfo=this.formQuickLink;
        getQuickLinks({ serviceId: this.serviceId })
       .then((result) => {
            this.links=result;
            let linkIds=[];
            const idVsLink = new Map();
            this.links.forEach(item=>{
                linkIds.push(item.id);
                idVsLink.set(item.id,item);
            })
            getApprovalHistoryByLinkIds({ linkIds: linkIds })
            .then((result) => {
                    result.forEach(item=>{
                         if(idVsLink.has(item.ProcessInstance.TargetObjectId)){
                            item['Name']=idVsLink.get(item.ProcessInstance.TargetObjectId).name;
                            item['AssignedTo']=item.OriginalActor.Name;
                            item['ActualApprover']=item.Actor.Name;
                         }
                    })
                    this.linksHistory=result;
            })
            .catch((error) => {
                this.error = error;
            });
       })
       .catch((error) => {
            this.error = error;
       });

    }

    resetQuickLinkForm(){
        this.formQuickLink.url=undefined;
        this.formQuickLink.name=undefined;
        this.formQuickLink.serviceId=this.serviceId;
    }

    get selectedLabel() {
        const selected = this.iconList.find(icon => icon.value === this.selectedIcon);
        return selected ? selected.label : '';
    }

    handleCreateNewLink(event) {
        this.openModal();
    }

    handleNameChange(event) {
        this.formQuickLink.name=event.detail.value;
    }

    handleUrlChange(event) {
         this.formQuickLink.desktopUrl=event.detail.value;
    }

    handleIconChange(event) {

    }

    handleCancel(event) {
        this.openModal=false;
    }

    handleSave(event) {
       let quickLinkInfo=this.formQuickLink;
       saveQuicklinks({ quickLinkInfos: [quickLinkInfo] })
      .then((result) => {
        this.showToast("Saved successfully!", "", "success");
      })
      .catch((error) => {
        this.error = error;
      });
    }

    handleSubmitForApproval(event) {
        let quickLinkInfo=JSON.stringify(this.formQuickLink);
        submitQuickLinksForApproval({ quickLinkInfoStrings: [quickLinkInfo] , saveQuickLinks : true})
        .then((result) => {
            this.showToast("Saved and submitted for approval successfully!", "", "success");
            this.showModal=!this.showModal;
            location.reload();
        })
        .catch((error) => {
            this.error = error;
        });
    }

    closeModal() {
        this.showModal = false;
    }

    openModal() {
        this.showModal = true;
    }

    handleRowSelection(event){
        let selectedRows=event.detail.selectedRows;
        this.selectedRowIds=[];
        selectedRows.forEach(item=>{
            this.selectedRowIds.push(item.id);
        })
    }

    handlePublish(){
        publishQuickLinks({ linkIds: this.selectedRowIds })
        .then((result) => {
            this.showToast("Published successfully!", "", "success");
            location.reload();
        })
        .catch((error) => {
            this.error = error;
        });
    }

    @track isDropdownOpen = false;
    iconList = [
        { value: 'standard:account', label: 'Account' },
        { value: 'standard:contact', label: 'Contact' },
        { value: 'standard:opportunity', label: 'Opportunity' },
        { value: 'standard:lead', label: 'Lead' },
        { value: 'standard:case', label: 'Case' },
        { value: 'doctype:audio', label: 'Audio'},
        { value: 'doctype:image', label: 'Image'},
        { value: 'doctype:mp4', label: 'MP4'},
        { value: 'doctype:xml', label: 'XML'},
        { value: 'standard:event', label: 'Event'},
        { value: 'standard:address', label: 'Address'},
        { value: 'standard:email', label: 'Email'}
    ];

    get dropdownClass() {
        return this.isDropdownOpen ? 'dropdown-list open' : 'dropdown-list';
    }

    toggleDropdown() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }

    handleSelection(event) {
        if (event.target.tagName === 'LIGHTNING-ICON') {
            // Handle the selected icon here
            const selectedIcon = event.target.iconName;
            this.selectedIcon = selectedIcon;
            this.isDropdownOpen = false;

        }
    }

    showToast(title, message, variant){
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant:variant
        });
        this.dispatchEvent(event);
    }
}