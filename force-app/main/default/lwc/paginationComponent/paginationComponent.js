export function setPaginationFlag(arrayElements, container) {
    if (arrayElements[0] !== undefined) {

        let totalCollectionWidth = 0;
        arrayElements.forEach(element => {
            totalCollectionWidth += element.offsetWidth;
        });

        return (totalCollectionWidth > (this.template.querySelector('.' + container)).offsetWidth);
    }
    else
        return false;
}

/**
 * @description We bind our pagination to target 
 * @param {*} elements 
 * @param {*} invokedByResize 
 * @param {*} container 
 * @param {*} componentContainer 
 */
export function generatePaginationElements(elements, invokedByResize, container, componentContainer) {

    let containerElements = this.template.querySelectorAll('.' + container);
    let selector = '[data-selector="paginationElement-' + container + '"]';
    var paginationElements = this.template.querySelectorAll(selector);
    let componentElements = this.template.querySelectorAll('.' + componentContainer);
    let currentPaginationItem = null;
    let autoScroll = this.template.querySelector("." + componentContainer + '[data-auto-cycle]') ? this.template.querySelector("." + componentContainer).getAttribute('data-auto-cycle') : false;
    let scrollDuration = 4000;
    let paginationNameVsElements = new Map();
    var paginationNameVsGroupedArray = new Map();
    let directionRight;

    let handleSlideNext = function (currentItem, paginationNameVsElements) {

        currentPaginationItem = currentItem.parentNode.querySelector('.active-pagination-element');
        let nextPaginationItem = currentPaginationItem.nextElementSibling;
        if (nextPaginationItem && nextPaginationItem.classList.contains('pagination-item') && nextPaginationItem.dataset.scrollamount) {
            nextPaginationItem.classList.add('active-pagination-element');
            paginationNameVsElements.get(currentItem.dataset.paginationname)[0].closest('.' + container).scrollLeft = nextPaginationItem.dataset.scrollamount;
            currentPaginationItem.classList.remove('active-pagination-element');
        }
        if (autoScroll && paginationNameVsElements.size > 0) {
            window.clearInterval(window.myInterval);
            window.myInterval = window.setInterval(() => {
                handleSlideSelection(currentPaginationItem, paginationNameVsElements)
            }, Number(scrollDuration));
        }
    }

    let handleSlidePrev = function (currentItem, paginationNameVsElements) {
        currentPaginationItem = currentItem.parentNode.querySelector('.active-pagination-element');
        let previousPaginationItem = currentPaginationItem.previousElementSibling;
        if (previousPaginationItem && previousPaginationItem.classList.contains('pagination-item') && previousPaginationItem.dataset.scrollamount) {
            previousPaginationItem.classList.add('active-pagination-element');
            paginationNameVsElements.get(currentItem.dataset.paginationname)[0].closest('.' + container).scrollLeft = previousPaginationItem.dataset.scrollamount;
            currentPaginationItem.classList.remove('active-pagination-element');
        }
        if (autoScroll && paginationNameVsElements.size > 0) {
            window.clearInterval(window.myInterval);
            window.myInterval = window.setInterval(() => {
                handleSlideSelection(currentPaginationItem, paginationNameVsElements)
            }, Number(scrollDuration));
        }
    }

    let handleSlideSelection = function (currentPaginationItem, paginationNameVsElements) {
        currentPaginationItem = currentPaginationItem || document.querySelector('.active-pagination-element');
        if (!currentPaginationItem) {
            return;
        }

        if (typeof currentPaginationItem.nextElementSibling === "undefined" || !currentPaginationItem.nextElementSibling.classList.contains('pagination-item')) {
            document.querySelector(selector).setAttribute('data-scroll-direction', false)
        }
        if (typeof currentPaginationItem.previousElementSibling === "undefined" || !currentPaginationItem.previousElementSibling.classList.contains('pagination-item')) {
            document.querySelector(selector).setAttribute('data-scroll-direction', true);
        }

        directionRight = document.querySelector(selector) !== null ? (document.querySelector(selector).getAttribute('data-scroll-direction') ? document.querySelector(selector).getAttribute('data-scroll-direction') : document.querySelector(selector).setAttribute('data-scroll-direction', true) && true) : null;

        if (directionRight === "true") {
            window.clearInterval(window.myInterval);
            handleSlideNext(currentPaginationItem, paginationNameVsElements);
        } else {
            window.clearInterval(window.myInterval);
            handleSlidePrev(currentPaginationItem, paginationNameVsElements);
        }

    }

    let buildArrowButton = function (direction, componentName, container) {
        let button = document.createElement('button');
        button.classList.add("scroll-button_" + direction);
        button.setAttribute('data-selector', 'paginationElement-' + container);
        button.setAttribute('data-paginationname', componentName);
        return button;
    }

    // We clear any existing pagination on the target container
    for (let i = 0; i < paginationElements.length; i++) {
        paginationElements[i].parentElement.removeChild(paginationElements[i]);
    }

    if (containerElements != undefined) {
        for (let i = 0; i < containerElements.length; i++) {
            //Add a class to scope styles when pagination is bound
            containerElements[i].classList.add("pagination-active");
            /*We check for if the container targetted has a position set so our absolute positioned elements sit in the correct place. if no position set, we default it to relative*/
            if (!containerElements[i].style.position || containerElements[i].style.position === "static") {
                containerElements[i].style.position = "relative";
            }
        }
    }

    //We build up our pager when there is a component container defined
    if (componentElements) {
        for (let i = 0; i < componentElements.length; i++) {
            let paginationContainer = document.createElement('div');
            paginationContainer.classList.add("pagination-wrapper");
            //Set lwc:dom to manual to allow appending elements
            componentElements[i].classList.add("component-container-wrapper");
            if (!componentElements[i].querySelector(".pagination-wrapper")) {
                componentElements[i].appendChild(paginationContainer);
            }
        }
    }

    //We build up the pager collection based on elements array passed as argument
    for (let i = 0; i < elements.length; i++) {
        if (elements[i].dataset.paginationname && paginationNameVsElements.has(elements[i].dataset.paginationname))
            paginationNameVsElements.get(elements[i].dataset.paginationname).push(elements[i]);
        else {
            let items = [elements[i]];
            paginationNameVsElements.set(elements[i].dataset.paginationname, items);
        }
    }

    //We pair pager dots to elements to allow scroll context to navigate to the item
    for (const key of paginationNameVsElements.keys()) {

        let arrowAdded = false;
        let groupedArray = [];
        let tempArray = [];
        let tempwidth = 0;
        let containerWidth = paginationNameVsElements.get(key)[0].closest('.' + container).offsetWidth;
        let componentElement = (paginationNameVsElements.get(key)[0].closest('.' + container)).closest('.' + componentContainer);
        let scroll = 0;

        (paginationNameVsElements.get(key)).forEach(element => {
            if (tempwidth == 0 || tempwidth + element.offsetWidth > containerWidth) {
                if (tempwidth + element.offsetWidth > containerWidth) {
                    groupedArray.push(tempArray);
                    tempArray = [];
                }
                tempArray.push(element);
                let paginationDot = document.createElement('span');
                paginationDot.textContent = '*';
                paginationDot.setAttribute('data-element', element.getAttribute('data-id'));
                paginationDot.setAttribute('data-selector', 'paginationElement-' + container);
                paginationDot.setAttribute('data-container', container);
                paginationDot.setAttribute('data-paginationname', key);
                paginationDot.setAttribute('data-scrollamount', scroll);

                if (tempwidth == 0)
                    paginationDot.classList.add('active-pagination-element');
                paginationDot.addEventListener('click', (event) => {
                    6
                    let elementSelector = 'paginationElement-' + event.target.dataset.container;
                    let paginationElements = this.template.querySelectorAll('[data-selector="' + elementSelector + '"]');
                    for (let i = 0; i < paginationElements.length; i++) {
                        paginationElements[i].classList.remove('active-pagination-element');
                    }
                    event.target.classList.add('active-pagination-element');

                    let container = event.target.dataset.container;

                    paginationNameVsElements.get(event.target.dataset.paginationname)[0].closest('.' + container).scrollLeft = event.target.dataset.scrollamount;
                });

                paginationDot.classList.add("pagination-item");

                if (componentElement) {
                    if (!arrowAdded && componentElement.dataset.showarrow) {
                        arrowAdded = true;
                        let firstArrow = buildArrowButton("prev", key, container);

                        firstArrow.addEventListener('click', (event) => {
                            handleSlidePrev(event.target, paginationNameVsElements);
                        });
                        componentElement.querySelector(".pagination-wrapper").appendChild(firstArrow);
                    }
                    componentElement.querySelector(".pagination-wrapper").appendChild(paginationDot);
                }
            }

            if (tempwidth + element.offsetWidth > containerWidth) {
                tempwidth = element.offsetWidth;
            }
            else {
                if (tempwidth != 0)
                    tempArray.push(element);
                tempwidth = tempwidth + element.offsetWidth;
            }
            
            scroll = scroll + element.offsetWidth;

        });

        groupedArray.push(tempArray);
        if (groupedArray.length == 1) {
            let selector = '[data-selector="paginationElement-' + container + '"]';
            var paginationElements = this.template.querySelectorAll(selector);
            for (let i = 0; i < paginationElements.length; i++) {
                paginationElements[i].parentElement.removeChild(paginationElements[i]);
            }
        }

        paginationNameVsGroupedArray.set(key, groupedArray);
        if (componentElement && componentElement.dataset.showarrow && groupedArray.length > 1) {
            let lastArrow = buildArrowButton("next", key, container);
            lastArrow.addEventListener('click', (event) => {
                handleSlideNext(event.target, paginationNameVsElements);
            });

            componentElement.querySelector(".pagination-wrapper").appendChild(lastArrow);
        }
    }

    if (autoScroll && paginationNameVsElements.size > 0) {
        window.clearInterval(window.myInterval);
        window.myInterval = window.setInterval(() => {
            handleSlideSelection(currentPaginationItem, paginationNameVsElements)
        }, Number(scrollDuration));
    }
}