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
      @shell = stub('shell', :open => nil, :layout= => nil, :pack => nil, :menu_bar= => nil, :text= => nil)
      @shell.stubs(:disposed?).returns(false, true)
      Smirch::Widgets::Shell.stubs(:new).returns(@shell)
      @grid_layout = stub('grid layout')
      Smirch::Layout::GridLayout.stubs(:new).returns(@grid_layout)

      @tab_folder_listener = nil
      @tab_folder = stub('tab folder', :layout_data= => nil, :selection= => nil)
      @tab_folder.stubs(:add_selection_listener).with { |l| @tab_folder_listener = l; true }  # bleh
      Smirch::Widgets::TabFolder.stubs(:new).returns(@tab_folder)
      @tab_item = stub('tab item', :text= => nil, :control= => nil)
      Smirch::Widgets::TabItem.stubs(:new).returns(@tab_item)
      @chat_box = stub_text('chat area')
      Smirch::Widgets::Text.stubs(:new).with(@tab_folder, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY | Smirch::SWT::V_SCROLL).returns(@chat_box)

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
      @menu_item = stub('menu item', :text= => nil, :add_listener => nil, :menu= => nil)
      Smirch::Widgets::MenuItem.stubs(:new).returns(@menu_item)
    end

    def test_window_and_main_loop
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

      Smirch::Widgets::TabFolder.expects(:new).with(@shell, Smirch::SWT::BORDER | Smirch::SWT::BOTTOM).returns(@tab_folder)
      @tab_folder.expects(:layout_data=).with(@grid_data)

      Smirch::Widgets::Text.expects(:new).with(@tab_folder, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY | Smirch::SWT::V_SCROLL).returns(@chat_box)

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
    end

    def test_msg_command
      s = Smirch::MainWindow.new
      s.stubs(:current_chat_box).returns(@chat_box)
      simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
      @client.expects(:privmsg).with('dude', 'hey')
      @chat_box.expects(:append).with(">dude< hey\n")
      simulate_input("/msg dude hey")
    end

    def test_msg_requires_connection
      @chat_box.expects(:append).with("You have to connect to a server first to do that.\n")
      s = Smirch::MainWindow.new
      s.stubs(:current_chat_box).returns(@chat_box)
      simulate_input("/msg dude hey")
    end

    def test_unknown_command
      s = Smirch::MainWindow.new
      simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
      @client.expects(:execute).with('foo', 'huge bar')
      simulate_input("/foo huge bar")
    end

    def test_unknown_command_requires_connection
      @chat_box.expects(:append).with("You have to connect to a server first to do that.\n")
      s = Smirch::MainWindow.new
      s.stubs(:current_chat_box).returns(@chat_box)
      simulate_input("/foo huge bar")
    end

    def test_connect
      config = {'server' => 'irc.freenode.net', 'port' => 6666, 'nick' => 'MyNick', 'user' => 'MyUser', 'real' => 'Dude guy'}
      Smirch.expects(:load_config).returns(config)

      Smirch::IrcClient.expects(:new).with('irc.freenode.net', 6666, 'MyNick', 'MyUser', 'Dude guy').returns(@client)
      @client.expects(:connect)

      s = Smirch::MainWindow.new
      simulate_input("/connect")
    end

    def test_poll_runner
      # test runners; should probably do this elsewhere
      display = stub('display')
      client = stub('client')
      runner = Smirch::MainWindow::PollRunner.new(display, client)

      run_seq = sequence('running')
      display.expects(:asyncExec).in_sequence(run_seq).yields
      client.expects(:poll).in_sequence(run_seq)
      display.expects(:timerExec).with(500, runner)
      runner.run
    end

    def test_receive_runner
      message = stub('message')
      display = stub('display')
      client = stub('client')
      parent = stub('main window')
      runner = Smirch::MainWindow::ReceiveRunner.new(display, client, parent)

      run_seq = sequence('running')
      client.expects(:queue).in_sequence(run_seq).returns([message])
      message.expects(:draw).with(parent).in_sequence(run_seq)
      display.expects(:timerExec).with(500, runner)
      runner.run
    end

    def test_find_tab
      s = Smirch::MainWindow.new
      s.stubs(:current_chat_box).returns(@chat_box)

      tab = stub_everything('new tab')
      Smirch::Widgets::TabItem.stubs(:new).returns(tab)
      text = stub_everything('new text box')
      Smirch::Widgets::Text.stubs(:new).returns(text)
      @tab_folder.expects(:selection=).with(tab)

      s.new_tab('#hugetown')
      result = s.find_tab('#hugetown')
      assert_equal tab, result[:tab]
      assert_equal text, result[:text]
      assert_equal '#hugetown', result[:name]
    end

    def test_close_tab
      s = Smirch::MainWindow.new

      tab = stub_everything('new tab')
      Smirch::Widgets::TabItem.stubs(:new).returns(tab)
      text = stub_everything('new text box')
      Smirch::Widgets::Text.stubs(:new).returns(text)

      s.new_tab('#hugetown')
      text.expects(:dispose)
      tab.expects(:dispose)
      @tab_folder.expects(:selection=).with(0)
      s.close_tab('#hugetown')
    end

    #def test_server_notice_received
      #s = Smirch::MainWindow.new
      #simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
      #@chat_box.expects(:append).with("hey buddy\n")
      #simulate_received(":gibson.freenode.net NOTICE * :hey buddy\r\n")
    #end
  end
end
