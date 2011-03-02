require 'helper'

class TestSmirch
  class TestApplication
    class TestTab < Test::Unit::TestCase
      def setup
        super
        @tab_folder = stub('tab folder')
        @black = stub('black color object')
        @white = stub('white color object')
        @font = stub('font object')

        # default cases
        @tab_item = stub_everything('tab item')
        Smirch::Widgets::TabItem.stubs(:new).returns(@tab_item)
        @chat_box = stub_everything('chat box')
        Smirch::Widgets::Text.stubs(:new).returns(@chat_box)
      end

      def test_new
        tab_item = mock('tab item')
        tab_item.expects(:text=).with('foo')
        Smirch::Widgets::TabItem.expects(:new).with(@tab_folder, Smirch::SWT::NONE).returns(tab_item)
        chat_box = mock('chat box')
        Smirch::Widgets::Text.expects(:new).with(@tab_folder, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY | Smirch::SWT::V_SCROLL).returns(chat_box)
        chat_box.expects(:background=).with(@black)
        chat_box.expects(:foreground=).with(@white)
        chat_box.expects(:font=).with(@font)
        tab_item.expects(:control=).with(chat_box)

        Smirch::Application::Tab.new(@tab_folder, 'foo', :background => @black, :foreground => @white, :font => @font)
      end

      def test_accessors
        tab = Smirch::Application::Tab.new(@tab_folder, 'foo', :background => @black, :foreground => @white, :font => @font)
        assert_equal 'foo', tab.name
        assert_equal @tab_item, tab.tab_item
        assert_equal @chat_box, tab.chat_box
      end

      def test_dispose
        tab = Smirch::Application::Tab.new(@tab_folder, 'foo', :background => @black, :foreground => @white, :font => @font)
        @tab_item.expects(:dispose)
        @chat_box.expects(:dispose)
        tab.dispose
      end
    end
  end
end
