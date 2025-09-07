import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import ITEM_OBJECT from '@salesforce/schema/Item__c';
import FAMILY_FIELD from '@salesforce/schema/Item__c.Family__c';
import TYPE_FIELD from '@salesforce/schema/Item__c.Type__c';

export default class ItemFilters extends LightningElement {
  @api total = 0;
  @track familyOptions = [];
  @track typeOptions = [];
  family; type; q = '';

  @wire(getObjectInfo, { objectApiName: ITEM_OBJECT }) objInfo;

  @wire(getPicklistValues, {
    recordTypeId: '$objInfo.data.defaultRecordTypeId',
    fieldApiName: FAMILY_FIELD
  })
  wiredFamily({ data }) {
    if (data) this.familyOptions = [{ label: 'All', value: '' }, ...data.values];
  }

  @wire(getPicklistValues, {
    recordTypeId: '$objInfo.data.defaultRecordTypeId',
    fieldApiName: TYPE_FIELD
  })
  wiredType({ data }) {
    if (data) this.typeOptions = [{ label: 'All', value: '' }, ...data.values];
  }

  handleChange(e) {
    const { name, value } = e.target;
    this[name] = value;
    this.fire();
  }


  handleSearchChange(e) {
    this.q = e.target.value || '';
    this.fire();
  }

  fire() {
    const detail = {
      family: this.family || '',
      type: this.type || '',
      q: this.q || ''
    };
    console.log('[filters] fire', detail);
    this.dispatchEvent(new CustomEvent('changefilters', { detail, bubbles: true, composed: true }));
  }
}
