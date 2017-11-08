## vkontakte_api [![Build Status](https://travis-ci.org/7even/vkontakte_api.svg?branch=master)](https://travis-ci.org/7even/vkontakte_api) [![Gem Version](https://badge.fury.io/rb/vkontakte_api.svg)](http://badge.fury.io/rb/vkontakte_api) [![Dependency Status](https://gemnasium.com/badges/github.com/7even/vkontakte_api.svg)](https://gemnasium.com/github.com/7even/vkontakte_api) [![Code Climate](https://codeclimate.com/github/7even/vkontakte_api/badges/gpa.svg)](https://codeclimate.com/github/7even/vkontakte_api) [![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/7even/vkontakte_api)

`vkontakte_api` &mdash; ruby-адаптер для ВКонтакте API. Он позволяет вызывать методы API, загружать файлы на сервера ВКонтакте, а также поддерживает все 3 доступных способа авторизации (при этом позволяя использовать стороннее решение).

## English version
For English version please go [here](README_en.md).

## Установка

``` ruby
# Gemfile
gem 'vkontakte_api', '~> 1.4'
```

или просто

``` sh
$ gem install vkontakte_api
```

## Использование

### Вызов методов

``` ruby
# создаем клиент
@vk = VkontakteApi::Client.new
# и вызываем методы API
@vk.users.get(user_ids: 1)

# в ruby принято использовать snake_case в названиях методов,
# поэтому likes.getList становится likes.get_list
@vk.likes.get_list
# также названия методов, которые возвращают '1' или '0',
# заканчиваются на '?', а возвращаемые значения приводятся
# к true или false
@vk.is_app_user? # => false

# если ВКонтакте ожидает получить параметр в виде списка,
# разделенного запятыми, то его можно передать массивом
users = @vk.users.get(user_ids: [1, 2, 3])

# большинство методов возвращает структуры Hashie::Mash
# и массивы из них
users.first.uid        # => 1
users.first.first_name # => "Павел"
users.first.last_name  # => "Дуров"

# если метод, возвращающий массив, вызывается с блоком,
# то блок будет выполнен для каждого элемента,
# и метод вернет обработанный массив
fields = [:first_name, :last_name, :screen_name]
@vk.friends.get(user_id: 2, fields: fields) do |friend|
  "#{friend.first_name} '#{friend.screen_name}' #{friend.last_name}"
end
# => ["Павел 'durov' Дуров"]
```

### Загрузка файлов

Загрузка файлов на сервера ВКонтакте осуществляется в несколько этапов: сначала вызывается метод API, возвращающий URL для загрузки, затем происходит сама загрузка файлов, и после этого в некоторых случаях нужно вызвать другой метод API, передав в параметрах данные, возвращенные сервером после предыдущего запроса. Вызываемые методы API зависят от типа загружаемых файлов и описаны в [соответствующем разделе документации](https://vk.com/dev/upload_files).

Файлы передаются в формате хэша, где ключом является название параметра в запросе (указано в документации, например для загрузки фото на стену это будет `photo`), а значением &mdash; массив из 2 строк: полный путь к файлу и его MIME-тип:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: ['/path/to/file.jpg', 'image/jpeg'])
```

Если загружаемый файл доступен как открытый IO-объект, его можно передать альтернативным синтаксисом &mdash; IO-объект, MIME-тип и путь к файлу:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: [file_io, 'image/jpeg', '/path/to/file.jpg'])
```

Метод вернет ответ сервера ВКонтакте, преобразованный в `Hashie::Mash`; его можно использовать при вызове метода API на последнем этапе процесса загрузки.

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
vk.friends.get(user_id: 1, fields: [:first_name, :last_name, :photo])
# VkontakteApi::Error: VKontakte returned an error 7: 'Permission to perform this action is denied' after calling method 'friends.get' with parameters {"user_id"=>"1", "fields"=>"first_name,last_name,photo"}.
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
  # работает только если переключить http_verb в :get
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
[любой другой адаптер](https://github.com/lostisland/faraday/blob/master/lib/faraday/adapter.rb),
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

`vkontakte_api` тестируется под MRI `2.1`, `2.2`, `2.3` и `2.4`, а также JRuby `9.x`.
Если в одной из этих сред что-то работает неправильно, либо вообще не работает,
то это следует считать багом, и написать об этом
в [issues на Github](https://github.com/7even/vkontakte_api/issues).
