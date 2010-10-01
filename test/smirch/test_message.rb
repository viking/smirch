require 'helper'

class TestSmirch
  class TestMessage < Test::Unit::TestCase
    def test_RPL_WELCOME
      message = %{:asimov.freenode.net 001 crookshanks :Welcome to the freenode Internet Relay Chat Network crookshanks}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 1, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal "Welcome to the freenode Internet Relay Chat Network crookshanks", result.text
    end

    def test_RPL_YOURHOST
      message = %{:asimov.freenode.net 002 crookshanks :Your host is asimov.freenode.net[82.96.64.4/6666], running version ircd-seven-1.0.0}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 2, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{Your host is asimov.freenode.net[82.96.64.4/6666], running version ircd-seven-1.0.0}, result.text
    end

    def test_RPL_CREATED
      message = %{:asimov.freenode.net 003 crookshanks :This server was created Sat Jan 30 2010 at 01:11:04 CET}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 3, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{This server was created Sat Jan 30 2010 at 01:11:04 CET}, result.text
    end

    def test_RPL_MYINFO
      message = %{:asimov.freenode.net 004 crookshanks asimov.freenode.net ircd-seven-1.0.0 DOQRSZaghilopswz CFILMPQbcefgijklmnopqrstvz bkloveqjfI}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 4, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{asimov.freenode.net ircd-seven-1.0.0 DOQRSZaghilopswz CFILMPQbcefgijklmnopqrstvz bkloveqjfI}, result.text
    end

    def test_RPL_ISUPPORT_1
      message = %{:asimov.freenode.net 005 crookshanks CHANTYPES=# EXCEPTS INVEX CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode KNOCK STATUSMSG=@+ CALLERID=g :are supported by this server}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 5, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{CHANTYPES=# EXCEPTS INVEX CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode KNOCK STATUSMSG=@+ CALLERID=g are supported by this server}, result.text
    end

    def test_RPL_ISUPPORT_2
      message = %{:asimov.freenode.net 005 crookshanks SAFELIST ELIST=U CASEMAPPING=rfc1459 CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 ETRACE CPRIVMSG CNOTICE DEAF=D MONITOR=100 :are supported by this server}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 5, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{SAFELIST ELIST=U CASEMAPPING=rfc1459 CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 ETRACE CPRIVMSG CNOTICE DEAF=D MONITOR=100 are supported by this server}, result.text
    end

    def test_RPL_ISUPPORT_3
      message = %{:asimov.freenode.net 005 crookshanks FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: EXTBAN=$,arx WHOX CLIENTVER=3.0 :are supported by this server}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 5, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: EXTBAN=$,arx WHOX CLIENTVER=3.0 are supported by this server}, result.text
    end

    def test_RPL_LUSERCLIENT
      message = %{:asimov.freenode.net 251 crookshanks :There are 766 users and 61772 invisible on 24 servers}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 251, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{There are 766 users and 61772 invisible on 24 servers}, result.text
    end

    def test_RPL_LUSEROP
      message = %{:asimov.freenode.net 252 crookshanks 38 :IRC Operators online}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 252, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{38 IRC Operators online}, result.text
    end

    def test_RPL_LUSERUNKNOWN
      message = %{:asimov.freenode.net 253 crookshanks 14 :unknown connection(s)}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 253, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{14 unknown connection(s)}, result.text
    end

    def test_RPL_LUSERCHANNELS
      message = %{:asimov.freenode.net 254 crookshanks 39099 :channels formed}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 254, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{39099 channels formed}, result.text
    end

    def test_RPL_LUSERME
      message = %{:asimov.freenode.net 255 crookshanks :I have 4029 clients and 8 servers}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 255, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{I have 4029 clients and 8 servers}, result.text
    end

    def test_RPL_LOCALUSERS
      message = %{:asimov.freenode.net 265 crookshanks 4029 6875 :Current local users 4029, max 6875}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 265, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{Current local users 4029, max 6875}, result.text
    end

    def test_RPL_GLOBALUSERS
      message = %{:asimov.freenode.net 266 crookshanks 62538 64364 :Current global users 62538, max 64364}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 266, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{Current global users 62538, max 64364}, result.text
    end

    def test_RPL_STATSCONN
      message = %{:asimov.freenode.net 250 crookshanks :Highest connection count: 6876 (6875 clients) (2102837 connections received)}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 250, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{Highest connection count: 6876 (6875 clients) (2102837 connections received)}, result.text
    end

    def test_RPL_MOTDSTART
      message = %{:asimov.freenode.net 375 crookshanks :- asimov.freenode.net Smirch::Message of the Day - }
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 375, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{- asimov.freenode.net Smirch::Message of the Day - }, result.text
    end

    def test_RPL_MOTD
      message = %{:asimov.freenode.net 372 crookshanks :- Welcome to asimov.freenode.net in Frankfurt, DE, EU. }
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 372, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{- Welcome to asimov.freenode.net in Frankfurt, DE, EU. }, result.text
    end

    def test_RPL_ENDOFMOTD
      message = %{:asimov.freenode.net 376 crookshanks :End of /MOTD command.}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 376, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal %{End of /MOTD command.}, result.text
    end

    def test_RPL_TOPIC
      message = %{:asimov.freenode.net 332 crookshanks #vim :Can't Talk? Get Registered on FreeNode (HOWTO: http://tinyurl.com/27a4cnw) | Vim 7.3.005 http://vim.sf.net | Don't ask to ask! | Before you ask :help, and :helpgrep, and google | SITE: http://vi-improved.org | WIKI: http://vim.wikia.com | FACEBOOK: http://tinyurl.com/vim-facebook | PASTE: http://vim.pastey.net | DONATE: http://www.vim.org/sponsor}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 332, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal "#vim", result.channel
      assert_equal %{Can't Talk? Get Registered on FreeNode (HOWTO: http://tinyurl.com/27a4cnw) | Vim 7.3.005 http://vim.sf.net | Don't ask to ask! | Before you ask :help, and :helpgrep, and google | SITE: http://vi-improved.org | WIKI: http://vim.wikia.com | FACEBOOK: http://tinyurl.com/vim-facebook | PASTE: http://vim.pastey.net | DONATE: http://www.vim.org/sponsor}, result.text
    end

    def test_RPL_TOPICWHOTIME
      message = %{:asimov.freenode.net 333 crookshanks #vim jamessan!~jamessan@debian/developer/jamessan 1284603579}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 333, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal '#vim', result.channel
      assert_equal %{jamessan!~jamessan@debian/developer/jamessan 1284603579}, result.text
    end

    def test_RPL_NAMREPLY
      message = %{:asimov.freenode.net 353 crookshanks = #vim :crookshanks amiri rejb remyo surgeon smeea galaxywatcher daniel_ RomD comand wokka AopicieR mavrc macrobat AkiraYB okayzed azoic gehdan DestinyAwaits viking WebDragon jonathanrwallace ajpiano malkomalko nevans sophacles dv_ agile riq gertidon quake_guy kTT orafu jjardon kojul drio paradigm bryanl threeve arturas pigdude fcuk112 ceej marchino julesa consumerism abstrakt vitiate1 b4d jamur2 tizbac rafab keystr0k hokapoka JohannesSM64 chris_cooke smuf}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 353, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal '#vim', result.channel
      assert_equal %{crookshanks amiri rejb remyo surgeon smeea galaxywatcher daniel_ RomD comand wokka AopicieR mavrc macrobat AkiraYB okayzed azoic gehdan DestinyAwaits viking WebDragon jonathanrwallace ajpiano malkomalko nevans sophacles dv_ agile riq gertidon quake_guy kTT orafu jjardon kojul drio paradigm bryanl threeve arturas pigdude fcuk112 ceej marchino julesa consumerism abstrakt vitiate1 b4d jamur2 tizbac rafab keystr0k hokapoka JohannesSM64 chris_cooke smuf}, result.text
    end

    def test_RPL_ENDOFNAMES
      message = %{:asimov.freenode.net 366 crookshanks #vim :End of /NAMES list.}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 366, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal '#vim', result.channel
      assert_equal %{End of /NAMES list.}, result.text
    end

    def test_RPL_CHANNELURL
      message = %{:services. 328 crookshanks #vim :http://vi-improved.org}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 328, result.code

      from = result.from
      assert_equal "services.", from.name
      assert from.server?

      assert_equal '#vim', result.channel
      assert_equal %{http://vi-improved.org}, result.text
    end

    def test_RPL_CHANNELMODEIS
      message = %{:asimov.freenode.net 324 crookshanks #hugetown +ns}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 324, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal '#hugetown', result.channel
      assert_equal %{+ns}, result.text
    end

    def test_RPL_CREATIONTIME
      message = %{:asimov.freenode.net 329 crookshanks #hugetown 1285777429}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Numeric, result
      assert_equal 329, result.code

      from = result.from
      assert_equal "asimov.freenode.net", from.name
      assert from.server?

      assert_equal '#hugetown', result.channel
      assert_equal %{1285777429}, result.text
    end

    def test_NOTICE_from_server
      message = ":gibson.freenode.net NOTICE * :*** Looking up your hostname..."
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Notice, result

      from = result.from
      assert_equal "gibson.freenode.net", from.name
      assert from.server?

      assert_equal "*** Looking up your hostname...", result.text
    end

    def test_NOTICE_from_user
      message = %{:viking!~viking@example.com NOTICE crookshanks :oh hai}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Notice, result

      from = result.from
      assert_equal "viking!~viking@example.com", from.name
      assert_equal "viking", from.nick
      assert_equal "~viking", from.user
      assert_equal "example.com", from.host
      assert from.client?

      assert_equal "oh hai", result.text
    end

    def test_NOTICE_from_services
      message = %{:ChanServ!ChanServ@services. NOTICE crookshanks :[#vim] vim discussion .. www.vim.org, vim.sf.net, :help}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Notice, result

      from = result.from
      assert_equal "ChanServ!ChanServ@services.", from.name
      assert_equal "ChanServ", from.nick
      assert_equal "ChanServ", from.user
      assert_equal "services.", from.host
      assert from.client?

      assert_equal "[#vim] vim discussion .. www.vim.org, vim.sf.net, :help", result.text
    end

    def test_PRIVMSG_from_user
      message = %{:viking!~viking@pdpc/supporter/21for7/viking PRIVMSG crookshanks :foo}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Privmsg, result

      from = result.from
      assert_equal "viking!~viking@pdpc/supporter/21for7/viking", from.name
      assert_equal "viking", from.nick
      assert_equal "~viking", from.user
      assert_equal "pdpc/supporter/21for7/viking", from.host
      assert from.client?

      assert_equal "foo", result.text
    end

    def test_PRIVMSG_to_channel
      message = %{:Silex!~ask@unitedsoft.ch PRIVMSG #vim ::D}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Privmsg, result

      from = result.from
      assert_equal "Silex!~ask@unitedsoft.ch", from.name
      assert_equal "Silex", from.nick
      assert_equal "~ask", from.user
      assert_equal "unitedsoft.ch", from.host
      assert from.client?

      assert_equal "#vim", result.channel
      assert_equal ":D", result.text
    end

    def test_MODE_for_user
      message = %{:crookshanks MODE crookshanks :+i}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Mode, result

      from = result.from
      assert_equal "crookshanks", from.name
      assert_equal "crookshanks", from.nick
      assert from.client?

      assert_equal "+i", result.text
    end

    def test_MODE_for_channel_1
      message = %{:viking!~viking@example.com MODE #hugetown +t }
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Mode, result

      from = result.from
      assert_equal "viking!~viking@example.com", from.name
      assert_equal "viking", from.nick
      assert_equal "~viking", from.user
      assert_equal "example.com", from.host
      assert from.client?

      assert_equal "#hugetown", result.channel
      assert_equal "+t", result.text
    end

    def test_MODE_for_channel_2
      message = %{:viking!~viking@example.com MODE #hugetown -o crookshanks}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Mode, result

      from = result.from
      assert_equal "viking!~viking@example.com", from.name
      assert_equal "viking", from.nick
      assert_equal "~viking", from.user
      assert_equal "example.com", from.host
      assert from.client?

      assert_equal "#hugetown", result.channel
      assert_equal "-o crookshanks", result.text
    end

    def test_JOIN
      message = %{:apropos!~apropos@89-168-187-13.dynamic.dsl.as9105.com JOIN :#vim}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Join, result

      from = result.from
      assert_equal "apropos!~apropos@89-168-187-13.dynamic.dsl.as9105.com", from.name
      assert_equal "apropos", from.nick
      assert_equal "~apropos", from.user
      assert_equal "89-168-187-13.dynamic.dsl.as9105.com", from.host
      assert from.client?

      assert_equal "#vim", result.channel
    end

    def test_PART
      message = %{:viking!~viking@example.com PART #hugetown}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Part, result

      from = result.from
      assert_equal "viking!~viking@example.com", from.name
      assert_equal "viking", from.nick
      assert_equal "~viking", from.user
      assert_equal "example.com", from.host
      assert from.client?

      assert_equal '#hugetown', result.channel
    end

    def test_PART_with_message
      message = %{:viking!~viking@example.com PART #hugetown :"Leaving"}
      result = Smirch::Message.parse(message)

      from = result.from
      assert_equal "viking!~viking@example.com", from.name
      assert_equal "viking", from.nick
      assert_equal "~viking", from.user
      assert_equal "example.com", from.host
      assert from.client?

      assert_equal '#hugetown', result.channel
      assert_equal %{"Leaving"}, result.text
    end

    def test_QUIT
      message = %{:Hates_!~hates_@host90-152-2-218.ipv4.regusnet.com QUIT :Read error: Connection reset by peer}
      result = Smirch::Message.parse(message)
      assert_instance_of Smirch::Message::Quit, result

      from = result.from
      assert_equal "Hates_!~hates_@host90-152-2-218.ipv4.regusnet.com", from.name
      assert_equal "Hates_", from.nick
      assert_equal "~hates_", from.user
      assert_equal "host90-152-2-218.ipv4.regusnet.com", from.host
      assert from.client?

      assert_equal "Read error: Connection reset by peer", result.text
    end

    ##def test_CTCP
      ##message = %{:frigg!~frigg@freenode/utility-bot/frigg PRIVMSG crookshanks :\001VERSION\001}
      ##parser = Smirch::MessageParser.new
      ##result = parser.parse(message)
      ##assert result, parser.failure_reason
    #assert_equal %{:\001VERSION\001}, result.text
    ##end
  end
end
