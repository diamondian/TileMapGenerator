package
{
	import flash.display.Bitmap;
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
		
		public function get fileNames():Array
		{
			return _fileNames;
		}

		public function get datas():Array
		{
			return _datas;
		}

		public function getBitmapByID(value:String):Bitmap
		{
			return new Bitmap(_datas[_fileNames.indexOf(value)] as BitmapData);
		}
		
		public static function getInstance():TileMapManager
		{
			instance ||= new TileMapManager(new shit());
			return instance;
		}
		
		
		private var _datas:Array;
		private var _fileNames:Array;
		
		public function TileMapManager(s:shit)
		{
			_datas = [];
			_fileNames = [];
		}
		
		
		
		public function set originalFiles(files:Array):void
		{			
			var _imageCreated:int;
			for (var i:int = 0; i < files.length; i++) 
			{
				var file:File = files[i] as File;
				_fileNames.push(file.name.split(".")[0]);
				var fileStream : FileStream = new FileStream();
				fileStream.open( file, FileMode.READ );
				const ba:ByteArray = new ByteArray();
				fileStream.readBytes(ba);
				var loader:Loader = new Loader();
				loader.name = i+"";
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
					function(e:Event):void {
						const bitmapdata:BitmapData = new BitmapData(LoaderInfo(e.target).width,LoaderInfo(e.target).height,true,0x0);
						bitmapdata.draw(LoaderInfo(e.target).content);  
						var index:int = int(LoaderInfo(e.target).loader.name);
						_datas[index] = bitmapdata;		
						_imageCreated++;
						if(_imageCreated == files.length){
							notifyFilePreProcessed();
						}
				});
				loader.loadBytes(ba);
			}			
		}
		
		private function notifyFilePreProcessed():void
		{
			this.dispatchEvent(new Event(FILE_PROCESSED));
		}
		
		
	}
}
class shit
{}