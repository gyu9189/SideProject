public class CntrlDisplayGame {
	
    // @ 생성자
    public CntrlDisplayGame(){
        searchGameInfo();	// 현재 등록되어있는 게임 정보 검색 (select)
        createGameInfo();	// 새로운 게임 정보를 추가 (insert)
        updateGameInfo();	// 게임 정보 수정 (update)
        deleteGameInfo();	// 게임 정보 삭제 (delete)
        upsertGameInfo();	// 게임 정보 추가 및 수정 (insert && update)
    } // 생성자
    
    // 게임 정보 검색 (select)
    public void searchGameInfo(){
        List<Game__c> gameList = [select 
                                  	Id,
                                  	Name,
                                  	Genrel__c,
                                  	ReleaseDate__c,
                                  	ProductionCompany__c
                                  from
                                  	Game__c]; // query
        
        System.debug('------------select 결과 start------------'); // log인듯
        System.debug('select 결과 수 : ' + gameList.size());
        
        for(Game__c game : gameList) {
            System.debug('-------------------');
            System.debug('게임 타이틀 : ' + game.Name);
            System.debug('게임 장르 : ' + game.Genrel__c);
            System.debug('게임 출시일 : ' + game.ReleaseDate__c);
            System.debug('게임 제작사 : ' + game.ProductionCompany__c);
        } // for
        System.debug('=========== select 결과 end ===========');
        
    } // searchGameInfo
    
    // 게임 정보 추가 (insert)
    public void createGameInfo() {
        Game__c newGame = new Game__c();
        newGame.Name = 'StarCraft';
        newGame.Genrel__c = 'RTS';
        newGame.ReleaseDate__c = Date.newInstance(2022, 11, 30);
        newGame.ProductionCompany__c = 'Blizzard';
        
        // 게임 정보 등록 (insert)
        insert newGame;
        
        List<Game__c> validGameList = [select 
                                  			Id,
                                  			Name,
                                  			Genrel__c,
                                  			ReleaseDate__c,
                                  			ProductionCompany__c
                                  	    from
                                  			Game__c]; // query
        
        System.debug('======== insert result start ========');
        System.debug('select 결과 수 : ' + validGameList.size());
        
        for(Game__c game : validGameList) {
            System.debug('-------------------');
            System.debug('게임 타이틀 : ' + game.Name);
            System.debug('게임 장르 : ' + game.Genrel__c);
            System.debug('게임 출시일 : ' + game.ReleaseDate__c);
            System.debug('게임 제작사 : ' + game.ProductionCompany__c);
        } // for
        System.debug('=========== insert result end ===========');
    }// createGameInfo
    
    // 게임 정보 수정 (update)
    
    public void updateGameInfo() {
        List<Game__c> validGameList = [select 
                                  	Id,
                                  	Name,
                                  	Genrel__c,
                                  	ReleaseDate__c,
                                  	ProductionCompany__c
                                  from
                                  	Game__c]; // query
        // 새로 추가한 StarCraft 정보 수정
        // index 를 알고 있는 경우
        // Game__c editGame = gameList.get(3);
        // Game__c editGame = gameList[3];
        
        Game__c editGame;
        
        for(Game__c game : validGameList) {
            // select 한 게임 정보의 리스트를 루프
            
            // if(game.Name.equals('StarCraft')) // equals 대소문자 구분
            
            if(game.Name.equalsIgnoreCase('StarCraft')) { // 대소문자 구분 X
                // 게임 이름이 StarCraft 인 게임 정보 레코드를 습득
                
                editGame = game;
                break;
            } // if
        } // for
        
        System.debug('========update result start =========');
        System.debug('update 이전 출시일 : ' + editGame.ReleaseDate__c);
        
        // 수정할 게임의 출시일을 수정
        editGame.ReleaseDate__c = Date.newInstance(1998, 11, 30);
        
        // 게임 정보 등록
        update editGame;
        
        // 게임명이 StarCraft 인 레코드를 select (SOQL 에서는 대소문자 구분 X)
        List<Game__c> validGame = [select 
                                   	Id, 
                                   	ReleaseDate__c 
                                   from 
                                   	Game__c 
                                   where 
                                   	Name = 'StarCraft'];
        
        System.debug('update 이후 출시일 : ' + validGame.get(0).ReleaseDate__c);
        System.debug('===================update end=================');        
    } // updateGameInfo
    
    // 게임 삭제
    public void deleteGameInfo() {

        List<Game__c> gameList = [SELECT 
                                  	Id,
                                  	Name,
                                  	Genrel__c,
                                  	ReleaseDate__c,
                                  	ProductionCompany__c
                                  FROM
                                  	Game__c]; // query

        // 새로 추가한 StarCraft 게임 정보 삭제
        Game__c delGame;

        for (Game__c game : gameList) {
            // SELECT한 게임 정보의 리스트를 루프

            if (game.Name.equalsIgnoreCase('StarCraft')) {		// equalsIgnoreCase : 대소문자 구분 X
                // 게임이름이 "StarCraft" 인 게임 정보 레코드를 습득

                delGame = game;
                break;
            }
        }

        delete delGame;


        // 게임명이 "StarCraft"인 레코드를 SELECT(SOQL에서는 대소문자 구분 X)
        List<Game__c> validGame = [SELECT Id, ReleaseDate__c FROM Game__c WHERE Name = 'StarCraft'];        
        System.debug('=================== DELETE 결과_START ==================');
        System.debug('게임 이름이 StarCraft인 레코드 SELECT 결과 : ' + validGame.size());
        System.debug('=================== DELETE 결과_END ====================');
    } // deleteGameInfo

    
    // 게임 정보 추가 및 수정(upsert)
    public void upsertGameInfo() {
        
        // 게임 개체에 등록되어 있는 레코드를 select
        List<Game__c> gameList = [select
                                 	Id,
                                 	Name,
                                 	Genrel__c,
                                 	ReleaseDate__c,
                                 	ProductionCompany__c
                                 from
                                 	Game__c]; // query
        
        // 신규 추가용 게임 정보 정의
        Game__c newGame = new Game__c(Name = 'OverWatch',
                                     Genrel__c = 'FPS',
                                     ReleaseDate__c = Date.newInstance(2016, 5, 24),
                                     ProductionCompany__c = 'Blizzard'); // set
        
        System.debug('==========upsert 이전 start=========');
        System.debug('select 결과수 : ' + gameList.size());
        for(Game__c game : gameList) {
            System.debug('---------------------');
            System.debug('게임 타이틀 : ' + game.Name);
            System.debug('게임 장르 : ' + game.Genrel__c);
            System.debug('게임 출시일 : ' + game.ReleaseDate__c);
            System.debug('게임 제작사 : ' + game.ProductionCompany__c);
        } // for 
        
        System.debug('===================upsert 이전 end ==================');
        
        // select 로 얻어온 게임 정보 리스트의 첫번째 레코드의 제작사를 변경
        gameList.get(0).ProductionCompany__c = '펍지';
        
        // upsert 대상 리스트에 신규 추가용 게임 정보를 추가
        gameList.add(newGame);
        
        // 게임 정보 리스트를 upsert
        upsert gameList;
        
        // 게임 개체에 등록되어 있는 레코드를 select
        List<Game__c> validGameList = [select
                                      	Id,
                                      	Name,
                                      	Genrel__c,
                                      	ReleaseDate__c,
                                      	ProductionCompany__c
                                      from
                                      	Game__c]; // query
        
        System.debug('==============upsert 이후 start ============');
        System.debug('select 결과 수 : ' + validGameList.size());
        for(Game__c game : validGameList) {
            System.debug('----------------------');
            System.debug('게임 타이틀 : ' + game.Name);
            System.debug('게임 장르 : ' + game.Genrel__c);
            System.debug('게임 출시일 : ' + game.ReleaseDate__c);
            System.debug('게임 제작사 : ' + game.ProductionCompany__c);
        } // for 
        System.debug('==============upsert 이후 end=============');
        
        
        
    } // upsertGameInfo
    
    
    
    
    
    
    
    
    
    
}