
ROOT =    File.expand_path(File.dirname(__FILE__) + '/../')
THEMES =  File.expand_path(ROOT + '/../themes')

$LOAD_PATH.unshift(ROOT + '/app/servlets')
$LOAD_PATH.unshift(ROOT + '/app/drops')
$LOAD_PATH.unshift(ROOT + '/app/tags')
$LOAD_PATH.unshift(ROOT + '/vendor/liquid/lib')
$LOAD_PATH.unshift(ROOT + '/vendor/rubyzip/lib')
$LOAD_PATH.unshift(ROOT + '/lib')
$LOAD_PATH.unshift(ROOT + '/app/models')
$LOAD_PATH.unshift(ROOT + '/app/filters')
$LOAD_PATH.unshift(ROOT + '/vendor/gems/ruby-debug-0.10.4/cli')

#Load ruby-debug-base based on operating system
case RUBY_PLATFORM 
when /linux/
  $LOAD_PATH.unshift(ROOT + '/vendor/gems/ruby-debug-base-0.10.4/lib')
when /win/
  $LOAD_PATH.unshift(ROOT + '/vendor/win/gems/ruby-debug-base-0.10.4-x86-mswin32/lib')
end

puts "vision is running on #{RUBY_PLATFORM}"

require 'webrick'
require 'yaml'
require 'class_attribute_accessor'
require 'module_attribute_accessors'
require 'logging'
require 'liquid'
require 'string_ext'
require 'fileutils'
require 'zip/zip'
require 'paginate'
require 'comment_form'
require 'active_support/json'
require 'date'
require 'ruby-debug-base'
require 'ruby-debug'

require File.dirname(__FILE__) + '/version'

Dir[ROOT + '/app/filters/*'].each do |file|
  filter = File.basename(file).split('.').first.to_classname
  require file
  Liquid::Template.register_filter Object.const_get(filter)
end


Liquid::Template.register_tag('paginate', Paginate)
Liquid::Template.register_tag('form', CommentForm)


# Require mount points. thats where the servlets of this server are setup
require File.dirname(__FILE__) + '/mounts'

#Extended Hash2Class-Function for Ruby-Hashes
class Hash
  def to_mod
    hash = self
    Class.new do
    	hash.each do |k,v|
	      self.instance_variable_set("@#{k}", v)
	      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
	      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
    	end
    end
  end
  def stringify_keys
		inject({}) do |options, (key, value)|
			options[key.to_s] = value
			options
		end
	end
end

#Same for Strings... I miss Rails :/
class String
	def to_date
		Date.parse(self)
	end
	
	def blank?
	  self.nil? || self == ""
	end
end

class Time
  def self.random(years_forward = 1)
    year = Time.now.year + rand(years_forward)+1
    month = rand(12) + 1
    day = rand(31) + 1
    Time.local(year, month, day)
  end
  def to_us_date
  	self.strftime("%Y-%m-%d")
	end
end


def nested_params? _outer, _inner, params, _allow_blank = false
	if params
		if params[_outer]
			return params[_outer][_inner] if _allow_blank == true
			return params[_outer][_inner] unless params[_outer][_inner].blank?
		end
	end
	return nil
end

