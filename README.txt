This program records last.fm radio stations. It works best on my computer, which is running OS X, though I run Debian GNU/Linux sometimes too, when I'm not drunkencoding. This program is by no means "good" or "portable" software. It just works for me. I hope it does the same for you.

FUN FACTS!

I wrote this program by reverse engineering the last.fm protocol, which is all going over unencrypted HTTP. It took an application named Wireshark, the official last.fm client application and about 3 hours of picking apart headers and testing HTTP sessions with Curl. This was primarily an exercise for me in HTTP web services and Ruby coding.

Recording the radio is not illegal! Last.fm does not let you choose the playlist you can listen to. It is a "DJ", which is a computer program that plays songs it thinks you would like to hear. Think of this software as a cassette tape, now that Muxtape is R.I.P.

Author:
Lee Azzarello <lee@rockingtiger.com>
