package Game
{
	import Events.GabbEvent;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Game_Disp_Objs
	{
		public var _stage_ref:Stage;
		public var disp_list:Array;
		private var custom_disp_list:Array;
		private var custom_text_list:Array;
		private var details_array:Array; 
		
		public function Game_Disp_Objs(stage_ref:Stage)
		{
			_stage_ref = stage_ref;
		}
		
		public function init_disp_objs():void{
			var w:int = _stage_ref.stageWidth;
			var h:int = _stage_ref.stageHeight;
			details_array = init_ref_array();
			disp_list = new Array();
			for(var i:int =0; i<details_array.length;i++){
				disp_list.push(init_disp_obj(w,h,details_array[i],i));
			}
			custom_disp_list = new Array();
			add_custom_disp_components();
			resize_custom_ui_components();
			custom_text_list = new Array();
			add_text_disp_components();
		}
		
		private function add_custom_disp_components():void{
			
			var user_picture:Sprite = new Sprite();
			custom_disp_list.push(user_picture);
			disp_list[1].addChild(user_picture);
			
			user_picture = new Sprite();
			custom_disp_list.push(user_picture);
			disp_list[2].addChild(user_picture);
		}
		
		private function add_text_disp_components():void{
			
			var common_TF:TextFormat = new TextFormat();
			common_TF.color = 0xFFFFFF;
			common_TF.font = "Myriad Pro";
			common_TF.size = 20;
			
			var name_text:TextField = new TextField();
			name_text.text = "James";
			name_text.height = 35;
			name_text.x = 5;
			name_text.y = custom_disp_list[0].y + custom_disp_list[0].height +5;
			name_text.setTextFormat(common_TF);
			
			var rank_test:TextField = new TextField();
			rank_test.text = "Rep: 1234";
			rank_test.height = 35;
			rank_test.x = 5;
			rank_test.y = name_text.y + name_text.height;
			rank_test.setTextFormat(common_TF);
			
			custom_text_list.push(name_text);
			custom_text_list.push(rank_test);
			disp_list[1].addChild(name_text);
			disp_list[1].addChild(rank_test);
			
			name_text = new TextField();
			name_text.text = "James";
			name_text.height = 35;
			name_text.x = 5;
			name_text.y = custom_disp_list[0].y + custom_disp_list[0].height +5;
			name_text.setTextFormat(common_TF);
			
			rank_test = new TextField();
			rank_test.text = "Rep: 1234";
			rank_test.height = 35;
			rank_test.x = 5;
			rank_test.y = name_text.y + name_text.height;
			rank_test.setTextFormat(common_TF);
			
			custom_text_list.push(name_text);
			custom_text_list.push(rank_test);
			disp_list[2].addChild(name_text);
			disp_list[2].addChild(rank_test);
			
		}
		
		private function resize_text_disp_components():void{
			custom_text_list[0].y = custom_disp_list[0].y + custom_disp_list[0].height+5;
			custom_text_list[1].y = custom_text_list[0].y + custom_text_list[0].height;
			custom_text_list[2].y = custom_disp_list[0].y + custom_disp_list[0].height+5;
			custom_text_list[3].y = custom_text_list[0].y + custom_text_list[0].height;
		}
		
		public function update_scores(update_val:String,update_type:int):void{
			if(update_type){
				custom_text_list[3].text = update_val;
			}else{
				custom_text_list[1].text = update_val;
			}
		}
		
		private function resize_custom_ui_components():void{
			for(var i:int = 0;i<custom_disp_list.length;i++){
				custom_disp_list[i].graphics.clear();
				var user_pic_width:int = new int(disp_list[i+1].width*9/10);
				var user_pic_height:int = new int(disp_list[i+1].height*9/10 );
				var user_pic_border_x:int = new int(disp_list[i+1].width-user_pic_width);
				var user_pic_border_y:int = new int(10);

				if ( user_pic_width > user_pic_height   ){
					user_pic_width = user_pic_height;
					user_pic_border_x = new int(disp_list[i+1].width-user_pic_width);
				} 
				
				custom_disp_list[i].x = user_pic_border_x/2;
				custom_disp_list[i].y = user_pic_border_y;
				custom_disp_list[i].graphics.beginFill(0xFFFFFF);
				custom_disp_list[i].graphics.drawRect(0,0,user_pic_width,user_pic_width);
				custom_disp_list[i].graphics.endFill();
			}	
		}
		
		public function get_disp_ref(i:int):Sprite{
			return disp_list[i];
		}
		
		public function init_ref_array():Array{
			// All heights are stored as percentages relative to
			// the stage height and width
			// Store an array of point objects 
			// x,y,l,w relative to 100
			// Treating an array as an enum
			// 0 - bg
			// 1 - left_bar
			// 2 - right_bar 
			// 3 - tiles
			// 4 - word_station
			// 5 - left_details
			// 6 - right_details
			
			var ref_array:Array = new Array();
			var refPoint:Object = new Object();
			var innerBorder:int = new int(5);
			var outerBorder:int = new int(5);
			
			// 0 - bg
			refPoint.x = new int(0);
			refPoint.y = new int(0);
			refPoint.w = new int(100);
			refPoint.h = new int(100);
			refPoint.color = 0x5BA9D9;
			refPoint.rounding = 0;
			ref_array.push(refPoint);	
			
			// 1 - left_bar
			refPoint = new Object();
			refPoint.w = new int(15);
			refPoint.h = new int(refPoint.w);
			refPoint.x = outerBorder;
			refPoint.y = new int(100 - outerBorder - 60);
			refPoint.color = 0x254EA5;
			refPoint.rounding = 24;			
			ref_array.push(refPoint);
			
			// 2 - right_bar
			refPoint = new Object();
			refPoint.w = new int(15);
			refPoint.h = new int(refPoint.w);
			refPoint.x = 100 - outerBorder - refPoint.w;
			refPoint.y = new int(100 - outerBorder - 60);
			refPoint.color = 0x254EA5;
			refPoint.rounding = 24;	
			ref_array.push(refPoint);
			
			// 3 - tiles
			refPoint = new Object();
			refPoint.w = new int(100 - outerBorder - 15 - innerBorder - innerBorder - 15 - outerBorder);
			refPoint.h = new int(60);
			refPoint.x = outerBorder + 15 + innerBorder;
			refPoint.y = 100 - outerBorder - refPoint.h;
			refPoint.color = 0x254EA5;
			refPoint.rounding = 24;	
			ref_array.push(refPoint);
			
			// 4 - word_station
			refPoint = new Object();
			refPoint.w = new int(100 - outerBorder - outerBorder); 
			refPoint.h = new int(20);
			refPoint.x = outerBorder;
			refPoint.y = outerBorder;
			refPoint.color = 0x254EA5;
			refPoint.rounding = 24;	
			ref_array.push(refPoint);
			
			// 5 - left_details
			refPoint = new Object();
			refPoint.w = new int(20);
			refPoint.h = new int(15);
			refPoint.x = outerBorder;
			refPoint.y = outerBorder;
			refPoint.color = 0x254EA5;
			refPoint.rounding = 24;	
			ref_array.push(refPoint);
			
			// 6 - right_details
			refPoint = new Object();
			refPoint.w = new int(20);
			refPoint.h = new int(15);
			refPoint.x = 100 - outerBorder - refPoint.w;
			refPoint.y = outerBorder;
			refPoint.color = 0x254EA5;
			refPoint.rounding = 24;	
			ref_array.push(refPoint);
			
			//7 Feature Box
			refPoint = new Object();
			//refPoint.w = new int(20);
			//refPoint.h = new int(20);
			refPoint.w = new int(0);
			refPoint.h = new int(0);
			refPoint.x = new int(100 - refPoint.w);
			refPoint.y = new int(100 - refPoint.h);
			refPoint.color = 0x000000;
			refPoint.rounding = 0;	
			ref_array.push(refPoint);
			
			return ref_array;
		}

		private function init_disp_obj(w:int,h:int,point_obj:Object,i:int):Sprite{
			var disp_obj:Sprite = new Sprite();
			var var_width:int = w * Number(point_obj.w/100);
			var var_height:int = h * Number(point_obj.h/100);
			var var_x:int = w * Number(point_obj.x/100);
			var var_y:int = h * Number(point_obj.y/100);
			
			if (i==1 || i==2){
				var_height = var_height + 50*3;
			}
			
			disp_obj.x = var_x;
			disp_obj.y = var_y;
			disp_obj.graphics.beginFill(point_obj.color,1);
			disp_obj.graphics.drawRoundRect(0,0,var_width,var_height,point_obj.rounding,point_obj.rounding);
			disp_obj.graphics.endFill()
			_stage_ref.addChild(disp_obj);
			return disp_obj;
		}
		
		public function resize_display_elements(e:Event):void{
			var h:int = _stage_ref.stageHeight;
			var w:int = _stage_ref.stageWidth;
			
			if(e.type == "resize"){
				for(var i:int =0; i<details_array.length;i++){
					resize_display_element(w,h,details_array[i],disp_list[i],i);
				}
				resize_custom_ui_components();
				resize_text_disp_components();

			}
			if(e.type == "focus_out"){
				trace ("Focus-out");
				// Show warning - do not pause the game
			}
		}
		
		private function resize_display_element(w:int,h:int,point_obj:Object,disp_sprite:Sprite,i:int):void{
			var var_width:int = w * Number(point_obj.w/100);
			var var_height:int = h * Number(point_obj.h/100);
			var var_x:int = w * Number(point_obj.x/100);
			var var_y:int = h * Number(point_obj.y/100);
			
			if (i==1 || i==2){
				var_height = var_height + 50*3;
			}
			
			// Update position of Sprite
			disp_sprite.x = var_x;
			disp_sprite.y = var_y;
			
			// Clear graphics object
			disp_sprite.graphics.clear();
			
			// Draw new one
			disp_sprite.graphics.beginFill(point_obj.color);
			disp_sprite.graphics.drawRoundRect(0,0,var_width,var_height,point_obj.rounding,point_obj.rounding);
			disp_sprite.graphics.endFill();
		}

		public function destruct_disp_objs():void{
			for (var i:int=0; i<details_array.length;i++){
				// Remove all objs from the stage
				// Reference all details and disp objs to null
			}
		}
		
		public function updateTimer(e:GabbEvent):void{
			// UpdateTimer
			// Called every 500ms
		}		
		public function updateScore(e:GabbEvent):void{
			// UpdateScore
		}
	}
}