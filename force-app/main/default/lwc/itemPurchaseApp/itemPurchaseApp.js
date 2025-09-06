import { LightningElement, api, track } from 'lwc';
import listItems from '@salesforce/apex/ItemController.listItems';
import countItems from '@salesforce/apex/ItemController.countItems';

export default class ItemPurchaseApp extends LightningElement {
  @api recordId;

  // filters
  @track filters = { family: '', type: '', q: '' };


  @track items = [];
  @track total = 0;
  page = 1;
  pageSize = 20;


  loading = false;

  connectedCallback() {
    this.load(); 
  }

  handleFilters(e) {
    this.filters = e.detail;   
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
        search: q            //'search'
      });

      // page rows
      const offsetVal = (this.page - 1) * this.pageSize;
      this.items = await listItems({
        family,
        type,
        search: q, 
        limitSize: this.pageSize,
        offsetVal
      });
    } catch (err) {

      console.error('load error', err);
      this.items = [];
      this.total = 0;
    } finally {
      this.loading = false;
    }
  }
}
