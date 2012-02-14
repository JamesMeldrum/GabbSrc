// Returns a string for a given AS3 'key code'

package Utils
{
	public class ASCII_matcher
	{
		public function ASCII_matcher()
		{
			// No real need for a constructor
		}
		
		public function get_letter(key_code:uint):String{
			return String.fromCharCode(key_code);
		}
	}
}