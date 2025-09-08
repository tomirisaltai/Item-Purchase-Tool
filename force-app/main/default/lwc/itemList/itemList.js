import { LightningElement, api, track } from 'lwc';

export default class ItemList extends LightningElement {
  @api items = [];
  @api total = 0;
  @api page = 1;
  @api pageSize = 6;
  @api loading = false;

  @track isDetailsOpen = false;
  @track selected = {};

  get hasRows() {
    return (this.items && this.items.length > 0);
  }

  get disablePrev() {
    return this.page <= 1;
  }

  get disableNext() {
    return this.page * this.pageSize >= this.total;
  }

  get fromNum() {
    if (!this.total) return 0;
    return (this.page - 1) * this.pageSize + 1;
  }

  get toNum() {
    return Math.min(this.page * this.pageSize, this.total || 0);
  }

  handlePrev = () => {
    this.dispatchEvent(new CustomEvent('prev'));
  };
  handleNext = () => {
    this.dispatchEvent(new CustomEvent('next'));
  };
  handleRefresh = () => {
    this.dispatchEvent(new CustomEvent('refresh'));
  };

  handleAdd = (e) => {
    const id = e.currentTarget.dataset.id;
    const item = this.items.find(x => x.Id === id) || this.selected;
    this.dispatchEvent(new CustomEvent('addtocart', { detail: { item } }));
  };

  openDetails = (e) => {
    const id = e.currentTarget.dataset.id;
    const found = this.items.find(x => x.Id === id);
    if (found) {
      this.selected = found;
      this.isDetailsOpen = true;
    }
  };

  closeDetails = () => {
    this.isDetailsOpen = false;
    this.selected = {};
  };
}
