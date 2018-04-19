# encoding: utf-8
require 'test_helper'

class RakeTaskTest < GeocoderTestCase
  def setup
    Rake.application.rake_require "tasks/geocoder"
    Rake::Task.define_task(:environment)
  end

  def test_rake_task_geocode_raise_specify_class_message
    omit("Errors on Travis") if ENV['TRAVIS'] # TODO: figure out why
    assert_raise(RuntimeError, "Please specify a CLASS (model)") do
      Rake.application.invoke_task("geocode:all")
    end
  end

  def test_rake_task_geocode_specify_class
    omit("Errors on Travis") if ENV['TRAVIS'] # TODO: figure out why
    ENV['CLASS'] = 'Place'
    assert_nil Rake.application.invoke_task("geocode:all")
  end
end
