package
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class TileMapManager
	{
		private static var instance:TileMapManager;
		
		public static function getInstance():TileMapManager
		{
			instance ||= new TileMapManager(new shit());
			return instance;
		}
		
		
		private var _datas:Vector.<BitmapData>;
		private var _fileNames:Vector.<String>;
		
		public function TileMapManager(s:shit)
		{
			_datas = new Vector.<BitmapData>();
			_fileNames = new Vector.<String>();
		}
		
		public function set originalFiles(files:Array):void
		{
			var fileStream : FileStream
			var loader:Loader;
			var file:File;
			for (var i:int = 0; i < files.length; i++) 
			{
				file = files[i] as File;
			
				fileStream = new FileStream();
				fileStream.open( file, FileMode.READ );
				const ba:ByteArray = new ByteArray();
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):void {
					const bitmapdata:BitmapData = new BitmapData(loader.contentLoaderInfo.width,loader.contentLoaderInfo.height,true,0x0);
					bitmapdata.draw(loader);    
					
				});
				loader.loadBytes(ba);
				
			}
			
		}
		
		
	}
}
class shit
{}