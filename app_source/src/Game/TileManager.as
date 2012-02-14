package Game
{
	import Events.GabbEvent;
	
	import Utils.ASCII_matcher;
	import Utils.WordReferee;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	public class TileManager extends EventDispatcher
	{
		private var _stage_ref:Stage;
		private var tb:Object;
		private var ws:Object;
		private var tile_array:Array;
		private var docked_array:Array;
		private const NUM_TILES:int = 12;
		private const NUM_ROWS:int = 3;
		private const NUM_COLS:int = 4;
		private var offset_x:Number;
		private var offset_y:Number;
		private var tile_details:Object;
		private var load_count:int;		
		private var word_ref:WordReferee;
		
		public function TileManager(stage_ref:Stage,tiles_bar_ref:Sprite,word_station_ref:Sprite)
		{
			_stage_ref = stage_ref;
			load_count = new int(0);
			init_disp_obj_pos_refs(tiles_bar_ref,word_station_ref);
			set_tile_details_obj();
			init_tiles();
			draw_tiles();
			add_tiles();
			init_keyboard_input();
			init_word_ref();
		}

		private function init_word_ref():void{
			word_ref = new WordReferee
			word_ref.addEventListener(GabbEvent.LOADCOMPLETE,dispatchLoadComplete);
		}
		
		protected function dispatchLoadComplete(event:Event):void
		{
			load_count++
			if(load_count>=1){
				this.dispatchEvent(new GabbEvent(GabbEvent.LOADCOMPLETE));
			}
		}
		
		private function dispatchLogEvent(time:uint,entry_type:uint,entry_details:String):void{
			var logEventInst:GabbEvent = new GabbEvent(GabbEvent.LOGEVENT);
			logEventInst.time = time;
			logEventInst.entry_type = entry_type;
			logEventInst.entry_details = entry_details;
			this.dispatchEvent(logEventInst);
		}
		
		private function init_keyboard_input():void{
			_stage_ref.addEventListener(KeyboardEvent.KEY_DOWN,key_pressed);
		}

		private function init_tiles():void{
			// Will need to load in external data here
			// consider XML from web2py
			tile_array = new Array();
			docked_array = new Array();
			
			var word_test_array:Array = new Array();
			word_test_array.push("A");
			word_test_array.push("D");
			word_test_array.push("T");
			word_test_array.push("J");
			word_test_array.push("U");
			word_test_array.push("I");
			word_test_array.push("O");
			word_test_array.push("S");
			word_test_array.push("C");
			word_test_array.push("X");
			word_test_array.push("Z");
			word_test_array.push("Y");
			
			for(var i:int =0; i<NUM_TILES;i++){
				var tile_data:TileData = new TileData(word_test_array[i],0,uint(i)); // Extends Sprite
				tile_data.addEventListener(MouseEvent.MOUSE_DOWN,tile_clicked);
				tile_array.push(tile_data);
			}
		}
		
		private function tile_clicked(e:MouseEvent):void{
			if(e.target.type=="dynamic"){
				if(e.target.parent._docked){
					dock_tile_toggle(e.target.parent);
				}else{
					dock_tile_toggle(e.target.parent);
				}
			}else{
				if(e.target._docked){
					dock_tile_toggle(e.target);
				}else{
					dock_tile_toggle(e.target);
				}
			}
		}

		private function key_pressed(e:KeyboardEvent):void{
			//Search all words in the tile_array for those matching
			// the pressed key. Ignore if they don't match or
			// if they're in they're docked.
		
			// Special case if backspace clicked
			// Need custom undocking function here as I'm not able to reference
			// any one particular Sprite
			
			if(e.charCode == 8){
				undock_tile_with_key();
				return
			}
			
			// Special case if enter clicked
			if(e.charCode == 13){
				submit_for_check();
			}
			
			var inputted_letter:String = String.fromCharCode(e.charCode).toUpperCase(); 
			for(var i:int =0; i<tile_array.length;i++){
				if (!tile_array[i]._docked && tile_array[i]._letter == inputted_letter){
					
					dock_tile_toggle(tile_array[i]);
					return;
				}else{
					// Do Nothing	
				}
			}
		}
		
		// Contain this in another class, I feel like im blowing up this gameplay class
		private function submit_for_check():void{
			// Create the word
			var word:String = ""
			for(var i:int =0; i<docked_array.length; i++){
				word += docked_array[i]._letter;
			}
			
			// Remove the word
			var docked_length:int = docked_array.length
			for(var j:int =0; j<docked_length; j++){
				undock_tile_with_key();
			}
			
			// Submit word for checking
			if(word_ref.checkGabbWord(word)){
				dispatchLogEvent(new uint(0),new uint(1), word); // Successful word
			}else{
				dispatchLogEvent(new uint(0),new uint(2), word); // Unsuccessful word
			}
		}

		private function undock_tile_with_key():void{
			if (docked_array.length == 0){
				return;
			}else{
				var undocked_tile_id:uint = new uint(docked_array[docked_array.length-1]._id);
				docked_array.pop()
				tile_array[undocked_tile_id]._docked = false;
				var tile_counter:uint = new uint(0);
				// Move tile back to its position in the grid	
				for(var j:int =0; j<NUM_ROWS;j++){
					for(var k:int =0; k<NUM_COLS;k++){
						if(tile_counter == undocked_tile_id){
							tile_array[tile_counter].x = tb.x + tile_details.w*k;
							tile_array[tile_counter].y = tb.y + tile_details.h*j;
							return;		
						}else{
							tile_counter++;
						}
					}
				}
			}
		}
		
		private function dock_tile_toggle(tile:Object):void{
			if(tile._docked){
				var undocked_tile_id:uint = new uint(docked_array[docked_array.length-1]._id);
				docked_array.pop()
				tile_array[undocked_tile_id]._docked = false;
				var tile_counter:uint = new uint(0);
				// Move tile back to its position in the grid	
				for(var j:int =0; j<NUM_ROWS;j++){
					for(var k:int =0; k<NUM_COLS;k++){
						if(tile_counter == undocked_tile_id){
							tile_array[tile_counter].x = tb.x + tile_details.w*k;
							tile_array[tile_counter].y = tb.y + tile_details.h*j;
							return;		
						}else{
							tile_counter++;
						}
					}
				}
			}else{
				tile._docked = true;
				// Move the tile to the wordbar
				tile.x = ws.x + tile_details.w*docked_array.length;
				tile.y = ws.y;
				docked_array.push(tile);
			}
		}
		
		public function resize_display_elements(tiles_bar_ref:Sprite,word_station_ref:Sprite):void{
			// Update the tile refs
			tb.x = tiles_bar_ref.x;
			tb.y = tiles_bar_ref.y;
			tb.h = tiles_bar_ref.height;
			tb.w = tiles_bar_ref.width;
			
			ws.x = word_station_ref.x;
			ws.y = word_station_ref.y;
			ws.w = word_station_ref.width;
			ws.h = word_station_ref.height;
			
			set_tile_details_obj();
			draw_tiles();
		}		

		private function set_tile_details_obj():void{
			tile_details = new Object();
			tile_details.w = new int(tb.w/4);
			tile_details.h = new int(tb.h/3);
			tile_details.c = new uint(0xFFFFFF);
			tile_details.r = new Number(0);
		}
		
		private function draw_tiles():void{
			
			// Draw the Sprites
			for(var i:int =0; i<NUM_TILES;i++){
				tile_array[i].drawTile(tile_details.w,tile_details.h,tile_details.c,tile_details.r);
			}
			
			// Position the Sprites
			// Will be dependent on whether docked or not
			var tile_counter:int =0;
			for(var j:int =0; j<NUM_ROWS;j++){
				for(var k:int =0; k<NUM_COLS;k++){
					tile_array[tile_counter].x = tb.x + tile_details.w*k;
					tile_array[tile_counter].y = tb.y + tile_details.h*j;
					tile_counter++;
				}
			}
		}

		private function add_tiles():void{
			for(var i:int =0; i<NUM_TILES;i++){
				_stage_ref.addChild(tile_array[i]);
			}
		}
		
		private function init_disp_obj_pos_refs(tiles_bar_ref:Sprite,word_station_ref:Sprite):void{
		
			tb = new Object();
			tb.x = tiles_bar_ref.x;
			tb.y = tiles_bar_ref.y;
			tb.h = tiles_bar_ref.height;
			tb.w = tiles_bar_ref.width;
			
			ws = new Object();
			ws.x = word_station_ref.x;
			ws.y = word_station_ref.y;
			ws.w = word_station_ref.width;
			ws.h = word_station_ref.height;
		}
		public function updateTimer(e:GabbEvent):void{
			// Updates the timer - dunno why I would
		}		
		public function updateTiles(update_obj:int):void{
			// Update the tileData
		}
	}
}