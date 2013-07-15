/**
 * 2013.7 Copyright Reserved By Blandon.Du.
 */
package com.starplatina.texture.tile
{
	import flash.display.BitmapData;

	public class TileMapData
	{
		private var _tileSheetBitmapData:BitmapData;
		
		private var _tileSheetXML:XML = <TextureAtlas imagePath="tile.png"></TextureAtlas>;
		private var _texturesXML:XML = <textures/>;
		
		private var _sheetNodeTemplate:XML = <SubTexture name="" x="" y="" width="" height=""/>
		private var _textureXMLnodeTemplate:XML = <Indexes></Indexes>;
		private var _tileNodeTemplate:XML = <Index offset="" idx="" />;
		
		private var _tileWidth:int;
		private var _tileHeight:int;
		
		public function TileMapData(tileSheetBitmapData:BitmapData,textures:Vector.<TileTexture>,tileWidth:int, tileHeight:int) 
		{
			_tileSheetBitmapData = tileSheetBitmapData;
			_tileWidth = tileWidth;
			_tileHeight = tileHeight;
			parseXML(textures);
		}
		
		private function parseXML(textures:Vector.<TileTexture>):void
		{
			for each (var tileTexture:TileTexture in textures) 
			{
				var texture:XML = _textureXMLnodeTemplate.copy();
				texture.@name = tileTexture.name;
				texture.@width = tileTexture.width;
				texture.@height = tileTexture.height;
				texture.@numberTiles = tileTexture.tiles.length;
				
				for each (var tile:Tile in tileTexture.tiles) 
				{
					//sheet
					var sheetNode:XML = _sheetNodeTemplate.copy();
					sheetNode.@name = tile.idx;
					sheetNode.@x = tile.x;
					sheetNode.@y = tile.y;
					sheetNode.@width = _tileWidth;
					sheetNode.@height = _tileHeight;
					
					_tileSheetXML.appendChild(sheetNode);
					//texture
					var tileNode:XML = _tileNodeTemplate.copy();
					tileNode.@offset = tile.offset;
					tileNode.@idx = tile.idx;
					
					texture.appendChild(tileNode);
				}
				_texturesXML.appendChild(texture);
			}
		}
		
		public function get texturesXMLList():XMLList
		{
			return _texturesXML.Indexes;
		}

		public function get tileSheetXML():XML
		{
			return _tileSheetXML;
		}
		
		public static function getXMLStr(xml:XML):String
		{
			return '<?xml version="1.0" encoding="utf-8"?>'+"\n"+xml.toXMLString();
		}

		public function get tileSheetBitmapData():BitmapData
		{
			return _tileSheetBitmapData;
		}

	}
}