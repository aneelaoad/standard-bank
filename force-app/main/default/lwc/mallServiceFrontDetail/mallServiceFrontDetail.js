import { LightningElement, track, wire } from 'lwc';
import getApprovalHistoryByServiceIds from "@salesforce/apex/MallServiceFrontDetailCtrl.getApprovalHistoryByServiceIds";
import getProductById from "@salesforce/apex/MallProductFrontManagementController.getProductById";
import getActiveRootCategories from "@salesforce/apex/MallDataService.getActiveRootCategories";
import { CurrentPageReference } from "lightning/navigation";

export default class MallServiceFrontDetail extends LightningElement {
    serviceId;
    error;
    @track categoryOptions = [];
    @track approvalHistoryRecords = [];
    @track service = {};

    @track columns = [
        {label: 'Step name',fieldName: 'StepStatus',},
        { label: "Date", fieldName: "CreatedDate"},
        { label: "Status", fieldName: "StepStatus"},
        { label: "Assigned To", fieldName: "OriginalActorName"},
        { label: "Actual Approver", fieldName: "ActorName"},
        {label: 'Comments',fieldName: 'Comments', type: "richText", wrapText: true},
    ];

    @track approvalHistoryRecords = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.serviceId = currentPageReference?.attributes?.recordId;
            this.getProductInfo(this.serviceId);
            this.getActiveCategories();
            this.getApprovalHistory(this.serviceId);
        }
    }

    async getProductInfo(serviceId) {
        try {
            let serviceInfo = await getProductById({serviceId : serviceId});
            this.service = {...serviceInfo};
        } catch(error) {
            this.error = error;
        }
    }

    async getActiveCategories() {
        try {
            let categories = await getActiveRootCategories();
            let categoryOptions = [];
            for (let i = 0; i < categories.length; i++) {
                if(this.service.categoryIds.includes(categories[i].id)) {
                    categoryOptions.push({
                        label: categories[i].name,
                        value: categories[i].name,
                        selected : false,
                        id:categories[i].id
                    });
                }
            }
            this.categoryOptions = [...categoryOptions];
        } catch (error) {
            this.error;
        }
    }

    async getApprovalHistory(serviceId) {
        try {
            let approvalHistoryRecords = await getApprovalHistoryByServiceIds({serviceIds : [serviceId]});
            let approvalRecordsFormatted = [];
            for(let row=0; row < approvalHistoryRecords.length; row++) {
                let approvalHistoryRecord = {...approvalHistoryRecords[row]};
                approvalHistoryRecord["OriginalActorName"] = approvalHistoryRecord["OriginalActor"]["Name"];
                approvalHistoryRecord["ActorName"] = approvalHistoryRecord["Actor"]["Name"];
                approvalRecordsFormatted.push(approvalHistoryRecord)
            }
            this.approvalHistoryRecords = [...approvalRecordsFormatted];
        } catch(error) {
            this.error = error;
        }
    }
}