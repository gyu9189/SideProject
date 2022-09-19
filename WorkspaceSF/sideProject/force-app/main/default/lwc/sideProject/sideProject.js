import { LightningElement, api, track, wire } from 'lwc';

// Apex
import getVideoList from '@salesforce/apex/VideoController.getVideoList';
import delVideoRecords from '@salesforce/apex/VideoController.delVideoRecords';
import getSearchList from '@salesforce/apex/VideoController.getSearchList';
import { getSObjectValue } from '@salesforce/apex';
// Schema
import VIDEO_OBJECT from '@salesforce/schema/Video__c';
import ID_FIELD from '@salesforce/schema/Video__c.Id';
import Name_FIELD from '@salesforce/schema/Video__c.Name'
import Video_Gnere__c_FIELD from '@salesforce/schema/Video__c.Video_Genre__c';
import IsLent__c_FIELD from '@salesforce/schema/Video__c.IsLent__c';
import Customer__c_FIELD from '@salesforce/schema/Video__c.Customer__c';
import LentDate__c_FIELD from '@salesforce/schema/Video__c.LentDate__c';
// Library
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const actions = [{ label: 'View', name: 'view' }, { label: 'Update', name: 'edit' }];
export default class SideProject extends NavigationMixin(LightningElement) {
    
    
    @api recordId;
    @api errorMessage;    
    @api selectedRecords = [];

    videoObject = VIDEO_OBJECT;

    columns = [        
        { label: '번호', fieldName: 'VideoNo__c', type: 'text'},
        { label: '비디오이름', fieldName: 'Name', type: 'text'},
        { label: '장르', fieldName: 'Video_Genre__c', type: 'text'},
        { label: '대여유무', fieldName: 'IsLent__c', type: 'boolean'},
        { label: '대여자', fieldName: 'Customer__r.Name', type: 'text'},
        { label: '대여날짜', fieldName: 'LentDate__c', type: 'date'},
        { type: 'action', typeAttributes: { rowActions: actions } }        
    ];

    @track data; // list에 띄울 레코드를 담을 변수
    @track searchData; // 검색 결과를 담을 list
    @track searchStr; // 검색 value
    @track isShowModal = false; // modal switch
    @track searchTitle;
    @track search = [
        {
            id: 'menu-item-1',
            label: '제목',
            value: 'Name'
        },
        {
            id: 'menu-item-2',
            label: '장르',
            value: 'Video_Genre__c'
        }
    ];

    @wire(getVideoList)
    wireData({ error, data }){
        if(data) {
            this.data = data.map( result => Object.assign(
                {'Customer__r.Name' : result.Customer__c != undefined ? result.Customer__r.Name : ''},
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
        delVideoRecords({vList: this.selectedRecords})
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
        const selectedRows = event.detail.selectedRows;
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
            switch (actionName) {
                case 'view':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: row.Id,
                            objectApiName: 'Video__c',
                            actionName: 'view'
                        }
                    });
                    break;
 
                case 'edit':
                     this[NavigationMixin.Navigate]({
                         type: 'standard__recordPage',
                         attributes: {
                             recordId: row.Id,
                             objectApiName: 'Video__c',
                             actionName: 'edit'
                         }
                     });
                    break;
            }
        } catch (error) {
            console.log(error);
        }
    } // handleRowActions()

    handleSearchTitle(event) {
        console.log('handleearchTitle Join!!! ');
        this.searchTitle = event.detail.value;
        
        console.log(this.searchTitle);
    } // handleSearchTitle()
    // 22-09-16
    handleSearch(event){
        var valTemp;
        valTemp = event.detail.value;
        this.searchStr = valTemp;

        console.log('searchStr !!! ');
        console.log(this.searchStr);

        var temp;
        temp = getSearchList({searchTitle: this.searchTitle}, {searchStr: this.searchStr});
        this.searchData = temp;

        console.log('searchData!!! ');
        console.log(this.searchData);
        
    } // handleSearch(event)

    showModalBox() {
        this.isShowModal = true;
        console.log('modal open');
        console.log(this.isShowModal);
    } // showModalBox()

    hideModalBox() {
        this.isShowModal = false;
        console.log('modal Close');
        console.log(this.isShowModal);
    } // hideModalBox()
}
