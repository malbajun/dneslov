# language: ru
@api @audio @controller @json
Свойство: Правач звѫчєј
   Предыстория:
      * є звѫчє сꙛ даными:
         | id           | 200001                                                             |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f053                               |
         | digest       | f50d68b2dcd74a2c38ce097e53ec72260b823cf72a2c867dd03a84b8cd10d167   |
         | meta         | {}                                                                 |
         | audio_path   | features/fixtures/bee.mp3                                          |
         | title        | Звѫчє                                                              |
      * єствує памѧть "Памѧтно"
      * є звѫчє сꙛ даными:
         | id           | 200012                               |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f063 |
         | meta         | {}                                   |
         | audio_path   | features/fixtures/ice_rock_drop.mp3  |
         | title        | Гласно                               |
         | attitude_to  | Памѧтно(0.5,0.6)                     |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200201" ѫ памѧти "Памѧтно"
      * є звѫчє сꙛ даными:
         | id           | 200013                                        |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f064          |
         | meta         | {}                                            |
         | audio_path   | features/fixtures/frisbee_plastic_throw.flac  |
         | title        | Звѫкъ                                         |
         | attitude_to  | Памѧтно#Сꙛбытие(1.1,1.2)                      |
      * єствує памѧть сꙛ даными:
         | id           | 101                                  |
         | short_name   | Памѧтна Ѫ                            |
         | title        | Титуло                               |
         | slug         | слуг                                 |
      * є звѫчє сꙛ даными:
         | id           | 200014                                  |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f065    |
         | meta         | {}                                      |
         | audio_path   | features/fixtures/garage_door_slam.wav  |
         | title        | Гласно 1                                |
         | attitude_to  | Памѧтна Ѫ(1.0,1.1)                      |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200202" ѫ памѧти "Памѧтна Ѫ"
      * є звѫчє сꙛ даными:
         | id           | 200015                               |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f066 |
         | meta         | {}                                   |
         | audio_path   | features/fixtures/hammer_hit.ogg     |
         | description  | Гѫдьба а꙯                             |
         | title        | Гѫдьба                               |
         | attitude_to  | Памѧтна Ѫ#Сꙛбытие(0.9,1.0)           |
      * є письмо сꙛ даными:
         | id              | 200021                                           |
         | type            | Troparion                                        |
         | text            | Тропарь для чтения вслух чтобы наговорить        |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Тропарь                                          |
         | description     | Тропарь для / чтения вслух // чтобы наговорити   |

   @get @collection
   Пример: Запрос к контроллеру звѫчєј в АПИ при отсутствии звѫчєј
      Пусть не єствує ни єднѣ звѫкѣ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/audios.json"
      То добѫдꙛ кодъ поврата "204"


   @get @collection
   Пример: Запрос к контроллеру звѫчєј в АПИ
      Пусть сѫ "1" слика
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/audios.json"
      То добѫдꙛ кодъ поврата "200"

   @get @collection
   Пример: Користник добыває списъ звѫчєј
      Если запытаю добыванје из изнахоѕи "/api/v0/audios.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cfaabc4dc397f74abd70d6f053
           language: ср
           alphabeth: СР
           title: Звѫчє
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f053.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f063
           language: ру
           alphabeth: РУ
           title: Гласно
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f063.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f064
           language: ср
           alphabeth: СР
           title: Звѫкъ
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f064.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f065
           language: ру
           alphabeth: РУ
           title: Гласно 1
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f065.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f066
           language: ср
           alphabeth: СР
           title: Гѫдьба
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f066.opus"
         """
      А добѫдꙛ охватъ "0-9/5"

   @get @collection @search
   Пример: Користник искає во спису звѫчєј по памѧтному едозу (єдином опозонавателю) во взору id
      Если запытаю добыванје из изнахоѕи "/api/v0/audios.json?m=101"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cfaabc4dc397f74abd70d6f065
           language: ру
           alphabeth: РУ
           title: Гласно 1
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f065.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f066
           language: ср
           alphabeth: СР
           title: Гѫдьба
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f066.opus"
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному кратку имени
      Если запытаю добыванје из изнахоѕи "/api/v0/audios.json?m=Памѧтно"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cfaabc4dc397f74abd70d6f063
           language: ру
           alphabeth: РУ
           title: Гласно
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f063.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f064
           language: ср
           alphabeth: СР
           title: Звѫкъ
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f064.opus"
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search
   Пример: Користник искає во спису личинок по событијну опозонавателю
      Если запытаю добыванје из изнахоѕи "/api/v0/audios.json?e=200201"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cfaabc4dc397f74abd70d6f064
           language: ср
           alphabeth: СР
           title: Звѫкъ
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f064.opus"
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтну и событијну опозонавателєм
      Если запытаю добыванје из изнахоѕи "/api/v0/audios.json?m=слуг&e=200201"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @search
   Пример: Користник искає во спису личинок по памѧтному едозу
      Если запытаю добыванје из изнахоѕи "/api/v0/audios.json?uno=Титуло#Сꙛбытие"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cfaabc4dc397f74abd70d6f066
           language: ср
           alphabeth: СР
           title: Гѫдьба
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f066.opus"
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection
   Пример: Запрос постраничный к контроллеру звѫчєј в АПИ
      Пусть сѫ звѫця:
         """
         ---
         - id: 200004
           uid: 6b9e05cfaabc4dc397f74abd70d6f057
           audio_path: features/fixtures/hey_cartoon.mp3
           meta: {}
           title: Aperçu 4
         """
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/audios.json" сꙛ доводом "per=3"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cfaabc4dc397f74abd70d6f053
           language: ср
           alphabeth: СР
           title: Звѫчє
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f053.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f063
           language: ру
           alphabeth: РУ
           title: Гласно
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f063.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f064
           language: ср
           alphabeth: СР
           title: Звѫкъ
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f064.opus"
         """
      А добѫдꙛ охватъ "0-2/6"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/audios.json" сꙛ доводом "per=3&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: 6b9e05cfaabc4dc397f74abd70d6f065
           language: ру
           alphabeth: РУ
           title: Гласно 1
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f065.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f066
           language: ср
           alphabeth: СР
           title: Гѫдьба
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f066.opus"
         - uid: 6b9e05cfaabc4dc397f74abd70d6f057
           language: фр
           alphabeth: ФР
           title: Aperçu 4
           url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f057.opus"
         """
      А добѫдꙛ охватъ "3-5/6"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/audios.json" сꙛ доводом "per=3&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @error @416
   Пример: Запрос к контроллеру звѫчєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/audios.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @error @416
   Пример: Запрос к контроллеру звѫчєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/audios.json" сꙛ заглавјем:
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
   Пример: Користник створяє звѫкё
      Если запытаю створенје изнахоѕи звѫкѣ "/api/v0/audios/create.json" сꙛ даными:
         | uid          | 6b9e05cfaabc4dc397f74abd70d6f054        |
         | kind         | Picture                                 |
         | meta         | {}                                      |
         | audio_path   | features/fixtures/hey_cartoon.mp3       |
         | title        | Звуче 1                                 |
         | description  | Описание                                |
         | reading      | Тропарь                                 |
         | language     | ру                                      |
         | alphabeth    | РУ                                      |
         | attitude_to  | Памѧтно(1.1,1.2)                        |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cfaabc4dc397f74abd70d6f054
         language: ру
         alphabeth: РУ
         title: Звуче 1
         url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f054.opus"
         """
      И изнахоѕь звѫкѣ "Звуче 1" бѫдє яко:
         """
         ---
         uid: 6b9e05cfaabc4dc397f74abd70d6f054
         kind: Picture
         meta: {}
         language: ру
         alphabeth: РУ
         title: Звуче 1
         description: Описание
         url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f054.opus"
         attitudes:
         - attitude_to: Памѧтно
           poses: "[(1.1,1.2)]"
           meta: {}
         """

   @create @object @error @422
   Пример: Користник кушає створити подвојну звѫкё, и не можє
      Если запытаю створенје изнахоѕи звѫкѣ "/api/v0/audios/create.json" сꙛ даными:
         | uid          | 6b9e05cfaabc4dc397f74abd70d6f054     |
         | type         | Picture                              |
         | meta         | {}                                   |
         | reading      | Тропарь                              |
         | audio_path   | features/fixtures/ice_rock_drop.mp3  |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         errors:
         - Digest has already been taken
         """
      А изнахоѕи звѫкѣ "Звѫчє 1" не бѫдє

   @update @object @error @404
   Пример: Користник поновяє данє звѫкё
      Если запытаю одсланје звѫкё в изнаходь "/api/v0/audios/6b9e05cfaabc4dc397f74abd70d6f053.json" сꙛ даными:
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054 |
         | kind         | Picture                              |
         | meta         | {}                                   |
         | audio_path   | features/fixtures/hey_cartoon.mp3    |
         | title        | Звѫчѥ                                |
         | description  | Описание                             |
         | language     | сс                                   |
         | alphabeth    | СС                                   |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cfaabc4dc397f74abd70d6f053
         digest: f50d68b2dcd74a2c38ce097e53ec72260b823cf72a2c867dd03a84b8cd10d167
         language: сс
         alphabeth: СС
         title: Звѫчѥ
         description: Описание
         url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f053.opus"
         meta: {}
         kind: Picture
         reading: ''
         attitudes: []
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/audios/6b9e05cfaabc4dc397f74abd70d6f053.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cfaabc4dc397f74abd70d6f053
         digest: f50d68b2dcd74a2c38ce097e53ec72260b823cf72a2c867dd03a84b8cd10d167
         language: сс
         alphabeth: СС
         title: Звѫчѥ
         description: Описание
         url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f053.opus"
         meta: {}
         kind: Picture
         reading: ''
         attitudes: []
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/audios/6b9e05cfaabc4dc397f74abd70d6f054.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object
   Пример: Користник добыває данє звѫцё
      Пусть є письмо сꙛ даными:
         | id              | 200020                                        |
         | type            | Scriptum                                      |
         | text            | Текст для чтения вслух чтобы наговорить       |
         | language_code   | ру                                            |
         | alphabeth_code  | РО                                            |
         | title           | Текст для чтения вслух чтобы наговорить       |
         | description     | Текст для / чтения вслух / чтобы наговорить   |
      Пусть є звѫчє сꙛ даными:
         | id           | 200020                                  |
         | uid          | 6b9e05cf-aabc-4dc3-97f7-4abd70d6f054    |
         | meta         | {}                                      |
         | audio_path   | features/fixtures/hey_cartoon.mp3       |
         | title        | Гласно 1                                |
         | attitude_to  | Памѧтно(1.1,1.2,1.3,1.4)                |
         | reading      | Текст для чтения вслух чтобы наговорить |
      Если запытаю добыванје из изнахоѕи "/api/v0/audios/6b9e05cfaabc4dc397f74abd70d6f054.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cfaabc4dc397f74abd70d6f054
         digest: 511d4de1578acb6f29aae78b0aa6aeaad012f2da2e8819a878f341e5b07e3395
         language: ру
         alphabeth: РУ
         title: Гласно 1
         description:
         url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f054.opus"
         meta: {}
         kind: Audio
         reading: Текст для чтения вслух чтобы наговорить
         attitudes:
         - attitude_to: Памѧтно
           poses: "[(1.1,1.2),(1.3,1.4)]"
           meta: {}
         """

   @get @object
   Пример: Користник добыває данє звѫцё
      Если запытаю добыванје из изнахоѕи "/api/v0/audios/6b9e05cfaabc4dc397f74abd70d6f053.json"
      То добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cfaabc4dc397f74abd70d6f053
         digest: f50d68b2dcd74a2c38ce097e53ec72260b823cf72a2c867dd03a84b8cd10d167
         language: ср
         alphabeth: СР
         title: Звѫчє
         description:
         url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f053.opus"
         meta: {}
         kind: Audio
         reading: ''
         attitudes: []
         """

   @delete @object
   Пример: Користник изтьрає иззначенє звѫкё
      Если запытаю изтрѣнје изнахоѕи "/api/v0/audios/6b9e05cfaabc4dc397f74abd70d6f053.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         uid: 6b9e05cfaabc4dc397f74abd70d6f053
         digest: f50d68b2dcd74a2c38ce097e53ec72260b823cf72a2c867dd03a84b8cd10d167
         language: ср
         alphabeth: СР
         title: Звѫчє
         description:
         url: "/audios/6/6b/6b9e05cfaabc4dc397f74abd70d6f053.opus"
         meta: {}
         kind: Audio
         reading: ''
         attitudes: []
         """
      И звѫчє "Звѫчє" не будє єствовати

   @get @collection @error
   Пример: Запрос к контроллеру звѫчєј в АПИ при отсутствии звѫчєј
      Пусть не єствує ни єднѣ звѫкѣ
      Если покушаю створити "GET" запытъ до адреса "/api/v0/audios.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
