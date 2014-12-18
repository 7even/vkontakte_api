## vkontakte_api [![Build Status](https://secure.travis-ci.org/7even/vkontakte_api.png)](http://travis-ci.org/7even/vkontakte_api) [![Gem Version](https://badge.fury.io/rb/vkontakte_api.png)](http://badge.fury.io/rb/vkontakte_api) [![Dependency Status](https://gemnasium.com/7even/vkontakte_api.png)](https://gemnasium.com/7even/vkontakte_api) [![Code Climate](https://codeclimate.com/github/7even/vkontakte_api.png)](https://codeclimate.com/github/7even/vkontakte_api)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/7even/vkontakte_api)

`vkontakte_api` &mdash; ruby-adapter for ВКонтакте API. It allows to call API methods, upload files to ВКонтакте server, and also supports 3 available methods of authorization (it also allows to use third-party solutions).

## Settings

``` ruby
# Gemfile
gem 'vkontakte_api', '~> 1.4'
```

or simply

``` sh
$ gem install vkontakte_api
```

## Usage

### Method calls

``` ruby
# creating cliend
@vk = VkontakteApi::Client.new
# and calling API method
@vk.users.get(uid: 1)

# it is a good practice to follow snake_case convention
# while creating methods in ruby
# that is why likes.getList becomes likes.get_list
@vk.likes.get_list
# names of methods that return '1' or '0',
# should end with '?', and returned values
# become true or false
@vk.is_app_user? # => false

# when ВКонтакте is supposed to obtain list of parameters
# separated by commas, then one can pass an array
users = @vk.users.get(uids: [1, 2, 3])

# most of methods return return Hashie::Mash structure
# and arrays with this type of structure
users.first.uid        # => 1
users.first.first_name # => "Павел"
users.first.last_name  # => "Дуров"

# when method returns an array and was called with a block
# then block is being executed for each element
# and method returns processed array
fields = [:first_name, :last_name, :screen_name]
@vk.friends.get(uid: 2, fields: fields) do |friend|
  "#{friend.first_name} '#{friend.screen_name}' #{friend.last_name}"
end
# => ["Павел 'durov' Дуров"]
```

### Files upload

Files upload to ВКонтакте server is composed of several states: in the beginning there is API method call, which returns URL for this call and then in some cases one needs another API method call, passing in the parameters obtained by previous call. Calling API method depends on type of files - this case is described in [the appropriate section section](https://vk.com/dev/upload_files).

Files are transferred in a Hash format, where key is the name of parameter in query (described in documentation, for example when one uploads a photo, then this key is named `photo`), and the value of &mdash; is an array composed of 2 strings: full path of the file and its MIME-type:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: ['/path/to/file.jpg', 'image/jpeg'])
```

If one wants to upload file as an IO-object, then it can be passed using alternative syntax &mdash; IO-object, MIME-type and the file path:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: [file_io, 'image/jpeg', '/path/to/file.jpg'])
```

Method returns ВКонтакте server response converted to `Hashie::Mash`, it may be used when calling API method in the last stage of upload process.

### Авторизация

Для вызова большинства методов требуется токен доступа (access token). Чтобы получить его, можно использовать авторизацию, встроенную в `vkontakte_api`, либо положиться на какой-то другой механизм (например, [OmniAuth](https://github.com/intridea/omniauth)). В последнем случае в результате авторизации будет получен токен, который нужно будет передать в `VkontakteApi::Client.new`.

Для работы с ВКонтакте API предусмотрено 3 типа авторизации: для сайтов, для клиентских приложений (мобильных либо десктопных, имеющих доступ к управлению браузером) и специальный тип авторизации серверов приложений для вызова административных методов без авторизации самого пользователя. Более подробно они описаны [тут](https://vk.com/dev/authentication); рассмотрим, как работать с ними средствами `vkontakte_api`.

Для авторизации необходимо задать параметры `app_id` (ID приложения), `app_secret` (защищенный ключ) и `redirect_uri` (адрес, куда пользователь будет направлен после предоставления прав приложению) в настройках `VkontakteApi.configure`. Более подробно о конфигурировании `vkontakte_api` см. далее в соответствующем разделе.

##### Сайт

Авторизация сайтов проходит в 2 шага. Сначала пользователь перенаправляется на страницу ВКонтакте для подтверждения запрошенных у него прав сайта на доступ к его данным. Со списком возможных прав можно ознакомиться [здесь](https://vk.com/dev/permissions). Допустим, нужно получить доступ к друзьям (`friends`) и фотографиям (`photos`) пользователя.

В соответствии с [рекомендациями](http://tools.ietf.org/html/draft-ietf-oauth-v2-30#section-10.12) в протоколе OAuth2 для защиты от [CSRF](http://ru.wikipedia.org/wiki/%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D0%BB%D0%BA%D0%B0_%D0%BC%D0%B5%D0%B6%D1%81%D0%B0%D0%B9%D1%82%D0%BE%D0%B2%D1%8B%D1%85_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2), нужно передать параметр `state`, содержащий случайное значение.

``` ruby
session[:state] = Digest::MD5.hexdigest(rand.to_s)
redirect_to VkontakteApi.authorization_url(scope: [:notify, :friends, :photos], state: session[:state])
```

После подтверждения пользователь перенаправляется на указанный в настройках `redirect_uri`, причем в параметрах будет передан код, по которому можно получить токен доступа, а также переданный ранее `state`. Если `state` не совпадает с тем, который был использован при отправлении пользователя на ВКонтакте, то скорее всего это попытка CSRF-атаки &mdash; стоит отправить пользователя на повторную авторизацию.

``` ruby
redirect_to login_url, alert: 'Ошибка авторизации' if params[:state] != session[:state]
```

`vkontakte_api` предоставляет метод `VkontakteApi.authorize`, который делает запрос к ВКонтакте, получает токен и создает клиент; нужно лишь передать ему код:

``` ruby
@vk = VkontakteApi.authorize(code: params[:code])
# и теперь можно вызывать методы API на объекте @vk
@vk.is_app_user?
```

Клиент будет содержать id пользователя, авторизовавшего приложение; его можно получить с помощью метода `VkontakteApi::Client#user_id`:

``` ruby
@vk.user_id # => 123456
```

Также в этот момент полезно сохранить полученный токен (и, при необходимости, id пользователя) в БД либо в сессии, чтобы использовать их повторно:

``` ruby
current_user.token = @vk.token
current_user.vk_id = @vk.user_id
current_user.save
# позже
@vk = VkontakteApi::Client.new(current_user.token)
```

##### Клиентское приложение

Авторизация клиентского приложения несколько проще &mdash; не нужно получать токен отдельным запросом, он выдается сразу после редиректа пользователя.

``` ruby
# пользователь направляется на следующий урл
VkontakteApi.authorization_url(type: :client, scope: [:friends, :photos])
```

Необходимо принимать во внимание, что `redirect_uri` нужно выставлять на `http://api.vkontakte.ru/blank.html`, иначе не получится вызывать методы, доступные клиентским приложениям.

Когда пользователь подтвердит права приложения, он будет перенаправлен на `redirect_uri`, при этом в параметре `access_token` будет токен, который нужно передать в `VkontakteApi::Client.new`.

##### Сервер приложения

Последний тип авторизации &mdash; самый простой, т.к. не предполагает участия пользователя.

``` ruby
@vk = VkontakteApi.authorize(type: :app_server)
```

### Прочее

Если клиент API (объект класса `VkontakteApi::Client`) был создан с помощью метода `VkontakteApi.authorize`, он будет содержать информацию об id текущего пользователя (`user_id`) и о времени истечения токена (`expires_at`). Получить их можно с помощью соответствующих методов:

``` ruby
vk = VkontakteApi.authorize(code: 'c1493e81f69fce1b43')
# => #<VkontakteApi::Client:0x007fa578f00ad0>
vk.user_id    # => 628985
vk.expires_at # => 2012-12-18 23:22:55 +0400
# можно проверить, истекло ли время жизни токена
vk.expired?   # => false
```

Также можно получить список прав доступа, которые дает данный токен, в виде, аналогичном формату параметра `scope` в авторизации:

``` ruby
vk.scope # => [:friends, :groups]
```

Это работает на основе метода `getUserSettings`, причем результат запоминается после первого обращения.

Чтобы создать короткий синоним `VK` для модуля `VkontakteApi`, достаточно вызвать метод `VkontakteApi.register_alias`:

``` ruby
VkontakteApi.register_alias
VK::Client.new # => #<VkontakteApi::Client:0x007fa578d6d948>
```

При необходимости можно удалить синоним методом `VkontakteApi.unregister_alias`:

``` ruby
VK.unregister_alias
VK # => NameError: uninitialized constant VK
```

### Обработка ошибок

Если ВКонтакте API возвращает ошибку, выбрасывается исключение класса `VkontakteApi::Error`.

``` ruby
vk = VK::Client.new
vk.friends.get(uid: 1, fields: [:first_name, :last_name, :photo])
# VkontakteApi::Error: VKontakte returned an error 7: 'Permission to perform this action is denied' after calling method 'friends.get' with parameters {"uid"=>"1", "fields"=>"first_name,last_name,photo"}.
```

Особый случай ошибки &mdash; 14: необходимо ввести код с captcha.
В этом случае можно получить параметры капчи методами
`VkontakteApi::Error#captcha_sid` и `VkontakteApi::Error#captcha_img` &mdash; например,
[так](https://github.com/7even/vkontakte_api/issues/10#issuecomment-11666091).

### Логгирование

`vkontakte_api` логгирует служебную информацию о запросах при вызове методов.
По умолчанию все пишется в `STDOUT`, но в настройке можно указать
любой другой совместимый логгер, например `Rails.logger`.

Есть возможность логгирования 3 типов информации,
каждому соответствует ключ в глобальных настройках.

|                        | ключ настройки  | по умолчанию | уровень логгирования |
| ---------------------- | --------------- | ------------ | -------------------- |
| URL запроса            | `log_requests`  | `true`       | `debug`              |
| JSON ответа при ошибке | `log_errors`    | `true`       | `warn`               |
| JSON удачного ответа   | `log_responses` | `false`      | `debug`              |

Таким образом, в rails-приложении с настройками по умолчанию в production
записываются только ответы сервера при ошибках;
в development также логгируются URL-ы запросов.

### Пример использования

Пример использования `vkontakte_api` совместно с `eventmachine` можно посмотреть
[здесь](https://github.com/7even/vkontakte_on_em).

Также был написан [пример использования с rails](https://github.com/7even/vkontakte_on_rails),
но он больше не работает из-за отсутствия прав на вызов метода `newsfeed.get`.

## Настройка

Глобальные параметры `vkontakte_api` задаются в блоке `VkontakteApi.configure` следующим образом:

``` ruby
VkontakteApi.configure do |config|
  # параметры, необходимые для авторизации средствами vkontakte_api
  # (не нужны при использовании сторонней авторизации)
  config.app_id       = '123'
  config.app_secret   = 'AbCdE654'
  config.redirect_uri = 'http://example.com/oauth/callback'
  
  # faraday-адаптер для сетевых запросов
  config.adapter = :net_http
  # HTTP-метод для вызова методов API (:get или :post)
  config.http_verb = :post
  # параметры для faraday-соединения
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
  # максимальное количество повторов запроса при ошибках
  config.max_retries = 2
  
  # логгер
  config.logger        = Rails.logger
  config.log_requests  = true  # URL-ы запросов
  config.log_errors    = true  # ошибки
  config.log_responses = false # удачные ответы
  
  # используемая версия API
  config.api_version = '5.21'
end
```

По умолчанию для HTTP-запросов используется `Net::HTTP`; можно выбрать
[любой другой адаптер](https://github.com/technoweenie/faraday/blob/master/lib/faraday/adapter.rb),
поддерживаемый `faraday`.

ВКонтакте [позволяет](https://vk.com/dev/api_requests)
использовать как `GET`-, так и `POST`-запросы при вызове методов API.
По умолчанию `vkontakte_api` использует `POST`, но в настройке `http_verb`
можно указать `:get`, чтобы совершать `GET`-запросы.

При необходимости можно указать параметры для faraday-соединения &mdash; например,
параметры прокси-сервера или путь к SSL-сертификатам.

Чтобы при каждом вызове API-метода передавалась определенная версия API, можно
указать ее в конфигурации в `api_version`. По умолчанию версия не указана.

Чтобы сгенерировать файл с настройками по умолчанию в rails-приложении,
можно воспользоваться генератором `vkontakte_api:install`:

``` sh
$ cd /path/to/app
$ rails generate vkontakte_api:install
```

## JSON-парсер

`vkontakte_api` использует парсер [Oj](https://github.com/ohler55/oj) &mdash; это
единственный парсер, который не показал [ошибок](https://github.com/7even/vkontakte_api/issues/1)
при парсинге JSON, генерируемого ВКонтакте.

Также в библиотеке `multi_json` (обертка для различных JSON-парсеров,
которая выбирает самый быстрый из установленных в системе и парсит им)
`Oj` поддерживается и имеет наивысший приоритет; поэтому если он установлен
в системе, `multi_json` будет использовать именно его.

## Roadmap

* CLI-интерфейс с автоматической авторизацией

## Участие в разработке

Если вы хотите поучаствовать в разработке проекта, форкните репозиторий,
положите свои изменения в отдельную ветку, покройте их спеками
и отправьте мне pull request.

`vkontakte_api` тестируется под MRI `1.9.3`, `2.0.0` и `2.1.2`.
Если в одной из этих сред что-то работает неправильно, либо вообще не работает,
то это следует считать багом, и написать об этом
в [issues на Github](https://github.com/7even/vkontakte_api/issues).
