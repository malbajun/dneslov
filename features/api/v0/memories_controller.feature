# language: ru
@api @memory @controller
Свойство: Правач памѧтєј
   Предыстория:
      * єствує слава сꙛ даными:
         | id              | 10000                                |
         | short_name      | Славник                              |
         | title           | Славник Титул                        |
         | description     | Описаловое                           |
         | base_year       | 1                                    |
         | slug            | слав                                 |
         | without_place   | true                                 |
      * єствує калѧдарь "Калѧдарь" сꙛ слугом "календ" и озом "200204"
      * єствує памѧть сꙛ даными:
         | id              | 200100                               |
         | short_name      | Памятно                              |
         | title           | Титулец                              |
         | description     | Описалово                            |
         | type            | Group                                |
         | kind            | Kind                                 |
         | quantity        | 4                                    |
         | base_year       | 1000                                 |
         | slug            | служ                                 |
         | without_place   | true                                 |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200201" ѫ памѧти "Памятно", коє сѧ случи во "1001"
      * єствує помин "Помин Б" сꙛ славој "слав" во калѧдарю "календ" для сꙛбытја "Сꙛбытие"
      * єствує памѧть сꙛ даными:
         | id              | 200101                               |
         | short_name      | Памѧтна Ѫ                            |
         | type            | Building                             |
         | title           | Титуло                               |
         | quantity        | ""                                   |
         | base_year       | 1001                                 |
         | slug            | слуг                                 |
         | without_place   | true                                 |
      * єствує сꙛбытие "Сꙛбытие А" сꙛ озом "200202" ѫ памѧти "Памѧтна Ѫ", коє сѧ случи во "1002"
      * єствує помин "Помин А" сꙛ славој "слав" и замѣткој "Заметка" во калѧдарю "календ" для сꙛбытја "Сꙛбытие А"

   @get @collection @json
   Пример: Запрос к контроллеру памѧтєј в АПИ при отсутствии памѧтєј
      Пусть не єствує ни єдне памѧти
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json"
      То добѫдꙛ кодъ поврата "204"

   @get @collection @json
   Пример: Користник добыває списъ памѧтєј
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200101
           slug: слуг
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин А
           note: Заметка
           happened_at: '1002'
           base_year: 1001
           short_name: Памѧтна Ѫ
           type: Building
           kind:
           calendary_slugs:
           - календ
         - id: 200100
           slug: служ
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин Б
           note:
           happened_at: '1001'
           base_year: 1000
           short_name: Памятно
           type: Group
           kind: Kind
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search @json
   Пример: Користник искає во спису памѧтєј по памѧтному опозонавателю
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?uno=200101"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200101
           slug: слуг
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин А
           note: Заметка
           happened_at: '1002'
           base_year: 1001
           short_name: Памѧтна Ѫ
           type: Building
           kind:
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису памѧтєј по типу
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?t=Building"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200101
           slug: слуг
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин А
           note: Заметка
           happened_at: '1002'
           base_year: 1001
           short_name: Памѧтна Ѫ
           type: Building
           kind:
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису памѧтєј по заглавку
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?tt=Памятно"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200100
           slug: служ
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин Б
           note:
           happened_at: '1001'
           base_year: 1000
           short_name: Памятно
           type: Group
           kind: Kind
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису памѧтєј по взору памѧти
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?k=Kind"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200100
           slug: служ
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин Б
           note:
           happened_at: '1001'
           base_year: 1000
           short_name: Памятно
           type: Group
           kind: Kind
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/1"

   Пример: Користник искає во спису памѧтєј по описанју
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?d=Описалово"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200100
           slug: служ
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин Б
           note:
           happened_at: '1001'
           base_year: 1000
           short_name: Памятно
           type: Group
           kind: Kind
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису памѧтєј по типу и взору памѧти
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?t=Building&k=Kind"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @search @json
   Пример: Користник искає во спису памѧтєј по памѧтному едозу
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?uno=Памѧтна Ѫ"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200101
           slug: слуг
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин А
           note: Заметка
           happened_at: '1002'
           base_year: 1001
           short_name: Памѧтна Ѫ
           type: Building
           kind:
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @json
   Пример: Запрос постраничный к контроллеру памѧтєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "per=1"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200101
           slug: слуг
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин А
           note: Заметка
           happened_at: '1002'
           base_year: 1001
           short_name: Памѧтна Ѫ
           type: Building
           kind:
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-0/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "per=1&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200100
           slug: служ
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин Б
           note:
           happened_at: '1001'
           base_year: 1000
           short_name: Памятно
           type: Group
           kind: Kind
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "1-1/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "per=1&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @json @error @416
   Пример: Запрос к контроллеру памѧтєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @json @error @416
   Пример: Запрос к контроллеру памѧтєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ заглавјем:
         """
         ---
         Range: records=100000-200000
         """
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         """


   @create @object @json
   Пример: Користник створяє памѧтѣ
      Если запытаю створенје изнахоѕи памѧти "/api/v0/memories/create.json" сꙛ даными:
         | id           | 103                                  |
         | short_name   | Памѧтно Г                            |
         | type         | Building                             |
         | kind         | Kind3                                |
         | base_year    | 1003                                 |
         | slug         | служ3                                |
      То добѫдꙛ кодъ поврата "200"
      И изнахоѕь памѧти "Памѧтно Г" бѫдє яко:
         """
         ---
         id: 103
         short_name: Памѧтно Г
         quantity:
         base_year: 1003
         type: Building
         kind: Kind3
         """

   @create @object @json @error @422
   Пример: Користник кушає створити погрѣшну памѧтѣ, и не можє
      Если запытаю створенје изнахоѕи памѧти "/api/v0/memories/create.json" сꙛ даными:
         | id           | 103                                  |
         | title        | Титулецъ 3                           |
         | description  | Описалово 3                          |
         | type         | Council                              |
         | kind         | Kind3                                |
         | quantity     | невѣрно                              |
         | base_year    | невѣрно                              |
         | slug         | служ3                                |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         errors:
         - Quantity is invalid
         - Events can't be blank
         """
      А изнахоѕи памѧти "103" не бѫдє

   @update @object @json @error @404
   Пример: Користник поновяє дане памѧти
      Если запытаю одсланје памѧти в изнаходь "/api/v0/memories/Памѧтна Ѫ.json" сꙛ даными:
         | id           | 200103                               |
         | short_name   | Памѧтно Г                            |
         | type         | Council                              |
         | kind         | Kind3                                |
         | quantity     | "?"                                  |
         | base_year    | 1003                                 |
         | slug         | служ3                                |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200101
         slug: служ3
         short_name: Памѧтно Г
         quantity: "?"
         base_year: 1003
         type: Council
         kind: Kind3
         title: Помин А
         description:
         order_short_name: Славник
         order_tweet: слав
         roundel_url:
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/memories/Памѧтно Г.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200101
         slug: служ3
         short_name: Памѧтно Г
         quantity: "?"
         base_year: 1003
         type: Council
         kind: Kind3
         title: Помин А
         description:
         order_short_name: Славник
         order_tweet: слав
         roundel_url:
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/memories/Памѧтна Ѫ.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object @json
   Пример: Користник добыває дане памѧти· иззначену краткꙛ именем
      Если запытаю добыванје из изнахоѕи "/api/v0/memories/Памятно.json"
      То добѫдꙛ выводъ:
         """
         ---
         id: 200100
         slug: служ
         short_name: Памятно
         quantity: '4'
         base_year: 1000
         type: Group
         kind: Kind
         title: Помин Б
         description:
         order_short_name: Славник
         order_tweet: слав
         roundel_url:
         """

   @delete @object @json
   Пример: Користник изтьрає иззначену плашкој памѧтѣ 
      Если запытаю изтрѣнје изнахоѕи "/api/v0/memories/служ.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200100
         slug: служ
         short_name: Памятно
         quantity: '4'
         base_year: 1000
         type: Group
         kind: Kind
         title: Помин Б
         description:
         order_short_name: Славник
         order_tweet: слав
         roundel_url:
         """
      И памѧть "Картинка" не будє єствовати

   @get @collection @json @error
   Пример: Запрос к контроллеру памѧтєј в АПИ при отсутствии памѧтєј
      Пусть не єствує ни єдне памѧти
      Если покушаю створити "GET" запытъ до адреса "/api/v0/memories.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє

   @get @collection @json
   Пример: Користник добыває списъ памѧтєј для соборна помина, кој оны включає
      Пусть єствує помин "Помин В" сꙛ славој "слав" во калѧдарю "календ" для сꙛбытја "Сꙛбытие" и є включенѫ во собор "Помин А"

      Если запытаю добыванје из изнахоѕи "/api/v0/memories/200101/content.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200100
           slug: служ
           order_short_name: Славник
           order_tweet: слав
           roundel_url:
           title: Помин В
           note:
           happened_at: '1001'
           base_year: 1000
           short_name: Памятно
           type: Group
           kind: Kind
           calendary_slugs:
           - календ
         """
      А добѫдꙛ охватъ "0-9/1"
