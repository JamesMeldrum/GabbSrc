package Utils
{
	import Events.GabbEvent;
	
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.events.EventDispatcher;
	
	public class WordReferee extends EventDispatcher
	{
		private var submitted_words:Array;
		private var dictionary_words:Array;
		public var dicLoader:LoaderMax;
		
		public function WordReferee()
		{
			// Init dictionaries
			submitted_words = new Array();
			loadDictionary();
		}
		
		private function loadDictionary():void{
			// Loads a dictionary in via GAE
			var serve_URL:String = "http://gabbsandbox.appspot.com/Gabb1/fb_serv/serve_dict.txt";
			dicLoader = new LoaderMax({name:"dicLoader",onComplete:buildDictionary,onError:errorHandler});
			dicLoader.append (new DataLoader(serve_URL,{name:"gabDic",format:"text"}));
			dicLoader.load();
		}
		
		private function buildDictionary(e:LoaderEvent):void{
			var i:int =0;
			var j:int =0;
			var dicObj:String = dicLoader.getContent("gabDic");
			dictionary_words = dicObj.split("&");
			
			for(i=1;i<dictionary_words.length;i++){
				dictionary_words[i-1] = new Array;
				dictionary_words[i-1] = dictionary_words[i].split("/");
			}
			this.dispatchEvent(new GabbEvent(GabbEvent.LOADCOMPLETE));
		}
		
		private function errorHandler(event:LoaderEvent):void{
			trace("error occured with " + event.target + ": " + event.text);
		}
		
		public function checkGabbWord(word:String):Boolean{
			for(var i:int =0; i<submitted_words.length;i++){
				if (word == submitted_words[i]){
					return false;
				}
			}

			const ASCII_OFFSET:int = 65;
			var code_of_first_letter_of_word:int = new int( word.charCodeAt(0)-ASCII_OFFSET);
			
			for (var j:int =0; j<dictionary_words[code_of_first_letter_of_word].length;j++){
				if (word == dictionary_words[code_of_first_letter_of_word][j]){
					submitted_words.push(word);
					return true;
				}
			}
			return false;
		}
	}
}