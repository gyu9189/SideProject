import { LightningElement, track, api, wire} from 'lwc';

// apex
import getCustomerList from '@salesforce/apex/MemberController.getCustomerList';
import delCustomerRecords from '@salesforce/apex/MemberController.delCustomerRecords';

// Library
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const actions = [{ label: 'View', name: 'view' }, { label: 'Update', name: 'edit' }];
export default class MemberLWC extends NavigationMixin(LightningElement) {

    columns = [        
        { label: '번호', fieldName: 'Customer_Number__c', type: 'text'},
        { label: '이름', fieldName: 'Name', type: 'text'},
        { label: '휴대폰 번호', fieldName: 'Phone_Number__c', type: 'phone'},
        { label: '대여유무', fieldName: 'IsLental__c', type: 'boolean'},
        { label: '대여비디오', fieldName: 'LentalVideo__r.Name', type: 'text'},
        { label: '대여수', fieldName: 'LentalCount__c', type: 'number'},
        { type: 'action', typeAttributes: { rowActions: actions } }
    ];

    @api recordId;
    @api errorMessage;    
    @api selectedRecords = [];

    @track data; // list에 띄울 레코드를 담을 변수
    @track isShowModal = false; // modal switch

    @wire(getCustomerList)
    wireData({ error, data }){
        if(data) {
            this.data = data.map( result => Object.assign(
                {'LentalVideo__r.Name' : result.LentalVideo__c != undefined ? result.LentalVideo__r.Name : ''},
                result
            ));
            this.error = undefined;
            console.log('data~!');
            console.log(data);
        } else if(error) {
            console.log('error....');
            this.data = undefined;
            this.error = error;
        } // else if
    } // deployRecordList()

    insertRecord() {
        this.isShowModal = false;
        history.go(0);
    } // insert Record()

    handleDelete(event){
        delCustomerRecords({cList: this.selectedRecords})
        .then((result) => {
            if(result == null || result == undefined) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: '하나 이상의 정보를 선택하셔야 합니다.',
                        variant: 'error'
                    }),
                );
                return;
            } // if
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records deleted',
                    variant: 'success'
                }),
                history.go(0)
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    getSelectedId(event){
        this.selectedRecords = [];
        try {
            for(let i = 0; i < selectedRows.length; i++) {

                this.selectedRecords.push(selectedRows[i].Id);
            } // for             
        } catch (error) {
            console.log(error);
        }
    }

    handleRowActions(event) {
        try {
            const actionName = event.detail.action.name;
            const row = event.detail.row;
            console.log('actionName : ');
            console.log(actionName);
            switch (actionName) {
                case 'view':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: row.Id,
                            objectApiName: 'Customer__c',
                            actionName: 'view'
                        }
                    });
                    break;
 
                case 'edit':
                     this[NavigationMixin.Navigate]({
                         type: 'standard__recordPage',
                         attributes: {
                             recordId: row.Id,
                             objectApiName: 'Customer__c',
                             actionName: 'edit'
                         }
                     });
                    break;
            }
        } catch (error) {
            console.log(error);
        }
    }

    showModalBox() {  
        this.isShowModal = true;
        console.log('modal open');
        console.log(this.isShowModal);
    }

    hideModalBox() {  
        this.isShowModal = false;
        console.log('modal Close');
        console.log(this.isShowModal);
    }
}