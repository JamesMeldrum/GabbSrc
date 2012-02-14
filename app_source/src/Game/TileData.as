// These are the entries that are pushed into
// tile_array

// Desc of vars:

	// Letter
	// STRING - representing the ASCII value of the Letter tile

	// Value
	// UINT - representing the multiplier applied to the tile
	// 0 - No multiplier
	// 1 - 2x
	// 2 - 3x
	// 3 - 4x

	// Docked
	// BOOL - is the tile in the tile bar or not
	// 0 - No
	// 1 - Yes

	// ID
	// UINT - position in order of letters. Used for positioning

package Game
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class TileData extends Sprite
	{
		public var _letter:String;
		public var _value:uint;
		public var _docked:Boolean;
		public var _id:uint;
		public var type:String; // Override type
		
		public function TileData(letter:String,value:uint,order:uint)
		{
			type = "Tile";
			_letter = letter;
			_value = value;
			_docked = false;
			_id = order;
		}
		
		public function drawTile(width:int,height:int,color:uint,rounding:Number):void{
			this.graphics.clear();
			this.graphics.beginFill(color);
			this.graphics.drawRoundRect(0,0,width,height,rounding,rounding);
			
			var letter_disp:TextField = new TextField();
			letter_disp.text = this._letter;
			letter_disp.selectable = false;
			this.addChild(letter_disp);
		}
		
		public function toggleDocked():Boolean{
			this._docked = !this._docked;
			return this._docked;
		}
	}
}