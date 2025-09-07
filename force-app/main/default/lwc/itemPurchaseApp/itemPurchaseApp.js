import { LightningElement, api, track } from 'lwc';
import listItems from '@salesforce/apex/ItemController.listItems';
import countItems from '@salesforce/apex/ItemController.countItems';

export default class ItemPurchaseApp extends LightningElement {
  @api recordId;

  @track filters = { family: '', type: '', q: '' };

  @track items = [];
  @track total = 0;
  page = 1;
  pageSize = 20;

  loading = false;

  @track cartItems = [];
  @track isCartOpen = false;

  connectedCallback() {
    this.load();
  }

  handleFilters(evt) {
    this.filters = evt.detail; 
    this.page = 1;
    this.load();
  }
  handlePrev() {
    if (this.page > 1) {
      this.page--;
      this.load();
    }
  }
  handleNext() {
    if (this.page * this.pageSize < this.total) {
      this.page++;
      this.load();
    }
  }
  handleRefresh() {
    this.load();
  }

  async load() {
    this.loading = true;
    try {
      const { family, type, q } = this.filters;

      this.total = await countItems({
        family,
        type,
        search: q //search
      });

      // rows for current page
      const offsetVal = (this.page - 1) * this.pageSize;
      this.items = await listItems({
        family,
        type,
        search: q,
        limitSize: this.pageSize,
        offsetVal
      });
    } catch (e) {
      console.error('load error', e);
      this.items = [];
      this.total = 0;
    } finally {
      this.loading = false;
    }
  }

  // ===== Cart =====
  handleAddToCart(event) {
    const item = event.detail.item;
    this.cartItems = [...this.cartItems, { ...item }];
    this.isCartOpen = true;
  }

  closeCart() {
    this.isCartOpen = false;
  }

  get cartTotal() {
    return (this.cartItems || []).reduce((sum, r) => sum + (r.Price__c || 0), 0);
  }

  checkout() {
    // Placeholder for now 07.09
    console.log('Checkout with:', JSON.parse(JSON.stringify(this.cartItems)));
    this.isCartOpen = false;
    this.cartItems = [];
  }
}
