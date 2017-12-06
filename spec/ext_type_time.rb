# encoding: ascii-8bit

module MessagePack
  module ExtType
    module Time
      UINT32_MAX = 2 ** 32 - 1
      UINT34_MAX = 2 ** 34 - 1
      MASK_UPPER32_OF_64BIT = 0x00000000bffffffff
      MASK_UPPER30_OF_32BIT = 0x03

      EXT_TYPE_TIME_ID = -1

      # s: system-dependent int16_t, n: big-endian 16bit integer
      RUNNING_ON_BIG_ENDIAN = [1].pack("s") == [1].pack("n")

      def self.generate(time)
        unix_time = time.to_i
        nsec = time.nsec
        if nsec == 0 && unix_time <= UINT32_MAX
          # timestamp 32 stores the number of seconds that have elapsed since 1970-01-01 00:00:00 UTC
          # in an 32-bit unsigned integer:
          # +--------+--------+--------+--------+--------+--------+
          # |  0xd6  |   -1   |   seconds in 32-bit unsigned int  |
          # +--------+--------+--------+--------+--------+--------+
          # Timestamp 32 format can represent a timestamp in [1970-01-01 00:00:00 UTC, 2106-02-07 06:28:16 UTC) range. Nanoseconds part is 0.
          [0xd6, EXT_TYPE_TIME_ID, unix_time].pack('CcN')
        elsif unix_time <= UINT34_MAX
          # timestamp 64 stores the number of seconds and nanoseconds that have elapsed since 1970-01-01 00:00:00 UTC
          # in 32-bit unsigned integers:
          # +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
          # |  0xd7  |   -1   |nanoseconds in 30-bit unsigned int |  seconds in 34-bit unsigned int   |
          # +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
          # Timestamp 64 format can represent a timestamp in [1970-01-01 00:00:00.000000000 UTC, 2514-05-30 01:53:04.000000000 UTC) range.
          data = (nsec << 34) | unix_time
          uint32_1 = data >> 32
          uint32_2 = data & MASK_UPPER32_OF_64BIT
          [0xd7, EXT_TYPE_TIME_ID, uint32_1, uint32_2].pack('CcNN')
        else
          # timestamp 96 stores the number of seconds and nanoseconds that have elapsed since 1970-01-01 00:00:00 UTC
          # in 64-bit signed integer and 32-bit unsigned integer:
          # +--------+--------+--------+--------+--------+--------+--------+
          # |  0xc7  |   12   |   -1   |nanoseconds in 32-bit unsigned int |
          # +--------+--------+--------+--------+--------+--------+--------+
          # +--------+--------+--------+--------+--------+--------+--------+--------+
          #                     seconds in 64-bit signed int                        |
          # +--------+--------+--------+--------+--------+--------+--------+--------+
          # Timestamp 96 format can represent a timestamp in [-584554047284-02-23 16:59:44 UTC, 584554051223-11-09 07:00:16.000000000 UTC) range.
          [0xc7, 12, EXT_TYPE_TIME_ID, nsec, unix_time].pack('CCcNq>')
          # nsec = binary[2..5].unpack('N').first
          # sec = binary[6..13].unpack('q>').first
        end
      end

      def self.parse(binary)
        case binary[0]
        when "\xd6"
          type = binary[1].unpack('c')[0]
          if type != EXT_TYPE_TIME_ID
            raise "unknown ext type id #{type}"
          end
          ::Time.at(binary[2..5].unpack('N')[0])
        when "\xd7"
          type = binary[1].unpack('c')[0]
          if type != EXT_TYPE_TIME_ID
            raise "unknown ext type id #{type}"
          end
          u, d = binary[2..9].unpack('NN')
          nsec = u >> 2
          sec = ((u & MASK_UPPER30_OF_32BIT) << 32) | d
          ::Time.at(sec + Rational(nsec, 1_000_000_000))
        when "\xc7"
          _, len, type, nsec, sec = binary.unpack('CCcNq>')
          if type != EXT_TYPE_TIME_ID
            raise "unknown ext type id #{type}"
          end
          if len != 12
            raise "incorrect length: #{len}"
          end
          ::Time.at(sec + Rational(nsec, 1_000_000_000))
        else
          raise "unknown msgpack header, '#{binary[0].unpack("H*")}'"
        end
      end
    end
  end
end
