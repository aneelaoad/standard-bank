import { LightningElement, track, wire } from 'lwc';
import getUserProfile from '@salesforce/apex/MallProfileManagementController.getUserProfile';
import loggedInUserId from '@salesforce/user/Id';
import getCaseRecords from '@salesforce/apex/MallStoreCasesController.getCaseRecords';
import { navigateToRecordPage } from 'c/mallNavigation';
import { NavigationMixin } from 'lightning/navigation';

export default class MallStoreCases extends NavigationMixin(LightningElement) {
    userProfile;
    accountId;
    @track cases;
    error;
    navigateToRecordPage = navigateToRecordPage.bind(this);
    formData = {};
    @track title = "Cases";

    @track isShowModal = false;
    @track selectedCaseId;

    connectedCallback() {
        this.getCases();
    }

    //pagination setup
    currentPage = 1;
    pageSize = 6;

    get totalPages() {
        if(this.cases) {
            return Math.ceil(this.cases.length / this.pageSize);
        } 
    }

    get displayedCases() {
        if(this.cases) {
            const startIndex = (this.currentPage - 1) * this.pageSize;
            const endIndex = startIndex + this.pageSize;
            return this.cases.slice(startIndex, endIndex);
        }
    }

    handlePaginationChange(event) {
        event.preventDefault();
        event.stopPropagation();
        this.currentPage = event.detail.selectedPage;
    }
                
    async getCases() {
        try{
            this.userProfile = await getUserProfile({ currentUserId: loggedInUserId });
            this.accountId = this.userProfile.user.AccountId;
            let cases = await getCaseRecords({ accountId: this.accountId });
            let casesCopy = [];
            for(let row=0; row < cases.length; row++) {
                let caseRec = {...cases[row]};
                caseRec.ContactName = caseRec.Contact.FirstName + ' ' + caseRec.Contact.LastName;
                casesCopy.push(caseRec);
            }
            this.cases = [...casesCopy];
            this.title += '(' + ((this.cases && this.cases.length > this.pageSize) ? (this.pageSize + '+') : this.cases.length) + ')';
        } catch(error) {
           this.error = error; 
        }
    }

    onSelectingCase(event) {
        event.preventDefault();
        event.stopPropagation();
        let selectedId =  event.target.dataset.id;
        this.navigateToRecordPage(selectedId);
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    handleEditClick(event) {
        this.selectedCaseId = event.target.dataset.id;
        if (this.selectedCaseId) {
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: this.selectedCaseId,
              actionName: 'edit'
            }
          });
        }
    }
}