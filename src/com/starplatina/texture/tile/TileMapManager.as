/**
 * 2013.7 Copyright Reserved By Blandon.Du.
 */
package com.starplatina.texture.tile
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
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.graphics.codec.PNGEncoder;

	public class TileMapManager extends EventDispatcher
	{
		public static const START_READING_FILES:String = "START_READING_FILES";
		public static const START_WRITING_FILES:String = "START_WRITING_FILES";
		public static const FILE_PROCESSED:String = "FILE_PROCESSED";
		public static const NOTIFYCLOSEPOPUPS:String = "NOTIFYCLOSEPOPUPS";
		public static const TILE_DATA_GENERATED:String = "TILE_DATA_GENERATED";
		public static const PREVIEW_DATA_GENERATED:String = "PREVIEW_DATA_GENERATED";
		
		private static var instance:TileMapManager;
		private var _output:File;
		
		public function get tileMapData():TileMapData
		{
			return _tileMapData;
		}

		public function get previewOutcome():Bitmap
		{
			return _tileMapData?(new Bitmap(_tileMapData.tileSheetBitmapData)):null;
		}

		public function get fileNames():Array
		{
			return _fileNames;
		}

		public function get datas():Array
		{
			return _bitmapDatas;
		}

		public function getBitmapByID(value:String):BitmapData
		{
			return _bitmapDatas[_fileNames.indexOf(value)] as BitmapData;
		}
		
		public static function getInstance():TileMapManager
		{
			instance ||= new TileMapManager(new shit());
			return instance;
		}
		
		private var _bitmapDatas:Array;
		private var _fileNames:Array;
		private var _tileMapData:TileMapData;
		private var _vector:Vector.<uint>;
		private var _numberTilesTotal:int;
		private var _scaleFactor:Number;
		private var _fsIndexes:Array;
		private var _imageCreated:int;
		private var _numberFiles:uint;
		private var _timeDelay:Number = 1;
		
		public function TileMapManager(s:shit)
		{
			_bitmapDatas = [];
			_fileNames = [];
			_fsIndexes = [];
		}
		
		public function set originalFiles(files:Array):void
		{			
			notifyFileReadingFiles();
			
			_numberFiles = files.length;
			
			setTimeout(function():void{
				for (var i:int = 0; i < files.length; i++) 
				{
					var file:File = files[i] as File;
					_fileNames.push(file.name.split(".")[0]);
					var fileStream : FileStream = new FileStream();
					fileStream.addEventListener(Event.COMPLETE,onFileReaded);
					_fsIndexes.push(fileStream)
					fileStream.openAsync( file, FileMode.READ );
				}			
			},_timeDelay * 1000);
		}
		
		protected function onFileReaded(event:Event):void
		{
			const fileStream:FileStream = FileStream(event.target);
			const ba:ByteArray = new ByteArray();
			fileStream.readBytes(ba);
			var loader:Loader = new Loader();
			loader.name = _fsIndexes.indexOf(fileStream)+"";
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			loader.loadBytes(ba);
		}
		
		protected function onImageLoaded(event:Event):void
		{
			const bitmapdata:BitmapData = new BitmapData(LoaderInfo(event.target).width,LoaderInfo(event.target).height,true,0x0);
			bitmapdata.draw(LoaderInfo(event.target).content);  
			var index:int = int(LoaderInfo(event.target).loader.name);
			_bitmapDatas[index] = bitmapdata;		
			_imageCreated++;
			if(_imageCreated == _numberFiles){
				notifyFilePreProcessed();
			}
		}
		
		private function notifyFileReadingFiles():void
		{
			this.dispatchEvent(new Event(START_READING_FILES));
		}
		
		private function notifyFileWritingFiles():void
		{
			this.dispatchEvent(new Event(START_WRITING_FILES));
		}
		
		private function notifyFilePreProcessed():void
		{
			this.dispatchEvent(new Event(FILE_PROCESSED));
		}
		
		private function notifyClosePopups():void
		{
			this.dispatchEvent(new Event(NOTIFYCLOSEPOPUPS));
		}
		
		private function notifyPreviewGenerated():void
		{
			this.dispatchEvent(new Event(PREVIEW_DATA_GENERATED));
		}
		
		private function notifyTileFilesGenerated():void
		{
			this.dispatchEvent(new Event(TILE_DATA_GENERATED));
		}
		
		public function buildTileMap(sheetWidth:int,sheetHeight:int,tileWidth:int, tileHeight:int,output:File,threshold:int = 0x00,scaleFactor:Number = 1,save:Boolean = false):void
		{
			notifyFileWritingFiles();
			
			setTimeout(function():void{
			
			_output = output;
			_scaleFactor = scaleFactor;
			
			resizeTextures(_scaleFactor);
			
			const spriteSheetData:BitmapData = new BitmapData(sheetWidth,sheetHeight,true,0x0);
			const hNumber:int = sheetWidth / tileWidth;
			var tiles:Vector.<Tile> = new Vector.<Tile>();
			var textures:Vector.<TileTexture> = new Vector.<TileTexture>();
			for (var i:int = 0; i < _bitmapDatas.length; i++) 
			{
				var data:BitmapData = _bitmapDatas[i] as BitmapData;
				
				const tileTexture:TileTexture = new TileTexture();
				tileTexture.name = _fileNames[i];
				tileTexture.width = data.width;
				tileTexture.height = data.height;
				tileTexture.tiles = getTilesFromBitmapData(data,tileWidth,tileHeight,threshold);
				
				textures.push(tileTexture);
				tiles = tiles.concat(tileTexture.tiles); 
			}
			for (i = 0; i < tiles.length; i++) 
			{
				var matrix:Matrix = new Matrix();
				var indexX:int = i % hNumber;
				var indexY:int = Math.floor(i / hNumber);
				
				tiles[i].x = indexX * tileWidth;
				tiles[i].y = indexY * tileHeight;
				
				if(tiles[i].y + tileHeight > spriteSheetData.height){
					Alert.show("Size of sprite sheet is not big enough to contain all tiles,please try to use a bigger size of it or reduce tile size instead.");
					notifyClosePopups();
					return;
				}
				
				matrix.translate(tiles[i].x,tiles[i].y);
				spriteSheetData.draw(tiles[i].data,matrix);
			}
			_tileMapData = new TileMapData(spriteSheetData,textures,tileWidth, tileHeight);
			
			if(save)
			{
				saveFiles();
			}
			else
			{
				notifyPreviewGenerated();
			}
			
			},_timeDelay * 1000);
		}
		
		private function resizeTextures(_scaleFactor:Number):void
		{
			const newBMDs:Array = [];
			for each (var bitmapdata:BitmapData in _bitmapDatas) 
			{
				var matrix:Matrix = new Matrix();
				matrix.scale(_scaleFactor, _scaleFactor);
				
				var newBMD:BitmapData = new BitmapData(bitmapdata.width * _scaleFactor, bitmapdata.height * _scaleFactor, true, 0x0);
				newBMD.draw(bitmapdata, matrix, null, null, null, true);
				newBMDs.push(newBMD);
			}
			_bitmapDatas = newBMDs;
		}
		
		private function saveFiles():void
		{
			var spriteSheet : FileStream = new FileStream();
			var spriteSheetXML : FileStream = new FileStream();
			const pngFile:File = _output.resolvePath("tile.png");
			const mainXML:File = _output.resolvePath("tile.xml");
			
			const png:PNGEncoder = new PNGEncoder();
			const ba:ByteArray = png.encode(_tileMapData.tileSheetBitmapData);
			
			const textureXMLList:XMLList = _tileMapData.texturesXMLList;
			
			try{
				spriteSheet.open(pngFile,FileMode.WRITE);
				spriteSheet.writeBytes(ba);
				spriteSheet.close();
				
				spriteSheetXML.open(mainXML,FileMode.WRITE);
				spriteSheetXML.writeUTFBytes(TileMapData.getXMLStr(_tileMapData.tileSheetXML));
				spriteSheet.close();
				
				for each (var xml:XML in textureXMLList) 
				{
					const fileName:String = xml.@name + ".xml";
					const textureXML:File = _output.resolvePath(fileName);
					const fs:FileStream = new FileStream();
					fs.open(textureXML,FileMode.WRITE);
					fs.writeUTFBytes(TileMapData.getXMLStr(xml));
					fs.close();
				}
				
				notifyTileFilesGenerated();
				
			}catch(error:Error){
				Alert.show(error.message);
			}
				
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
						tile.offset = j * hNumber + i;
						tile.idx = getNumbericID(_numberTilesTotal);
						tile.data = bmd;
						tiles.push(tile);
						
						_numberTilesTotal++;
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