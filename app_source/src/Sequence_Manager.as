// Controls the application life-cycle

package
{
	
	import Game.Game_Manager;
	
	import flash.display.Stage;
	
	public class Sequence_Manager
	{
		public var _stage_ref:Stage
		public var _game_manager:Game_Manager;
		private var current_state:uint;
		
		// 0 - Menu
		// 1 - Game
		
		public function Sequence_Manager(stage_ref:Stage)
		{
			_stage_ref = stage_ref;
			current_state = 1;
			init_app_cycle();
		}
		
		public function sequence_change(to:int):void{
			
		}
		
		public function init_app_cycle():void{
			init_game_manager();
		}
		
		public function init_game_manager():void{
			// New Game
			// User's ID
			// Opponent's ID
			// Events String
			
			_game_manager = new Game_Manager(_stage_ref);
		}

	}
}