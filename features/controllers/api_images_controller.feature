# language: ru
@api @image @controller @json
Свойство: Правач картинок
   Предыстория:
      * є картинка сѫ даными:
         | id           | 200001                               |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053 |
         | type         | Picture                              |
         | meta         | {}                                   |
         | image_path   | features/fixtures/y2000-green.webp   |
         | title        | Картинка                             |
      * єствує памѧть "Памѧтно"
      * є картинка сѫ даными:
         | id           | 200012                               |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f063 |
         | type         | Photo                                |
         | meta         | {}                                   |
         | image_path   | features/fixtures/y1500.png          |
         | title        | Фотка                                |
         | attitude_to  | Памѧтно(40,100)                      |
      * єствує сꙛбытє сꙛ даными:
         | id                 | 200201        |
         | title              | Сꙛбытие       |
         | memory_short_name  | Памѧтно       |
      * є картинка сѫ даными:
         | id           | 200013                               |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064 |
         | type         | Painting                             |
         | meta         | {}                                   |
         | image_path   | features/fixtures/y1500-blue.jpg     |
         | title        | Картина                              |
         | attitude_to  | Памѧтно#Сꙛбытие(100,10)              |
      * єствує памѧть сꙛ даными:
         | id           | 101                                  |
         | short_name   | Памѧтна Ѫ                            |
         | title        | Титуло                               |
         | slug         | слуг                                 |
      * є картинка сѫ даными:
         | id           | 200014                               |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f065 |
         | type         | Photo                                |
         | meta         | {}                                   |
         | image_path   | features/fixtures/y1500-green.gif    |
         | title        | Фотка 1                              |
         | attitude_to  | Памѧтна Ѫ(30,100)                    |
      * єствує сꙛбытє сꙛ даными:
         | id                 | 200202        |
         | title              | Сꙛбытие       |
         | memory_short_name  | Памѧтна Ѫ     |
      * є картинка сѫ даными:
         | id           | 200015                               |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f066 |
         | type         | Icon                                 |
         | meta         | {}                                   |
         | image_path   | features/fixtures/y1500-green.webp   |
         | title        | Иконка                               |
         | description  | Иконка 1                             |
         | attitude_to  | Памѧтна Ѫ#Сꙛбытие(20,100)            |

      * сꙛбуке для правача сѫ таковы:
         | language  | ру |
         | alphabeth | РУ |

   @get @collection
   Пример: Запрос к контроллеру картинок в АПИ при отсутствии картинок
      Пусть не єствує ни єдне картинке
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/images.json"
      То добѫдꙛ кодъ поврата "204"


   @get @collection
   Пример: Запрос к контроллеру картинок в АПИ
      Пусть сѫ "1" слика
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/images.json"
      То добѫдꙛ кодъ поврата "200"

   @get @collection
   Пример: Користник добыває списъ картинок
      Если запытаю добыванје из изо "/api/v1/images.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f066
           title: Иконка
           description: Иконка 1
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           type: Icon
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f065
           title: Фотка 1
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f065.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f065.webp"
           type: Photo
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064
           title: Картина
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           type: Painting
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f063
           title: Фотка
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f063.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f063.webp"
           type: Photo
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
           title: Картинка
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
           type: Picture
         """
      А добѫдꙛ охватъ "0-9/5"

   @get @collection @search
   Пример: Користник искає во спису картинок по памѧтному едозу (єдином опозонавателю) во взору id
      Если запытаю добыванје из изо "/api/v1/images.json?m=101"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f066
           title: Иконка
           description: Иконка 1
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           type: Icon
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f065
           title: Фотка 1
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f065.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f065.webp"
           type: Photo
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному кратку имени
      Если запытаю добыванје из изо "/api/v1/images.json?m=Памѧтно"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f063
           title: Фотка
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f063.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f063.webp"
           type: Photo
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064
           title: Картина
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           type: Painting
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search
   Пример: Користник искає во спису личинок по событијну опозонавателю
      Если запытаю добыванје из изо "/api/v1/images.json?e=200201"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064
           title: Картина
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           type: Painting
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтну и событијну опозонавателєм
      Если запытаю добыванје из изо "/api/v1/images.json?m=слуг&e=200201"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному едозу
      Если запытаю добыванје из изо "/api/v1/images.json?uno=Титуло#Сꙛбытие"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f066
           title: Иконка
           description: Иконка 1
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           type: Icon
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection
   Пример: Запрос постраничный к контроллеру картинок в АПИ
      Пусть сѫ слике:
         """
         ---
         - id: 200004
           uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f057
           type: Photo
           image_path: features/fixtures/y2000-cyan.webp
           meta: {}
           title: Aperçu 4
         """
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/images.json" сꙛ доводом "per=3"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f057
           title:
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f057.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f057.webp"
           type: Photo
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f066
           title: Иконка
           description: Иконка 1
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f066.webp"
           type: Icon
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f065
           title: Фотка 1
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f065.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f065.webp"
           type: Photo
         """
      А добѫдꙛ охватъ "0-2/6"
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/images.json" сꙛ доводом "per=3&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064
           title: Картина
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f064.webp"
           type: Painting
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f063
           title: Фотка
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f063.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f063.webp"
           type: Photo
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
           title: Картинка
           description:
           thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
           url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
           type: Picture
         """
      А добѫдꙛ охватъ "3-5/6"
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/images.json" сꙛ доводом "per=3&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @error @416
   Пример: Запрос к контроллеру картинок в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/images.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @error @416
   Пример: Запрос к контроллеру картинок в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/images.json" сꙛ заглавјем:
         """
         ---
         Range: records=100000-200000
         """
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         """


   @create @object
   Пример: Користник створяє картинку
      Если запытаю створенје изнахоѕи картинци "/api/v1/images/create.json" сꙛ даными:
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054    |
         | type         | Picture                                 |
         | meta         | {}                                      |
         | image_path   | features/fixtures/100x600-yellow.tiff   |
         | title        | Картинка 1                              |
         | description  | Описание                                |
         | attitude_to  | Памѧтно(100,10)                         |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
         title: Картинка 1
         description: Описание
         thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
         url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
         width: 250
         height: 1500
         meta: {}
         type: Picture
         attitudes:
         - attitude_to: Памѧтно
           pos: "<(100,10),30>"
           meta: {}
         """
      И изнахоѕь картинци "Картинка 1" бѫдє яко:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
         type: Picture
         meta: {}
         width: 250
         height: 1500
         title: Картинка 1
         description: Описание
         url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
         attitudes:
         - attitude_to: Памѧтно
           pos: "<(100,10),30>"
           meta: {}
         """

   @create @object @error @422
   Пример: Користник кушає створити подвојну картинку, и не можє
      Если запытаю створенје изнахоѕи картинци "/api/v1/images/create.json" сꙛ даными:
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054 |
         | type         | Picture                              |
         | meta         | {}                                   |
         | image_path   | features/fixtures/y2000-green.webp   |
         | title        | Картинка 1                           |
         | description  | Описание                             |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         errors:
         - Digest has already been taken
         """
      А изнахоѕи картинци "Картинка 1" не бѫдє

   @create @object @error @422
   Пример: Користник кушає створити малу картинку, и не можє
      Если запытаю створенје изнахоѕи картинци "/api/v1/images/create.json" сꙛ даными:
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054 |
         | type         | Picture                              |
         | meta         | {}                                   |
         | image_path   | features/fixtures/canvas.jpg         |
         | title        | Картинка 1                           |
         | description  | Описание                             |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         errors:
         - Image has 100 px. height less than 1500 px.
         - Image has 100 px. width less than 150 px.
         """
      А изнахоѕи картинци "Картинка 1" не бѫдє

   @update @object @error @404
   Пример: Користник поновяє дане картинке
      Если запытаю одсланје картинке в изнаходь "/api/v1/images/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json" сꙛ даными:
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054 |
         | type         | Picture                              |
         | meta         | {}                                   |
         | image_path   | features/fixtures/y2000-green.webp   |
         | title        | Картинка 1                           |
         | description  | Описание 1                           |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
         title: Картинка 1
         description: Описание 1
         thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
         url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
         width: 300
         height: 2000
         meta: {}
         type: Picture
         attitudes: []
         """
      Если запытаю добыванје из изо "/api/v1/images/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
         title: Картинка 1
         description: Описание 1
         thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
         url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
         width: 300
         height: 2000
         meta: {}
         type: Picture
         attitudes: []
         """
      Если запытаю добыванје из изо "/api/v1/images/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object
   Пример: Користник добыває дане картинке
      Если запытаю добыванје из изо "/api/v1/images/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json"
      То добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
         title: Картинка
         description:
         thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
         url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
         width: 300
         height: 2000
         meta: {}
         type: Picture
         attitudes: []
         """

   @delete @object
   Пример: Користник изтьрає иззначену картинку
      Если запытаю изтрѣнје изо "/api/v1/images/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
         title: Картинка
         description:
         thumb_url: "/images/6/6b/thumb_6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
         url: "/images/6/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
         width: 300
         height: 2000
         meta: {}
         type: Picture
         attitudes: []
         """
      И картинка "Картинка" не будє єствовати

   @get @collection @error
   Пример: Запрос к контроллеру картинок в АПИ при отсутствии картинок
      Пусть не єствує ни єдне картинке
      Если покушаю створити "GET" запытъ до адреса "/api/v1/images.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
