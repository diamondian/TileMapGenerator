package com.starplatina.texture.tile
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class TileMapManager extends EventDispatcher
	{
		public static const FILE_PROCESSED:String = "FILE_PROCESSED";
		public static const TILE_DATA_GENERATED:String = "TILE_DATA_GENERATED";
		
		private static var instance:TileMapManager;
		
		public function get tileMapData():TileMapData
		{
			return _tileMapData;
		}

		public function get fileNames():Array
		{
			return _fileNames;
		}

		public function get datas():Array
		{
			return _datas;
		}

		public function getBitmapByID(value:String):BitmapData
		{
			return _datas[_fileNames.indexOf(value)] as BitmapData;
		}
		
		public static function getInstance():TileMapManager
		{
			instance ||= new TileMapManager(new shit());
			return instance;
		}
		
		private var _datas:Array;
		private var _fileNames:Array;
		private var _tileMapData:TileMapData;
		private var _vector:Vector.<uint>;
		
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
		
		private function notifyTileDataGenerated():void
		{
			this.dispatchEvent(new Event(TILE_DATA_GENERATED));
		}
		
		public function buildTileMap(sheetWidth:int,sheetHeight:int,tileWidth:int, tileHeight:int,threshold:int = 0x00):void
		{
			const spriteSheetData:BitmapData = new BitmapData(sheetWidth,sheetHeight,true,0x0);
			const hNumber:int = sheetWidth / tileWidth;
			var tiles:Vector.<Tile> = new Vector.<Tile>();
			var textures:Array = [];
			for (var i:int = 0; i < _datas.length; i++) 
			{
				var data:BitmapData = _datas[i] as BitmapData;
				textures.push(getTilesFromBitmapData(data,tileWidth,tileHeight,threshold));
				tiles = tiles.concat(textures[i]); 
			}
			for (i = 0; i < tiles.length; i++) 
			{
				var matrix:Matrix = new Matrix();
				var indexX:int = i % hNumber;
				var indexY:int = Math.floor(i / hNumber);
				
				tiles[i].idx = getNumbericID(i);
				tiles[i].x = indexX * tileWidth;
				tiles[i].y = indexY * tileHeight;
				
				matrix.translate(tiles[i].x,tiles[i].y);
				spriteSheetData.draw(tiles[i].data,matrix);
			}
			_tileMapData = new TileMapData(spriteSheetData,textures,tileWidth, tileHeight);
			
			notifyTileDataGenerated()
		}
		
		private function getNumbericID(number:int,digits:int = 6):String
		{
			var str:String = number+"";
			if(str.length > digits){
				digits = str.length + 1;
			}
			while(str.length < digits){
				str = "0"+str;
			}
			return str;
		}
		
		private function getTilesFromBitmapData(data:BitmapData,tileWidth:int, tileHeight:int,threshold:int):Vector.<Tile>
		{
			const hNumber:int = Math.ceil(data.width / tileWidth);
			const vNumber:int = Math.ceil(data.height / tileHeight);
			
			var squareWidth:Number;
			var squareHeight:Number;
			
			var tiles:Vector.<Tile> = new Vector.<Tile>();
			for (var i:int = 0; i < hNumber; i++) 
			{
				for (var j:int = 0; j < vNumber; j++) 
				{
					var bmd:BitmapData = new BitmapData(tileWidth,tileHeight,true,0x0);
					var matrix:Matrix = new Matrix();
					matrix.translate(-i * tileWidth,-j * tileHeight);
					bmd.draw(data,matrix);
					
					if(!isOpaque(bmd,threshold)){
						var tile:Tile = new Tile();
						tile.offset = j * vNumber + i;
						tile.data = bmd;
						tiles.push(tile);
					}
				}
			}
			return tiles;
		}		
		
		private function isOpaque(bmd:BitmapData,threshold:int):Boolean
		{
			_vector = bmd.getVector(bmd.rect);
			var a:int;
			for each (var argb:uint in _vector) 
			{
				if(threshold < ( argb >> 24 & 0xFF ))
				{
					return false;
				}
			}
			return true;
		}
		
	}
}
class shit
{}