import { LightningElement, wire } from 'lwc';
import sayHello from '@salesforce/apex/HelloWorld.sayHello';

export default class HelloWorld extends LightningElement {
    greeting;

    // hard-coded name sent to Apex
    @wire(sayHello, { name: 'Tomiris' })
    wiredHello({ data, error }) {
        if (data) {
            this.greeting = data;   // "Hello, Tomiris!"
        } else if (error) {
            this.greeting = 'Error: ' + (error.body?.message || error);
        }
    }
}
