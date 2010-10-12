require 'helper'

class TestSmirch
  class TestApplication
    class TestDialogSettings < Test::Unit::TestCase
      def setup
        super
        @parent = stub('dialog parent')
        @event = stub('dialog event')

        @shell = stub('dialog window', :pack => nil, :open => nil, :layout= => nil, :text= => nil)
        Smirch::Widgets::Shell.stubs(:new).returns(@shell)
        @layout = stub('grid layout')
        Smirch::Layout::GridLayout.stubs(:new).returns(@layout)
        @label = stub("label", :text= => nil)
        Smirch::Widgets::Label.stubs(:new).returns(@label)
        @button = stub("button", :text= => nil, :layout_data= => nil, :add_selection_listener => nil)
        Smirch::Widgets::Button.stubs(:new).returns(@button)
        @grid_data = stub('grid data')
        Smirch::Layout::GridData.stubs(:new).returns(@grid_data)
      end

      def test_new_with_no_settings
        Smirch.stubs(:load_config).returns(nil)

        Smirch::Widgets::Shell.expects(:new).with(@parent, instance_of(Fixnum)).returns(@shell)
        Smirch::Layout::GridLayout.expects(:new).returns(@layout)
        @shell.expects(:layout=).with(@layout)

        label_seq = sequence('labels')
        labels = Array.new(5) do |i|
          label = stub("label #{i}", :text= => nil)
          Smirch::Widgets::Label.expects(:new).in_sequence(label_seq).returns(label)
          label
        end

        input_seq = sequence('inputs')
        input_values = %w{irc.freenode.net 6666 foobar foo bar}
        inputs = Array.new(5) do |i|
          input = stub("input #{i}", :layout_data= => nil, :text => input_values[i])
          Smirch::Widgets::Text.expects(:new).in_sequence(input_seq).returns(input)
          input
        end

        button_seq = sequence('buttons')
        save_button = stub("save button", :text= => nil, :layout_data= => nil)
        save_button.expects(:add_selection_listener).yields
        Smirch::Widgets::Button.expects(:new).in_sequence(button_seq).returns(save_button)

        save_seq = sequence('saving')
        Smirch.expects(:save_config).with({
          'server' => 'irc.freenode.net', 'port' => 6666,
          'nick' => 'foobar', 'user' => 'foo', 'real' => 'bar'
        }).in_sequence(save_seq)
        @shell.expects(:close).in_sequence(save_seq)

        cancel_button = stub("cancel button", :text= => nil, :layout_data= => nil)
        cancel_button.expects(:add_selection_listener).yields
        Smirch::Widgets::Button.expects(:new).in_sequence(button_seq).returns(cancel_button)

        cancel_seq = sequence('canceling')
        @shell.expects(:close).in_sequence(cancel_seq)

        dialog = Smirch::Application::SettingsDialog.new(@parent, @event)
      end

      def test_new_with_existing_settings
        input_values = ['irc.example.net', 7001, 'mister', 'buddy', 'guy']
        config = Hash[*%w{server port nick user real}.zip(input_values).flatten]
        Smirch.stubs(:load_config).returns(config)

        input_seq = sequence('inputs')
        inputs = Array.new(5) do |i|
          input = stub("input #{i}", :layout_data= => nil, :text => input_values[i])
          input.expects(:text=).with(input_values[i].to_s)
          Smirch::Widgets::Text.expects(:new).in_sequence(input_seq).returns(input)
          input
        end

        dialog = Smirch::Application::SettingsDialog.new(@parent, @event)
      end
    end
  end
end
