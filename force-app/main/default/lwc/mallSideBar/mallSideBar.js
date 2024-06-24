import { LightningElement, track } from 'lwc';
import { sidebarOffset, getAvailableSpace, getHeaderHeight, getViewportHeight, getFooterCoordinates } from 'c/sidebarScrollingOffset';
import { navigateToWebPage, getBaseUrl } from 'c/mallNavigation';
import { NavigationMixin } from "lightning/navigation";

const MALL_TOOLTIP_OTP_TITLE = "OTP access";
const MALL_TOOLTIP_OTP_MESSAGE = "To access files with a lock icon, you need an OTP. This is to protect your data and prevent unauthorised access.";
const MALL_MY_DASHBOARD_SIDEBAR_HEADING = "Sidebar menu";

export default class MallSideBar extends NavigationMixin(LightningElement) {

    el;
    sidebar;
    scrollEventAdded = false;
    resizeEventAdded = false;
    windowEl = window;
    sidebarOpen = false;
    sidebarExtended = false;
    expanded = false;
    showTooltip = false;
    otpCheck = false;
    mobileSidebarExpandText = "Sidebar";
    SidebarClassList = `sidebar`;
    expandButtonText = `Minimize view`;
    sidebarButtonsClassList = `sidebar-buttons button-expand`;
    buttonDashboardClassList = `sidebar-buttons button-dashboard`;
    buttonDocumentsClassList = `sidebar-buttons button-documents`;
    buttonStatementsClassList = `sidebar-buttons button-statements`;
    mobileSidebarHeading = MALL_MY_DASHBOARD_SIDEBAR_HEADING;
    tooltipTitle = MALL_TOOLTIP_OTP_TITLE;
    tooltipMessage = MALL_TOOLTIP_OTP_MESSAGE;
    host;
    tooltipCoordinates;
    navigateToWebPage = navigateToWebPage.bind(this);
    @track linkList = [
        {
            classes: "sidebar-buttons button-dashboard active",
            linkText: "Dashboard",
            otpRequired: false,
            link: "/mall/s/my-dashboard"
        },
        {
            classes: "sidebar-buttons button-documents",
            linkText: "Business Documents",
            otpRequired: false,
            link: "/mall/s/my-documents"
        },
        {
            classes: "sidebar-buttons button-statements",
            linkText: "Statements",
            otpRequired: false,
            link: "/mall/s/my-statements"
        }
    ];

    renderedCallback() {
        if (window.location.href.indexOf("my-dashboard") != -1) {
            this.buttonDashboardClassList = `sidebar-buttons button-dashboard active`;
        } else if (window.location.href.indexOf("my-documents") != -1) {
            this.buttonDocumentsClassList = `sidebar-buttons button-documents active`;
        } else if (window.location.href.indexOf("my-statements") != -1) {
            this.buttonStatementsClassList = `sidebar-buttons button-statements active`;
        }
    }

    connectedCallback() {
        this.host = this.template.host;
        this.scrollEventAdded || this.windowEl.addEventListener('scroll', () => {
            this.scrollEventAdded = true;
            this.handleScrollResize();
        });
        this.resizeEventAdded || this.windowEl.addEventListener('resize', () => {
            this.resizeEventAdded = true;
            this.handleScrollResize();
        });
    }

    /**
     * The function `getPosition` calculates the coordinates of an element's tooltip by subtracting an
     * offset from the element's left and top positions.
     * @param elem - The `elem` parameter is the element for which we want to get the position.
     */
    getPosition(elem) {
        const iconOffset = 3 * 16;
        let posLeft = Math.round(elem.getBoundingClientRect().left);
        let posTop = Math.round(elem.getBoundingClientRect().top);

        this.tooltipCoordinates = {
            left: posLeft - iconOffset,
            top: posTop
        }
    }

    toggleShowTooltip(event) {
        event.preventDefault();
        event.stopImmediatePropagation();
        this.showTooltip = !this.showTooltip;
        this.getPosition(event.target);
    }

    handleShowTooltip(event) {
        this.showTooltip = true;
        this.getPosition(event.target);
    }

    handleHideTooltip() {
        this.showTooltip = false;
    }

    /**
     * The function calculates the height of the sidebar based on the viewport height and the offset of
     * the footer.
     * @param viewportHeight - The viewportHeight parameter represents the height of the viewport or
     * the visible area of the web page in pixels.
     * @returns the height of the sidebar.
     */
    getSidebarHeight(viewportHeight) {
        let footerOffset = getFooterCoordinates();
        if (footerOffset < viewportHeight) {
            return footerOffset - viewportHeight;
        } else {
            return 0;
        }
    }

    scrollBottom(element) {
        return element.scrollHeight - element.scrollTop - element.clientHeight;
    }

    /**
     * The function sets the height of the sidebar based on the header height and viewport height.
     */
    setSidebarHeight() {
        let headerHeight = getHeaderHeight();
        let viewportHeight = getViewportHeight();
        let sidebarHeight = this.getSidebarHeight(headerHeight, viewportHeight);
        this.host.style.setProperty("--footer-offset", ((sidebarHeight / 16) * -1) + "rem");
        this.host.style.setProperty("--header-offset", (headerHeight / 16) + "rem");
    }

    handleScrollResize() {
        this.setSidebarHeight();
    };

    extendSidebar() {
        this.sidebarExtended = !this.sidebarExtended;
        this.sidebarExtended ? this.SidebarClassList = `sidebar extended` : this.SidebarClassList = `sidebar`;
    }

    showOtpHelper() {
        this.showTooltip = !this.showTooltip;
    }

    triggerOtpStepper() {
        this.windowEl.dispatchEvent(
            new CustomEvent("initOtpStepper"));
    }

    /**
     * The function `handleSidebarNavigation` is used to handle navigation in a sidebar, including
     * triggering an OTP stepper if necessary.
     * @param event - The event parameter is an object that represents the event that triggered the
     * function. It contains information about the event, such as the target element that triggered the
     * event and any additional data associated with the event. In this case, the function is likely being
     * called in response to a click event on a sidebar navigation
     * @returns If the `otpCheck` condition is true, the function will call `triggerOtpStepper()` and then
     * return. Otherwise, it will construct a URL using `baseUrl` and `linkUrl`, and then call
     * `navigateToWebPage(url)`. No explicit return value is specified in the code.
     */
    handleSidebarNavigation(event) {
        event.preventDefault();
        event.stopPropagation();

        if (this.otpCheck) {
            this.triggerOtpStepper();
            return;
        }
        const baseUrl = getBaseUrl();

        let linkUrl = event.target.dataset.link ? event.target.dataset.link : event.currentTarget.dataset.link;
        let url = `${baseUrl}${linkUrl}`;

        this.navigateToWebPage(url);
    }
}