import { LightningElement, api} from 'lwc';

export default class CmnFlexibleTitle extends LightningElement {
  @api title;
  @api titleColor;
  @api level;
  @api horizontalAlignment;
  @api separator;
  @api separatorColor;
  @api backgroundColour;
  @api fullWidth;
  style = '';
  styleBG='';

  isFirstRender = true;

  get isH1() { return this.level === "h1"; }
  get isH2() { return this.level === "h2"; }
  get isH3() { return this.level === "h3"; }
  get isH4() { return this.level === "h4"; }
  get isH5() { return this.level === "h5"; }
  get isH6() { return this.level === "h6"; }

  connectedCallback(){
    this.style = 'text-align: ' + this.horizontalAlignment + ';';
    this.styleBG = 'background: ' + this.backgroundColour + ';';
  }

  
  initCSSVariables() {
    var css = document.body.style;
    if (this.separator && this.separatorColor !== "") css.setProperty('--separatorColor', this.separatorColor);
  }
  
  renderedCallback() {
    if(this.isFirstRender === false) return;
    this.isFirstRender = false;
    this.initCSSVariables();
  }

}