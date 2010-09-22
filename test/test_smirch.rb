require 'helper'

class TestSmirch < Test::Unit::TestCase
  def stub_text(name = 'text widget')
    stub(name, :layout_data= => nil, :background= => nil, :foreground= => nil, :add_key_listener => nil)
  end

  def setup
    super
    @color = stub('color')
    @display = stub('display', :read_and_dispatch => false, :sleep => nil, :dispose => nil, :system_color => @color)
    Smirch::Display.stubs(:new).returns(@display)
    @shell = stub('shell', :open => nil, :layout= => nil, :pack => nil)
    @shell.stubs(:disposed?).returns(false, true)
    Smirch::Shell.stubs(:new).returns(@shell)
    @grid_layout = stub('grid layout')
    Smirch::GridLayout.stubs(:new).returns(@grid_layout)
    @text = stub_text
    Smirch::Text.stubs(:new).returns(@text)
    @grid_data = stub_everything("GridData object")
    Smirch::GridData.stubs(:new).returns(@grid_data)
  end

  def test_window
    Smirch::Display.expects(:new).returns(@display)
    Smirch::Shell.expects(:new).with(@display).returns(@shell)
    @shell.expects(:open)
    @shell.expects(:disposed?).twice.returns(false, true)
    @display.expects(:read_and_dispatch).returns(false)
    @display.expects(:sleep)
    @display.expects(:dispose)

    s = Smirch.new
    s.main_loop
  end

  def test_layout
    Smirch::GridLayout.expects(:new).with(1, true).returns(@grid_layout)
    @shell.expects(:layout=).with(@grid_layout)

    chat_area = stub_text('chat area')
    Smirch::Text.expects(:new).with(@shell, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY).returns(chat_area)
    chat_area.expects(:layout_data=).with(@grid_data)

    input_box = stub_text('input box')
    Smirch::Text.expects(:new).with(@shell, Smirch::SWT::BORDER).returns(input_box)
    input_box.expects(:layout_data=).with(@grid_data)
    input_box.expects(:add_key_listener)

    s = Smirch.new
    s.main_loop
  end
end
