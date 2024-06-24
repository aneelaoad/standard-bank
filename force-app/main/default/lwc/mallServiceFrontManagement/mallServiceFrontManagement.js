import { LightningElement, track } from "lwc";
import loggedInUserId from "@salesforce/user/Id";
import IS_GUEST from "@salesforce/user/isGuest";
import getUserProfile from "@salesforce/apex/MallProfileManagementController.getUserProfile";
import getProducts from "@salesforce/apex/MallProductFrontManagementController.getProducts";
import getSegmentTags from "@salesforce/apex/MallDataService.getSegmentTags";
import getActiveRootCategories from "@salesforce/apex/MallDataService.getActiveRootCategories";
import submitForApproval from "@salesforce/apex/MallProductFrontManagementController.submitForApproval";
import saveProduct from "@salesforce/apex/MallProductFrontManagementController.saveProduct";
import recallProducts from "@salesforce/apex/MallProductFrontManagementController.recallProducts";
import publishProduct from "@salesforce/apex/MallProductFrontManagementController.publishProduct";
import unpublishProduct from "@salesforce/apex/MallProductFrontManagementController.unpublishProduct";
import uploadImage from "@salesforce/apex/MallProductFrontManagementController.handleImageUpload";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const actions = [
    { label: "Edit", name: "edit" },
    { label: "Delete", name: "delete" }
  ];

export default class MallServiceFrontManagement extends LightningElement {
    @track columns = [
        {
            label: 'Service name',
            fieldName: 'mallProductUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'name' }, 
            target: '_self'},
            sortable: true
        },
        { label: "Online", fieldName: "online", type: 'boolean', sortable: true},
        { label: "Created date", fieldName: "createdDate"},
        { label: "Last modified by", fieldName: "lastModifiedBy"},
        { label: "Status", fieldName: "productStatus", sortable: true},
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        },
    ];

    get listViewOptions() {
        return [
            { label: 'All', value: '' },
            { label: 'Published services', value: 'Published'},
            { label: 'Approved services', value: 'Approved'},
            { label: 'Submitted services', value: 'Submitted'},
            { label: 'Draft services', value: 'Draft'},
            { label: 'Rejected services', value: 'Rejected'}
        ];
    }

    title = "Services";
    userProfile;
    providerId;
    accountId;
    @track products;
    allProducts;
    showProductScreen = false;
    formTitle;
    showAddProductPublishButton = false;
    showUnpublishButton=false;
    @track viewMode = false;
    @track addMode=false;
    @track formProduct;
    showSpinner=false;

    maxLengthShortDescription = 100;
    lengthShortDescription = 0;
    maxLengthLongDescription = 1000;
    lengthLongDescription = 0;

    showCategoryPlaceholder = true;
    categoryInputPlaceholder = 'Select categories';
    @track showCategoryDropdown = false;
    @track categoryPlaceHolder='Select categories';

    @track needsOptions = [];
    @track categoryOptions = [];
    @track selectedNeed;
    @track selectedCategories=[];

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    selectedListView = "";
    queryTerm = "";
    allTimePublishBool = true;
    imageGuide = true;
    acceptedImageFormats = [".png", ".jpg", ".jpeg"];
    error;

    connectedCallback() {
        if (!IS_GUEST) {
          this.fetchUserProfile();
        }
        getSegmentTags()
        .then((result) => {
            for (let i = 0; i < result.length; i++) {
            this.needsOptions.push({
                label: result[i].name=='Individual'?'Personal':result[i].name,
                value: result[i].id
            });
            }
            this.selectedNeed = this.needsOptions[0].value;
        })
        .catch((error) => {
          this.error = error;
        });

        getActiveRootCategories()
        .then((result) => {
            for (let i = 0; i < result.length; i++) {
            this.categoryOptions.push({
                label: result[i].name,
                value: result[i].name,
                selected : false,
                id:result[i].id
            });
            }
        })
        .catch((error) => {
          this.error = error;
        });
        this.resetFormProduct();
    }

    handleAllTimePublishing(event) {
      event.preventDefault();
      event.stopPropagation();
      const value = event.target.checked;
      this.allTimePublishBool = value;
    }
    handleListViewChange(event) {
        this.selectedListView = event.detail.value;
        if(this.allProducts) {
            let filteredProduct = [];
            for(let row=0; row < this.allProducts.length; row++) {
                if(this.allProducts[row].productStatus == this.selectedListView) {
                    filteredProduct.push(this.allProducts[row])
                }
            }
            this.products = [...filteredProduct];
        }
    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = event.target.value;
            if(this.allProducts) {
                let filteredProduct = [];
                for(let row=0; row < this.allProducts.length; row++) {
                    if(this.allProducts[row].name.includes(this.queryTerm)) {
                        filteredProduct.push(this.allProducts[row])
                    }
                }
                this.products = [...filteredProduct];
            }
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.products];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.products = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    fetchUserProfile() {
        getUserProfile({ currentUserId: loggedInUserId })
          .then((result) => {
            this.userProfile = result;
            this.accountId = this.userProfile.user.AccountId;

            getProducts({ accountId: this.accountId })
              .then((result) => {
                this.providerId = result[0].providerId;
                this.products = result;
                this.allProducts = [...this.products];
                this.prepareProductsForDataTable();
              })
              .catch((error) => {
                this.error = error;
              });
          })
          .catch((error) => {
            this.error = error;
        });
    }

    handleRowAction(event) {
    }

    prepareProductsForDataTable(event) {
    }

    handleCreateNewService(event) {
    }

    async handleImageUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let singleFile;
        if (uploadedFiles && uploadedFiles.length > 0) {
        singleFile = uploadedFiles[0];
        }
        if (singleFile) {
        uploadImage({ imageId: singleFile.contentVersionId })
        .then((result) => {
            this.formProduct.uploadedImageUrl = result;
            this.formProduct.imageUploaded = true;
            this.formProduct.imageUrl = result;
        })
        .catch((error) => {
          this.error = error;
        });
        }
    }

  handleAddProduct() {
    this.showProductScreen = true;
    this.addMode=true;
    this.formTitle='Add Service';
    this.resetFormProduct();
  }

  handleClear(){
    this.handleRemoveImage();
    this.template.querySelectorAll("lightning-input").forEach(item=>{
            item.value=undefined;
    })
    this.template.querySelectorAll("lightning-input-rich-text").forEach(item=>{
       item.value='';
    })
    this.template.querySelectorAll("lightning-textarea").forEach(item=>{
      item.value=undefined;
    })
    this.categoryOptions.forEach(item=>{
      item.selected=false;
    })
  }

  handleSubmitValidation() {
    let errors = [];
    if(!this.formProduct.name) {
        errors.push(' Name');
    }
    if(!this.formProduct.productUrl) {
        errors.push(' Service URL');
    }
    if(!this.formProduct.publishedFrom) {
        errors.push(' published from date');
    }
    if(!this.formProduct.publishedUntil) {
        errors.push(' published until date');  
    }
    if(!this.formProduct.categoryIds.length) {
      errors.push(' Category');   
    }
    if(!this.formProduct.shortDesc) {
      errors.push(' Short description');  
    }
    if(!this.formProduct.longDesc) {
      errors.push(' Long description');  
    }
    if(!this.formProduct.uploadedImageUrl && !this.formProduct.imageUploaded) {
      errors.push(' Service image');   
    }
    
    return errors.join(', ');

}

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "delete" :
        break;
      case "view":
        this.viewMode = true;
        this.showProductScreen = true;
        this.formProduct = row;
        this.showAddProductPublishButton = false;
        this.showUnpublishButton = false;
        this.selectedNeed = row.segmentId;
        this.categoryPlaceHolder='';
        this.formTitle='View Service';
        this.addMode=false;
        this.categoryOptions.forEach(item=>{
            if(row.categoryIds.includes(item.id)){
               item.selected=true;
            }
            else{
              item.selected=false;
            }
        })
        const element = this.template.querySelector('.rich-text-container');
        element.classList.add('disabled-rich-text');
        break;
      case "edit":
        this.viewMode = (row.productStatus == "Approved" || row.productStatus == "Published" || row.productStatus == "Submitted") ? true : false;
        this.showProductScreen = true;
        this.formProduct = row;
        this.showAddProductPublishButton =
          row.productStatus == "Approved" ? true : false;
        this.showUnpublishButton = row.productStatus == "Published" ? true : false;
        this.selectedNeed = row.segmentId;
        this.formTitle='Edit Service';
        this.categoryPlaceHolder='';
        this.addMode=false;
        this.categoryOptions.forEach(item=>{
          if(row.categoryIds.includes(item.id)){
             item.selected=true;
          }
          else{
            item.selected=false;
          }
      })
        break;
      default:
    }
  }

  handleCancel() {
    this.resetVariables();
  }

  closeModal() {
    this.resetVariables();
  }

  handleSave() {
    this.formProduct.accountId = this.accountId;
    this.formProduct.providerId = this.providerId;
    if (!this.formProduct.segmentId) {
      this.formProduct.segmentId = this.selectedNeed;
    }
    if (!this.formProduct.categoryIds) {
      this.formProduct.categoryIds = this.selectedCategories;
    }
    let errors=this.handleSubmitValidation();
    if(errors){
      this.showToast("Please fill up following information : ", errors , "error");
      return;
    }
    let productData = JSON.stringify(this.formProduct);
    this.showSpinner=true;
    saveProduct({ productInfoStrings: [productData] })
      .then((result) => {
        this.showToast("Saved successfully!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handlePublish() {
    let productData = JSON.stringify(this.formProduct);
    this.showSpinner=true;
    publishProduct({ productInfoStrings: [productData] })
      .then((result) => {
        this.showToast("Published Sucessfully!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleUnpublishProduct(){
    let productIdsToUnpublish=[this.formProduct.productId];
    this.showSpinner=true;
    unpublishProduct({ productIds: productIdsToUnpublish })
    .then((result) => {
      this.showToast("Product Unpublished!", "", "success");
      this.resetVariables();
      this.showSpinner=false;
      location.reload();
    })
    .catch((error) => {
      this.error = error;
    });
  }

  handleSubmitForApproval() {
    this.formProduct.accountId = this.accountId;
    this.formProduct.providerId = this.providerId;
    if (!this.formProduct.segmentId) {
      this.formProduct.segmentId = this.selectedNeed;
    }
    if (!this.formProduct.categoryIds) {
      this.formProduct.categoryIds = this.selectedCategories;
    }
    let errors=this.handleSubmitValidation();
    if(errors){
      this.showToast("Please fill up following information : ", errors , "error");
      return;
    }
    let productData = JSON.stringify(this.formProduct);
    this.showSpinner=true;
    submitForApproval({ productInfoStrings: [productData] })
      .then((result) => {
        this.showToast("Submitted for approval!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleNameChange(event) {
    this.formProduct.name = event.target.value;
  }

  handleUrlChange(event) {
    this.formProduct.productUrl = event.target.value;
  }

  handleFrom(event) {
    this.formProduct.publishedFrom = event.target.value;
  }

  handleUntil(event) {
    this.formProduct.publishedUntil = event.target.value;
  }

  handleNeedsChange(event) {
    this.formProduct.segmentId = event.target.value;
  }

  handleApprovalComment(event) {
    this.formProduct.comment = event.target.value;
  }

  handleShortDesc(event){
    if(this.formProduct.shortDesc && this.formProduct.shortDesc.length >= this.maxLengthShortDescription) {
      return;
    }
    this.formProduct.shortDesc=event.target.value;
    this.lengthShortDescription = this.formProduct.shortDesc ? this.formProduct.shortDesc.length : 0;
    
  }

  handleLongDesc(event){
    if(this.formProduct.longDesc && this.formProduct.longDesc.length >= this.maxLengthLongDescription) {
      return;
    }
    this.formProduct.longDesc=event.target.value;
    this.lengthLongDescription = this.formProduct.longDesc ? this.formProduct.longDesc.length : 0;
  }

  resetVariables() {
    this.showProductScreen = false;
    this.viewMode = false;
    this.showAddProductPublishButton = false;
    this.selectedNeed = this.needsOptions[0].value;
    this.categoryOptions.forEach(item=>{
         item.selected=false;
    })
    this.selectedCategories=[];
    this.showUnpublishButton=false;
    this.resetFormProduct();
  }

  resetFormProduct() {
    this.formProduct = {
      productId: undefined,
      categoryIds: undefined,
      publishedFrom: undefined,
      publishedUntil: undefined,
      uploadedImageUrl: undefined,
      productUrl: undefined,
      segmentId: undefined,
      cutId: undefined,
      categoryTagProductId: undefined,
      segmentTagProductId: undefined,
      publishingUnitId: undefined,
      linkId: undefined,
      productStatus: undefined,
      name: undefined,
      imageUrl: undefined,
      comment: undefined,
      accountId: this.accountId,
      providerId: this.providerId,
      longDesc:undefined,
      shortDesc:undefined
    };
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  /* This Method Displays that fieldName of the selected rows */
  handleRowSelection(event) {
    this.disableRecallButton = true;
    this.disablePublishButton = true;
    this.disableSubmitButton = true;
    this.disableUnpublishButton=true;
    this.unpublishProductIds=[];
    this.recallProductIds=[];
    this.submitForApprovalRecords=[];
    this.publishRecords=[];
    const selectedRows = event.detail.selectedRows;
    for (let i = 0; i < selectedRows.length; i++) {
      if (selectedRows[i].productStatus == "Submitted") {
        this.disableRecallButton = false;
        this.recallProductIds.push(selectedRows[i].productId);
      } else if (selectedRows[i].productStatus == "Approved") {
        this.disablePublishButton = false;
        this.publishRecords.push(JSON.stringify(selectedRows[i]));
      } else if (selectedRows[i].productStatus == "Draft") {
        this.disableSubmitButton = false;
        this.submitForApprovalRecords.push(JSON.stringify(selectedRows[i]));
      } else if (selectedRows[i].productStatus == "Published") {
        this.disableUnpublishButton = false;
        this.unpublishProductIds.push(selectedRows[i].productId);
      }
    }
  }

  showImageGuide() {
    this.imageGuide = !this.imageGuide;
  }

  handleCategorySelection(event) {
    event.stopPropagation();
    this.categoryOptions = event.detail;
    this.selectedCategories=[];
    event.detail.forEach(item=>{
        if(item.selected)
        this.selectedCategories.push(item.id);
    })
    this.formProduct.categoryIds=this.selectedCategories;
  }
}