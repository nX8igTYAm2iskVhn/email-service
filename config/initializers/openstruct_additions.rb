require 'ostruct'

class Object
 def to_openstruct
   self
 end
end

class Array
 def to_openstruct
   map{ |el| el.to_openstruct }
 end
end

class Hash
 def to_openstruct
   mapped = {}
   each{ |key,value| mapped[key] = value.to_openstruct }
   OpenStruct.new(mapped)
 end
end

class OpenStruct
  def to_hash
    @table.inject({}) do |h, (k,v)|
      h[k] = v.is_a?(OpenStruct) ? v.to_hash : v
      h[k] = h[k].map {|i| i.is_a?(OpenStruct) ? i.to_hash : i } if h[k].is_a?(Array)
      h
    end
  end
  def symbolize_keys
    self.to_hash.symbolize_keys
  end
  def [](v)
    send(v)
  end
end
