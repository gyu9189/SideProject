import { LightningElement, track, wire } from 'lwc';

// apex Controller
import getDefaultImageList from '@salesforce/apex/Side_GetImageListController.getDefaultImageList';

// static resource
import images from '@salesforce/resourceUrl/images';

// Library
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class Side_imageDown extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference)
    pageRef;

    @track imagesInfo;  // all image data [ all ]
    @track imageData;   // display sending image data [ limit 12 ]
    @track imageCheck;
    checkedImageId = [];
    type = '';          // image 주제
    imageSize;          // 총 데이터 수

    // paging variable
    datePerPage;        // 한 페이지에 나타낼 이미지 수
    globalCurrentPage;  // 현재 버튼 숫자
    pagingSwitch;       // 페이지 이동시 render switch
    pagebutton;         // page 갯수 올림처리
    pageArr;            // page No
    pageArea;           // page Area         
    buttonLimit;        // PageBttn Limit
    pageCnt             // 전체 Area 수


    connectedCallback(){
        this.checkedImageId = [];
        getDefaultImageList({type : this.type})
        .then(res => {
            this.imagesInfo = res.imageList;
            this.imageCheck = res.imageId;
            
            // paging
            this.imageSize = res.imageSize; // 총 데이터 수
            this.datePerPage = 12;          // 한 페이지에 나타낼 이미지 수
            this.globalCurrentPage = this.pageRef.state.pageNum?this.pageRef.state.pageNum:1;     // 현재 버튼 숫자
            this.pageArea = this.pageRef.state.pageArea?this.pageRef.state.pageArea:1;            // 현재 페이지 그룹

            // 화면에 보내줄 image수 Handle
            this.imagesSizeLimit(this.globalCurrentPage);
            // 화면에 나타낼 번호 수, 번호 Handle
            this.buttonLimit = this.pageArea * 5 - 4;              // button 시작 번호 수식
            this.handlePageBttn();
            // pageBttn handler ( activate / disabled)
            this.moveBttnHandle();
        })
        .catch(err => {
            console.log('err ::: ' + JSON.stringify(err));
        });
    }

    imagesSizeLimit(pageNum){
        this.pagingSwitch = false;
        try {
            let endIndex = 0;
            let startIndex = 0;
            endIndex = pageNum * 12;
            if(pageNum != 1){                
                startIndex = endIndex - 12;
            }

            this.imageData = [];
            for(let i = startIndex; i < endIndex; i++) {
                if(this.imagesInfo[i].Id == this.imagesInfo[this.imageSize-1].Id) {
                    this.imageData.push(this.imagesInfo[i]);
                    break;
                } else {
                    let temp = this.imagesInfo[i];
                    this.imageData.push(temp);
                } // else
            } // for
            this.pagingSwitch = true;
        } catch (error) {
            console.log('error ::: ' + JSON.stringify(error));
        } // try / catch
    }

    // 이미지 주제 클릭시
    contentTypeHandle(e){
        let title = e.target.textContent;
        this.globalCurrentPage = 1;
        this.pageArea = 1;
        switch(title) {
            case "센과 치히로":
                this.type = 'chihiro';
                break;
            case "포뇨":
                this.type = 'ponyo';
                console.log(this.type);
                break;
            default:
                this.type = 'chihiro';
                break;
        } // Switch
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
            state: {
                pageNum: this.globalCurrentPage,
                pageArea: this.pageArea
            }
        });
        this.connectedCallback();
    }

    handleChecked(e){
        // loadScript('https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js');
        let cls = e.currentTarget;
        let clsName = cls.className;

        let cnt = 0;
        for(let i = 0; i < this.checkedImageId.length; i++) {
            if(this.checkedImageId[i] == e.currentTarget.dataset.id) {
                if(i == 0) break;
                else {
                    cnt++;
                    break;
                }
            }
            cnt = i;
        } // for

        let imageUrl = '';
        let imageName = '';
        for(let i = 0; i < this.imageSize; i++) {
            if(e.currentTarget.dataset.id == this.imagesInfo[i].Id) {
                imageUrl = this.imagesInfo[i].ImageUrl__c;
                imageName = this.imagesInfo[i].Name;
            }
        } // for

        // start download tag create
        let divTag = document.createElement('div');
        divTag.setAttribute('class', 'download-div');
        
        let aTag = document.createElement('a');
        aTag.setAttribute('class', 'image-downLink');
        aTag.setAttribute('href', `${imageUrl}`);
        aTag.setAttribute('download', `${imageName}`);
        
        let bttnTag = document.createElement('button'); 
        bttnTag.setAttribute('class', 'image-bttn');
        bttnTag.setAttribute('title', 'DownLoad');
        bttnTag.innerHTML ='Image Download';
        // end download tag create
        
        // tag className check & download tag add || delete
        if(clsName == 'checked') {
            cls.className = 'image-box';
            delete this.checkedImageId[cnt];
            cls.removeChild(cls.lastChild);
        } else {
            cls.className = 'checked';
            this.checkedImageId.push(e.currentTarget.dataset.id);
            
            cls.appendChild(divTag);
            divTag.appendChild(aTag);
            aTag.appendChild(bttnTag);
        } // else
    }

    // Page 버튼 생성 함수
    handlePageBttn(){
        this.pagebutton = Math.ceil(this.imageSize / 12);  // 총 data size를 한페이지에 12개씩 보여준다 칠때 나올 버튼 수 ( 올림 처리 )
        this.pageCnt = Math.ceil(this.pagebutton / 5);     // 버튼이 12개 나온다 칠때 area 는 3개
        this.pageArr = [];                                 // button for문 돌릴거
        
        let remainderPage = this.pagebutton % 5; // 나머지 버튼 수
        const defaultBttn = 6;                     // 기본 버튼 수 버튼 갯수를
        if(this.pageArea < this.pageCnt) {
            for(let i = this.buttonLimit; i < defaultBttn; i++) {
                this.pageArr.push({No : i});
            } // for
        } else if(this.pageArea == this.pageCnt && this.pageCnt != 1) {
            for(let i = this.buttonLimit; i < remainderPage + this.buttonLimit; i++) { // 현재 page 와 PageCnt 가 같다면 나머지 버튼만
                this.pageArr.push({No : i});
            } // for
        } else {
            if(this.pagebutton < defaultBttn){
                for(let i = this.buttonLimit; i <= this.pagebutton; i++) { // pageBttn 수가 6 이하 일때
                    this.pageArr.push({No : i});
                } // for
            } else {
                for(let i = this.buttonLimit; i < defaultBttn; i++) { // 전부 아니라면 기본 버튼수 ㄱㄱ
                    this.pageArr.push({No : i});
                } // for
            }
        }// else
    }

    // 페이지 번호 이동
    onPagination(e) {
        this.globalCurrentPage = e.target.value;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
            state: {
                pageNum: this.globalCurrentPage,
                pageArea: this.pageArea
            }
        });
        this.connectedCallback();
    }

    // 페이지 <<, <, >, >> 버튼 이동
    pageAreaMove(e) {
        let action = e.target.value;
        switch (action){
            case "<":
                this.pageArea = this.pageArea - 1;
                this.globalCurrentPage = this.pageArea * 5 - 4;

                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Home'
                    },
                    state: {
                        pageNum: this.globalCurrentPage,
                        pageArea: this.pageArea
                    }
                });
                this.connectedCallback();
                break;

            case "<<":
                this.globalCurrentPage = 1;
                this.pageArea = 1;

                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Home'
                    },
                    state: {
                        pageNum: this.globalCurrentPage,
                        pageArea: this.pageArea
                    }
                });
                this.connectedCallback();
                break;

            case ">":
                this.pageArea = this.pageArea + 1;
                this.globalCurrentPage = this.pageArea * 5 - 4;

                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Home'
                    },
                    state: {
                        pageNum: this.globalCurrentPage,
                        pageArea: this.pageArea
                    }
                });
                this.connectedCallback();
                break;

            case ">>":
                this.globalCurrentPage = this.pagebutton;
                this.pageArea = this.pageCnt;

                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Home'
                    },
                    state: {
                        pageNum: this.globalCurrentPage,
                        pageArea: this.pageArea
                    }
                });
                this.connectedCallback();
                break;
            default :
                break;
        }
    }

    // move bttn 활성화 / 비활성화
    moveBttnHandle() {
        let firstBttn = this.template.querySelector('.first-Page-bttn');
        let previousBttn = this.template.querySelector('.previous-page-bttn'); 
        let nextBttn = this.template.querySelector('.next-page-bttn');
        let endBttn = this.template.querySelector('.end-page-bttn');

        firstBttn.disabled = true;
        previousBttn.disabled = true;
        nextBttn.disabled = true;
        endBttn.disabled = true;

        if(this.globalCurrentPage != 1) firstBttn.disabled = false;              // 현재 페이지가 1이 아니라면 << 버튼 활성화 
        if(this.pageArea != 1) previousBttn.disabled = false;                    // 현재 pageArea 가 1이 아니라면 < 버튼 활성화
        if(this.pageArea < this.pageCnt) nextBttn.disabled = false;              // 현재 pageArea 가 pageCnt보다 낮다면 > 활성화
        if(this.globalCurrentPage != this.pagebutton) endBttn.disabled = false;  // 현재 page가 endPage가 아니라면 >> 활성화
    } 
}


