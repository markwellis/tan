package TAN::View::Template::Classic::FAQ;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'faq');
    print qq\
        <ul class="TAN-inside">
            <li>
                <h1>Embedding videos</h1>
                <ul>
                    <li>Can be used in comments or blogs. Links automatically embed based on the url submitted.</li>
                    <li>Embedding videos in comments is easy, just do the following, it'll be converted to the video when you post the comment.</li>
                    <li><strong><em>[video]URL[/video]</em></strong></li>
                    <li>&nbsp;</li>
                    <li>The following sites are supported</li>
                    <li>
                        <ul>
                            <li>youtube</li>
                            <li>liveleak</li>
                            <li>google video</li>
                            <li>yahoo video</li>
                            <li>spiked humor</li>
                            <li>college humor</li>
                            <li>funny or die</li>
                            <li>metacafe</li>
                            <li>daily motion</li>
                            <li>vimeo</li>
                            <li>megavideo</li>
                            <li>kontraband video</li>
                        </ul>
                    </li>
                    <li>&nbsp;</li>
                    <li><strong>Examples</strong></li>
                    <li>
                        <ul>
                            <li>[video]http://www.youtube.com/watch?v=HMhks1TSFog[/video]</li>
                            <li>[video]http://www.funnyordie.com/videos/faca37d4c7/drunk-girl-j-chris-newberg[/video]</li>
                            <li>[video]http://www.liveleak.com/view?i=774_1228266264[/video]</li>
                            <li>and so on...</li>
                        </ul>
                    </li>
                </ul>
                <br />
                <h1>Image Uploads</h1>
                <ul>
                    <li>The maximum image upload is 3mb.</li>
                    <li>Make sure you set the <a href="http://en.wikipedia.org/wiki/Not_safe_for_work">NSFW</a> option if the image isn't suitable for work</li>
                    <li>Tags are used for image searching when submitting links/blogs so please make sure they're appropriate</li>
                </ul>
                <br />
                <h1>Site Rules</h1>
                <ul>
                    <li>There kinda arnt any other than no illegal images, or goatse/similar.</li>
                    <li>Avatars must be <a href="http://en.wikipedia.org/wiki/Not_safe_for_work">SFW</a></li>
                    <li>Freedom of speech is king here. Although in <em><strong>very</strong> rare</em> cases your content may be edited or removed with valid reason; such as reposts, illegal images, or in the case of blogs, poor quality (short, nonsense, could be posted as a link/picture) etc.</li>
                    <li>All spam is forbidden and will be removed. What is spam is not strongly defined, just what we consider to be spam. Spammers can burn in hell. In the past spammers have suffered our wrath upon their site, please be aware of this if you're a spammer; also please fuck off. kthnxbye.</li>
                </ul>
                <h1>Chat (<a href="http://en.wikipedia.org/wiki/Internet_Relay_Chat">IRC</a>)</h1>
                <ul>
                    <li>Please keep IRC stuff off the main site, this means no IRC blogs etc</li>
                    <li>Don't spam IRC, keep it civil(ish)</li>
                    <li>To connect to IRC using <a href="http://www.mirc.com/">mirc</a> please install <a href="http://www.mirc.com/download/openssl-0.9.8o-setup.exe">this</a> and connect to server: <em>irc.mibbit.com</em>, port: <em>+6697</em></li>
                    <li>To connect with <a href="https://addons.mozilla.org/en-US/firefox/addon/16/">chatzilla</a>, please issue the command <em>/sslserver irc.mibbit.com:6697</em>, or click <a href="ircs://irc.mibbit.com:6697/#thisaintnews">here</a></li>
                    <li>The room we use is <em>#thisaintnews</em> join with the command <em>/join #thisaintnews</em></li>
                </ul>
                <br />
                <h1>Search</h1>
                <ul>
                    <li>you can do a more advanced search using the following fields</li>
                    <ul>
                        <li>id:number</li>
                        <li>title:text</li>
                        <li>description:text</li>
                        <li>nsfw:y|n</li>
                        <li>type:link|blog|picture</li>
                    </ul>
                    <li>you can also use the keywords <em>AND</em> <em>OR</em> and <em>quotes(&quot;)</em> to group details</li>
                    <li><strong>examples</strong></li>
                    <ul>
                        <li>type:link description:&quot;Michael Jackson has died&quot;</li>
                        <li>type:picture nsfw:y</li>
                    </ul>
                </ul>
            </li>
        </ul>\;
}

1;