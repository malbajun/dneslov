import { matchLanguages, matchAlphabeths, matchLetters, matchEmptyObject, matchCodes, matchEmptyCollection } from 'matchers'

export const scriptumMeta = {
   default: "text", //TODO (value) => { return value.text || value.ref_title || value.title },
   remoteNames: 'api/v0/scripta',
   remoteName: 'scriptum',
   title: 'Тексты',
   new: 'Новый текст',
   update: 'Обнови текст',
   create: 'Создай текст',
   close: 'Закрой',
   remove: {
      title: 'Точно ли удалить текст %default?',
      yes: "Да"
   },
   row: {
      id: {
         title: 'Оз',
      },
      type: {
         title: 'Вид',
         value: (value) => {
            const scriptumTable = {
               'Prolog': 'Пролог',
               'Irmos': 'Ирмос',
               'Ikos': 'Икос',
               'Troparion': 'Тропарь',
               'Kontakion': 'Кондак',
               'Stichira': 'Стихира',
               'CryStichira': 'Воззвашна',
               'Exapostilarion': 'Светилен',
               'SessionalHymn': 'Седальна',
               'Kanonion': 'Седальна канона',
               'Kathismion': 'Седальна кафизмы',
               'Polileosion': 'Седальна полиелея',
               'Apostichus': 'Стиховна',
               'Stichiron': 'Литийна',
               'Praision': 'Хвалитна',
               'Sedation': 'Степенна',
               'Anatolion': 'Восточна',
               'Resurrexion': 'Воскресна',
               'Ipakoi': 'Ипакой', // на 17-й кафизмѣ
               'Magnification': 'Величание',
               'Prayer': 'Молитва',
               'Orison': 'Моление',
               'Canticle': 'Спевна',
               'Chant': 'Песнопение',
               'Canto': 'Песма',
               'Bible': 'Библия',
               'Scriptum': 'Текст',
               'Stichus': 'Стих',
            }

            return scriptumTable[value.type]
         },
      },
      language_code: {
         title: 'Язык',
      },
      alphabeth_code: {
         title: 'Азбука',
      },
      title: {
         title: 'Заглавок',
      },
      root_ref_title: {
         title: 'Корень',
      },
      bond_to_ref_title: {
         title: 'Ссылка',
      },
      prosomeion_ref_title: {
         title: 'Подобен',
      },
      resource_title: {
         title: 'Изнаходь',
      },
   },
   form: {
      id: {
         kind: 'hidden',
      },
      type: {
         kind: 'select',
         title: 'Вид текста',
         codeNames: {
            '': 'Избери вид текста...',
            'Scriptum': 'Текст',
            'Bible': 'Библия',
            'Prolog': 'Пролог',
            'Canto': 'Песма',
            'Chant': 'Песнопение',
            'Canticle': 'Спевна',
            'Orison': 'Моление',
            'Magnification': 'Величание',
            'Prayer': 'Молитва',
            'Irmos': 'Ирмос',
            'Ikos': 'Икос',
            'Troparion': 'Тропарь',
            'Stichira': 'Стихира',
            'Kontakion': 'Кондак',
            'Exapostilarion': 'Светилен',
            'SessionalHymn': 'Седальна',
            'Kanonion': 'Седальна канона',
            'Kathismion': 'Седальна кафизмы',
            'Polileosion': 'Седальна полиелея',
            'Apostichus': 'Стиховна',
            'CryStichira': 'Воззвашна',
            'Stichiron': 'Литийна',
            'Praision': 'Хвалитна',
            'Sedation': 'Степенна',
            'Anatolion': 'Восточна',
            'Resurrexion': 'Воскресна',
            'Stichus': 'Стих',
            'Ipakoi': 'Ипакой' // на 17-й кафизмѣ
         },
         display_scheme: '12-2-2-2',
         validations: {
            'Пункт из списка должен быть выбран': matchEmptyObject,
         },
      },
      language_code: {
         kind: 'dynamic',
         title: 'Язык',
         display_scheme: '12-3-3-3',
         pathname: 'api/v0/subjects/ac',
         humanized_name: 'language',
         context_value: { k: "Language" },
         key_name: 'value',
         value_name: 'key',
         placeholder: 'Начни ввод наименования языка...',
         subscribeTo: '@alphabeth_code',
         validations: {
            'Избранный язык не соотвествует избранной азбуке': matchCodes,
            'Язык из списка должен быть выбран': matchEmptyObject,
         }
      },
      alphabeth_code: {
         kind: 'dynamic',
         title: 'Азбука',
         display_scheme: '12-3-3-3',
         pathname: 'api/v0/subjects/ac',
         humanized_name: 'alphabeth',
         context_value: { k: "Alphabeth" },
         key_name: 'value',
         value_name: 'key',
         placeholder: 'Начни ввод наименования азбуки...',
         subscribeTo: '@language_code',
         validations: {
            'Избранная азбука не соотвествует избранному языку': matchCodes,
            'Азбука из списка должна быть выбрана': matchEmptyObject,
         }
      },
      resource_id: {
         kind: 'dynamic',
         title: 'Изнаходь',
         humanized_name: 'resource_name',
         display_scheme: '12-4-4-4',
         placeholder: 'Начни ввод наименования изнаходи...',
         pathname: 'api/v0/resources/ac',
         key_name: 'value',
         value_name: 'key',
         validations: {
            'Изнаходь должна быть избрана':  matchEmptyObject,
         }
      },
      title: {
         kind: 'text',
         title: 'Титул / сокращение текста',
         placeholder: 'Введи сокращение',
         display_scheme: '12-8-8-8',
      },
      root_id: {
         kind: 'dynamic',
         humanized_name: 'root_ref_title',
         title: 'Корневой заголовок',
         display_scheme: '12-4-4-4',
         placeholder: 'Начни ввод заголовка...',
         pathname: 'api/v0/scripta/ac',
         key_name: 'value',
         value_name: 'key',
      },
      text: {
         kind: 'tale',
         title: 'Текст',
         placeholder: 'Введи текст',
         display_scheme: '12-12-12-12',
         subscribeTo: '@alphabeth_code',
         visible_if: { 
            ref_title:  (value, _context) => { return value.isBlank() }
         },
         validations: {
            'Текст отсутствует': (value, context) => {
               return !context.ref_title && matchEmptyObject(value)
            },
            'Текст содержит знаки вне перечня избранной азбуки': matchLetters,
         }
      },
      bind_kind_name: {
         humanized_name: 'bind_kind_humanized',
         kind: 'dynamic',
         display_scheme: '12-3-3-3',
         title: 'Вид связки',
         placeholder: 'Начни ввод связки...',
         pathname: 'api/v0/subjects/ac',
         context_value: { k: "TextBindKind" },
         key_name: 'value',
         value_name: 'key',
         subscribeTo: '@bond_to_id',
         default: "несвязаное", // default value
         humanized_default: "Не связанное", // default value name
         validations: {
            'Вид связки из списка должен быть выбран': matchEmptyObject,
            'Вид связки не должен иметь значение "Не связанное" в случае, если связаное имя задано': (value, context) => {
               return context.bond_to_id && value == "несвязана"
            },
            'Вид связки должен иметь значение "Не связанное" в случае, если связаное имя отсутствует': (value, context) => {
               return !context.bond_to_id && value != "несвязана"
            },
         }
      },
      bond_to_id: {
         kind: 'dynamic',
         title: 'Связаный заголовок',
         humanized_name: 'bond_to_ref_title',
         display_scheme: '12-4-4-4',
         placeholder: 'Начни ввод заголовка...',
         pathname: 'api/v0/scripta/ac',
         key_name: 'value',
         value_name: 'key',
         subscribeTo: ['@bind_kind_name', '@text'],
         validations: {
            'Связаный заголовок не должен соответствовать текущему заголовку': (value, context) => {
               return value && value == context.id
            },
         }
      },
      tone: {
         kind: 'select',
         title: 'Глас',
         visible_if: { type: [
            "Irmos", "Troparion", "Stichira", "Kontakion", "Exapostilarion", "SessionalHymn",
            "Kanonion", "Kathismion", "Polileosion", "Apostichus", "CryStichira",
            "Stichiron", "Praision", "Sedation", "Anatolion", "Resurrexion", "Ipakoi"] },
         display_scheme: '12-1-1-1',
         default: "",
         codeNames: {
            '0': 'Избери глас...',
            '1': '1-й',
            '2': '2-й',
            '3': '3-й',
            '4': '4-й',
            '5': '5-й',
            '6': '6-й',
            '7': '7-й',
            '8': '8-й',
         },
      },
      prosomeion_id: {
         kind: 'dynamic',
         title: 'Подобен',
         humanized_name: 'prosomeion_ref_title',
         display_scheme: '12-4-4-4',
         placeholder: 'Начни ввод подобна...',
         pathname: 'api/v0/scripta/ac',
         key_name: 'value',
         value_name: 'key',
         visible_if: { type: [
            "Irmos", "Troparion", "Stichira", "Kontakion", "Exapostilarion", "SessionalHymn",
            "Kanonion", "Kathismion", "Polileosion", "Apostichus", "CryStichira",
            "Stichiron", "Praision", "Sedation", "Anatolion", "Resurrexion", "Ipakoi"] },
      },
      target_events: {
         kind: 'collection',
         title: "Отношения к событиям",
         action: "Добавь отношение",
         display_scheme: '12-12-12-12',
         validations: {
            'Минимум одно отношение должно быть задано': (value, context) => {
               if (matchEmptyObject(value, context)) { return true }
            }
         },
         meta: {
            id: {
               kind: 'hidden',
            },
            kind: {
               kind: 'select',
               title: 'Род отношения',
               display_scheme: '12-3-2-1',
               codeNames: {
                  '': 'Избери вид отношения...',
                  'From': 'Обращение от...',
                  'To': 'Обращение к...',
                  'About': 'Текст о...',
                  'Author': 'Автор',
                  'Translator': 'Переводчик',
               },
               validations: {
                  'Пункт из списка должен быть выбран': matchEmptyObject,
               },
            },
            event_id: {
               kind: 'dynamic',
               title: 'Память',
               humanized_name: 'event_name',
               display_scheme: '12-9-10-11',
               placeholder: 'Начни ввод текста имени или описания памяти...',
               pathname: 'api/v0/events/ac',
               key_name: 'value',
               value_name: 'key',
               validations: {
                  'Память должна быть избрана':  matchEmptyObject,
               }
            },
         }
      },
      author: {
         kind: 'text',
         title: 'Автор',
         placeholder: 'Введи автора',
         display_scheme: '12-12-12-12',
      },
      description: {
         kind: 'tale',
         title: 'Описание текста',
         placeholder: 'Введи описание текста',
         display_scheme: '12-12-12-12',
      },
   },
}
