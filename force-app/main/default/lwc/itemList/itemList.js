import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ItemList extends LightningElement {

  @api items = [];      
  @api total = 0;       
  @api loading = false;    
  @api page = 1;     
  @api pageSize = 20;     


  columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Family', fieldName: 'Family__c' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Price', fieldName: 'Price__c', type: 'currency' },
    { label: 'Description', fieldName: 'Description__c', wrapText: true },

    { type: 'action', typeAttributes: { rowActions: this.getRowActions } }
  ];

  getRowActions(row, done) {
    done([
      { label: 'Details', name: 'details' },
      { label: 'Add to Cart', name: 'add_to_cart' }
    ]);
  }


  get hasRows() {
    return Array.isArray(this.items) && this.items.length > 0;
  }

  get fromNum() {
    const start = (this.page - 1) * this.pageSize + 1;
    return this.hasRows ? start : 0;
  }

  get toNum() {
    const end = (this.page - 1) * this.pageSize + this.items.length;
    return this.hasRows ? end : 0;
  }

  get disablePrev() {
    return this.page <= 1;
  }

  get disableNext() {
    return this.page * this.pageSize >= this.total;
  }


  handlePrev() {
    this.dispatchEvent(new CustomEvent('prev'));
  }
  handleNext() {
    this.dispatchEvent(new CustomEvent('next'));
  }

  // ===== DETAILS MODAL =====
  @track isDetailsOpen = false;
  @track selected = null;

  handleRowAction(event) {
    const { name } = event.detail.action;
    const row = event.detail.row;
    if (name === 'details') {
      this.selected = row;
      this.isDetailsOpen = true;
    } else if (name === 'add_to_cart') {
      this.dispatchEvent(new CustomEvent('addtocart', { detail: { item: row } }));
    }
  }

  closeDetails() {
    this.isDetailsOpen = false;
    this.selected = null;
  }

  handleEditSuccess() {
    this.dispatchEvent(new ShowToastEvent({ title: 'Item saved', variant: 'success' }));
    this.closeDetails();
    this.dispatchEvent(new CustomEvent('refresh'));
  }
}
