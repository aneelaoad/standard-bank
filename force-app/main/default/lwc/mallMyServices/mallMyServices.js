import { LightningElement, track } from 'lwc';
import getMyServices from '@salesforce/apex/MallMyServicesController.getMyServices';
import getShops from '@salesforce/apex/MallMyServicesController.getShops';
import updateShortcuts from '@salesforce/apex/MallMyServicesController.updateShortcuts';
import getActiveRootCategories from '@salesforce/apex/MallDataService.getActiveRootCategories';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";


export default class MallMyServices extends LightningElement {
    @track items;
    @track isShowModal = false;
    @track products;
    shops;
    @track selectedShopIds=[];
    @track recentSelectedServices=[];
    showServices = false;
    showServicesMobile = false;
    selectedService;
    selectionChecked = false;
    categories = [];

    SERVICEARROWBTN_BASE_CLASS = "serviceTile-arrowBtn";
    SERVICETILE_BASE_CLASS = "serviceTile";

    myServicesHeader = "My Services";
    myServicesSubHeader = "We're your one-stop shop for business products and solutions.";
    newBannerText = "New";
    myServicesBtnText = "Edit";
    error;

    connectedCallback(){
        let selectedShops=[];
        getMyServices({tagIds : []})
        .then((result) => {
            result.forEach(function(resultItem) {
                selectedShops.push(resultItem.shopId);
            });
            this.items=result;
            this.selectedShopIds=selectedShops;
            for(let i = 0; i < this.items.length; i++) {
                this.items[i].serviceTileClassList = this.SERVICETILE_BASE_CLASS;
                this.items[i].selectedServiceArrowBtnClassList = this.SERVICEARROWBTN_BASE_CLASS;
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
      }
    
    showServicesHandler(event) {
        if(this.selectedService == event.currentTarget.dataset.shopId) {
            if(this.showServices || this.showServicesMobile) {
                this.showServices = false;;
                this.showServicesMobile = false;
                if(this.items && this.items.length > 0) {
                    for(let row=0; row < this.items.length; row++) {
                        this.items[row].serviceTileClassList = this.SERVICETILE_BASE_CLASS;
                        this.items[row].selectedServiceArrowBtnClassList = this.SERVICEARROWBTN_BASE_CLASS;
                        if(this.items[row].shopId == this.selectedService) {
                            this.products = [];
                            this.items[row].showMobileService = false;
                        }
                    }
                }
                return;
            }
        }
        this.selectedService = event.currentTarget.dataset.shopId;
        this.selectedServiceTile = event.currentTarget;
        this.showServicesMobile = !this.showServicesMobile;
        this.selectedServiceArrowBtn = this.selectedServiceTile.querySelector(".serviceTile-arrowBtn");
        if(!this.showServices) {
            this.showServices = !this.showServices;
        }
        if(this.items && this.items.length > 0) {
            for(let row=0; row < this.items.length; row++) {
                this.items[row].showMobileService=this.items[row].shopId==this.selectedService;
                this.selectedService == this.items[row].shopId ? this.items[row].serviceTileClassList = `${this.SERVICETILE_BASE_CLASS} serviceTileActive` : this.items[row].serviceTileClassList = `${this.SERVICETILE_BASE_CLASS}`;
                this.items[row].serviceTileClassList == `${this.SERVICETILE_BASE_CLASS} serviceTileActive` ? this.items[row].selectedServiceArrowBtnClassList = `${this.SERVICEARROWBTN_BASE_CLASS} serviceTile-arrowBtnActive` : this.items[row].selectedServiceArrowBtnClassList = `${this.SERVICEARROWBTN_BASE_CLASS}`;
                if(this.items[row].shopId == this.selectedService) {
                    this.products = this.items[row].services;
                }
            }
        } 
    }

    async showModalBox(event) {
        try {
            this.isShowModal = true;
            let tags=[];
            await this.getCategoryTags();
            this.categories.forEach(category => {tags.push(category.id)});
            let selectedServices=this.selectedShopIds;
            this.recentSelectedServices=this.selectedShopIds;
            let result = await getShops({tagIds:tags});
            result.forEach(resultItem => {
                resultItem.isSelected=selectedServices.includes(resultItem.id);
            });
            this.shops=result;
        } catch(error) {
            this.error = error;
        }   
    }

    saveShortcuts() {
        this.isShowModal = false;
        updateShortcuts({shopIds:this.recentSelectedServices})
        .then((result) => {
            this.showToast('Success!','Your Services have been saved!!','success');
            location.reload();
        })
        .catch((error) => {
            this.showToast('Something went wrong!',error.message,'error');
            location.reload();
        });
        
    }

    setSelectedServices(event) {
        if(!this.recentSelectedServices.includes(event.currentTarget.dataset.id)){
           this.recentSelectedServices.push(event.currentTarget.dataset.id);
        }
        else{
            const index = this.recentSelectedServices.indexOf(event.currentTarget.dataset.id);
            if (index > -1) { 
                this.recentSelectedServices.splice(index, 1);
            }
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

    setSelectAllServices(event) {
        let checkboxElements=this.template.querySelectorAll(".service-check");
        if(event.currentTarget.checked){
            let allShopIds=[];
            for(let row=0;row<this.shops.length;row++){
                allShopIds.push(this.shops[row].id);
            }
            this.recentSelectedServices=allShopIds;
            checkboxElements.forEach(function(element) {
                element.checked=true;
            });
        }
        else{
            this.recentSelectedServices=[];
            checkboxElements.forEach(function(element) {
                element.checked=false;
            });
        }
	}

    hideModalBox(){
        this.isShowModal = false;
    }

    async getCategoryTags() {
        try {
            const categories = await getActiveRootCategories();
            this.categories = categories;
        } catch(error) {

        }
    }
}