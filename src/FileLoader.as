package
{
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import mx.utils.StringUtil;
	
	import fl.controls.TextArea;
	
	public class FileLoader extends Sprite
	{
		private var text:TextArea;
		
		private const JSONURL:String="assest/MOVIE.txt";
		
		private var dataList:Array = []; 
		private var loadIndex:int=0;
		public function FileLoader()
		{
			initUI();
			loadJSON();
		}
		
		private function clickLoad(event:MouseEvent):void
		{
//			file.download();
		}
		
		private function loadJSON():void
		{
			var request:URLRequest = new URLRequest(JSONURL);
			request.method = URLRequestMethod.GET;
			request.data = this.loaderInfo.parameters.content;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			loader.addEventListener(Event.COMPLETE, complete);
			loader.load(request);
		}
		
		private function ioError(event:IOErrorEvent):void
		{
			appendMessage("配置文件加载失败？？？");
		}
		
		private function complete(event:Event):void
		{
			dataList = [];
			
			var loader:URLLoader = event.target as URLLoader;
			var format:String=String(loader.data).replace(/\r/g, "").replace(/\n/g, "").replace(/NumberLong/g, "");
			
			while(format.indexOf("(") >= 0)
			{
				var left:int = format.indexOf("(");
				var right:int = format.indexOf(")");
				var str:String = format.slice(left, right+1);
				var rep:String = str.replace(/"/g, "").replace(/\(/g, '"').replace(/\)/g, '"');
				format = format.replace(str, rep);
			}
			
			var position:int=0;
			var index:int=0;
			while((position = format.indexOf("/* "+index+" */")) >= 0)
			{
				if(position == 0)
					format = format.replace("/* "+index+" */", "");
				else
					format = format.replace("/* "+index+" */", "#");
					
				index++;
			}
			
			dataList = format.replace(/  /g, "").split("#");
			
			appendMessage("配置文件加载完成！！！\n");
			appendMessage("开始下载文件/n");
			startLoad(loadIndex=0);
		}
		
		private function startLoad(index:int):void
		{
			appendMessage("");
			var data:Object = JSON.parse(dataList[index]);
//			var data:Object = dataList[index];
			var resFileInfo:Object = data.resFileList[0].resFileInfo;
			var url:String = "http://221.228.74.42"+"/"+resFileInfo.localGroupName+"/"+resFileInfo.localFileName;
			var ar:Array = String(resFileInfo.localFileName).split("/");
			var name:String = ar[ar.length-1];
			loadFile(url, name);
			loadIndex++;
		}
		
		private function loadFile(url:String, fileName:String):void
		{
			var request:URLRequest = new URLRequest(url);
			var file:File = new File(File.desktopDirectory.resolvePath(fileName).nativePath);
//			var fileList:FileReferenceList = new FileReferenceList();
//			fileList.
			file.addEventListener(Event.OPEN, openHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
			file.download(request, fileName);
		}
		
		private function openHandler(event:Event):void
		{
			
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			startLoad(loadIndex);
		}
		
		private function securityError(event:SecurityErrorEvent):void
		{
			
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			appendMessage("当前下载进度："+event.bytesLoaded+"/"+event.bytesTotal+"\n");
		}
		
		private function completeHandler(event:Event):void
		{
			startLoad(loadIndex);
		}
		
		public function appendMessage(data:String):void
		{
			text.appendText(data);
			
			text.verticalScrollPosition = text.maxVerticalScrollPosition;
		}
		
		private function initUI():void
		{
			var label:TextField = new TextField();
			label.x = 30;
			label.y = 50;
			addChild(label);
			label.selectable = false;
			var format:TextFormat = new TextFormat("宋体", 14);
			label.defaultTextFormat = format;
			label.text = "上传文件：";
			
			var input:TextField = new TextField();
			input.x = label.x + 65;
			input.y = 50;
			addChild(input);
			input.border = true;
			input.type = TextFieldType.INPUT;
			input.width = 300;
			input.height = 25;
			
			var btn:Sprite = new Sprite();
			btn.x = input.x + 320;
			btn.y = 50;
			addChild(btn);
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.CLICK, clickLoad);
			
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xcccccc);
			bg.graphics.drawRoundRect(0, 0, 55, 25, 5);
			bg.graphics.endFill();
			btn.addChild(bg);
			
			var tf:TextFormat = new TextFormat("宋体", 13);
			label.defaultTextFormat = tf;
			label.text = "上传文件：";
			
			var txt:TextField = new TextField();
			txt.width = 45;
			txt.height = 22;
			txt.x = (btn.width-txt.width)/2;
			txt.y = (btn.height-txt.height)/2;
			btn.addChild(txt);
			txt.defaultTextFormat = tf;
			txt.mouseEnabled = false;
			txt.text = "开  始";
//			var txt:
			
//			progressTxt  = new TextField();
//			progressTxt.w
			
			text = new TextArea();
			text.width = 300;
			text.height = 200;
			text.enabled = true;
			text.editable = false;
			text.horizontalScrollPolicy = "off";
			text.verticalScrollPolicy = "on";
			text.wordWrap = true;
			text.x = input.x;
			text.y = input.y+50;
			this.addChild(text);
			text.setStyle("textFormat", format);
		}
	}
}