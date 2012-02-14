package Game
{
	
	import Events.GabbEvent;
	
	import Utils.GameTimer;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Utils.Recorder;
		
	public class Game_Manager extends EventDispatcher
	{
		// Gameplayer Managers
		private var recorder:Recorder;
		private var tile_manager:TileManager;
		private var game_disp_objs:Game_Disp_Objs;
		private var game_timer:GameTimer;
		// Gameplay refs
		private  var _stage_ref:Stage;
		public var _left_bar_ref:Sprite;
		public var _right_bar_ref:Sprite;
		public var _tiles_bar_ref:Sprite;
		public var _word_station_ref:Sprite;
		private var new_game_flag:Boolean;
		// Loading refs
		private var load_count:int;
		private var game_data_manager:GameDataManager;

		public function Game_Manager(stage_ref:Stage)
		{
			_stage_ref = stage_ref;
			new_game_flag = new Boolean(false);
			load_count = new int(0);
			load_objects();
		}
		
		private function load_objects():void{
			load_game_data();
			init_disp_objs();
			init_recorder();
			init_tiles();
			init_resize_listeners();
			init_timer(2); // Pass through number of minutes
		}

		private function load_game_data():void{
			game_data_manager = new GameDataManager();
			game_data_manager.addEventListener(GabbEvent.LOADCOMPLETE,dispatchLoadComplete);			
		}
		
		protected function dispatchLoadComplete(event:Event):void
		{
			// game_data_manager has loaded
			// tile_manager has loaded
			load_count++;
			if(load_count>=2){
				startGame();
			}
		}
		
		private function startGame():void{
			begin_timer();
		}
		
		private function init_timer(timer_length:int):void{
			game_timer = new GameTimer(timer_length);
			game_timer.addEventListener(GabbEvent.TICKEVENT,updateTimer);
			game_timer.addEventListener(TimerEvent.TIMER_COMPLETE,stopTimer);
		}
		
		protected function updateTimer(e:GabbEvent):void{
			// Update display elements
			// Update logging elements
			game_data_manager.updateTimer(e);
			tile_manager.updateTimer(e);
			game_disp_objs.updateTimer(e);
		}
		
		protected function stopTimer(e:TimerEvent):void{
			this.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		}
		
		private function begin_timer():void{
			game_timer.beginTimer();
			recorder.write_to_recorder(new uint(0),new uint(0),new String("Game Start!"));
		}
		
		private function init_resize_listeners():void{
			_stage_ref.addEventListener(Event.RESIZE,resize_disp_elements);
		}
		
		public function resize_disp_elements(e:Event):void{
			game_disp_objs.resize_display_elements(e);
			tile_manager.resize_display_elements(game_disp_objs.get_disp_ref(3),game_disp_objs.get_disp_ref(4));
		}
		
		private function init_disp_objs():void{
			game_disp_objs= new Game_Disp_Objs(_stage_ref);
			game_disp_objs.init_disp_objs();
			_left_bar_ref = game_disp_objs.get_disp_ref(1);
			_right_bar_ref = game_disp_objs.get_disp_ref(2);
			_tiles_bar_ref = game_disp_objs.get_disp_ref(3);
			_word_station_ref = game_disp_objs.get_disp_ref(4);
		}
		
		private function init_tiles():void{
			tile_manager = new TileManager(_stage_ref,_tiles_bar_ref,_word_station_ref);
			tile_manager.addEventListener(GabbEvent.LOGEVENT,log_event);
			tile_manager.addEventListener(GabbEvent.LOADCOMPLETE,dispatchLoadComplete);
		}
		
		private function init_recorder():void
		{
			recorder = new Recorder();
		}
		
		// Log event when called
		protected function log_event(e:GabbEvent):void
		{
			recorder.write_to_recorder(e.time,e.entry_type,e.entry_details);
		}

	}
}