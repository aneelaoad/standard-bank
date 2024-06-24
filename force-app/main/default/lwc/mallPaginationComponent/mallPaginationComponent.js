export function setPaginationFlag(arrayElements, container) {
  if (window.innerWidth > 768) {
    if (arrayElements[0] !== undefined) {
      let totalCollectionWidth = 0;
      arrayElements.forEach((element) => {
        totalCollectionWidth += element.offsetWidth;
      });

      return (
        totalCollectionWidth >
        this.template.querySelector("." + container).offsetWidth
      );
    } else return false;
  }

  if (window.innerWidth < 769) {
    return arrayElements.length > 1;
  }

  return arrayElements.length > 4;
}

/**
 * @description We bind our pagination to target
 * @param {*} elements
 * @param {*} invokedByResize
 * @param {*} container
 * @param {*} componentContainer
 */
export function generatePaginationElements(
  elements,
  invokedByResize,
  container,
  componentContainer
) {
  let containerElements = this.template.querySelectorAll("." + container);
  let selector = '[data-selector="paginationElement-' + container + '"]';
  var paginationElements = this.template.querySelectorAll(selector);
  let componentElements = this.template.querySelectorAll(
    "." + componentContainer
  );
  let currentPaginationItem = null;
  let autoScroll = this.template.querySelector(
    "." + componentContainer + "[data-auto-cycle]"
  )
    ? this.template
        .querySelector("." + componentContainer)
        .getAttribute("data-auto-cycle")
    : false;
  let scrollDuration = 4000;
  let paginationNameVsElements = new Map();
  var paginationNameVsGroupedArray = new Map();
  let directionRight;

  let handleSlideNext = function (currentItem, paginationNameVsElements) {
    currentPaginationItem = currentItem.parentNode.querySelector(
      ".active-pagination-element"
    );
    let nextPaginationItem = currentPaginationItem.nextElementSibling;
    if (
      nextPaginationItem &&
      nextPaginationItem.classList.contains("pagination-item") &&
      nextPaginationItem.dataset.scrollamount
    ) {
      nextPaginationItem.classList.add("active-pagination-element");
      paginationNameVsElements
        .get(currentItem.dataset.paginationname)[0]
        .closest("." + container).scrollLeft =
        nextPaginationItem.dataset.scrollamount;
      currentPaginationItem.classList.remove("active-pagination-element");
    }
    if (autoScroll && paginationNameVsElements.size > 0) {
      window.clearInterval(window.myInterval);
      window.myInterval = window.setInterval(() => {
        handleSlideSelection(currentPaginationItem, paginationNameVsElements);
      }, Number(scrollDuration));
    }
  };

  let handleSlidePrev = function (currentItem, paginationNameVsElements) {
    currentPaginationItem = currentItem.parentNode.querySelector(
      ".active-pagination-element"
    );
    let previousPaginationItem = currentPaginationItem.previousElementSibling;
    if (
      previousPaginationItem &&
      previousPaginationItem.classList.contains("pagination-item") &&
      previousPaginationItem.dataset.scrollamount
    ) {
      previousPaginationItem.classList.add("active-pagination-element");
      paginationNameVsElements
        .get(currentItem.dataset.paginationname)[0]
        .closest("." + container).scrollLeft =
        previousPaginationItem.dataset.scrollamount;
      currentPaginationItem.classList.remove("active-pagination-element");
    }
    if (autoScroll && paginationNameVsElements.size > 0) {
      window.clearInterval(window.myInterval);
      window.myInterval = window.setInterval(() => {
        handleSlideSelection(currentPaginationItem, paginationNameVsElements);
      }, Number(scrollDuration));
    }
  };

  let handleSlideSelection = function (
    currentPaginationItem,
    paginationNameVsElements
  ) {
    currentPaginationItem =
      currentPaginationItem ||
      document.querySelector(".active-pagination-element");
    if (!currentPaginationItem) {
      return;
    }

    if (
      typeof currentPaginationItem.nextElementSibling === "undefined" ||
      !currentPaginationItem.nextElementSibling.classList.contains(
        "pagination-item"
      )
    ) {
      document
        .querySelector(selector)
        .setAttribute("data-scroll-direction", false);
    }
    if (
      typeof currentPaginationItem.previousElementSibling === "undefined" ||
      !currentPaginationItem.previousElementSibling.classList.contains(
        "pagination-item"
      )
    ) {
      document
        .querySelector(selector)
        .setAttribute("data-scroll-direction", true);
    }

    directionRight =
      document.querySelector(selector) !== null
        ? document.querySelector(selector).getAttribute("data-scroll-direction")
          ? document
              .querySelector(selector)
              .getAttribute("data-scroll-direction")
          : document
              .querySelector(selector)
              .setAttribute("data-scroll-direction", true) && true
        : null;

    if (directionRight === "true") {
      window.clearInterval(window.myInterval);
      handleSlideNext(currentPaginationItem, paginationNameVsElements);
    } else {
      window.clearInterval(window.myInterval);
      handleSlidePrev(currentPaginationItem, paginationNameVsElements);
    }
  };

  let buildArrowButton = function (direction, componentName, container) {
    let button = document.createElement("button");
    button.classList.add("scroll-button_" + direction);
    button.setAttribute("data-selector", "paginationElement-" + container);
    button.setAttribute("data-paginationname", componentName);
    return button;
  };

  // We clear any existing pagination on the target container
  for (let i = 0; i < paginationElements.length; i++) {
    paginationElements[i].parentElement.removeChild(paginationElements[i]);
  }

  if (containerElements != undefined) {
    for (let i = 0; i < containerElements.length; i++) {
      //Add a class to scope styles when pagination is bound
      containerElements[i].classList.add("pagination-active");
      /*We check for if the container targetted has a position set so our absolute positioned elements sit in the correct place. if no position set, we default it to relative*/
      if (
        !containerElements[i].style.position ||
        containerElements[i].style.position === "static"
      ) {
        containerElements[i].style.position = "relative";
      }
    }
  }

  //We build up our pager when there is a component container defined
  if (componentElements) {
    for (let i = 0; i < componentElements.length; i++) {
      let paginationContainer = document.createElement("div");
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
    if (
      elements[i].dataset.paginationname &&
      paginationNameVsElements.has(elements[i].dataset.paginationname)
    )
      paginationNameVsElements
        .get(elements[i].dataset.paginationname)
        .push(elements[i]);
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
    let containerWidth = paginationNameVsElements
      .get(key)[0]
      .closest("." + container).offsetWidth;
    let componentElement = paginationNameVsElements
      .get(key)[0]
      .closest("." + container)
      .closest("." + componentContainer);
    let scroll = 0;

    paginationNameVsElements.get(key).forEach((element) => {
      if (tempwidth == 0 || tempwidth + element.offsetWidth > containerWidth) {
        if (tempwidth + element.offsetWidth > containerWidth) {
          groupedArray.push(tempArray);
          tempArray = [];
        }
        tempArray.push(element);
        let paginationDot = document.createElement("span");
        paginationDot.textContent = "*";
        paginationDot.setAttribute(
          "data-element",
          element.getAttribute("data-id")
        );
        paginationDot.setAttribute(
          "data-selector",
          "paginationElement-" + container
        );
        paginationDot.setAttribute("data-container", container);
        paginationDot.setAttribute("data-paginationname", key);
        paginationDot.setAttribute("data-scrollamount", scroll);

        if (tempwidth == 0)
          paginationDot.classList.add("active-pagination-element");
        paginationDot.addEventListener("click", (event) => {
          6;
          let elementSelector =
            "paginationElement-" + event.target.dataset.container;
          let paginationElements = this.template.querySelectorAll(
            '[data-selector="' + elementSelector + '"]'
          );
          for (let i = 0; i < paginationElements.length; i++) {
            paginationElements[i].classList.remove("active-pagination-element");
          }
          event.target.classList.add("active-pagination-element");

          let container = event.target.dataset.container;

          paginationNameVsElements
            .get(event.target.dataset.paginationname)[0]
            .closest("." + container).scrollLeft =
            event.target.dataset.scrollamount;
        });

        paginationDot.classList.add("pagination-item");

        if (componentElement) {
          if (!arrowAdded && componentElement.dataset.showarrow) {
            arrowAdded = true;
            let firstArrow = buildArrowButton("prev", key, container);

            firstArrow.addEventListener("click", (event) => {
              handleSlidePrev(event.target, paginationNameVsElements);
            });
            componentElement
              .querySelector(".pagination-wrapper")
              .appendChild(firstArrow);
          }
          componentElement
            .querySelector(".pagination-wrapper")
            .appendChild(paginationDot);
        }
      }

      if (tempwidth + element.offsetWidth > containerWidth) {
        tempwidth = element.offsetWidth;
      } else {
        if (tempwidth != 0) tempArray.push(element);
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
    if (
      componentElement &&
      componentElement.dataset.showarrow &&
      groupedArray.length > 1
    ) {
      let lastArrow = buildArrowButton("next", key, container);
      lastArrow.addEventListener("click", (event) => {
        handleSlideNext(event.target, paginationNameVsElements);
      });

      componentElement
        .querySelector(".pagination-wrapper")
        .appendChild(lastArrow);
    }
  }

  if (autoScroll && paginationNameVsElements.size > 0) {
    window.clearInterval(window.myInterval);
    window.myInterval = window.setInterval(() => {
      handleSlideSelection(currentPaginationItem, paginationNameVsElements);
    }, Number(scrollDuration));
  }
}

export function applyCarousel(itemClassNameString) {
  // Variables to target our base class,  get carousel items, count how many carousel items there are, set the slide to 0 (which is the number that tells us the frame we're on), and set motion to true which disables interactivity.
  var itemClassName = itemClassNameString;
  (items = document.getElementsByClassName(itemClassName)),
    (totalItems = items.length),
    (slide = 0),
    (moving = true);

  // To initialise the carousel we'll want to update the DOM with our own classes
  function setInitialClasses() {
    // Target the last, initial, and next items and give them the relevant class.
    // This assumes there are three or more items.
    items[totalItems - 1].classList.add("prev");
    items[0].classList.add("active");
    items[1].classList.add("next");
  }

  // Set click events to navigation buttons

  function setEventListeners() {
    var next = document.getElementsByClassName("carousel__button--next")[0],
      prev = document.getElementsByClassName("carousel__button--prev")[0];

    next.addEventListener("click", moveNext);
    prev.addEventListener("click", movePrev);
  }

  // Disable interaction by setting 'moving' to true for the same duration as our transition (0.5s = 500ms)
  function disableInteraction() {
    moving = true;

    setTimeout(function () {
      moving = false;
    }, 500);
  }

  function moveCarouselTo(slide) {
    // Check if carousel is moving, if not, allow interaction
    if (!moving) {
      // temporarily disable interactivity
      disableInteraction();

      // Preemptively set variables for the current next and previous slide, as well as the potential next or previous slide.
      var newPrevious = slide - 1,
        newNext = slide + 1,
        oldPrevious = slide - 2,
        oldNext = slide + 2;

      // Test if carousel has more than three items
      if (totalItems - 1 > 3) {
        // Checks if the new potential slide is out of bounds and sets slide numbers
        if (newPrevious <= 0) {
          oldPrevious = totalItems - 1;
        } else if (newNext >= totalItems - 1) {
          oldNext = 0;
        }

        // Check if current slide is at the beginning or end and sets slide numbers
        if (slide === 0) {
          newPrevious = totalItems - 1;
          oldPrevious = totalItems - 2;
          oldNext = slide + 1;
        } else if (slide === totalItems - 1) {
          newPrevious = slide - 1;
          newNext = 0;
          oldNext = 1;
        }

        // Now we've worked out where we are and where we're going, by adding and removing classes, we'll be triggering the carousel's transitions.

        // Based on the current slide, reset to default classes.
        items[oldPrevious].className = itemClassName;
        items[oldNext].className = itemClassName;

        // Add the new classes
        items[newPrevious].className = itemClassName + " prev";
        items[slide].className = itemClassName + " active";
        items[newNext].className = itemClassName + " next";
      }
    }
  }

  // Next navigation handler
  function moveNext() {
    // Check if moving
    if (!moving) {
      // If it's the last slide, reset to 0, else +1
      if (slide === totalItems - 1) {
        slide = 0;
      } else {
        slide++;
      }

      // Move carousel to updated slide
      moveCarouselTo(slide);
    }
  }

  // Previous navigation handler
  function movePrev() {
    // Check if moving
    if (!moving) {
      // If it's the first slide, set as the last slide, else -1
      if (slide === 0) {
        slide = totalItems - 1;
      } else {
        slide--;
      }

      // Move carousel to updated slide
      moveCarouselTo(slide);
    }
  }

  // Initialise carousel
  function initCarousel() {
    setInitialClasses();
    setEventListeners();

    // Set moving to false now that the carousel is ready
    moving = false;
  }

  // make it rain
  initCarousel();
}