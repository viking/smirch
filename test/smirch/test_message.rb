require 'helper'

class Smirch
  class TestMessage < Test::Unit::TestCase
    def test_NOTICE_from_server
      message = ":gibson.freenode.net NOTICE * :*** Looking up your hostname..."
      result = Message.parse(message)
      assert_equal "NOTICE", result.command

      origin = result.origin
      assert_equal "gibson.freenode.net", origin.full_name
      assert origin.server?

      recipient = result.recipient
      assert_equal "*", recipient.full_name

      assert_equal "*** Looking up your hostname...", result.text
    end

    def test_RPL_WELCOME
      message = %{:asimov.freenode.net 001 crookshanks :Welcome to the freenode Internet Relay Chat Network crookshanks}
      result = Message.parse(message)
      assert_equal "001", result.command

      origin = result.origin
      assert_equal "asimov.freenode.net", origin.full_name
      assert origin.server?

      recipient = result.recipient
      assert_equal "crookshanks", recipient.full_name
      assert_equal "crookshanks", recipient.nick
      assert recipient.client?

      assert_equal "Welcome to the freenode Internet Relay Chat Network crookshanks", result.text
    end

    #def test_RPL_YOURHOST
      #message = %{:kornbluth.freenode.net 002 crookshanks :Your host is kornbluth.freenode.net[82.96.64.4/6666], running version ircd-seven-1.0.0}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_CREATED
      #message = %{:kornbluth.freenode.net 003 crookshanks :This server was created Sat Jan 30 2010 at 01:11:04 CET}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_MYINFO
      #message = %{:kornbluth.freenode.net 004 crookshanks kornbluth.freenode.net ircd-seven-1.0.0 DOQRSZaghilopswz CFILMPQbcefgijklmnopqrstvz bkloveqjfI}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_ISUPPORT_1
      #message = %{:kornbluth.freenode.net 005 crookshanks CHANTYPES=# EXCEPTS INVEX CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode KNOCK STATUSMSG=@+ CALLERID=g :are supported by this server}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_ISUPPORT_2
      #message = %{:kornbluth.freenode.net 005 crookshanks SAFELIST ELIST=U CASEMAPPING=rfc1459 CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 ETRACE CPRIVMSG CNOTICE DEAF=D MONITOR=100 :are supported by this server}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_ISUPPORT_3
      #message = %{:kornbluth.freenode.net 005 crookshanks FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: EXTBAN=$,arx WHOX CLIENTVER=3.0 :are supported by this server}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_LUSERCLIENT
      #message = %{:kornbluth.freenode.net 251 crookshanks :There are 766 users and 61772 invisible on 24 servers}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_LUSEROP
      #message = %{:kornbluth.freenode.net 252 crookshanks 38 :IRC Operators online}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_LUSERUNKNOWN
      #message = %{:kornbluth.freenode.net 253 crookshanks 14 :unknown connection(s)}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_LUSERCHANNELS
      #message = %{:kornbluth.freenode.net 254 crookshanks 39099 :channels formed}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_LUSERME
      #message = %{:kornbluth.freenode.net 255 crookshanks :I have 4029 clients and 8 servers}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_LOCALUSERS
      #message = %{:kornbluth.freenode.net 265 crookshanks 4029 6875 :Current local users 4029, max 6875}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_GLOBALUSERS
      #message = %{:kornbluth.freenode.net 266 crookshanks 62538 64364 :Current global users 62538, max 64364}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_STATSCONN
      #message = %{:kornbluth.freenode.net 250 crookshanks :Highest connection count: 6876 (6875 clients) (2102837 connections received)}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_MOTDSTART
      #message = %{:kornbluth.freenode.net 375 crookshanks :- kornbluth.freenode.net Message of the Day - }
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_MOTD
      #message = %{:kornbluth.freenode.net 372 crookshanks :- Welcome to kornbluth.freenode.net in Frankfurt, DE, EU. }
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_ENDOFMOTD
      #message = %{:kornbluth.freenode.net 376 crookshanks :End of /MOTD command.}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    def test_MODE
      message = %{:crookshanks MODE crookshanks :+i}
      result = Message.parse(message)
      assert_equal "MODE", result.command

      origin = result.origin
      assert_equal "crookshanks", origin.full_name
      assert_equal "crookshanks", origin.nick
      assert origin.client?

      recipient = result.recipient
      assert_equal "crookshanks", recipient.full_name
      assert_equal "crookshanks", recipient.nick
      assert recipient.client?

      assert_equal "+i", result.text
    end

    def test_PRIVMSG
      message = %{:viking!~viking@pdpc/supporter/21for7/viking PRIVMSG crookshanks :foo}
      result = Message.parse(message)
      assert_equal "PRIVMSG", result.command

      origin = result.origin
      assert_equal "viking!~viking@pdpc/supporter/21for7/viking", origin.full_name
      assert_equal "viking", origin.nick
      assert_equal "~viking", origin.user
      assert_equal "pdpc/supporter/21for7/viking", origin.host
      assert origin.client?

      recipient = result.recipient
      assert_equal "crookshanks", recipient.full_name
      assert_equal "crookshanks", recipient.nick
      assert recipient.client?

      assert_equal "foo", result.text
    end

    #def test_RPL_TOPIC
      #message = %{:kornbluth.freenode.net 332 crookshanks #vim :Can't Talk? Get Registered on FreeNode (HOWTO: http://tinyurl.com/27a4cnw) | Vim 7.3.005 http://vim.sf.net | Don't ask to ask! | Before you ask :help, and :helpgrep, and google | SITE: http://vi-improved.org | WIKI: http://vim.wikia.com | FACEBOOK: http://tinyurl.com/vim-facebook | PASTE: http://vim.pastey.net | DONATE: http://www.vim.org/sponsor}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_TOPICWHOTIME
      #message = %{:kornbluth.freenode.net 333 crookshanks #vim jamessan!~jamessan@debian/developer/jamessan 1284603579}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_NAMREPLY
      #message = %{:kornbluth.freenode.net 353 crookshanks = #vim :crookshanks amiri rejb remyo surgeon smeea galaxywatcher daniel_ RomD comand wokka AopicieR mavrc macrobat AkiraYB okayzed azoic gehdan DestinyAwaits viking WebDragon jonathanrwallace ajpiano malkomalko nevans sophacles dv_ agile riq gertidon quake_guy kTT orafu jjardon kojul drio paradigm bryanl threeve arturas pigdude fcuk112 ceej marchino julesa consumerism abstrakt vitiate1 b4d jamur2 tizbac rafab keystr0k hokapoka JohannesSM64 chris_cooke smuf}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_ENDOFNAMES
      #message = %{:kornbluth.freenode.net 366 crookshanks #vim :End of /NAMES list.}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    def test_NOTICE_from_user
      message = %{:viking!~viking@huge.com NOTICE crookshanks :oh hai}
      result = Message.parse(message)
      assert_equal "NOTICE", result.command

      origin = result.origin
      assert_equal "viking!~viking@huge.com", origin.full_name
      assert_equal "viking", origin.nick
      assert_equal "~viking", origin.user
      assert_equal "huge.com", origin.host
      assert origin.client?

      recipient = result.recipient
      assert_equal "crookshanks", recipient.full_name
      assert_equal "crookshanks", recipient.nick
      assert recipient.client?

      assert_equal "oh hai", result.text
    end

    def test_NOTICE_from_services
      message = %{:ChanServ!ChanServ@services. NOTICE crookshanks :[#vim] vim discussion .. www.vim.org, vim.sf.net, :help}
      result = Message.parse(message)
      assert_equal "NOTICE", result.command

      origin = result.origin
      assert_equal "ChanServ!ChanServ@services.", origin.full_name
      assert_equal "ChanServ", origin.nick
      assert_equal "ChanServ", origin.user
      assert_equal "services.", origin.host
      assert origin.client?

      recipient = result.recipient
      assert_equal "crookshanks", recipient.full_name
      assert_equal "crookshanks", recipient.nick
      assert recipient.client?

      assert_equal "[#vim] vim discussion .. www.vim.org, vim.sf.net, :help", result.text
    end

    #def test_RPL_CHANNELURL
      #message = %{:services. 328 crookshanks #vim :http://vi-improved.org}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    def test_PRIVMSG_to_channel
      message = %{:Silex!~ask@unitedsoft.ch PRIVMSG #vim ::D}
      result = Message.parse(message)
      assert_equal "PRIVMSG", result.command

      origin = result.origin
      assert_equal "Silex!~ask@unitedsoft.ch", origin.full_name
      assert_equal "Silex", origin.nick
      assert_equal "~ask", origin.user
      assert_equal "unitedsoft.ch", origin.host
      assert origin.client?

      recipient = result.recipient
      assert_equal "#vim", recipient.full_name
      assert recipient.channel?

      assert_equal ":D", result.text
    end

    def test_JOIN
      message = %{:apropos!~apropos@89-168-187-13.dynamic.dsl.as9105.com JOIN :#vim}
      result = Message.parse(message)
      assert_equal "JOIN", result.command

      origin = result.origin
      assert_equal "apropos!~apropos@89-168-187-13.dynamic.dsl.as9105.com", origin.full_name
      assert_equal "apropos", origin.nick
      assert_equal "~apropos", origin.user
      assert_equal "89-168-187-13.dynamic.dsl.as9105.com", origin.host
      assert origin.client?

      channel = result.channel
      assert_equal "#vim", channel.full_name
      assert channel.channel?
    end

    def test_QUIT
      message = %{:Hates_!~hates_@host90-152-2-218.ipv4.regusnet.com QUIT :Read error: Connection reset by peer}
      result = Message.parse(message)
      assert_equal "QUIT", result.command

      origin = result.origin
      assert_equal "Hates_!~hates_@host90-152-2-218.ipv4.regusnet.com", origin.full_name
      assert_equal "Hates_", origin.nick
      assert_equal "~hates_", origin.user
      assert_equal "host90-152-2-218.ipv4.regusnet.com", origin.host
      assert origin.client?

      assert_equal "Read error: Connection reset by peer", result.text
    end

    def test_PART
      message = %{:viking!~viking@pdpc/supporter/21for7/viking PART #hugetown :"Leaving"}
      result = Message.parse(message)
      assert_equal "PART", result.command

      origin = result.origin
      assert_equal "viking!~viking@pdpc/supporter/21for7/viking", origin.full_name
      assert_equal "viking", origin.nick
      assert_equal "~viking", origin.user
      assert_equal "pdpc/supporter/21for7/viking", origin.host
      assert origin.client?

      recipient = result.recipient
      assert_equal "#hugetown", recipient.full_name
      assert recipient.channel?

      assert_equal %{"Leaving"}, result.text
    end

    #def test_RPL_CHANNELMODEIS
      #message = %{:hubbard.freenode.net 324 crookshanks #hugetown +ns}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_RPL_CREATIONTIME
      #message = %{:hubbard.freenode.net 329 crookshanks #hugetown 1285777429}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end

    #def test_CTCP
      #message = %{:frigg!~frigg@freenode/utility-bot/frigg PRIVMSG crookshanks :\001VERSION\001}
      #parser = MessageParser.new
      #result = parser.parse(message)
      #assert result, parser.failure_reason
    #end
  end
end
