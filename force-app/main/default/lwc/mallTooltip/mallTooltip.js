import { LightningElement, api } from 'lwc';

export default class MallTooltip extends LightningElement {
    @api isVisible = false;
    @api ariaControlledBy;
    @api title;
    @api message;
    @api icon;
    @api position = "left";
    @api coordinates;
    wrapperClassList = "tooltip-wrapper ";
    tooltipPosition;

    renderPosition(pos) {
        this.wrapperClassList = "tooltip-wrapper position-" + pos;
    }

    /**
     * The function `setCoords` takes an object as input and returns a string with CSS style properties
     * for positioning an element based on the object's `top` and `left` properties.
     * @param obj - The `obj` parameter is an object that contains the `top` and `left` properties.
     * @returns a string that sets the CSS properties "top" and "left" based on the values of the "top"
     * and "left" properties of the "obj" parameter. The values are divided by 16 and appended with
     * "rem" units.
     */
    setCoords(obj) {
        return `top:${obj?.top / 16}rem; left:${obj?.left / 16}rem;`
    }

    connectedCallback() {
        this.renderPosition(this.position);
    }

    renderedCallback() {
        this.tooltipPosition = this.setCoords(this.coordinates);
    }
}