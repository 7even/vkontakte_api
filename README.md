## vkontakte_api [![Build Status](https://secure.travis-ci.org/7even/vkontakte_api.png)](http://travis-ci.org/7even/vkontakte_api) [![Dependency Status](https://gemnasium.com/7even/vkontakte_api.png)](https://gemnasium.com/7even/vkontakte_api) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/7even/vkontakte_api)

`vkontakte_api` - ruby-адаптер для ВКонтакте API. Он позволяет вызывать методы API, загружать файлы на сервера ВКонтакте, а также поддерживает все 3 доступных способа авторизации (при этом позволяя использовать стороннее решение).

## Установка

``` ruby
# Gemfile
gem 'vkontakte_api', '~> 1.0.rc'
```

или просто

``` sh
$ gem install vkontakte_api --pre
```

## Использование

### Вызов методов

``` ruby
# создаем клиент
@vk = VkontakteApi::Client.new
# и вызываем методы API
@vk.users.get(uid: 1)

# в ruby принято использовать snake_case в названиях методов,
# поэтому likes.getList становится likes.get_list
@vk.likes.get_list
# также названия методов, которые возвращают '1' или '0',
# заканчиваются на '?', а возвращаемые значения приводятся
# к true или false
@vk.is_app_user? # => false

# если ВКонтакте ожидает получить параметр в виде списка,
# разделенного запятыми, то его можно передать массивом
users = @vk.users.get(uids: [1, 2, 3])

# большинство методов возвращает структуры Hashie::Mash
# и массивы из них
users.first.uid        # => 1
users.first.first_name # => "Павел"
users.first.last_name  # => "Дуров"
users.first.online?    # => true

# если метод, возвращающий массив, вызывается с блоком,
# то блок будет выполнен для каждого элемента,
# и метод вернет обработанный массив
fields = [:first_name, :last_name, :screen_name]
@vk.friends.get(fields: fields) do |friend|
  "#{friend.first_name} '#{friend.screen_name}' #{friend.last_name}"
end
# => ["Павел 'durov' Дуров"]
```

### Загрузка файлов

Загрузка файлов на сервера ВКонтакте осуществляется в несколько этапов: сначала вызывается метод API, возвращающий URL для загрузки, затем происходит сама загрузка файлов, и после этого в некоторых случаях нужно вызвать другой метод API, передав в параметрах данные, возвращенные сервером после предыдущего запроса. Вызываемые методы API зависят от типа загружаемых файлов и описаны в [соответствующем разделе документации](http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81_%D0%B7%D0%B0%D0%B3%D1%80%D1%83%D0%B7%D0%BA%D0%B8_%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2_%D0%BD%D0%B0_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80_%D0%92%D0%9A%D0%BE%D0%BD%D1%82%D0%B0%D0%BA%D1%82%D0%B5).

Файлы передаются в формате хэша, где ключом является название параметра в запросе (указано в документации, например для загрузки фото на стену это будет `photo`), а значением - массив из 2 строк: полный путь к файлу и его MIME-тип:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: ['/path/to/file.jpg', 'image/jpeg'])
```

Метод вернет ответ сервера ВКонтакте, преобразованный в `Hashie::Mash`; его можно использовать при вызове метода API на последнем этапе процесса загрузки.

### Авторизация

Для вызова большинства методов требуется токен доступа (access token). Чтобы получить его, можно использовать авторизацию, встроенную в `vkontakte_api`, либо положиться на какой-то другой механизм (например, [OmniAuth](https://github.com/intridea/omniauth)). В последнем случае в результате авторизации будет получен токен, который нужно будет передать в `VkontakteApi::Client.new`.

Для работы с ВКонтакте API предусмотрено 3 типа авторизации: для сайтов, для клиентских приложений (мобильных либо десктопных, имеющих доступ к управлению браузером) и специальный тип авторизации серверов приложений для вызова административных методов без авторизации самого пользователя. Более подробно они описаны [тут](http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F); рассмотрим, как работать с ними средствами `vkontakte_api`.

Для авторизации необходимо задать параметры `app_id` (ID приложения), `app_secret` (защищенный ключ) и `redirect_uri` (адрес, куда пользователь будет направлен после предоставления прав приложению) в настройках `VkontakteApi.configure`. Более подробно о конфигурировании `vkontakte_api` см. далее в соответствующем разделе.

##### Сайт

Авторизация сайтов проходит в 2 шага: сначала пользователь перенаправляется на страницу ВКонтакте для подтверждения запрошенных у него прав сайта на доступ к его данным. Со списком возможных прав можно ознакомиться [здесь](http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%B0%D0%B2%D0%B0_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0_%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B9). Допустим, нужно получить доступ к друзьям (`friends`) и фотографиям (`photos`) пользователя.

``` ruby
redirect_to VkontakteApi.authorization_url(scope: [:friends, :photos])
```

После подтверждения пользователь перенаправляется на указанный в настройках `redirect_uri`, причем в параметрах будет передан код, по которому можно получить токен доступа. `vkontakte_api` предоставляет метод `VkontakteApi.authorize`, который делает запрос к ВКонтакте, получает токен и создает клиент; нужно лишь передать ему код:

``` ruby
@vk = VkontakteApi.authorize(code: params[:code])
# и теперь можно вызывать методы API на объекте @vk
@vk.is_app_user?
```

Также в этот момент полезно сохранить полученный токен в БД либо в сессии, чтобы использовать его повторно:

``` ruby
current_user.token = @vk.token
current_user.save
# позже
@vk = VkontakteApi::Client.new(current_user.token)
```

##### Клиентское приложение

Авторизация клиентского приложения несколько проще - не нужно получать токен отдельным запросом, он выдается сразу после редиректа пользователя.

``` ruby
# пользователь направляется на следующий урл
VkontakteApi.authorization_url(type: :client, scope: [:friends, :photos])
```

Необходимо принимать во внимание, что `redirect_uri` нужно выставлять на `http://api.vkontakte.ru/blank.html`, иначе не получится вызывать методы, доступные клиентским приложениям.

Когда пользователь подтвердит права приложения, он будет перенаправлен на `redirect_uri`, при этом в параметре `access_token` будет токен, который нужно передать в `VkontakteApi::Client.new`.

##### Сервер приложения

Последний тип авторизации - самый простой, т.к. не предполагает участия пользователя.

``` ruby
@vk = VkontakteApi.authorize(type: :app_server)
```

### Обработка ошибок

Если ВКонтакте API возвращает ошибку, выбрасывается исключение класса `VkontakteApi::Error`.

``` ruby
vk = VK::Client.new
vk.friends.get(uid: 1, fields: [:first_name, :last_name, :photo])
# VkontakteApi::Error: VKontakte returned an error 7: 'Permission to perform this action is denied' after calling method 'friends.get' with parameters {"uid"=>"1", "fields"=>"first_name,last_name,photo"}.
```

### Логгирование

`vkontakte_api` логгирует служебную информацию о запросах при вызове методов. По умолчанию все пишется в `STDOUT`, но в настройке можно указать любой другой совместимый логгер, например `Rails.logger`.

Есть возможность логгирования 3 типов информации, каждому соответствует ключ в глобальных настройках.

|                        | ключ настройки  | по умолчанию | уровень логгирования |
| ---------------------- | --------------- | ------------ | -------------------- |
| URL запроса            | `log_requests`  | `true`       | `debug`              |
| JSON ответа при ошибке | `log_errors`    | `true`       | `warn`               |
| JSON удачного ответа   | `log_responses` | `false`      | `debug`              |

Таким образом, в rails-приложении с настройками по умолчанию в production записываются только ответы сервера при ошибках; в development также логгируются URL-ы запросов.

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
  
  # логгер
  config.logger        = Rails.logger
  config.log_requests  = true  # URL-ы запросов
  config.log_errors    = true  # ошибки
  config.log_responses = false # удачные ответы
end
```

По умолчанию для HTTP-запросов используется `Net::HTTP`; можно выбрать [любой другой адаптер](https://github.com/technoweenie/faraday/blob/master/lib/faraday/adapter.rb), поддерживаемый `faraday`.

Чтобы сгенерировать файл с настройками по умолчанию в rails-приложении, можно воспользоваться генератором `vkontakte_api:install`:

``` sh
$ cd /path/to/app
$ rails generate vkontakte_api:install
```

## JSON-парсер

`vkontakte_api` использует парсер [Oj](https://github.com/ohler55/oj) - это единственный парсер, который не показал [ошибок](https://github.com/7even/vkontakte_api/issues/1) при парсинге JSON, генерируемого ВКонтакте.

Также в библиотеке `multi_json` (обертка для различных JSON-парсеров, которая выбирает самый быстрый из установленных в системе и парсит им) `Oj` поддерживается и имеет наивысший приоритет; поэтому если он установлен в системе, `multi_json` будет использовать именно его.

## Участие в разработке

Если вы хотите поучаствовать в разработке проекта, форкните репозиторий, положите свои изменения в отдельную ветку и отправьте мне pull request.

`vkontakte_api` тестируется под MRI `1.8.7`, `1.9.2`, `1.9.3` и `2.0.0-dev`. Если в одной из этих сред что-то работает неправильно, либо вообще не работает, то это следует считать багом, и написать об этом в [issues на Github](https://github.com/7even/vkontakte_api/issues).
