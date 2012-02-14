// These are the entries that are pushed into
// the Recorder Array

// Desc of vars:

	// Time
	// UINT of how many milliseconds have elapsed since the start of the game

	// entry_type
	// UINT type of the event

package Utils
{
	public class Recorder_Entry extends Object
	{
		public var _time:uint;
		public var _entry_type:uint;
		public var _entry_details:String;
		
		public function Recorder_Entry(time:uint,entry_type:uint,entry_details:String)
		{
			_time = new uint(time);
			_entry_type = new uint(entry_type);
			_entry_details = new String(entry_details);
		}
	}
}