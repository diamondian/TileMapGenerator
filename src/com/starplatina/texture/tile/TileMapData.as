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
		
		public function TileMapData(tileSheetBitmapData:BitmapData,textures:Array,tileWidth:int, tileHeight:int) 
		{
			_tileSheetBitmapData = tileSheetBitmapData;
			_tileWidth = tileWidth;
			_tileHeight = tileHeight;
			parseXML(textures);
		}
		
		private function parseXML(textures:Array):void
		{
			for each (var tiles:Vector.<Tile> in textures) 
			{
				var texture:XML = _textureXMLnodeTemplate.copy();
				for each (var tile:Tile in tiles) 
				{
					//sheet
					var sheetNode:XML = _sheetNodeTemplate.copy();
					sheetNode.@name = tile.idx;
					sheetNode.@x = tile.x;
					sheetNode.@y - tile.y;
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
			return _texturesXML.children();
		}

		public function get tileSheetXML():XML
		{
			return _tileSheetXML;
		}

		public function get tileSheetBitmapData():BitmapData
		{
			return _tileSheetBitmapData;
		}

	}
}