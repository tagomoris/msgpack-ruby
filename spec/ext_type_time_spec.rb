# encoding: ascii-8bit
require 'spec_helper'
require_relative 'ext_type_time'

describe MessagePack::ExtType::Time do
  describe 'a time without nsec, after 1970-01-01, before 2106-02-07' do
    it 'is packed into fixext 4' do
      t1 = Time.gm(2017, 9, 19, 13, 22, 4, 0) # usec == 0
      bin = MessagePack::ExtType::Time.generate(t1)

      bin.size.should == 6 # msgpack_type(1), ext_type_id(1), data(4)
      bin[0].should == "\xd6"
      bin[1].should == "\xff" # -1 as signed int 8

      t2 = MessagePack::ExtType::Time.parse(bin)
      t2.should == t1
      t2.nsec.should == 0
    end
  end

  describe 'a time with nsec, after 1970-01-01, before 2514-05-30' do
    it 'is packed into fixext 8' do
      t1 = Time.gm(2017, 9, 19, 13, 22, 4, 123456)
      bin = MessagePack::ExtType::Time.generate(t1)

      bin.size.should == 10 # msgpack_type(1), ext_type_id(1), data(8)
      bin[0].should == "\xd7"
      bin[1].should == "\xff" # -1 as signed int 8

      t2 = MessagePack::ExtType::Time.parse(bin).utc
      t2.to_i.should == t1.to_i
      t2.nsec.should == 123456000
      t2.should == t1
    end
  end

  describe 'a time with nsec, after 2514-05-30' do
    it 'is packed into ext 8' do
      t1 = Time.gm(2912, 9, 19, 13, 22, 4, 123456)
      bin = MessagePack::ExtType::Time.generate(t1)

      bin.size.should == 15 # msgpack_type(1), length(1) ext_type_id(1), nsec(4), sec(8)
      bin[0].should == "\xc7"
      bin[1].should == "\x0c" # 12 as length of body
      bin[2].should == "\xff" # -1 as signed int 8

      t2 = MessagePack::ExtType::Time.parse(bin).utc
      t2.to_i.should == t1.to_i
      t2.nsec.should == 123456000
      t2.should == t1
    end
  end

  describe 'a time without nsec, before 1970-01-01' do
    
  end
end
