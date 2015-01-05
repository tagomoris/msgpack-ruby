require "msgpack/version"

if /java/ =~ RUBY_PLATFORM
  $LOAD_PATH << File.expand_path("../ext", __FILE__)
  require 'java'
  require 'javassist-3.15.0-GA'
  require 'msgpack-0.6.6'
  require 'msgpack_jruby'
  require 'msgpack/jruby_support'
else
  begin
    require "msgpack/#{RUBY_VERSION[/\d+.\d+/]}/msgpack"
  rescue LoadError
    require "msgpack/msgpack"
  end
end
