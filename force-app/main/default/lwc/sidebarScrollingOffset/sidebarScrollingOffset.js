export function getHeaderHeight() {
    let headerOffset = document.querySelector('c-sbg-navigation-bar').clientHeight;
    return headerOffset;
}

export function getFooterCoordinates() {
    const footer = document.querySelector('footer');
    let rect = Math.round(footer.getBoundingClientRect().top);
    return rect;
}

export function getViewportHeight() {
    let viewportHeight = window.innerHeight;
    return viewportHeight;
}

export function getAvailableSpace(viewportHeight, headerHeight) {
    let viewport = viewportHeight;
    let header = headerHeight;
    let availableSpace = viewport - (header + 20);
    return availableSpace;
}