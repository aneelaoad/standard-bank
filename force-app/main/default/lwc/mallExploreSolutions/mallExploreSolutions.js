import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";
import getMallSubNavigationItems from "@salesforce/apex/CTRL_MallSubNavigationItems.getMallSubNavigationItems";

export default class MallExploreSolutions extends NavigationMixin(LightningElement) {

    chevronLeft = sbgIcons + "/NAVIGATION/icn_chevron_left.svg";
    chevronRight = sbgIcons + "/NAVIGATION/icn_chevron_right.svg";

    @track navigationItems = [];
    @track mainNavigationCategories = [];
    @track selectedMainNavigationCategory = [];
    @track subNavigationItems = [];
    @track selectedSubNavigationItem = [];
    @track chunks = [];
    @track currentPage = 0;
    @track pageSize = 4;
    @track _pages = [];

    @track showModal = false;
    @track modalTitle;
    selectedSolutionId;

    handleShowModal() {
        this.showModal = true;
    }

    handleCloseModal() {
        this.resetActiveSubNavigationItem();
        this.showModal = false;
    }

    handleConfirmAction() {

        if(this.selectedSubNavigationItem != undefined && this.selectedSubNavigationItem.uRLLink != undefined){
            this.showModal = false;
            window.open(this.selectedSubNavigationItem.uRLLink, '_self');
        }
    }    
    

    @wire(getMallSubNavigationItems)
    wiredSubNavigationItems({ error, data }) {
        if (data) {
            this.navigationItems = data.map(item => ({
                ...item,
                iconFullPath: sbgIcons + item.icon
            }));
            this.filterSolutionPageMainCategories();
        } else if (error) {
            this.navigationItems = undefined;
            console.error('Error fetching navigation items: ', error);
        }

    }

    filterSolutionPageMainCategories(){

        this.mainNavigationCategories = this.navigationItems.filter((item=>{
            return (item.isMain == true && item.availableInSolutionPage == true);
        }));
    }

    filterSubSolutionsByMainCategory(){
        
        // Reset existing selectedSubNavigationItem
        this.resetActiveSubNavigationItem();
        
        this.selectedMainNavigationCategory = this.mainNavigationCategories.find(item=>{
            return item.id === this.selectedSolutionId;
        });
        

        this.subNavigationItems = this.navigationItems.filter((item=>{
            return ((item.orderNumber > this.selectedMainNavigationCategory.orderNumber && item.orderNumber <= this.selectedMainNavigationCategory.orderNumber + 9) && (item.isMain == false));
        }));

    }

    handleMainNavigationCategoryAction(event){

        event.preventDefault();
        this.modalTitle = event.currentTarget.dataset.title;
        this.selectedSolutionId = event.currentTarget.dataset.id;

        this.filterSubSolutionsByMainCategory();
        this.handleShowModal();
    }


    handleSubNavigationItemAction(event){

        const selectedSubNavigationItemId =  event.currentTarget.dataset.id;
        
        this.resetActiveSubNavigationItem();

        this.selectedSubNavigationItem = this.subNavigationItems.find(item=>{
            return item.id === selectedSubNavigationItemId;
        });

        this.selectedSubNavigationItem.buttonClass = 'activeCard';

    }


    resetActiveSubNavigationItem(){

        if(this.selectedSubNavigationItem){
            this.selectedSubNavigationItem.buttonClass = '';
            this.selectedSubNavigationItem = undefined;
        }
    }

    // Pagination Data

    get totalPages() {
        return Math.ceil(this.mainNavigationCategories.length / this.pageSize) - 1;
    }

    get isFirstPage() {
        return this.currentPage === 0;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get paginatedData() {
        this.generatePages();
        return this.mainNavigationCategories.slice(this.currentPage, this.currentPage + this.pageSize);
    }

    get pages(){
        return this._pages ? this._pages : [];
    }

    get disableNextbutton(){
        return this.selectedSubNavigationItem!= undefined ? false : true;
    }

    generatePages(){
        this._pages = [];
        for (let i = 0; i <= this.totalPages; i++) {
            this._pages.push({id:i, isCurrent: i === this.currentPage, cssClass: (i === this.currentPage) ? 'page-tag active' : 'page-tag'});
        }
    }

    updatePaginatedData() {
        this.paginatedData = this.mainNavigationCategories.slice(this.currentPage, this.currentPage + this.pageSize);   
    }

    previousPage() {
        if (this.currentPage > 0) {
            this.currentPage -= 1;
        }
    }

    nextPage() {
        if (this.currentPage < this.mainNavigationCategories.length - this.pageSize) {
            this.currentPage += 1;
        }
    }    

}