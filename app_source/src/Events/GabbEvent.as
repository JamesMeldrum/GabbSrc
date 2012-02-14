package Events
{
	import flash.events.Event;
	
	// Added custom vars to pass with event for logging
	// See Game.Recorder.as for more details
	public class GabbEvent extends Event
	{
		
		public static const LOGEVENT:String = "LogEvent";
		public static const TICKEVENT:String = "TickEvent";
		public static const LOADCOMPLETE:String = "LoadComplete";
		
		public var time:uint;
		public var entry_type:uint;
		public var entry_details:String;
		
		public function GabbEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type,bubbles,cancelable);
			time = new uint();
			entry_type = new uint();
			entry_details = new String();
		}
		
		public override function clone():Event{
			return new GabbEvent(type,bubbles,cancelable);
		}
		
		public override function toString():String{
			return formatToString("GabbEvent","type","bubbles","cancelable","eventPhase");
		}
		
	}
}