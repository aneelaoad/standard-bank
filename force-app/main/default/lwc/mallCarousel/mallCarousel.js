import { LightningElement, api, track } from 'lwc';
import ContainerQuery from "c/mallContainerQuery";
const HIDDEN_CLASS = "";
const VISIBLE_CLASS = "active";
const CAROUSEL_CLASS = "carousel-item"
const PAGINATION_CLASS = "pagination-item"

const MOCK_OBJECT = [{
    type: "document",
    list: [{
        id: "1",
        title: "test",
        description: "test",
        url: "test"
    }, {
        id: "2",
        title: "test",
        description: "test",
        url: "test"
    }]
}]

export default class MallCarousel extends LightningElement {
    @api set collection(collection) {
        if (this.mockEnabled) {
            collection = MOCK_OBJECT;
        }
        this.setContentArray(collection);
    }

    get collection() {
        return [...this.slides];
    }

    @api enableAutoCycle = false;
    @api mockEnabled = false;
    @api intervalCount;
    @api type;
    @api enableButtons = false;

    isBanner = false;
    isShopSlider = false;
    isProductRange = false;
    isShopRange = false;
    isHeroCarousel = false;
    isDocument = false;
    isImageGallery = false;

    runOnce = false;
    @track containerQueryClass = '';

    index = 1;
    timer;
    slides = [];
    error;

    setCarouselType(type) {
        type = type.toLowerCase()
        switch (type) {
            case "banner":
                this.isBanner = true;
                break;
            case "shopslider":
                this.isShopSlider = true;
                break;
            case "productrange":
                this.isProductRange = true;
                break;
            case "shoprange":
                this.isShopRange = true;
                break;
            case "herocarousel":
                this.isHeroCarousel = true;
                break;
            case "imageBanner":
                this.isImageBanner = true;
                break;
            case "document":
                this.isDocument = true;
                break;
            case "imagegallery":
                this.isImageGallery = true;
            default:
                this.error = "There is no configuration for type " + type;
                break;
        }
    }

    get carouselCollection() {
        return !this.slides.length ? this.setContentArray(this.collection) : this.slides;
    }

    set carouselCollection(data) {
        this.slides = data.map((item, index) => {
            return index === 0 ? {
                ...item,
                index: index + 1,
                itemClasses: `${CAROUSEL_CLASS} ${VISIBLE_CLASS}`,
                dotClass: `${PAGINATION_CLASS} ${VISIBLE_CLASS}`
            } : {
                ...item,
                index: index + 1,
                itemClasses: `${CAROUSEL_CLASS} ${HIDDEN_CLASS}`,
                dotClass: `${PAGINATION_CLASS} ${HIDDEN_CLASS}`
            }
        });
    }

    setContentArray(data) {
        let result = data;
        let jsonCheck = () => {
            if (result && Array.isArray(result) && result.length === 0) {
                try {
                    JSON.parse(result);
                } catch (e) {
                    return false;
                }
                return true;
            } else {
                this.error = "banner data not set";
                return;
            }
        }

        if (jsonCheck()) {
            result = JSON.parse(result);
        }

        result = result.map((item, index) => {
            return index === 0 ? {
                ...item,
                index: index + 1,
                itemClasses: `${CAROUSEL_CLASS} ${VISIBLE_CLASS}`,
                dotClass: `${PAGINATION_CLASS} ${VISIBLE_CLASS}`
            } : {
                ...item,
                index: index + 1,
                itemClasses: `${CAROUSEL_CLASS} ${HIDDEN_CLASS}`,
                dotClass: `${PAGINATION_CLASS} ${HIDDEN_CLASS}`
            }
        });
        this.slides = result
        return this.slides;
    }

    nextSlide() {
        let index = this.index + 1;
        this.selectionHandler(index);
    }
    prevSlide() {
        let index = this.index - 1;
        this.selectionHandler(index);
    }
    setSlide(event) {
        let index = Number(event.target.dataset.id);
        this.selectionHandler(index);
    }
    selectionHandler(id) {
        if (id > this.slides.length) {
            this.index = 1;
        } else if (id < 1) {
            this.index = this.slides.length;
        } else {
            this.index = id
        }
        this.slides = this.slides.map(item => {
            return this.index === item.index ? {
                ...item,
                itemClasses: "carousel-item " + VISIBLE_CLASS,
                dotClass: "pagination-item " + VISIBLE_CLASS
            } : {
                ...item,
                itemClasses: "carousel-item " + HIDDEN_CLASS,
                dotClass: "pagination-item " + HIDDEN_CLASS
            }
        });
    }

    connectedCallback() {
        this.setCarouselType(this.type);
        if (this.enableAutoCycle || this.enableAutoCycle === "true") {
            this.timer = window.setInterval(() => {
                this.selectionHandler(this.index + 1)
            }, this.intervalCount || 5000);
        }
        this.containerQueryClass = ContainerQuery.checkContainerBreakpoint(this.template.host, 1268);
    }

    renderedCallback() {
        if (this.template) {
            this.containerQueryClass = ContainerQuery.checkContainerBreakpoint(this.template.host, 1268);
            if (!this.runOnce) {
                window.addEventListener("resize", () => {
                    setTimeout(() => {
                        this.containerQueryClass = ContainerQuery.checkContainerBreakpoint(this.template.host, 1268);
                    });
                });
                this.runOnce = true;
            }
        }
    }
}