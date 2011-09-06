require 'helper'

class UnitTests::TestNumeric < Test::Unit::TestCase
  def setup
    super
    @app = stub('app')
    @client = stub('client')
  end

  test "to_s" do
    data = %{:asimov.freenode.net 001 crookshanks :Welcome to the freenode Internet Relay Chat Network crookshanks}
    message = Smirch::IrcMessage.parse(data)
    assert_equal "* Welcome to the freenode Internet Relay Chat Network crookshanks", message.to_s
  end

  test "names" do
    data = %{:asimov.freenode.net 353 crookshanks = #vim :crookshanks amiri rejb remyo surgeon smeea galaxywatcher daniel_ RomD comand wokka AopicieR mavrc macrobat AkiraYB okayzed azoic gehdan DestinyAwaits viking WebDragon jonathanrwallace ajpiano malkomalko nevans sophacles dv_ agile riq gertidon quake_guy kTT orafu jjardon kojul drio paradigm bryanl threeve arturas pigdude fcuk112 ceej marchino julesa consumerism abstrakt vitiate1 b4d jamur2 tizbac rafab keystr0k hokapoka JohannesSM64 chris_cooke smuf}
    message = Smirch::IrcMessage.parse(data)
    assert_equal "#vim", message.channel_name
    expected = %w{crookshanks amiri rejb remyo surgeon smeea galaxywatcher daniel_ RomD comand wokka AopicieR mavrc macrobat AkiraYB okayzed azoic gehdan DestinyAwaits viking WebDragon jonathanrwallace ajpiano malkomalko nevans sophacles dv_ agile riq gertidon quake_guy kTT orafu jjardon kojul drio paradigm bryanl threeve arturas pigdude fcuk112 ceej marchino julesa consumerism abstrakt vitiate1 b4d jamur2 tizbac rafab keystr0k hokapoka JohannesSM64 chris_cooke smuf}
    assert_equal expected, message.nicks
  end
end
