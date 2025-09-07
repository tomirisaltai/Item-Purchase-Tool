import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import listItems from '@salesforce/apex/ItemController.listItems';
import countItems from '@salesforce/apex/ItemController.countItems';
import createPurchase from '@salesforce/apex/PurchaseController.createPurchase';
import isCurrentUserManager from '@salesforce/apex/UserController.isCurrentUserManager';

import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_NUMBER from '@salesforce/schema/Account.AccountNumber';
import ACCOUNT_INDUSTRY from '@salesforce/schema/Account.Industry';

export default class ItemPurchaseApp extends NavigationMixin(LightningElement) {
  @api recordId;

  @wire(CurrentPageReference)
  getStateFromUrl(pageRef) {
    if (pageRef && !this.recordId) {
      const aid = pageRef?.state?.c__accountId;
      if (aid) {
        this.recordId = aid;
        console.log('recordId set from URL c__accountId =', this.recordId);
      }
    }
  }

  // ---------- Account header ----------
  @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME, ACCOUNT_NUMBER, ACCOUNT_INDUSTRY] })
  account;

  get hasAccount() {
    return !!(this.account && this.account.data);
  }

  // ---------- manager flag ----------
  @track isManager = false;
  @wire(isCurrentUserManager)
  wiredIsManager({ data, error }) {
    if (data !== undefined) this.isManager = data === true;
    else if (error) this.isManager = false;
  }

  // ---------- filters / pagination ----------
  @track filters = { family: '', type: '', q: '' };
  @track items = [];
  @track total = 0;
  page = 1;
  pageSize = 20;
  loading = false;

  // ---------- cart ----------
  @track cartItems = [];
  @track isCartOpen = false;

  // ---------- manager: new item modal ----------
  @track isNewItemOpen = false;
  openNewItemModal = () => (this.isNewItemOpen = true);
  closeNewItemModal = () => (this.isNewItemOpen = false);

  // ---------- lifecycle ----------
  connectedCallback() {
    this.load();
  }

  // ---------- filters/pagination handlers ----------
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

  // ---------- data load ----------
  async load() {
    this.loading = true;
    try {
      const { family, type, q } = this.filters;

      this.total = await countItems({
        family,
        type,
        search: q
      });

      const offsetVal = (this.page - 1) * this.pageSize;
      this.items = await listItems({
        family,
        type,
        search: q,
        limitSize: this.pageSize,
        offsetVal
      });


      console.log('Loaded items:', this.items?.length, 'Total:', this.total);
    } catch (e) {
      console.error('load error', e);
      this.items = [];
      this.total = 0;
    } finally {
      this.loading = false;
    }
  }

  // ---------- cart actions ----------
  handleAddToCart(event) {
    const item = event.detail.item;
    this.cartItems = [...this.cartItems, { ...item }];
    this.isCartOpen = true;

    console.log('Added to cart:', item?.Id, 'Cart size:', this.cartItems.length);
  }

  closeCart() {
    this.isCartOpen = false;
  }

  get cartTotal() {
    return (this.cartItems || []).reduce((sum, r) => sum + (r.Price__c || 0), 0);
  }

  // ---------- checkout ----------
  async checkout() {

    console.log('Checkout started, accountId =', this.recordId);

    try {
      const itemIds = (this.cartItems || []).map(i => i.Id);

      console.log('Sending to Apex, itemIds =', itemIds);

      const purchaseId = await createPurchase({
        accountId: this.recordId,
        itemIds
      });


      console.log('Apex returned purchase Id =', purchaseId);

      if (purchaseId) {
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: purchaseId,
            objectApiName: 'Purchase__c',
            actionName: 'view'
          }
        });

        console.log('Navigation triggered to Purchase__c', purchaseId);
      } else {

        console.error('No purchaseId returned from Apex');
      }
    } catch (e) {

      console.error('checkout error:', e);
    } finally {

      console.log('Closing cart modal');
      this.isCartOpen = false;
      this.cartItems = [];
    }
  }

  // ---------- manager----------
  handleNewItemSuccess() {
    this.isNewItemOpen = false;
    this.load(); //refresh
  }
}
