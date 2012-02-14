// This class logs gameplay events to an array, then
// encodes its contents as a string and sends it to
// the server for recording

// Desc of vars:

// Time
// UINT - Representing seconds since beginning of game

// Entry_Type
// UINT - Representing the type of event
// 0 - System messages
// 1 - Successful Words
// 2 - Failed Words


// Entry_Details
// String - Extrapolates on entry_type

package Utils
{
	public class Recorder
	{
		private var recorder_array:Array;
		
		public function Recorder()
		{
			init_recorder();
		}
		
		private function init_recorder():void{
			recorder_array = new Array;
			
		}
		
		public function write_to_recorder(time:uint,entry_type:uint,entry_details:String):void{
			var log_entry:Recorder_Entry = new Recorder_Entry(time,entry_type,entry_details);
			trace("Logged: "+log_entry);
			trace("Time: "+log_entry._time);
			trace("Entry Type: "+log_entry._entry_type);
			trace("Entry Details: "+log_entry._entry_details);
			recorder_array.push(log_entry);
		}
		
		public function encode_recorder():String{
			var ret_string:String = new String("");
			for (var i:int =0;i<recorder_array.length;i++){
				ret_string += "*"
				ret_string +=recorder_array[i]._time;
				ret_string += "/";
				ret_string += recorder_array[i]._entry_type;
				ret_string += "/";
				ret_string += recorder_array[i]._entry_details;
			}
			return ret_string;
		}
	}
}