
require 'bundler'
Bundler::GemHelper.install_tasks

require 'fileutils'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'yard'

task :spec => :compile

desc 'Run RSpec code examples and measure coverage'
task :coverage do |t|
  ENV['SIMPLE_COV'] = '1'
  Rake::Task["spec"].invoke
end

desc 'Generate YARD document'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/msgpack/version.rb','doclib/**/*.rb']
  t.options = []
  t.options << '--debug' << '--verbose' if $trace
end

spec = eval File.read("msgpack.gemspec")

if RUBY_PLATFORM =~ /java/
  require 'rake/javaextensiontask'

  task :compile do
    require 'rbconfig'
    jruby_jar_path = File.expand_path(File.join(File.dirname(RbConfig.ruby), "..", "lib", "jruby.jar"))
    classpath = (Dir["lib/ext/*.jar"] + [jruby_jar_path]).join(':')
    system %(javac -Xlint:-options -deprecation -source 1.6 -target 1.6 -cp #{classpath} ext/java/*.java ext/java/org/msgpack/jruby/*.java)
    exit($?.exitstatus) unless $?.success?
  end

  task :package => :compile do
    class_files = Dir['ext/java/**/*.class'].map { |path| path = path.sub('ext/java/', ''); "-C ext/java '#{path}'" }
    system %(jar cf lib/ext/msgpack_jruby.jar #{class_files.join(' ')})
    exit($?.exitstatus) unless $?.success?
  end

  # task :release => :package do
  #   version_string = "v#{MessagePack::VERSION}"
  #   unless %x(git tag -l).split("\n").include?(version_string)
  #     system %(git tag -a #{version_string} -m #{version_string})
  #   end
  #   system %(gem build msgpack-jruby.gemspec && gem push msgpack-jruby-*.gem && mv msgpack-jruby-*.gem pkg)
  # end

  # Rake::JavaExtensionTask.new('msgpack', spec) do |ext|
  #   ext.ext_dir = 'ext/java'
  #   ext.lib_dir = File.join(*['lib', 'msgpack', ENV['FAT_DIR']].compact)
  #   ext.classpath = Dir['lib/msgpack/java/*.jar'].map { |x| File.expand_path x }.join ':'
  # end

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ["-c", "-f progress"]
    t.rspec_opts << "-Ilib"
    t.pattern = 'spec/{,jruby/}*_spec.rb'
    t.verbose = true
  end

else
  require 'rake/extensiontask'

  Rake::ExtensionTask.new('msgpack', spec) do |ext|
    ext.ext_dir = 'ext/msgpack'
    ext.cross_compile = true
    ext.lib_dir = File.join(*['lib', 'msgpack', ENV['FAT_DIR']].compact)
    #ext.cross_platform = 'i386-mswin32'
  end

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ["-c", "-f progress"]
    t.rspec_opts << "-Ilib"
    t.pattern = 'spec/{,cruby/}*_spec.rb'
    t.verbose = true
  end
end

# require "rake/clean" ?
CLEAN.include('lib/msgpack/msgpack.*')
CLEAN.include('ext/java/**/*.class')

task :default => [:spec, :build, :doc]


###
## Cross compile memo
##
## Ubuntu Ubuntu 10.04.1 LTS
##
#
### install mingw32 cross compiler with w64 support
# sudo apt-get install gcc-mingw32
# sudo apt-get install mingw-w64
#
### install rbenv
# git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
# echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
# echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
# exec $SHELL -l
#
### install cross-compiled ruby 2.0.0
# rbenv install 2.0.0-p247
# rbenv shell 2.0.0-p247
# gem update --system
# gem install rake-compiler
# rake-compiler cross-ruby VERSION=2.0.0-p247
#
### install cross-compiled ruby 1.9.3
# rbenv install 1.9.3-p327
# rbenv shell 1.9.3-p327
# gem update --system
# gem install rake-compiler
# rake-compiler cross-ruby VERSION=1.9.3-p327
#
### install cross-compiled ruby 1.8.7
# rbenv install 1.8.7-p374
# rbenv shell 1.8.7-p374
# gem update --system
# gem install rake-compiler
# rake-compiler cross-ruby VERSION=1.8.7-p374
#
### build gem
# rbenv shell 1.8.7-p374
# gem install bundler
# bundle
# rake cross native gem RUBY_CC_VERSION=1.8.7:1.9.3:2.0.0
#

