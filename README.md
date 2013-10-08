[![Stories in Ready](https://badge.waffle.io/7even/vkontakte_api.png?label=ready)](https://waffle.io/7even/vkontakte_api)  
## vkontakte_api [![Build Status](https://secure.travis-ci.org/7even/vkontakte_api.png)](http://travis-ci.org/7even/vkontakte_api) [![Gem Version](https://badge.fury.io/rb/vkontakte_api.png)](http://badge.fury.io/rb/vkontakte_api) [![Dependency Status](https://gemnasium.com/7even/vkontakte_api.png)](https://gemnasium.com/7even/vkontakte_api) [![Code Climate](https://codeclimate.com/github/7even/vkontakte_api.png)](https://codeclimate.com/github/7even/vkontakte_api)

`vkontakte_api` - ruby-P0P4P0P?QP5Q  P4P;Q PPP>P=QP0P:QP5 API. PP= P?P>P7P2P>P;QP5Q P2QP7QP2P0QQ P<P5QP>P4Q API, P7P0P3Q QP6P0QQ QP0P9P;Q P=P0 QP5Q P2P5Q P0 PPP>P=QP0P:QP5, P0 QP0P:P6P5 P?P>P4P4P5Q P6P8P2P0P5Q P2QP5 3 P4P>QQQP?P=QQ QP?P>QP>P1P0 P0P2QP>Q P8P7P0QP8P8 (P?Q P8 QQP>P< P?P>P7P2P>P;QQ P8QP?P>P;QP7P>P2P0QQ QQP>Q P>P=P=P5P5 Q P5QP5P=P8P5).

## P#QQP0P=P>P2P:P0

``` ruby
# Gemfile
gem 'vkontakte_api', '~> 1.2'
```

P8P;P8 P?Q P>QQP>

``` sh
$ gem install vkontakte_api
```

## PQP?P>P;QP7P>P2P0P=P8P5

### PQP7P>P2 P<P5QP>P4P>P2

``` ruby
# QP>P7P4P0P5P< P:P;P8P5P=Q
@vk = VkontakteApi::Client.new
# P8 P2QP7QP2P0P5P< P<P5QP>P4Q API
@vk.users.get(uid: 1)

# P2 ruby P?Q P8P=QQP> P8QP?P>P;QP7P>P2P0QQ snake_case P2 P=P0P7P2P0P=P8QQ P<P5QP>P4P>P2,
# P?P>QQP>P<Q likes.getList QQP0P=P>P2P8QQQ likes.get_list
@vk.likes.get_list
# QP0P:P6P5 P=P0P7P2P0P=P8Q P<P5QP>P4P>P2, P:P>QP>Q QP5 P2P>P7P2Q P0Q	P0QQ '1' P8P;P8 '0',
# P7P0P:P0P=QP8P2P0QQQQ P=P0 '?', P0 P2P>P7P2Q P0Q	P0P5P<QP5 P7P=P0QP5P=P8Q P?Q P8P2P>P4QQQQ
# P: true P8P;P8 false
@vk.is_app_user? # => false

# P5QP;P8 PPP>P=QP0P:QP5 P>P6P8P4P0P5Q P?P>P;QQP8QQ P?P0Q P0P<P5QQ  P2 P2P8P4P5 QP?P8QP:P0,
# Q P0P7P4P5P;P5P=P=P>P3P> P7P0P?QQQP<P8, QP> P5P3P> P<P>P6P=P> P?P5Q P5P4P0QQ P<P0QQP8P2P>P<
users = @vk.users.get(uids: [1, 2, 3])

# P1P>P;QQP8P=QQP2P> P<P5QP>P4P>P2 P2P>P7P2Q P0Q	P0P5Q QQQ QP:QQQ Q Hashie::Mash
# P8 P<P0QQP8P2Q P8P7 P=P8Q
users.first.uid        # => 1
users.first.first_name # => "PP0P2P5P;"
users.first.last_name  # => "PQQ P>P2"

# P5QP;P8 P<P5QP>P4, P2P>P7P2Q P0Q	P0QQ	P8P9 P<P0QQP8P2, P2QP7QP2P0P5QQQ Q P1P;P>P:P>P<,
# QP> P1P;P>P: P1QP4P5Q P2QP?P>P;P=P5P= P4P;Q P:P0P6P4P>P3P> QP;P5P<P5P=QP0,
# P8 P<P5QP>P4 P2P5Q P=P5Q P>P1Q P0P1P>QP0P=P=QP9 P<P0QQP8P2
fields = [:first_name, :last_name, :screen_name]
@vk.friends.get(uid: 2, fields: fields) do |friend|
  "#{friend.first_name} '#{friend.screen_name}' #{friend.last_name}"
end
# => ["PP0P2P5P; 'durov' PQQ P>P2"]
```

### PP0P3Q QP7P:P0 QP0P9P;P>P2

PP0P3Q QP7P:P0 QP0P9P;P>P2 P=P0 QP5Q P2P5Q P0 PPP>P=QP0P:QP5 P>QQQ	P5QQP2P;QP5QQQ P2 P=P5QP:P>P;QP:P> QQP0P?P>P2: QP=P0QP0P;P0 P2QP7QP2P0P5QQQ P<P5QP>P4 API, P2P>P7P2Q P0Q	P0QQ	P8P9 URL P4P;Q P7P0P3Q QP7P:P8, P7P0QP5P< P?Q P>P8QQP>P4P8Q QP0P<P0 P7P0P3Q QP7P:P0 QP0P9P;P>P2, P8 P?P>QP;P5 QQP>P3P> P2 P=P5P:P>QP>Q QQ QP;QQP0QQ P=QP6P=P> P2QP7P2P0QQ P4Q QP3P>P9 P<P5QP>P4 API, P?P5Q P5P4P0P2 P2 P?P0Q P0P<P5QQ P0Q P4P0P=P=QP5, P2P>P7P2Q P0Q	P5P=P=QP5 QP5Q P2P5Q P>P< P?P>QP;P5 P?Q P5P4QP4QQ	P5P3P> P7P0P?Q P>QP0. PQP7QP2P0P5P<QP5 P<P5QP>P4Q API P7P0P2P8QQQ P>Q QP8P?P0 P7P0P3Q QP6P0P5P<QQ QP0P9P;P>P2 P8 P>P?P8QP0P=Q P2 [QP>P>QP2P5QQQP2QQQ	P5P< Q P0P7P4P5P;P5 P4P>P:QP<P5P=QP0QP8P8](http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81_%D0%B7%D0%B0%D0%B3%D1%80%D1%83%D0%B7%D0%BA%D0%B8_%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2_%D0%BD%D0%B0_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80_%D0%92%D0%9A%D0%BE%D0%BD%D1%82%D0%B0%D0%BA%D1%82%D0%B5).

P$P0P9P;Q P?P5Q P5P4P0QQQQ P2 QP>Q P<P0QP5 QQQP0, P3P4P5 P:P;QQP>P< QP2P;QP5QQQ P=P0P7P2P0P=P8P5 P?P0Q P0P<P5QQ P0 P2 P7P0P?Q P>QP5 (QP:P0P7P0P=P> P2 P4P>P:QP<P5P=QP0QP8P8, P=P0P?Q P8P<P5Q  P4P;Q P7P0P3Q QP7P:P8 QP>QP> P=P0 QQP5P=Q QQP> P1QP4P5Q `photo`), P0 P7P=P0QP5P=P8P5P< - P<P0QQP8P2 P8P7 2 QQQ P>P:: P?P>P;P=QP9 P?QQQ P: QP0P9P;Q P8 P5P3P> MIME-QP8P?:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: ['/path/to/file.jpg', 'image/jpeg'])
```

PP5QP>P4 P2P5Q P=P5Q P>QP2P5Q QP5Q P2P5Q P0 PPP>P=QP0P:QP5, P?Q P5P>P1Q P0P7P>P2P0P=P=QP9 P2 `Hashie::Mash`; P5P3P> P<P>P6P=P> P8QP?P>P;QP7P>P2P0QQ P?Q P8 P2QP7P>P2P5 P<P5QP>P4P0 API P=P0 P?P>QP;P5P4P=P5P< QQP0P?P5 P?Q P>QP5QQP0 P7P0P3Q QP7P:P8.

### PP2QP>Q P8P7P0QP8Q

PP;Q P2QP7P>P2P0 P1P>P;QQP8P=QQP2P0 P<P5QP>P4P>P2 QQ P5P1QP5QQQ QP>P:P5P= P4P>QQQP?P0 (access token). P'QP>P1Q P?P>P;QQP8QQ P5P3P>, P<P>P6P=P> P8QP?P>P;QP7P>P2P0QQ P0P2QP>Q P8P7P0QP8Q, P2QQQ P>P5P=P=QQ P2 `vkontakte_api`, P;P8P1P> P?P>P;P>P6P8QQQQ P=P0 P:P0P:P>P9-QP> P4Q QP3P>P9 P<P5QP0P=P8P7P< (P=P0P?Q P8P<P5Q , [OmniAuth](https://github.com/intridea/omniauth)). P P?P>QP;P5P4P=P5P< QP;QQP0P5 P2 Q P5P7QP;QQP0QP5 P0P2QP>Q P8P7P0QP8P8 P1QP4P5Q P?P>P;QQP5P= QP>P:P5P=, P:P>QP>Q QP9 P=QP6P=P> P1QP4P5Q P?P5Q P5P4P0QQ P2 `VkontakteApi::Client.new`.

PP;Q Q P0P1P>QQ Q PPP>P=QP0P:QP5 API P?Q P5P4QQP<P>QQ P5P=P> 3 QP8P?P0 P0P2QP>Q P8P7P0QP8P8: P4P;Q QP0P9QP>P2, P4P;Q P:P;P8P5P=QQP:P8Q P?Q P8P;P>P6P5P=P8P9 (P<P>P1P8P;QP=QQ P;P8P1P> P4P5QP:QP>P?P=QQ, P8P<P5QQ	P8Q P4P>QQQP? P: QP?Q P0P2P;P5P=P8Q P1Q P0QP7P5Q P>P<) P8 QP?P5QP8P0P;QP=QP9 QP8P? P0P2QP>Q P8P7P0QP8P8 QP5Q P2P5Q P>P2 P?Q P8P;P>P6P5P=P8P9 P4P;Q P2QP7P>P2P0 P0P4P<P8P=P8QQQ P0QP8P2P=QQ P<P5QP>P4P>P2 P1P5P7 P0P2QP>Q P8P7P0QP8P8 QP0P<P>P3P> P?P>P;QP7P>P2P0QP5P;Q. PP>P;P5P5 P?P>P4Q P>P1P=P> P>P=P8 P>P?P8QP0P=Q [QQQ](http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F); Q P0QQP<P>QQ P8P<, P:P0P: Q P0P1P>QP0QQ Q P=P8P<P8 QQ P5P4QQP2P0P<P8 `vkontakte_api`.

PP;Q P0P2QP>Q P8P7P0QP8P8 P=P5P>P1QP>P4P8P<P> P7P0P4P0QQ P?P0Q P0P<P5QQ Q `app_id` (ID P?Q P8P;P>P6P5P=P8Q), `app_secret` (P7P0Q	P8Q	P5P=P=QP9 P:P;QQ) P8 `redirect_uri` (P0P4Q P5Q, P:QP4P0 P?P>P;QP7P>P2P0QP5P;Q P1QP4P5Q P=P0P?Q P0P2P;P5P= P?P>QP;P5 P?Q P5P4P>QQP0P2P;P5P=P8Q P?Q P0P2 P?Q P8P;P>P6P5P=P8Q) P2 P=P0QQQ P>P9P:P0Q `VkontakteApi.configure`. PP>P;P5P5 P?P>P4Q P>P1P=P> P> P:P>P=QP8P3QQ P8Q P>P2P0P=P8P8 `vkontakte_api` QP<. P4P0P;P5P5 P2 QP>P>QP2P5QQQP2QQQ	P5P< Q P0P7P4P5P;P5.

##### P!P0P9Q

PP2QP>Q P8P7P0QP8Q QP0P9QP>P2 P?Q P>QP>P4P8Q P2 2 QP0P3P0. P!P=P0QP0P;P0 P?P>P;QP7P>P2P0QP5P;Q P?P5Q P5P=P0P?Q P0P2P;QP5QQQ P=P0 QQQ P0P=P8QQ PPP>P=QP0P:QP5 P4P;Q P?P>P4QP2P5Q P6P4P5P=P8Q P7P0P?Q P>QP5P=P=QQ Q P=P5P3P> P?Q P0P2 QP0P9QP0 P=P0 P4P>QQQP? P: P5P3P> P4P0P=P=QP<. P!P> QP?P8QP:P>P< P2P>P7P<P>P6P=QQ P?Q P0P2 P<P>P6P=P> P>P7P=P0P:P>P<P8QQQQ [P7P4P5QQ](http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%B0%D0%B2%D0%B0_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0_%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B9). PP>P?QQQP8P<, P=QP6P=P> P?P>P;QQP8QQ P4P>QQQP? P: P4Q QP7QQP< (`friends`) P8 QP>QP>P3Q P0QP8QP< (`photos`) P?P>P;QP7P>P2P0QP5P;Q.

P QP>P>QP2P5QQQP2P8P8 Q [Q P5P:P>P<P5P=P4P0QP8QP<P8](http://tools.ietf.org/html/draft-ietf-oauth-v2-30#section-10.12) P2 P?Q P>QP>P:P>P;P5 OAuth2 P4P;Q P7P0Q	P8QQ P>Q [CSRF](http://ru.wikipedia.org/wiki/%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D0%BB%D0%BA%D0%B0_%D0%BC%D0%B5%D0%B6%D1%81%D0%B0%D0%B9%D1%82%D0%BE%D0%B2%D1%8B%D1%85_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2), P=QP6P=P> P?P5Q P5P4P0QQ P?P0Q P0P<P5QQ  `state`, QP>P4P5Q P6P0Q	P8P9 QP;QQP0P9P=P>P5 P7P=P0QP5P=P8P5.

``` ruby
session[:state] = Digest::MD5.hexdigest(rand.to_s)
redirect_to VkontakteApi.authorization_url(scope: [:notify, :friends, :photos], state: session[:state])
```

PP>QP;P5 P?P>P4QP2P5Q P6P4P5P=P8Q P?P>P;QP7P>P2P0QP5P;Q P?P5Q P5P=P0P?Q P0P2P;QP5QQQ P=P0 QP:P0P7P0P=P=QP9 P2 P=P0QQQ P>P9P:P0Q `redirect_uri`, P?Q P8QP5P< P2 P?P0Q P0P<P5QQ P0Q P1QP4P5Q P?P5Q P5P4P0P= P:P>P4, P?P> P:P>QP>Q P>P<Q P<P>P6P=P> P?P>P;QQP8QQ QP>P:P5P= P4P>QQQP?P0, P0 QP0P:P6P5 P?P5Q P5P4P0P=P=QP9 Q P0P=P5P5 `state`. PQP;P8 `state` P=P5 QP>P2P?P0P4P0P5Q Q QP5P<, P:P>QP>Q QP9 P1QP; P8QP?P>P;QP7P>P2P0P= P?Q P8 P>QP?Q P0P2P;P5P=P8P8 P?P>P;QP7P>P2P0QP5P;Q P=P0 PPP>P=QP0P:QP5, QP> QP:P>Q P5P5 P2QP5P3P> QQP> P?P>P?QQP:P0 CSRF-P0QP0P:P8 - QQP>P8Q P>QP?Q P0P2P8QQ P?P>P;QP7P>P2P0QP5P;Q P=P0 P?P>P2QP>Q P=QQ P0P2QP>Q P8P7P0QP8Q.

``` ruby
redirect_to login_url, alert: 'PQP8P1P:P0 P0P2QP>Q P8P7P0QP8P8' if params[:state] != session[:state]
```

`vkontakte_api` P?Q P5P4P>QQP0P2P;QP5Q P<P5QP>P4 `VkontakteApi.authorize`, P:P>QP>Q QP9 P4P5P;P0P5Q P7P0P?Q P>Q P: PPP>P=QP0P:QP5, P?P>P;QQP0P5Q QP>P:P5P= P8 QP>P7P4P0P5Q P:P;P8P5P=Q; P=QP6P=P> P;P8QQ P?P5Q P5P4P0QQ P5P<Q P:P>P4:

``` ruby
@vk = VkontakteApi.authorize(code: params[:code])
# P8 QP5P?P5Q Q P<P>P6P=P> P2QP7QP2P0QQ P<P5QP>P4Q API P=P0 P>P1Q
P5P:QP5 @vk
@vk.is_app_user?
```

PP;P8P5P=Q P1QP4P5Q QP>P4P5Q P6P0QQ id P?P>P;QP7P>P2P0QP5P;Q, P0P2QP>Q P8P7P>P2P0P2QP5P3P> P?Q P8P;P>P6P5P=P8P5; P5P3P> P<P>P6P=P> P?P>P;QQP8QQ Q P?P>P<P>Q	QQ P<P5QP>P4P0 `VkontakteApi::Client#user_id`:

``` ruby
@vk.user_id # => 123456
```

P"P0P:P6P5 P2 QQP>Q P<P>P<P5P=Q P?P>P;P5P7P=P> QP>QQ P0P=P8QQ P?P>P;QQP5P=P=QP9 QP>P:P5P= (P8, P?Q P8 P=P5P>P1QP>P4P8P<P>QQP8, id P?P>P;QP7P>P2P0QP5P;Q) P2 PP P;P8P1P> P2 QP5QQP8P8, QQP>P1Q P8QP?P>P;QP7P>P2P0QQ P8Q P?P>P2QP>Q P=P>:

``` ruby
current_user.token = @vk.token
current_user.vk_id = @vk.user_id
current_user.save
# P?P>P7P6P5
@vk = VkontakteApi::Client.new(current_user.token)
```

##### PP;P8P5P=QQP:P>P5 P?Q P8P;P>P6P5P=P8P5

PP2QP>Q P8P7P0QP8Q P:P;P8P5P=QQP:P>P3P> P?Q P8P;P>P6P5P=P8Q P=P5QP:P>P;QP:P> P?Q P>Q	P5 - P=P5 P=QP6P=P> P?P>P;QQP0QQ QP>P:P5P= P>QP4P5P;QP=QP< P7P0P?Q P>QP>P<, P>P= P2QP4P0P5QQQ QQ P0P7Q P?P>QP;P5 Q P5P4P8Q P5P:QP0 P?P>P;QP7P>P2P0QP5P;Q.

``` ruby
# P?P>P;QP7P>P2P0QP5P;Q P=P0P?Q P0P2P;QP5QQQ P=P0 QP;P5P4QQQ	P8P9 QQ P;
VkontakteApi.authorization_url(type: :client, scope: [:friends, :photos])
```

PP5P>P1QP>P4P8P<P> P?Q P8P=P8P<P0QQ P2P> P2P=P8P<P0P=P8P5, QQP> `redirect_uri` P=QP6P=P> P2QQQP0P2P;QQQ P=P0 `http://api.vkontakte.ru/blank.html`, P8P=P0QP5 P=P5 P?P>P;QQP8QQQ P2QP7QP2P0QQ P<P5QP>P4Q, P4P>QQQP?P=QP5 P:P;P8P5P=QQP:P8P< P?Q P8P;P>P6P5P=P8QP<.

PP>P3P4P0 P?P>P;QP7P>P2P0QP5P;Q P?P>P4QP2P5Q P4P8Q P?Q P0P2P0 P?Q P8P;P>P6P5P=P8Q, P>P= P1QP4P5Q P?P5Q P5P=P0P?Q P0P2P;P5P= P=P0 `redirect_uri`, P?Q P8 QQP>P< P2 P?P0Q P0P<P5QQ P5 `access_token` P1QP4P5Q QP>P:P5P=, P:P>QP>Q QP9 P=QP6P=P> P?P5Q P5P4P0QQ P2 `VkontakteApi::Client.new`.

##### P!P5Q P2P5Q  P?Q P8P;P>P6P5P=P8Q

PP>QP;P5P4P=P8P9 QP8P? P0P2QP>Q P8P7P0QP8P8 - QP0P<QP9 P?Q P>QQP>P9, Q.P:. P=P5 P?Q P5P4P?P>P;P0P3P0P5Q QQP0QQP8Q P?P>P;QP7P>P2P0QP5P;Q.

``` ruby
@vk = VkontakteApi.authorize(type: :app_server)
```

### PQ P>QP5P5

PQP;P8 P:P;P8P5P=Q API (P>P1Q
P5P:Q P:P;P0QQP0 `VkontakteApi::Client`) P1QP; QP>P7P4P0P= Q P?P>P<P>Q	QQ P<P5QP>P4P0 `VkontakteApi.authorize`, P>P= P1QP4P5Q QP>P4P5Q P6P0QQ P8P=QP>Q P<P0QP8Q P>P1 id QP5P:QQ	P5P3P> P?P>P;QP7P>P2P0QP5P;Q (`user_id`) P8 P> P2Q P5P<P5P=P8 P8QQP5QP5P=P8Q QP>P:P5P=P0 (`expires_at`). PP>P;QQP8QQ P8Q P<P>P6P=P> Q P?P>P<P>Q	QQ QP>P>QP2P5QQQP2QQQ	P8Q P<P5QP>P4P>P2:

``` ruby
vk = VkontakteApi.authorize(code: 'c1493e81f69fce1b43')
# => #<VkontakteApi::Client:0x007fa578f00ad0>
vk.user_id    # => 628985
vk.expires_at # => 2012-12-18 23:22:55 +0400
# P<P>P6P=P> P?Q P>P2P5Q P8QQ, P8QQP5P:P;P> P;P8 P2Q P5P<Q P6P8P7P=P8 QP>P:P5P=P0
vk.expired?   # => false
```

P"P0P:P6P5 P<P>P6P=P> P?P>P;QQP8QQ QP?P8QP>P: P?Q P0P2 P4P>QQQP?P0, P:P>QP>Q QP5 P4P0P5Q P4P0P=P=QP9 QP>P:P5P=, P2 P2P8P4P5, P0P=P0P;P>P3P8QP=P>P< QP>Q P<P0QQ P?P0Q P0P<P5QQ P0 `scope` P2 P0P2QP>Q P8P7P0QP8P8:

``` ruby
vk.scope # => [:friends, :groups]
```

P-QP> Q P0P1P>QP0P5Q P=P0 P>QP=P>P2P5 P<P5QP>P4P0 `getUserSettings`, P?Q P8QP5P< Q P5P7QP;QQP0Q P7P0P?P>P<P8P=P0P5QQQ P?P>QP;P5 P?P5Q P2P>P3P> P>P1Q P0Q	P5P=P8Q.

P'QP>P1Q QP>P7P4P0QQ P:P>Q P>QP:P8P9 QP8P=P>P=P8P< `VK` P4P;Q P<P>P4QP;Q `VkontakteApi`, P4P>QQP0QP>QP=P> P2QP7P2P0QQ P<P5QP>P4 `VkontakteApi.register_alias`:

``` ruby
VkontakteApi.register_alias
VK::Client.new # => #<VkontakteApi::Client:0x007fa578d6d948>
```

PQ P8 P=P5P>P1QP>P4P8P<P>QQP8 P<P>P6P=P> QP4P0P;P8QQ QP8P=P>P=P8P< P<P5QP>P4P>P< `VkontakteApi.unregister_alias`:

``` ruby
VK.unregister_alias
VK # => NameError: uninitialized constant VK
```

### PP1Q P0P1P>QP:P0 P>QP8P1P>P:

PQP;P8 PPP>P=QP0P:QP5 API P2P>P7P2Q P0Q	P0P5Q P>QP8P1P:Q, P2QP1Q P0QQP2P0P5QQQ P8QP:P;QQP5P=P8P5 P:P;P0QQP0 `VkontakteApi::Error`.

``` ruby
vk = VK::Client.new
vk.friends.get(uid: 1, fields: [:first_name, :last_name, :photo])
# VkontakteApi::Error: VKontakte returned an error 7: 'Permission to perform this action is denied' after calling method 'friends.get' with parameters {"uid"=>"1", "fields"=>"first_name,last_name,photo"}.
```

PQP>P1QP9 QP;QQP0P9 P>QP8P1P:P8 - 14: P=P5P>P1QP>P4P8P<P> P2P2P5QQP8 P:P>P4 Q captcha. P QQP>P< QP;QQP0P5 P<P>P6P=P> P?P>P;QQP8QQ P?P0Q P0P<P5QQ Q P:P0P?QP8 P<P5QP>P4P0P<P8 `VkontakteApi::Error#captcha_sid` P8 `VkontakteApi::Error#captcha_img` - P=P0P?Q P8P<P5Q , [QP0P:](https://github.com/7even/vkontakte_api/issues/10#issuecomment-11666091).

### PP>P3P3P8Q P>P2P0P=P8P5

`vkontakte_api` P;P>P3P3P8Q QP5Q QP;QP6P5P1P=QQ P8P=QP>Q P<P0QP8Q P> P7P0P?Q P>QP0Q P?Q P8 P2QP7P>P2P5 P<P5QP>P4P>P2. PP> QP<P>P;QP0P=P8Q P2QP5 P?P8QP5QQQ P2 `STDOUT`, P=P> P2 P=P0QQQ P>P9P:P5 P<P>P6P=P> QP:P0P7P0QQ P;QP1P>P9 P4Q QP3P>P9 QP>P2P<P5QQP8P<QP9 P;P>P3P3P5Q , P=P0P?Q P8P<P5Q  `Rails.logger`.

PQQQ P2P>P7P<P>P6P=P>QQQ P;P>P3P3P8Q P>P2P0P=P8Q 3 QP8P?P>P2 P8P=QP>Q P<P0QP8P8, P:P0P6P4P>P<Q QP>P>QP2P5QQQP2QP5Q P:P;QQ P2 P3P;P>P1P0P;QP=QQ P=P0QQQ P>P9P:P0Q.

|                        | P:P;QQ P=P0QQQ P>P9P:P8  | P?P> QP<P>P;QP0P=P8Q | QQ P>P2P5P=Q P;P>P3P3P8Q P>P2P0P=P8Q |
| ---------------------- | --------------- | ------------ | -------------------- |
| URL P7P0P?Q P>QP0            | `log_requests`  | `true`       | `debug`              |
| JSON P>QP2P5QP0 P?Q P8 P>QP8P1P:P5 | `log_errors`    | `true`       | `warn`               |
| JSON QP4P0QP=P>P3P> P>QP2P5QP0   | `log_responses` | `false`      | `debug`              |

P"P0P:P8P< P>P1Q P0P7P>P<, P2 rails-P?Q P8P;P>P6P5P=P8P8 Q P=P0QQQ P>P9P:P0P<P8 P?P> QP<P>P;QP0P=P8Q P2 production P7P0P?P8QQP2P0QQQQ QP>P;QP:P> P>QP2P5QQ QP5Q P2P5Q P0 P?Q P8 P>QP8P1P:P0Q; P2 development QP0P:P6P5 P;P>P3P3P8Q QQQQQ URL-Q P7P0P?Q P>QP>P2.

### PQ P8P<P5Q  P8QP?P>P;QP7P>P2P0P=P8Q

PQ P8P<P5Q  P8QP?P>P;QP7P>P2P0P=P8Q `vkontakte_api` QP>P2P<P5QQP=P> Q `eventmachine` P<P>P6P=P> P?P>QP<P>QQ P5QQ [P7P4P5QQ](https://github.com/7even/vkontakte_on_em).

P"P0P:P6P5 P1QP; P=P0P?P8QP0P= [P?Q P8P<P5Q  P8QP?P>P;QP7P>P2P0P=P8Q Q rails](https://github.com/7even/vkontakte_on_rails), P=P> P>P= P1P>P;QQP5 P=P5 Q P0P1P>QP0P5Q P8P7-P7P0 P>QQQQQQP2P8Q P?Q P0P2 P=P0 P2QP7P>P2 P<P5QP>P4P0 `newsfeed.get`.

## PP0QQQ P>P9P:P0

PP;P>P1P0P;QP=QP5 P?P0Q P0P<P5QQ Q `vkontakte_api` P7P0P4P0QQQQ P2 P1P;P>P:P5 `VkontakteApi.configure` QP;P5P4QQQ	P8P< P>P1Q P0P7P>P<:

``` ruby
VkontakteApi.configure do |config|
  # P?P0Q P0P<P5QQ Q, P=P5P>P1QP>P4P8P<QP5 P4P;Q P0P2QP>Q P8P7P0QP8P8 QQ P5P4QQP2P0P<P8 vkontakte_api
  # (P=P5 P=QP6P=Q P?Q P8 P8QP?P>P;QP7P>P2P0P=P8P8 QQP>Q P>P=P=P5P9 P0P2QP>Q P8P7P0QP8P8)
  config.app_id       = '123'
  config.app_secret   = 'AbCdE654'
  config.redirect_uri = 'http://example.com/oauth/callback'
  
  # faraday-P0P4P0P?QP5Q  P4P;Q QP5QP5P2QQ P7P0P?Q P>QP>P2
  config.adapter = :net_http
  # HTTP-P<P5QP>P4 P4P;Q P2QP7P>P2P0 P<P5QP>P4P>P2 API (:get P8P;P8 :post)
  config.http_verb = :post
  # P?P0Q P0P<P5QQ Q P4P;Q faraday-QP>P5P4P8P=P5P=P8Q
  config.faraday_options = {
    ssl: {
      ca_path:  '/usr/lib/ssl/certs'
    },
    proxy: {
      uri:      'http://proxy.example.com',
      user:     'foo',
      password: 'bar'
    }
  }
  # P<P0P:QP8P<P0P;QP=P>P5 P:P>P;P8QP5QQP2P> P?P>P2QP>Q P>P2 P7P0P?Q P>QP0 P?Q P8 P>QP8P1P:P0Q
  config.max_retries = 2
  
  # P;P>P3P3P5Q 
  config.logger        = Rails.logger
  config.log_requests  = true  # URL-Q P7P0P?Q P>QP>P2
  config.log_errors    = true  # P>QP8P1P:P8
  config.log_responses = false # QP4P0QP=QP5 P>QP2P5QQ
end
```

PP> QP<P>P;QP0P=P8Q P4P;Q HTTP-P7P0P?Q P>QP>P2 P8QP?P>P;QP7QP5QQQ `Net::HTTP`; P<P>P6P=P> P2QP1Q P0QQ [P;QP1P>P9 P4Q QP3P>P9 P0P4P0P?QP5Q ](https://github.com/technoweenie/faraday/blob/master/lib/faraday/adapter.rb), P?P>P4P4P5Q P6P8P2P0P5P<QP9 `faraday`.

PPP>P=QP0P:QP5 [P?P>P7P2P>P;QP5Q](http://vk.com/developers.php?oid=-1&p=%D0%92%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2_%D0%BA_API) P8QP?P>P;QP7P>P2P0QQ P:P0P: `GET`-, QP0P: P8 `POST`-P7P0P?Q P>QQ P?Q P8 P2QP7P>P2P5 P<P5QP>P4P>P2 API. PP> QP<P>P;QP0P=P8Q `vkontakte_api` P8QP?P>P;QP7QP5Q `POST`, P=P> P2 P=P0QQQ P>P9P:P5 `http_verb` P<P>P6P=P> QP:P0P7P0QQ `:get`, QQP>P1Q QP>P2P5Q QP0QQ `GET`-P7P0P?Q P>QQ.

PQ P8 P=P5P>P1QP>P4P8P<P>QQP8 P<P>P6P=P> QP:P0P7P0QQ P?P0Q P0P<P5QQ Q P4P;Q faraday-QP>P5P4P8P=P5P=P8Q - P=P0P?Q P8P<P5Q , P?P0Q P0P<P5QQ Q P?Q P>P:QP8-QP5Q P2P5Q P0 P8P;P8 P?QQQ P: SSL-QP5Q QP8QP8P:P0QP0P<.

P'QP>P1Q QP3P5P=P5Q P8Q P>P2P0QQ QP0P9P; Q P=P0QQQ P>P9P:P0P<P8 P?P> QP<P>P;QP0P=P8Q P2 rails-P?Q P8P;P>P6P5P=P8P8, P<P>P6P=P> P2P>QP?P>P;QP7P>P2P0QQQQ P3P5P=P5Q P0QP>Q P>P< `vkontakte_api:install`:

``` sh
$ cd /path/to/app
$ rails generate vkontakte_api:install
```

## JSON-P?P0Q QP5Q 

`vkontakte_api` P8QP?P>P;QP7QP5Q P?P0Q QP5Q  [Oj](https://github.com/ohler55/oj) - QQP> P5P4P8P=QQP2P5P=P=QP9 P?P0Q QP5Q , P:P>QP>Q QP9 P=P5 P?P>P:P0P7P0P; [P>QP8P1P>P:](https://github.com/7even/vkontakte_api/issues/1) P?Q P8 P?P0Q QP8P=P3P5 JSON, P3P5P=P5Q P8Q QP5P<P>P3P> PPP>P=QP0P:QP5.

P"P0P:P6P5 P2 P1P8P1P;P8P>QP5P:P5 `multi_json` (P>P1P5Q QP:P0 P4P;Q Q P0P7P;P8QP=QQ JSON-P?P0Q QP5Q P>P2, P:P>QP>Q P0Q P2QP1P8Q P0P5Q QP0P<QP9 P1QQQQ QP9 P8P7 QQQP0P=P>P2P;P5P=P=QQ P2 QP8QQP5P<P5 P8 P?P0Q QP8Q P8P<) `Oj` P?P>P4P4P5Q P6P8P2P0P5QQQ P8 P8P<P5P5Q P=P0P8P2QQQP8P9 P?Q P8P>Q P8QP5Q; P?P>QQP>P<Q P5QP;P8 P>P= QQQP0P=P>P2P;P5P= P2 QP8QQP5P<P5, `multi_json` P1QP4P5Q P8QP?P>P;QP7P>P2P0QQ P8P<P5P=P=P> P5P3P>.

## Roadmap

* CLI-P8P=QP5Q QP5P9Q Q P0P2QP>P<P0QP8QP5QP:P>P9 P0P2QP>Q P8P7P0QP8P5P9

## P#QP0QQP8P5 P2 Q P0P7Q P0P1P>QP:P5

PQP;P8 P2Q QP>QP8QP5 P?P>QQP0QQP2P>P2P0QQ P2 Q P0P7Q P0P1P>QP:P5 P?Q P>P5P:QP0, QP>Q P:P=P8QP5 Q P5P?P>P7P8QP>Q P8P9, P?P>P;P>P6P8QP5 QP2P>P8 P8P7P<P5P=P5P=P8Q P2 P>QP4P5P;QP=QQ P2P5QP:Q, P?P>P:Q P>P9QP5 P8Q QP?P5P:P0P<P8 P8 P>QP?Q P0P2QQP5 P<P=P5 pull request.

`vkontakte_api` QP5QQP8Q QP5QQQ P?P>P4 MRI `1.9.2`, `1.9.3` P8 `2.0.0`. PQP;P8 P2 P>P4P=P>P9 P8P7 QQP8Q QQ P5P4 QQP>-QP> Q P0P1P>QP0P5Q P=P5P?Q P0P2P8P;QP=P>, P;P8P1P> P2P>P>P1Q	P5 P=P5 Q P0P1P>QP0P5Q, QP> QQP> QP;P5P4QP5Q QQP8QP0QQ P1P0P3P>P<, P8 P=P0P?P8QP0QQ P>P1 QQP>P< P2 [issues P=P0 Github](https://github.com/7even/vkontakte_api/issues).
