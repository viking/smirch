require 'helper'

class TestSmirch
  class TestMainWindow < Test::Unit::TestCase
    def stub_text(name = 'text widget', more_stubs = {})
      stub(name, {
        :layout_data= => nil, :background= => nil, :foreground= => nil,
        :text => 'foo', :text= => nil, :font= => nil, :append => nil,
        :set_focus => nil
      }.merge(more_stubs))
    end

    def simulate_input(text)
      @input_box.stubs(:text).returns(text)
      @input_box_listener.keyPressed(stub(:character => Smirch::SWT::CR))
    end

    def simulate_received(text)
      @client.stubs(:queue).returns([text])
      @runner = Smirch::MainWindow::ReceiveRunner.new(@display, @client, @chat_box)
      @runner.run
    end

    def setup
      super
      @color = stub('color')
      @display = stub('display', :read_and_dispatch => false, :sleep => nil, :dispose => nil, :system_color => @color, :timerExec => nil)
      Smirch::Widgets::Display.stubs(:new).returns(@display)
      @shell = stub('shell', :open => nil, :layout= => nil, :pack => nil, :menu_bar= => nil)
      @shell.stubs(:disposed?).returns(false, true)
      Smirch::Widgets::Shell.stubs(:new).returns(@shell)
      @grid_layout = stub('grid layout')
      Smirch::Layout::GridLayout.stubs(:new).returns(@grid_layout)
      @chat_box = stub_text('chat area')
      Smirch::Widgets::Text.stubs(:new).with(@shell, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY | Smirch::SWT::V_SCROLL).returns(@chat_box)

      @input_box = stub_text('input box')
      Smirch::Widgets::Text.stubs(:new).with(@shell, Smirch::SWT::BORDER).returns(@input_box)
      @input_box.stubs(:add_key_listener).with { |l| @input_box_listener = l; true }

      @grid_data = stub_everything("GridData object")
      Smirch::Layout::GridData.stubs(:new).returns(@grid_data)

      @font = stub_everything("Font object")
      Smirch::Graphics::Font.stubs(:new).returns(@font)

      @client = stub('client', :connect => nil, :queue => [])
      Smirch::IrcClient.stubs(:new).returns(@client)

      @menu = stub('menu')
      Smirch::Widgets::Menu.stubs(:new).returns(@menu)
      Smirch::Widgets::MenuItem.stubs(:new).returns(stub_everything('menu item'))
      Smirch::Widgets::Label.stubs(:new).returns(stub_everything('label'))
      Smirch::Widgets::Button.stubs(:new).returns(stub_everything('button'))
    end

    def test_window
      Smirch::Widgets::Display.expects(:new).returns(@display)
      Smirch::Widgets::Shell.expects(:new).with(@display).returns(@shell)
      @shell.expects(:open)
      @shell.expects(:disposed?).twice.returns(false, true)
      @display.expects(:read_and_dispatch).returns(false)
      @display.expects(:sleep)
      @display.expects(:dispose)

      s = Smirch::MainWindow.new
      s.main_loop
    end

    def test_layout
      Smirch::Layout::GridLayout.expects(:new).with(1, true).returns(@grid_layout)
      @shell.expects(:layout=).with(@grid_layout)

      Smirch::Widgets::Text.expects(:new).with(@shell, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY | Smirch::SWT::V_SCROLL).returns(@chat_box)
      @chat_box.expects(:layout_data=).with(@grid_data)

      Smirch::Widgets::Text.expects(:new).with(@shell, Smirch::SWT::BORDER).returns(@input_box)
      @input_box.expects(:layout_data=).with(@grid_data)
      @input_box.expects(:add_key_listener)

      s = Smirch::MainWindow.new
      s.main_loop
    end

    def test_server_command
      s = Smirch::MainWindow.new

      Smirch::IrcClient.expects(:new).with('irc.freenode.net', 6666, 'MyNick', 'MyUser', 'Dude guy').returns(@client)
      @client.expects(:connect)

      poll_runner = nil
      @display.expects(:timerExec).with do |ms, r|
        ms == 250 && r.is_a?(Smirch::MainWindow::PollRunner) && poll_runner = r
      end

      receive_runner = nil
      @display.expects(:timerExec).with do |ms, r|
        ms == 500 && r.is_a?(Smirch::MainWindow::ReceiveRunner) && receive_runner = r
      end

      simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
      assert_not_nil poll_runner

      # test runners; should probably do this elsewhere
      timer_1 = sequence('timer 1')
      @display.expects(:asyncExec).yields.in_sequence(timer_1)
      @client.expects(:poll).in_sequence(timer_1)
      @display.expects(:timerExec).with(500, poll_runner).in_sequence(timer_1)
      poll_runner.run

      timer_2 = sequence('timer 2')
      @client.expects(:queue).returns(["foo"]).in_sequence(timer_2)
      @chat_box.expects(:append).with("foo\n").in_sequence(timer_2)
      @display.expects(:timerExec).with(500, receive_runner).in_sequence(timer_2)
      receive_runner.run
    end

    def test_msg_command
      s = Smirch::MainWindow.new
      simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
      @client.expects(:privmsg).with('dude', 'hey')
      @chat_box.expects(:append).with(">dude< hey\n")
      simulate_input("/msg dude hey")
    end

    def test_unknown_command
      s = Smirch::MainWindow.new
      simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
      @client.expects(:execute).with('foo', 'huge bar')
      simulate_input("/foo huge bar")
    end

    #def test_server_notice_received
      #s = Smirch::MainWindow.new
      #simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
      #@chat_box.expects(:append).with("hey buddy\n")
      #simulate_received(":gibson.freenode.net NOTICE * :hey buddy\r\n")
    #end
  end
end
