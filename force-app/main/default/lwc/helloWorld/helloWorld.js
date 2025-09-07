import { LightningElement, wire } from 'lwc';
import sayHello from '@salesforce/apex/HelloWorld.sayHello';

export default class HelloWorld extends LightningElement {
    greeting;


    @wire(sayHello, { name: 'Tomiris' })
    wiredHello({ data, error }) {
        if (data) {
            this.greeting = data;  
        } else if (error) {
            this.greeting = 'Error: ' + (error.body?.message || error);
        }
    }
}
