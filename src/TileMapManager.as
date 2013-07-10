package
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class TileMapManager extends EventDispatcher
	{
		private static var instance:TileMapManager;
		public static const FILE_PROCESSED:String = "FILE_PROCESSED";
		
		public static function getInstance():TileMapManager
		{
			instance ||= new TileMapManager(new shit());
			return instance;
		}
		
		
		private var _datas:Array;
		private var _fileNames:Vector.<String>;
		
		public function TileMapManager(s:shit)
		{
			_datas = [];
			_fileNames = new Vector.<String>();
		}
		
		public function get sampleData():BitmapData
		{
			if(_datas.length)return null;
			return _datas[0] as BitmapData;
		}
		
		public function set originalFiles(files:Array):void
		{			
			
			for (var i:int = 0; i < files.length; i++) 
			{
				var file:File = files[i] as File;
				_fileNames.push(file.name);
				var fileStream : FileStream = new FileStream();
				fileStream.open( file, FileMode.READ );
				const ba:ByteArray = new ByteArray();
				fileStream.readBytes(ba);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.parameters={};
				loader.contentLoaderInfo.parameters["id"] = i;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
					function(e:Event):void {
						const bitmapdata:BitmapData = new BitmapData(LoaderInfo(e.target).width,LoaderInfo(e.target).height,true,0x0);
						bitmapdata.draw(LoaderInfo(e.target).content);  
						var index:int = LoaderInfo(e.target).loader;
						_datas[index] = bitmapdata;						
						if(index == files.length - 1){
							this.dispatchEvent(new Event(FILE_PROCESSED));
						}
				});
				loader.loadBytes(ba);
			}			
		}
		
		
	}
}
class shit
{}