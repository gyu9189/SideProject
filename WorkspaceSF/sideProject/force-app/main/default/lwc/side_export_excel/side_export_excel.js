import { LightningElement, track, wire } from 'lwc';

// Controller
import getDefaultData from '@salesforce/apex/Side_GetExportData.getDefaultData';
import getAllObjectList from '@salesforce/apex/Side_GetExportData.getAllObjectList';
import getFieldToObject from '@salesforce/apex/Side_GetExportData.getFieldToObject';
import getChoiceData from '@salesforce/apex/Side_GetExportData.getChoiceData';

export default class Side_export_excel extends LightningElement {

    object;             // org에 있는 모든 Object
    field;              // 선택한 Object에 대한 field
    targetBox;          // 선택한 Object checkbox에 대한 정보
    targetObject;       // 선택한 Object Name

    @track data;        // excel로 내보내줄 데이터
    @track size;        // data.length

    columnHeader = [];  // excel header (예 : Id  |  Name  |  firstName  |  LastName )

    connectedCallback(){
        getAllObjectList()
        .then(res => {
            this.object = res;
        })
        .catch(err => {
            console.log('error :::::::::::::::::::::::');
            console.log(err);
        })
    }

    checkedHandle(e){
        if(this.targetBox) this.targetBox.checked = false;
        this.targetBox = e.target;
        
        let target = e.target;
        target.checked = true;

        this.targetObject = e.target.dataset.name;
        this.columnHeader = [];

        let fieldBox = this.template.querySelectorAll('.field-input');
        fieldBox.forEach(ele => {
            ele.checked = false;
        });

        console.log(this.targetObject);
        this.getTargetObjectField();
    }

    getTargetObjectField(){
        getFieldToObject({objectName: this.targetObject})
        .then(res => {
            this.field = res;
        })
        .catch(err => {
            console.log('error ::: ' + JSON.stringify(err));
        })
    }

    usingFieldSet(e){
        let fieldName = e.target.dataset.name;
        let fieldBox = e.target;
        if(fieldBox.checked) {
            console.log('true');
            this.columnHeader.push(fieldName);
            console.log('this.columnHeader ::: ' + JSON.stringify(this.columnHeader));
            console.log('this.columnHeader[] ::: ' + JSON.stringify(this.columnHeader[0]));
            console.log(this.columnHeader.length);
        }else{
            console.log('false');
            this.columnHeader = this.columnHeader.filter((element) => element !== fieldName);
            console.log('this.columnHeader ::: ' + JSON.stringify(this.columnHeader));
        }
    }


    getExportData(){
        console.log('exportData Start !!!');
        getChoiceData({objectName : this.targetObject, fields : this.columnHeader})
        .then(res => {
            console.log('SELECT result ::: ' + JSON.stringify(res));
            this.exportData(res);
        })
        .catch(err => {
            console.log('error ::: ' + JSON.stringify(err));
        })
    }

    exportData(res) {
        this.data = res.fieldList;
        this.size = res.size;
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {
            doc += '<th>'+ element +'</th>'
        });
        doc += '</tr>';
        // Add the data rows
        
        this.data.forEach(record => {
            let i = 0;
            doc += '<tr>';
            while(i < this.columnHeader.length){
                for(let key in record) {                    
                    if(key == this.columnHeader[i]) {
                        doc += '<th>'+ record[key] +'</th>'
                        i++;
                    }
                }
            }
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

}