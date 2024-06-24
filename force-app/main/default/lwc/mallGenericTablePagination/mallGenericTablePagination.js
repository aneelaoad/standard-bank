import { LightningElement, api, track } from 'lwc';
import mallIcons from "@salesforce/resourceUrl/mallIcons";

export default class GenericPagination extends LightningElement {
    page=0;
    allPage=0;
    @api selectedType;
    
    get rightIcon () {
        return (!this.disableNext ?  mallIcons + "/ic_chevron-pagination-right.svg" : mallIcons + "/ic_chevron-pagination-disabled-right.svg");
    }
    
    get leftIcon() {
        return (!this.disablePrevious ? mallIcons + "/ic_chevron-pagination-left.svg" : mallIcons + "/ic_chevron-pagination-disabled-left.svg");
    } 

    get renderPagination() {
        return (this.pages && this.pages.length > 1) ? true : false; 
    }

    @api set currentPage(page) {
        this.page = page;
    }

    get currentPage() {
        return this.page;
    }

    @api set totalPages(page) {
        this.allPages = page;
    }

    get totalPages() {
        return this.allPages;
    }

    get pages() {
        const pageArray = [];
        for (let i = 1; i <= this.totalPages; i++) {
            if(this.currentPage == i) {
                pageArray.push({label : i, class : 'active'});
            } else {
                pageArray.push({label : i, class : ''});
            }
        }
        return pageArray;
    }

    get disablePrevious() {
        return this.currentPage === 1;
    }

    get disableNext() {
        return this.currentPage === this.totalPages;
    }

    handlePrevious(event) {
        event.preventDefault();
        event.stopPropagation();
        let eventParams = {
            selectedPage: this.currentPage - 1,
            type: this.selectedType
        };
        if (this.currentPage > 1) {
            this.dispatchEvent(new CustomEvent('paginationchange', { detail: eventParams }));
        }
    }

    handleNext(event) {
        event.preventDefault();
        event.stopPropagation();
        let eventParams = {
            selectedPage: this.currentPage + 1,
            type: this.selectedType
        };
        if (this.currentPage < this.totalPages) {
            this.dispatchEvent(new CustomEvent('paginationchange', { detail: eventParams }));
        }
    }

    handlePageClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const selectedPage = parseInt(event.target.textContent);
        let eventParams = {
            selectedPage: selectedPage,
            type: this.selectedType
          };
        if (selectedPage !== this.currentPage) {
            this.dispatchEvent(new CustomEvent('paginationchange', { detail: eventParams}));
        }
    }
}