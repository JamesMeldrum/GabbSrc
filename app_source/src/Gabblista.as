package
{
	import Game.Game_Manager;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	public class Gabblista extends Sprite
	{
		
		public var stage_ref:Stage;
		public var _sequence_manager:Sequence_Manager;

		public function Gabblista()
		{
			super();
			init_stage();
			init_sequence_manager();
		}
		
		public function init_stage():void{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage_ref = this.stage;
			
		}
		
		public function init_sequence_manager():void{
			_sequence_manager = new Sequence_Manager(stage_ref);
		}
	}
}