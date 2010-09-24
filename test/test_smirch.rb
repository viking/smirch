require 'helper'

class TestSmirch < Test::Unit::TestCase
  def stub_text(name = 'text widget', more_stubs = {})
    stub(name, {
      :layout_data= => nil, :background= => nil, :foreground= => nil,
      :text => 'foo', :text= => nil, :font= => nil, :append => nil
    }.merge(more_stubs))
  end

  def simulate_input(text)
    @input_box.stubs(:text).returns(text)
    @input_box_listener.keyPressed(stub(:character => Smirch::SWT::CR))
  end

  def simulate_received(text)
    @client.stubs(:queue).returns([text])
    @runner = Smirch::ReceiveRunner.new(@display, @client, @chat_box)
    @runner.run
  end

  def setup
    super
    @color = stub('color')
    @display = stub('display', :read_and_dispatch => false, :sleep => nil, :dispose => nil, :system_color => @color, :timerExec => nil)
    Smirch::Display.stubs(:new).returns(@display)
    @shell = stub('shell', :open => nil, :layout= => nil, :pack => nil)
    @shell.stubs(:disposed?).returns(false, true)
    Smirch::Shell.stubs(:new).returns(@shell)
    @grid_layout = stub('grid layout')
    Smirch::GridLayout.stubs(:new).returns(@grid_layout)
    @chat_box = stub_text('chat area')
    Smirch::Text.stubs(:new).with(@shell, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY | Smirch::SWT::V_SCROLL).returns(@chat_box)

    @input_box = stub_text('input box')
    Smirch::Text.stubs(:new).with(@shell, Smirch::SWT::BORDER).returns(@input_box)
    @input_box.stubs(:add_key_listener).with { |l| @input_box_listener = l; true }

    @grid_data = stub_everything("GridData object")
    Smirch::GridData.stubs(:new).returns(@grid_data)

    @font = stub_everything("Font object")
    Smirch::Font.stubs(:new).returns(@font)

    @client = stub('client', :connect => nil, :queue => [])
    Smirch::Client.stubs(:new).returns(@client)
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

    Smirch::Text.expects(:new).with(@shell, Smirch::SWT::BORDER | Smirch::SWT::MULTI | Smirch::SWT::READ_ONLY | Smirch::SWT::V_SCROLL).returns(@chat_box)
    @chat_box.expects(:layout_data=).with(@grid_data)

    Smirch::Text.expects(:new).with(@shell, Smirch::SWT::BORDER).returns(@input_box)
    @input_box.expects(:layout_data=).with(@grid_data)
    @input_box.expects(:add_key_listener)

    s = Smirch.new
    s.main_loop
  end

  def test_server_command
    s = Smirch.new

    Smirch::Client.expects(:new).with('irc.freenode.net', 6666, 'MyNick', 'MyUser', 'Dude guy').returns(@client)
    @client.expects(:connect)

    poll_runner = nil
    @display.expects(:timerExec).with do |ms, r|
      ms == 250 && r.is_a?(Smirch::PollRunner) && poll_runner = r
    end

    receive_runner = nil
    @display.expects(:timerExec).with do |ms, r|
      ms == 500 && r.is_a?(Smirch::ReceiveRunner) && receive_runner = r
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
    s = Smirch.new
    simulate_input("/server irc.freenode.net 6666 MyNick MyUser Dude guy")
    @client.expects(:privmsg).with('dude', 'hey')
    @chat_box.expects(:append).with(">dude< hey\n")
    simulate_input("/msg dude hey")
  end
end
