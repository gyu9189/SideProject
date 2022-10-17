import { LightningElement, track, wire } from 'lwc';

// Controller
import getDefaultData from '@salesforce/apex/Side_GetExportData.getDefaultData';
import getAllObjectList from '@salesforce/apex/Side_GetExportData.getAllObjectList';
import getFieldToObject from '@salesforce/apex/Side_GetExportData.getFieldToObject';
import getChoiceData from '@salesforce/apex/Side_GetExportData.getChoiceData';
import getFieldType from '@salesforce/apex/Side_GetExportData.getFieldType';
import getPickList from '@salesforce/apex/Side_GetExportData.getPickList';

// Library
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Side_export_excel extends LightningElement {


    /* 
    1. controller에서 query 정상적으로 들어가는지 확인.
    2. JS에서 lsatIndex가 1이면 논리연산자 display none.
    3. add input box시 target index - 1에 해당 되는 논리연산자 display on.
    4. 엑셀 이름도 사용자가 입력할 수 있게 하자. excel download 누를시 입력창 나오게 ㄱㄱ
     */


    @track object;             // org에 있는 모든 Object
    @track field;              // 선택한 Object에 대한 field
    @track targetBox;          // 선택한 Object checkbox에 대한 정보
    @track targetObject;       // 선택한 Object Name

    @track data;               // excel로 내보내줄 데이터
    @track size;               // data.length

    @track columnHeader = [];  // excel header (예 : Id  |  Name  |  firstName  |  LastName )
    
    @track operList = ['None', 'equals', 'not equal to', 'starts with', 'contains', 'dose not contain',
                'less than', 'greater than', 'less or equal', 'greater or equal'];

    whereSet = [{check: false, index: 1, field: '', operator: '', value: '', logic: 'none'}];
    index = 1;
    @track isWhereBoxSwitch = true;
    @track exportSwitch;
    @track whereList = [];

    // input type (.where-value)
    @track isDefault = true;
    @track isText;
    @track isDatetimeLocal;
    @track isDate;
    @track isBool;
    @track isPickList;
    @track isNumber;
    
    // logical operator List
    @track operatorList = ['None', 'and', 'or'];

    // toast
    @track title;          // toast 제목
    @track variant;        // toast type
    @track message;        // toast message




    connectedCallback(){
        getAllObjectList()
        .then(res => {
            this.object = res;
            console.log('Start a ConnCallback Func in Export_Excel.js');
            this.pickListType['isDefault'];
        })
        .catch(err => {            
            console.log('ERROR : ' + JSON.stringify(err));
        })
    }

    // checkbox의 초기화, 값 변경에 대한 handle
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
        this.isWhereBoxSwitch = false;
        this.whereSet = [{check: false, index: 1, field: '', operator: '', value: ''}];
        this.index = 1;
        this.getTargetObjectField();        
        setTimeout(() => this.isWhereBoxSwitch = true, 500);
    }

    // 사용자가 선택한 object 에 대한 fields
    getTargetObjectField(){
        getFieldToObject({objectName: this.targetObject})
        .then(res => {
            this.field = res;
        })
        .catch(err => {
            console.log('error ::: ' + JSON.stringify(err));
        })
    }

    // 사용자가 excel에 표기하려 하는 데이터를 모아두는 함수
    usingFieldSet(e){
        let fieldName = e.target.dataset.name;
        let fieldBox = e.target;
        if(fieldBox.checked) {
            this.columnHeader.push(fieldName);
        }else{
            this.columnHeader = this.columnHeader.filter((element) => element !== fieldName);
        }
    }

    // 사용자가 원하는 data를 가공 및 table에서 데이터를 가져오는 함수
    getExportData(){
        // check undefine in whereSet
        this.validateWhereSet();

        if(this.exportSwitch == 'Y') {
            let dataGroup = {objectName: this.targetObject, where: this.whereSet};
            this.objectToList();
            getChoiceData({objectName: this.targetObject , fields: this.columnHeader, whereList: this.whereList})
            .then(res => {
                this.data = res.fieldList;
                this.exportData();
            })
            .catch(err => {
                console.log('error ::: ' + JSON.stringify(err));
            });
        }
    }

    // 최종적으로 data를 뽑아 excel로 출력 및 download 해준는 함수
    exportData() {
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        
        doc += '<tr>';
        this.columnHeader.forEach(element => {
            doc += '<th>'+ element +'</th>'
        });
        doc += '</tr>';

        this.data.forEach(record => {
            doc += '<tr>';
            for(let i = 0; i < this.columnHeader.length; i++){
                if(record[this.columnHeader[i]] !== undefined) {
                    doc += '<th>'+ record[this.columnHeader[i]] +'</th>';
                } else {
                    doc += '<th>'+ 'undefine' +'</th>';
                }
            }
            doc += '</tr>';
        })
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.encodeURIComponent
        downloadElement.target = '_self';
        downloadElement.download = 'data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    // where 절의 조건을 더 추가하기 위해 add 를 누르면 box 추가 del 하면 box 삭제
    addWhereBox(e) {
        let clsName = e.target.className;
        let result = '';
        console.log(clsName);
        if(clsName == 'addBox'){
            if(this.index < 5) {
                this.index = this.index + 1;

                if(this.whereSet[this.index-1] == null || this.whereSet[this.index-1] == undefined){
                    this.whereSet.push({check: false, index: this.index, field: '', operator: '', value: '', logic: 'none'});
                    this.operatorHandle(clsName);                    
                }
            } else {
                this.title = '조건 행 추가 제한';
                this.variant = 'warning';
                this.message = '행을 5개 이상 추가할 수 없습니다.';
                this.showToast();
            }
        } else {
            if(this.index > 1) {
                this.index = this.index - 1;
                this.whereSet = this.whereSet.filter((element) => element !== this.whereSet[this.index]);
                this.operatorHandle(clsName);                

            } else {
                this.title = '조건 행 삭제 제한';
                this.variant  = 'warning';
                this.message = '1 이하로 지울 수 없습니다.';
                this.showToast();
            }
        }
        this.isWhereBoxSwitch = true;
    }

    // // 사용자가 입력한 데이터를 object type 변수에 push 하는 함수 1 
    whereDataSet(e){
        let clsName = e.target.className;
        let index = e.target.dataset.id - 1;
        let val = e.target.value;
        let checked = e.target.checked;

        this.utilMap(clsName, index, val, checked);
    }

    // 사용자가 입력한 데이터를 object type 변수에 push 하는 함수 2
    utilMap(clsName, index, val, checked){
        let i = 0;
        let result = this.whereSet.map((v) =>{
            this.isData = true;
            if(i == index){
                switch(clsName){
                    case 'where-field':
                        v.field = val;
                        this.getFieldType(val, index);
                        break;
                    case 'where-operator':
                        v.operator = val;
                        break;
                    case 'where-value':
                        v.value = val;
                        break;
                    case 'where-active':
                        v.check = checked;
                    case 'where-Logical-operator':
                        v.logic = val;
                        break;
                    default:
                        break;
                }
            }
            i++;
        });
    }

    // where절 의 check box가 선택 되어 있는것들 중 필드가 채워지지 않은 부분이 있다면 
    // event 생성 => showToast()
    validateWhereSet(){
        this.isWhereBoxSwitch = false;
        this.exportSwitch = 'Y';
        let i = 1;
        let message = '';
        this.whereSet.forEach(data => {
            for(let key in data) {
                console.log(data[key]);
                if(key == 'check' && data[key] == true) {
                    if(data['field'] == '' || data['operator'] == '' || data['value'] == ''){
                        message += '[' + i + ']';
                        console.log('message ::: ' + JSON.stringify(message));
                    }
                }
            }
            i++;
        });
        if(message != ''){
            this.exportSwitch = 'N';
            this.title = '항목 필드 빈칸 ERROR';
            this.variant  = 'error';
            this.message = message + '번째 행이 활성화 되어있지만, 필드가 채워져 있지 않습니다. (비활성 혹은 필드를 채워주세요.)';
            this.showToast();
        }

        this.isWhereBoxSwitch = true;
    }

    // where에서 사용자가 선택, 입력한 data들을 object type 에서 List type으로 변환시켜주는 함수
    objectToList() {
        this.whereList = [];
        this.whereSet.forEach(data => {
            for(let key in data) {
                if(key == 'check' && data[key] == true){
                    this.whereList.push(data['operator']);
                    this.whereList.push(data['field']);                    
                    this.whereList.push(data['value']);
                    this.whereList.push(data['logic']);
                }
            }
            console.log(this.whereList);
        });        
    }


    // http://jun.hansung.ac.kr/cwp/htmls/HTML%20Input%20Types.html << input tag types
    // where 절의 field 선택시 해당 field의 type에 따라 입력 input tag의 속성을 변경 시켜주는 역할을 하는 함수
    async getFieldType(val, index){        

        await getFieldType({objectName: this.targetObject, fieldName: val})
        .then(res => {
            console.log(res);
            index = index + 1;
            // let parent = this.template.querySelector('div[data-idx="' + index + '"]');            
            // input type visibel
            this.isDefault = false;
            this.isText = false;
            this.isBool = false;
            this.isDate = false;
            this.isDatetimeLocal = false;
            this.isNumber = false;
            this.isPickList = false;

            if(res == 'STRING') {
                this.isText = true;
            } else if(res == 'DATETIME'){
                this.isDatetimeLocal = true;
            } else if(res == 'PICKLIST'){
                getPickList({objectName: this.targetObject, fieldName: val})
                .then(res => {
                    this.pickList = res;
                })
                .catch(err => {
                    console.log('error !!!');
                    console.log(err);
                })
                this.isPickList = true;
            } else if(res == 'DATE'){
                this.isDate = true;
            } else if(res == 'BOOLEAN'){
                this.isBool = true;
            } else if(res == 'INTEGER'){
                this.isNumber = true;
            } else {
                this.isDefault = true;
            }
        })
        .catch(err => {
            console.log('err ::: ' + JSON.stringify(err));
        });        
    }

    operatorHandle(action){
        var prevOperator;
        let index = this.index;

        if(action == 'addBox'){
            index = index - 1;
            prevOperator = this.template.querySelector('select[data-no="' + index + '"]');
            prevOperator.style.visibility = 'visible';
        } else if(action == 'delBox') {
            prevOperator = this.template.querySelector('select[data-no="' + index + '"]');
            prevOperator.style.visibility = 'hidden';
        }

        this.isWhereBoxSwitch = false;
    }

     // 이벤트 생성 함수
    showToast() {
        const event = new ShowToastEvent({
            title: this.title,
            variant: this.variant,
            message: this.message,
        });
        this.dispatchEvent(event);
    }

}
