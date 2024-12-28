# language: ru
@api @roundel @controller @json
Свойство: Правач личинок
   Предыстория:
      * єствує памѧть "Памѧтно" сꙛ озом "100"
      * єствує личинка сѫ даными:
         | id                 | 200001                                     |
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053       |
         | roundelable_name   | Памѧтно                                    |
         | roundel_path       | features/fixtures/400x400-green.webp       |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200201" ѫ памѧти "Памѧтно"
      * єствує личинка сѫ даными:
         | id                 | 200002                                     |
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054       |
         | roundelable_name   | Памѧтно#Сꙛбытие                            |
         | roundel_path       | features/fixtures/400x400-transparent.png  |
      * єствує памѧть "Памѧтна 1" сꙛ озом "101"
      * єствує личинка сѫ даными:
         | id                 | 200004                                     |
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f056       |
         | roundelable_name   | Памѧтна 1                                  |
         | roundel_path       | features/fixtures/401x401-yellow.bmp       |
      * єствує сꙛбытие "Сꙛбытко" сꙛ озом "200202" ѫ памѧти "Памѧтна 1"
      * єствує личинка сѫ даными:
         | id                 | 200003                                     |
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f055       |
         | roundelable_name   | Памѧтна 1#200202                           |
         | roundel_path       | features/fixtures/500x500-blue.webp        |

   @get @collection
   Пример: Запрос к контроллеру личинок в АПИ при отсутствии личинок
      Пусть не єствує ни єдне личинке
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/roundels.json"
      То добѫдꙛ кодъ поврата "204"

   @get @collection
   Пример: Запрос к контроллеру личинок в АПИ
      Пусть єствує "1" личинка
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/roundels.json"
      То добѫдꙛ кодъ поврата "200"

   @get @collection
   Пример: Користник добыває списъ личинок
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
           roundelable_name: Памѧтно
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
           roundelable_name: Памѧтно#200201
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f056
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f056.webp"
           roundelable_name: Памѧтна 1
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f055
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f055.webp"
           roundelable_name: Памѧтна 1#200202
         """
      А добѫдꙛ охватъ "0-9/4"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному едозу (єдином опозонавателю) во взору id
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels.json?m=101"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f056
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f056.webp"
           roundelable_name: Памѧтна 1
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f055
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f055.webp"
           roundelable_name: Памѧтна 1#200202
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному кратку имени
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels.json?m=Памѧтно"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
           roundelable_name: Памѧтно
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
           roundelable_name: Памѧтно#200201
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному едозу (єдином опозонавателюa) во взору id
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels.json?e=200201"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
           roundelable_name: Памѧтно#200201
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному едозу (єдином опозонавателюa) во взору id
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels.json?m=101&e=Сꙛбытие"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному едозу (єдином опозонавателюa) во взору id
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels.json?uno=Памѧтно#Сꙛбытие"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
           roundelable_name: Памѧтно#200201
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection
   Пример: Запрос постраничный к контроллеру личинок в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/roundels.json" сꙛ доводом "per=2"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
           roundelable_name: Памѧтно
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f054.webp"
           roundelable_name: Памѧтно#200201
         """
      А добѫдꙛ охватъ "0-1/4"
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/roundels.json" сꙛ доводом "per=2&page=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f056
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f056.webp"
           roundelable_name: Памѧтна 1
         - uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f055
           url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f055.webp"
           roundelable_name: Памѧтна 1#200202
         """
      А добѫдꙛ охватъ "2-3/4"

   @get @collection @error @416
   Пример: Запрос к контроллеру картинок в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/roundels.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @error @416
   Пример: Запрос к контроллеру картинок в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/roundels.json" сꙛ заглавјем:
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
   Пример: Користник створяє личинку
      Если запытаю створенје изнахоѕи личинци "/api/v1/roundels/create.json" сꙛ даными:
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f059 |
         | roundel_path       | features/fixtures/600x600-cyan.png   |
         | roundelable_name   | Памѧтно                              |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f059
         url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f059.webp"
         roundelable_name: Памѧтно
         event_id:
         memory_short_name: Памѧтно
         """
      И изнахоѕь личинци для "Памѧтно" бѫдє яко:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f059
         url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f059.webp"
         roundelable_name: Памѧтно
         event_id:
         memory_short_name: Памѧтно
         """

   @create @object @error @422
   Пример: Користник кушає створити подвојну личинку, и не можє.
           Излетає бо изключеие ActionController::ParameterMissing
      Если єствує сꙛбытие "Сꙛбытково" сꙛ озом "200203" ѫ памѧти "Памѧтно"
      И запытаю створенје изнахоѕи личинци "/api/v1/images/create.json" сꙛ даными:
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064 |
         | roundel_path       | features/fixtures/400x400-green.webp |
         | roundelable_name   | Памѧтно#200203                       |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         args: {}
         error:
         - 'param is missing or the value is empty: picture'
         """
      А изнахоѕи личинци "Памѧтно#200203" не бѫдє

   @create @object @error @422
   Пример: Користник кушає створити подвојну личинку, и не можє
      Если єствує сꙛбытие "Сꙛбытково" сꙛ озом "200203" ѫ памѧти "Памѧтно"
      И запытаю створенје изнахоѕи личинци "/api/v1/roundels/create.json" сꙛ даными:
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064 |
         | roundel_path       | features/fixtures/400x400-green.webp |
         | roundelable_name   | Памѧтно#200203                       |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         args: {}
         error:
         - Digest has already been taken
         """
      А изнахоѕи личинци "Памѧтно#200203" не бѫдє

   @create @object @error @422
   Пример: Користник кушає створити малу личинку, и не можє
      Если єствує сꙛбытие "Сꙛбытково" сꙛ озом "200203" ѫ памѧти "Памѧтно"
      И запытаю створенје изнахоѕи личинци "/api/v1/roundels/create.json" сꙛ даными:
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064 |
         | roundel_path       | features/fixtures/canvas.jpg         |
         | roundelable_name   | Памѧтно#200203                       |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         args: {}
         error:
         - Image has 100 px. height less than 400 px.
         """
      А изнахоѕи личинци "Памѧтно#200203" не бѫдє

   @update @object @error @404
   Пример: Користник поновяє дане личинке
      Если запытаю одсланје личинке в изнаходь "/api/v1/roundels/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json" сꙛ даными:
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f060 |
         | roundel_path       | features/fixtures/600x600-cyan.png   |
         | roundelable_name   | Памѧтна 1#200202                     |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f060
         url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f060.webp"
         roundelable_name: Памѧтна 1#200202
         event_id: 200202
         memory_short_name: Памѧтна 1
         """
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels/6b9e05cf-aabc-4dc3-97f7-4abd70d6f060.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f060
         url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f060.webp"
         roundelable_name: Памѧтна 1#200202
         event_id: 200202
         memory_short_name: Памѧтна 1
         """
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json"
      То добѫдꙛ кодъ поврата "404"
      И добѫдꙛ выводъ:
         """
         ---
         args:
           uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
         """

   @update @object @error @422
   Пример: Користник поновяє дане личинке
      Если запытаю одсланје личинке в изнаходь "/api/v1/roundels/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json" сꙛ даными:
         | uid                | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054 |
         | roundel_path       | features/fixtures/401x401-yellow.bmp |
         | roundelable_name   | Памѧтно#200202                       |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         args:
           uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
         error:
         - Uid has already been taken
         - Url has already been taken
         """

   @get @object
   Пример: Користник добыває дане личинке
      Если запытаю добыванје из изнахоѕи "/api/v1/roundels/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json"
      То добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
         url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
         roundelable_name: Памѧтно
         event_id:
         memory_short_name: Памѧтно
         """

   @delete @object
   Пример: Користник изтьрає иззначену личинку
      Если запытаю изтрѣнје изнахоѕи "/api/v1/roundels/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053
         url: "/roundels/6b/6b9e05cf-aabc-4dc3-97f7-4abd70d6f053.webp"
         roundelable_name: Памѧтно
         event_id:
         memory_short_name: Памѧтно
         """
      И личинка "Личинка" не будє єствовати

   @get @collection @error
   Пример: Запрос к контроллеру личинок в АПИ при отсутствии личинок
      Пусть не єствує ни єдне личинке
      Если покушаю створити "GET" запытъ до адреса "/api/v1/roundels.jsonp"
      То не добѫдꙛ кодъ поврата
