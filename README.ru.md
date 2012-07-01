# vkontakte_api [![Build Status](https://secure.travis-ci.org/7even/vkontakte_api.png)](http://travis-ci.org/7even/vkontakte_api) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/7even/vkontakte_api)

`vkontakte_api` - ruby-обертка для API ВКонтакте. Она позволяет вызывать методы API настолько просто, насколько это возможно.

Это русская версия readme. Английская версия лежит [здесь](https://github.com/7even/vkontakte_api/blob/master/README.md).

## Установка

``` bash
$ gem install vkontakte_api
```

## Использование

Все запросы к API отправляются через объект класса `VkontakteApi::Client`.

``` ruby
@app = VkontakteApi::Client.new
```

Чтобы создать клиент для отправки авторизованных запросов, нужно просто передать в конструктор токен доступа.

``` ruby
@app = VkontakteApi::Client.new('my_access_token')
```

Пожалуй, самый простой способ получить токен в веб-приложении - использовать [OmniAuth](https://github.com/intridea/omniauth), но если это неприемлемо, можно реализовать свой механизм авторизации. На данный момент `vkontakte_api` не умеет получать токен.

Теперь можно вызывать методы API. Все названия методов переведены в underscore_case - в отличие от [официальной документации](http://vk.com/developers.php?oid=-17680044&p=API_Method_Description), где они в camelCase, т.е. `getGroups` становится `get_groups`. Можно по прежнему писать методы в camelCase, но это не соответствует стандартам стиля кода, принятым в ruby.

``` ruby
@app.get_user_settings  # => 327710
@app.groups.get         # => [1, 31022447]
```

Предикатные методы (названия которых начинаются с `is`, например `is_app_user`) должны возвращать результат какого-то условия, поэтому в конец названия метода добавляется '?', и возвращается булево значение (`true` или `false`):

``` ruby
@app.is_app_user? # => true
```

Можно вызывать эти методы и без '?' на конце, тогда они будут возвращать `'0'` или `'1'`.

Теперь о параметрах. Все параметры именованные, и передаются в методы в виде хэша, где ключи соответствуют названиям параметров, а значения - соответственно, их значениям:

``` ruby
@app.friends.get(fields: 'uid,first_name,last_name')
# =>  [
#       {
#         :uid          => "1",
#         :first_name   => "Павел",
#         :last_name    => "Дуров"
#       },
#       {
#         :uid          => "6492",
#         :first_name   => "Andrew",
#         :last_name    => "Rogozov"
#       }
#     ]
```

Если значение параметра - список, разделенный запятыми, то его можно передать в виде массива; он будет корректно обработан перед отправкой запроса:

``` ruby
users_ids = [1, 6492]
@app.users.get(uids: users_ids) # => тот же вывод, что и выше
```

Все хэши в результатах методов оборачиваются в `Hashie::Mash`, поэтому к их атрибутам можно обращаться как по строковым ключам, так и по символьным, а также через методы-аксессоры. Продолжая пример выше:

``` ruby
users = @app.users.get(uids: users_ids)
users.first[:uid]        # => "1"
users.last['first_name'] # => "Andrew"
users.last.last_name     # => "Rogozov"
# проверим, есть ли у первого юзера uid
users.first.uid?         # => true
```

Если результат метода - Enumerable, то методу можно передать блок, который будет вызван для каждого элемента результата. В этом случае метод вернет массив из результатов выполнения блока с каждым элементом (аналогично `Enumerable#map`):

``` ruby
@app.friends.get(fields: 'first_name,last_name') do |friend|
  "#{friend.first_name} #{friend.last_name}"
end
# => ["Павел Дуров", "Andrew Rogozov"]
```

`vkontakte_api` не содержит списка названий методов (если не считать пространств имен, вроде `friends` или `groups`) - когда вызывается метод, его название переводится в camelCase, а уже потом отправляется запрос к ВКонтакте. Поэтому когда новый метод добавляется в API, не нужно ждать новой версии гема `vkontakte_api` - можно использовать этот новый метод сразу же. Если в названии запрошенного метода допущены ошибки, или вызван метод, на выполнение которого отсутствуют права, будет выброшено исключение с соответствующим сообщением (об исключениях чуть ниже).

### Обработка ошибок

Если ВКонтакте возвращает ошибку, выбрасывается исключение класса `VkontakteApi::Error` со всей значимой информацией, которую можно получить:

``` ruby
@app.audio.get_by_id
# => VkontakteApi::Error: VKontakte returned an error 1: 'Unknown error occured' after calling method 'audio.getById' without parameters.
```

## Настройка

Глобальные параметры библиотеки можно указать в блоке `VkontakteApi.configure`:

``` ruby
VkontakteApi.configure do |config|
  config.adapter       = :net_http
  config.logger        = Rails.logger
  config.log_errors    = true
  config.log_responses = false
end
```

* по умолчанию для HTTP-запросов используется `Net::HTTP`; можно выбрать [любой другой адаптер](https://github.com/technoweenie/faraday/blob/master/lib/faraday/adapter.rb), поддерживаемый `faraday`
* стандартный логгер выводит все в `STDOUT`; в rails-приложении имеет смысл назначить логгером `Rails.logger`
* по умолчанию в лог пишется только JSON в ситуациях, когда ВКонтакте возвращает ошибку; при желании можно также выводить JSON при удачном запросе (ошибки логгируются с уровнем `warn`, удачные ответы - с уровнем `debug`)

## Y U NO USE MULTI_JSON?

Единственный парсер, у которого получается парсить весь JSON от ВКонтакте - это `Oj`. Вот пример с использованием `multi_json`:

``` bash
$ pry -r faraday -r multi_json
```

``` ruby
response = Faraday.get('https://api.vkontakte.ru/method/groups.getById?gids=23201%2C23202%2C23203&fields=country%2Ccity')
# => #<Faraday::Response:0x7f846b829dc0 ...>
MultiJson.adapter
# => MultiJson::Adapters::Oj < Object
MultiJson.decode(response.body)
# success

MultiJson.use :yajl
MultiJson.decode(response.body)
# => MultiJson::DecodeError: lexical error: invalid character inside string.

MultiJson.use :json_gem
MultiJson.decode(response.body)
# => MultiJson::DecodeError: 387: unexpected token at ...

MultiJson.use :json_pure
MultiJson.decode(response.body)
# => MultiJson::DecodeError: 387: unexpected token at ...

MultiJson.use :ok_json
MultiJson.decode(response.body)
# => Encoding::CompatibilityError: incompatible character encodings: UTF-8 and ASCII-8BIT
```

Пример актуален на момент написания, но данные динамические, и со временем эти ошибки могут исчезнуть.

## Changelog

* 0.1 Первая стабильная версия
* 0.2 Поддержка аргументов-массивов, подчищенные неавторизованные запросы, обновленный список пространств имен, документация кода
* 0.2.1 Пространство имен `stats`
* 1.0 Настраиваемый логгер, результаты методов в виде `Hashie::Mash`, JSON парсится Oj

## Планы

* Авторизация (получение токена доступа с ВКонтакте)
* Загрузка файлов на сервера ВКонтакте
* Rails-генератор для инициализатора

## Участие в разработке

Если вы хотите поучаствовать в разработке проекта, форкните репозиторий, положите свои изменения в отдельную ветку и отправьте мне pull request.

`vkontakte_api` тестируется под MRI `1.8.7`, `1.9.2` и `1.9.3`. Если в одной из этих сред что-то работает неправильно, либо вообще не работает, то это следует считать багом, и написать об этом в [issues на Github](https://github.com/7even/vkontakte_api/issues).
