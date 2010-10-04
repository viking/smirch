require 'helper'
require 'tmpdir'
require 'fileutils'

class TestSmirch
  def setup
    super
    @pwuid = stub(:dir => "/foo/bar")
    Etc.stubs(:getpwuid).returns(@pwuid)
  end

  def test_load_config
    File.expects(:exist?).with("/foo/bar/.smirchrc").returns(true)
    YAML.expects(:load_file).with("/foo/bar/.smirchrc").returns({:foo => 'bar'})
    assert_equal({:foo => 'bar'}, Smirch.load_config)
  end

  def test_load_config_no_file
    File.expects(:exist?).with("/foo/bar/.smirchrc").returns(false)
    assert_nil Smirch.load_config
  end

  def test_save_config
    file = mock('file') { expects(:write).with({:foo => 'bar'}.to_yaml) }
    File.expects(:open).with("/foo/bar/.smirchrc", "w").yields(file)
    Smirch.save_config({:foo => 'bar'})
  end
end
