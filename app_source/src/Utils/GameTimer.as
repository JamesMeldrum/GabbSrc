package Utils
{
	import Events.GabbEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class GameTimer extends EventDispatcher
	{

		private var timer_obj:Timer;
		private var on_second:Boolean
		private var second_count:uint;
		private var half_second_count:uint;
		public function GameTimer(timer_length:int)
		{
			const tick_inter:Number = 500;
			var rep_count:int = 240;
			timer_obj = new Timer(tick_inter,rep_count);
			timer_obj.addEventListener(TimerEvent.TIMER,tick_timer);
			timer_obj.addEventListener(TimerEvent.TIMER_COMPLETE,stopTimer);
			on_second = new Boolean(true);
			half_second_count = new uint();
			
		}
		
		public function beginTimer():void{
			timer_obj.start();
		}
		
		private function tick_timer(e:TimerEvent):void{
			var tick_event:GabbEvent = new GabbEvent(GabbEvent.TICKEVENT);
			half_second_count++
			tick_event.time = half_second_count;
			this.dispatchEvent(tick_event);
		}
		
		private function stopTimer(e:TimerEvent):void{
			this.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		}
	}
}