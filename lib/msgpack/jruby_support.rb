require 'msgpack'

if /java/ =~ RUBY_PLATFORM
  class Array
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class Bignum
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class FalseClass
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class Fixnum
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class Float
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class Hash
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class NilClass
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class String
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class Symbol
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end

  class TrueClass
    def to_msgpack(io=nil)
      return MessagePack.pack(self) unless io
      io << MessagePack.pack(self)
      nil
    end
  end
end
