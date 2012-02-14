package Game
{
	import Events.GabbEvent;
	
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.events.EventDispatcher;
	
	public class GameDataManager extends EventDispatcher
	{
		private var new_game_flag:int;

		private var event_data:Array;
		private var start_letters_data:Array;
		
		private var opponent_data:Array;
		private var playerDataLoader:LoaderMax;
		private var oppDataLoader:LoaderMax;
		
		public function GameDataManager()
		{
			// Init
			new_game_flag = new int(1);
			var player_ID:int = 1;
			var opponent_ID:int = 2;
			var game_ID:int = 0;
			
			opponent_data = new Array();
			loadPlayerData(player_ID,opponent_ID,game_ID);
		}
		
		public function loadPlayerData(player_ID:int,opponent_ID:int,game_ID:int):void{
			var serve_URL:String = "http://gabbsandbox.appspot.com/Gabb1/fb_serv/serve_player_data.txt"; // Live
			//var serve_URL:String = "http://127.0.0.1:8000/Gabb1/fb_serv/serve_player_data.txt"; // Debug
			serve_URL += "?player_ID="+String(player_ID);
			serve_URL += "&opponent_ID="+String(opponent_ID);
			serve_URL += "&game_ID="+String(game_ID);
			trace(serve_URL);
			playerDataLoader = new LoaderMax({name:"GameDataLoader_Pla",onComplete:buildPlayerData,onError:errorHandler});
			playerDataLoader.append (new DataLoader(serve_URL,{name:"playerData",format:"text"}));
			playerDataLoader.load();
		}

		private function buildPlayerData(e:LoaderEvent):void{
			var playerDataString:String = playerDataLoader.getContent("playerData");
			trace(playerDataString);
			parsePlayerDataString(playerDataString);
			parseEventString();
			if(new_game_flag){
				dispatchLoadComplete();				
			}else{
				loadOpponentData();
			}
		}
		// Create start_letters_data
		// Create event_data 
		private function parsePlayerDataString(playerDataString:String):void
		{
			var splitArray:Array = playerDataString.split("&");
			start_letters_data = splitArray[0].split("")
			event_data = splitArray[1].split("*");
			event_data.pop(); // Remove last empty split
		}
		
		private function parseEventString():void
		{
			// TODO: Create Event data array.
			// Will need to split event_data by ","
			// and use the length and order of events
			// to fire events depending on the tick
			// count of the clock.
			
			// May need a multi-element array
			// [Time,type,details,tile_location]
			// then hook up with the update
			// clock function to fire events
			// in the viewed application.
			
		}
		
		private function loadOpponentData():void
		{
			var serve_URL:String = "http://gabbsandbox.appspot.com/Gabb1/fb_serv/serve_dict.txt";
			oppDataLoader = new LoaderMax({name:"GameDataLoader_Opp",onComplete:buildPlayerData,onError:errorHandler});
			oppDataLoader.append (new DataLoader(serve_URL,{name:"playerData",format:"text"}));
			oppDataLoader.load();
		}
		
		private function buildOpponentData():void{
			var dicObj:String = playerDataLoader.getContent("playerData");
			dispatchLoadComplete();
		}
		
		private function errorHandler(event:LoaderEvent):void{
			trace("error occured with " + event.target + ": " + event.text);
		}
		
		private function dispatchLoadComplete():void{
			this.dispatchEvent(new GabbEvent(GabbEvent.LOADCOMPLETE));
		}		
		
		public function updateTimer(e:GabbEvent):void{
			// Listen for changes in tick event
			// and compare that with theentries in 
		}
	}
}