// Global vars
resX = 0;
resY = 0;

// Global functions

// FB API 
FB.init({
	appId  : 'APP ID',
});


// Re-size listener
function reSize() {
	document.getElementById('output').innerHTML = "HTML Content Width: " + window.innerWidth + " Height: " + window.innerHeight;
	console.log(window.innerWidth + ' x ' + window.innerHeight);
	$('div#container').css('height',window.innerHeight+'px');
	$('div#container').css('width',window.innerWidth+'px')
	resX = window.innerWidth;
	resY = window.innerHeight;
}

   reSize();
   window.onresize = reSize;
   
// Content Manager
   function changeStates(from_state,to_state){
	   // Load to_state
	   if(loadState(to_state)){
		   console.log("Successfully loaded state: "+to_state);
	   }else{
		   console.log("Error loading state: "+to_state);
	   }
	   // Unload to_state
	   if( unloadState(from_state) ){
		   console.log("Successfully loaded state: "+from_state);
	   }else{
		   console.log("Error loading state: "+from_state);
	   }
   }
   
   function loadState(state_enum){
	   // Load JS
	   loadJS(state_enum);
	   // Load CSS
	   loadCSS(state_enum);
   }
   
   function unloadState(state_enum){
	   // Unload JS
	   unloadJS(state_enum);
	   // Unload CSS
	   unloadCSS(state_enum);
	   var jsArray = document.getElementsByTagName('script');
   }
   
   function loadJS(state_enum){
	   var fileref = document.createElement('script');
	   var js_source = "{{=host_domain}}/js_"+state_enum+".js"
	   fileref.setAttribute('type','text/javascript');
	   fileref.setAttribute('src',js_source)
	   document.getElementsByTagName("head")[0].appendChild(fileref);
   }
   
   function test_call(){
	   alert("Called from fuckface")
   }
   