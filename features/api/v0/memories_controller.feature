# language: ru
@api @memory @controller @json
Свойство: Правач памѧтєј
   Предыстория:
      * єствує памѧть сꙛ даными:
         | id              | 100                                  |
         | short_name      | Памѧтно                              |
         | title           | Титулецъ                             |
         | description     | Описалово                            |
         | type            | Group                                |
         | kind            | Kind                                 |
         | quantity        | 4                                    |
         | base_year       | 1000                                 |
         | slug            | служ                                 |
         | without_place   | true                                 |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200201" ѫ памѧти "Памѧтно"
      * єствує памѧть сꙛ даными:
         | id              | 101                                  |
         | short_name      | Памѧтна 1                            |
         | type            | Building                             |
         | title           | Титуло                               |
         | quantity        | ""                                   |
         | base_year       | 1001                                 |
         | slug            | слуг                                 |
         | without_place   | true                                 |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200202" ѫ памѧти "Памѧтна 1"

   @get @collection
   Пример: Запрос к контроллеру памѧтєј в АПИ при отсутствии памѧтєј
      Пусть не єствує ни єдне памѧти
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json"
      То добѫдꙛ кодъ поврата "204"

   @get @collection
   Пример: Користник добыває списъ памѧтєј
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: служ
           short_name: Памѧтно
           quantity: '4'
           base_year: 1000
           type: Group
           kind: Kind
         - slug: слуг
           short_name: Памѧтна 1
           quantity:
           base_year: 1001
           type: Building
           kind:
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search
   Пример: Користник искає во спису памѧтєј по памѧтному опозонавателю
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?uno=101"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: слуг
           short_name: Памѧтна 1
           quantity:
           base_year: 1001
           type: Building
           kind:
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search
   Пример: Користник искає во спису памѧтєј по типу
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?t=Building"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: слуг
           short_name: Памѧтна 1
           quantity:
           base_year: 1001
           type: Building
           kind:
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search
   Пример: Користник искає во спису памѧтєј по заглавку
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?tt=Памѧтно"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: служ
           short_name: Памѧтно
           quantity: '4'
           base_year: 1000
           type: Group
           kind: Kind
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search
   Пример: Користник искає во спису памѧтєј по взору памѧти
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?k=Kind"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: служ
           short_name: Памѧтно
           quantity: '4'
           base_year: 1000
           type: Group
           kind: Kind
         """
      А добѫдꙛ охватъ "0-9/1"

   Пример: Користник искає во спису памѧтєј по описанју
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?d=Описалово"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: служ
           short_name: Памѧтно
           quantity: '4'
           base_year: 1000
           type: Group
           kind: Kind
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search
   Пример: Користник искає во спису памѧтєј по типу и взору памѧти
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?t=Building&k=Kind"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @search
   Пример: Користник искає во спису памѧтєј по памѧтному едозу
      Если запытаю добыванје из изнахоѕи "/api/v0/memories.json?uno=Памѧтна 1"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: слуг
           short_name: Памѧтна 1
           quantity:
           base_year: 1001
           type: Building
           kind:
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection
   Пример: Запрос постраничный к контроллеру памѧтєј в АПИ
      И сѫ памѧти:
         """
         ---
         - slug: памят1
           short_name: Памѧтно1
           quantity: "4"
           base_year: 1000
           type: Group
           kind: Kind
           language: ру
           alphabeth: РУ
           title: Титулецъ
           description: Описалово
           without_place: true
         - slug: памят2
           short_name: Памѧтно2
           base_year: 1000
           type: Identity
           kind: Kind
           language: ру
           alphabeth: РУ
           title: Титулецъ
           description: Описалово
           without_place: true
         - slug: памят3
           short_name: Памѧтно3
           base_year: 1000
           type: Building
           kind: Kind
           language: ру
           alphabeth: РУ
           title: Титулецъ3
           description: Описалово3
           without_place: true
        """
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "per=3"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: служ
           short_name: Памѧтно
           quantity: '4'
           base_year: 1000
           type: Group
           kind: Kind
         - slug: памят1
           short_name: Памѧтно1
           quantity: '4'
           base_year: 1000
           type: Group
           kind: Kind
         - slug: памят2
           short_name: Памѧтно2
           quantity:
           base_year: 1000
           type: Identity
           kind: Kind
         """
      А добѫдꙛ охватъ "0-2/5"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "per=3&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - slug: памят3
           short_name: Памѧтно3
           quantity:
           base_year: 1000
           type: Building
           kind: Kind
         - slug: слуг
           short_name: Памѧтна 1
           quantity:
           base_year: 1001
           type: Building
           kind:
         """
      А добѫдꙛ охватъ "3-5/5"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "per=3&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @error @416
   Пример: Запрос к контроллеру памѧтєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/memories.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @error @416
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
         args: {}
         """


   @create @object
   Пример: Користник створяє памѧтѣ
      Если запытаю створенје изнахоѕи памѧти "/api/v0/memories/create.json" сꙛ даными:
         | id           | 103                                  |
         | short_name   | Памѧтно 3                            |
         | title        | Титулецъ 3                           |
         | description  | Описалово 3                          |
         | type         | Building                             |
         | kind         | Kind3                                |
         | base_year    | 1003                                 |
         | slug         | служ3                                |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 103
         slug: служ3
         short_name: Памѧтно 3
         quantity:
         base_year: 1003
         type: Building
         kind: Kind3
         language: ру
         alphabeth: РУ
         title: Титулецъ 3
         description: Описалово 3
         """
      И изнахоѕь памѧти "Памѧтно 3" бѫдє яко:
         """
         ---
         id: 103
         short_name: Памѧтно 3
         quantity:
         base_year: 1003
         type: Building
         kind: Kind3
         language: ру
         alphabeth: РУ
         title: Титулецъ 3
         description: Описалово 3
         """

   @create @object @error @422
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
         args: {}
         error:
         - Quantity is invalid
         - Events can't be blank
         """
      А изнахоѕи памѧти "103" не бѫдє

   @update @object @error @404
   Пример: Користник поновяє дане памѧти
      Если запытаю одсланје памѧти в изнаходь "/api/v0/memories/Памѧтна 1.json" сꙛ даными:
         | id           | 103                                  |
         | short_name   | Памѧтно 3                            |
         | title        | Титулецъ 3                           |
         | description  | Описалово 3                          |
         | type         | Council                              |
         | kind         | Kind3                                |
         | quantity     | "?"                                  |
         | base_year    | 1003                                 |
         | slug         | служ3                                |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 101
         slug: служ3
         short_name: Памѧтно 3
         quantity: "?"
         base_year: 1003
         type: Council
         kind: Kind3
         language: ру
         alphabeth: РУ
         title: Титулецъ 3
         description: Описалово 3
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/memories/Памѧтно 3.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 101
         slug: служ3
         short_name: Памѧтно 3
         quantity: "?"
         base_year: 1003
         type: Council
         kind: Kind3
         language: ру
         alphabeth: РУ
         title: Титулецъ 3
         description: Описалово 3
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/memories/Памѧтна 1.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object
   Пример: Користник добыває дане памѧти· иззначену краткꙛ именем
      Если запытаю добыванје из изнахоѕи "/api/v0/memories/Памѧтно.json"
      То добѫдꙛ выводъ:
         """
         ---
         id: 100
         slug: служ
         short_name: Памѧтно
         quantity: '4'
         base_year: 1000
         type: Group
         kind: Kind
         language: ру
         alphabeth: РУ
         title: Титулецъ
         description: Описалово
         """

   @delete @object
   Пример: Користник изтьрає иззначену плашкој памѧтѣ 
      Если запытаю изтрѣнје изнахоѕи "/api/v0/memories/служ.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 100
         slug: служ
         short_name: Памѧтно
         quantity: '4'
         base_year: 1000
         type: Group
         kind: Kind
         language: ру
         alphabeth: РУ
         title: Титулецъ
         description: Описалово
         """
      И памѧть "Картинка" не будє єствовати

   @get @collection @error
   Пример: Запрос к контроллеру памѧтєј в АПИ при отсутствии памѧтєј
      Пусть не єствує ни єдне памѧти
      Если покушаю створити "GET" запытъ до адреса "/api/v0/memories.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
