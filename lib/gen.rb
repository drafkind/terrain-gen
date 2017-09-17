require 'ox'

class SerializableToXml
	def getTagName
		raise "Must override Marshallable.getTagName"
	end

	def addTo(root, instance_variable)
		value = instance_variable_get(instance_variable)	
		if value.is_a?(SerializableToXml)
			root << value.to_xml
		else
			name = instance_variable.to_s
			name[0] = ''
			root[name] = value
		end
	end

	def to_xml
		root = Ox::Element.new(getTagName())
		instance_variables.map{|instance_variable| addTo(root, instance_variable) }
		root
	end
end

class Heightfield
	
	def r(low, hi)
		rand(hi-low)+low
	end

	def build(width, height, lo, hi)
		write(MapData.new(width, height, nil), lo, hi)
	end

	def write(mapData, x1, y1, x2, y2, lo, hi)
	end

	def write(mapData, lo, hi)
		write(mapData, 0, 0, mapData.width-1, mapData.height-1, lo, hi)
	end
end

class MapData
	attr_reader :width, :height

	def initialize(width, height, defaultValue = 0)
		@width = width
		@height = height
		@data = Array.new(width*height, defaultValue)
	end

	def get(x, y)
		@data[x + y*@width]
	end

	def put(x, y, v)
		@data[x + y*@width] = v
	end

	def maybePut(x, y, v)
		index = x + y*@width
		if (@data[index] != nil)
			data[index] = v
		end
	end

	def to_s
		"\n" + @data.join(",") + "\n"
	end
end

class LayerData < SerializableToXml
	def getTagName
		"data"
	end

	attr_reader :encoding, :data

	def initialize(encoding, data)
		@encoding = encoding
		@data = data
	end

	def to_xml
		root = Ox::Element.new(getTagName())
		addTo(root, :@encoding)
		root << data
		root
	end
end

class Layer < SerializableToXml
	def getTagName
		"layer"
	end
	
	attr_reader :name, :width, :height, :data

	def initialize(name, width, height, data)
		@name = name
		@width = width
		@height = height
		@data = data
	end
end

class Image < SerializableToXml
	def getTagName
		"image"
	end

	attr_reader :source, :width, :height

	def initialize(source, width, height)
		@source = source
		@width = width
		@height = height
	end
end

class TileSet < SerializableToXml
	def getTagName
		"tileset"
	end

	attr_reader :firstgid, :name, :tilewidth, :tileheight, :tilecount, :image

	def initialize(firstgid, name, tilewidth, tileheight, tilecount, image)
		@firstgid = firstgid
		@name = name
		@tilewidth = tilewidth
		@tileheight = tileheight
		@tilecount = tilecount
		@image = image
	end
end

class Map < SerializableToXml

	def getTagName
		"map"
	end

	attr_reader :orientation, :renderorder, :width, :height, :tilewidth, :tileheight, :nextobjectid, :tileset, :layer

	def initialize(orientation, renderorder, width, height, tilewidth, tileheight, nextobjectid, tileset, layer)
		@version = "1.0"
		@orientation = orientation
		@renderorder = renderorder
		@width = width
		@height = height
		@tilewidth = tilewidth
		@tileheight = tileheight
		@nextobjectid = nextobjectid
		@tileset = tileset
		@layer = layer
	end
end

doc = Ox::Document.new(:version => '1.0')

mapData = MapData.new(100, 100)

map = Map.new("orthogonal", "right-down", 100, 100, 32, 32, 1, 
	TileSet.new(1, "DungeonCrawl_ProjectUtumnoTileset", 32, 32, 3072,
		Image.new("../../../../Downloads/DungeonCrawl_ProjectUtumnoTileset.png", 2048, 1536)),
	Layer.new("Tile Layer 1", 100, 100,
		LayerData.new("csv", mapData.to_s)))
doc << map.to_xml

puts Ox.dump(doc)
