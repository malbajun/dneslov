import { matchLanguages, matchAlphabeths, matchLetters, matchEmptyObject, matchCodes, matchEmptyCollection } from 'matchers'
import UrlRegexp from 'UrlRegexp'

export const memoMeta = {
   default: 'memory',
   remoteNames: 'memoes',
   remoteName: 'memo',
   title: 'Помины',
   new: 'Новый помин',
   update: 'Обнови память',
   create: 'Создай память',
   close: 'Закрой',
   remove: {
      title: 'Точно ли удалить помин %default?',
      yes: "Да"
   },
   row: {
      order: {
         title: 'Чин',
         value: (value) => { return value.memo_orders && value.memo_orders[0] && value.memo_orders[0].order },
      },
      memory: {
         title: 'Память',
         value: (value) => { return value.memory_name },
      },
      year_date: {
         title: 'Дата',
      },
      happened_at: {
         title: 'Пора',
      },
      event: {
         title: 'Событие',
         value: (value) => { return value.event_short_title },
      },
      bond_to: {
         title: 'Связка с...',
         value: (value) => {
            if (value.bond_to_title && value.bond_to_title.length > 40) {
               return value.bond_to_title.slice(0, 40) + '...'
            } else {
               return value.bond_to_title
            }
         },
      },
      add_date: {
         title: 'Добавлено...',
      },
      calendary: {
         title: 'Календарь',
         value: (value) => { return value.calendary_title },
      }
   },
   form: {
      id: {
         kind: 'hidden',
      },
      calendary_id: {
         kind: 'dynamic',
         title: 'Календарь',
         humanized_name: 'calendary_title',
         pathname: 'api/v0/calendaries/ac',
         key_name: 'value',
         value_name: 'key',
         placeholder: 'Начни ввод наименования календаря...',
         display_scheme: '12-6-4-4',
         validations: {
            "Календарь должен быть избран": /^$/
         }
      },
      memory_id: {
         kind: 'dynamic',
         humanized_name: 'memory_name',
         display_scheme: '12-6-4-4',
         pathname: 'api/v0/memories/ac',
         queryKey: 'q',
         key_name: 'value',
         value_name: 'key',
         title: 'Память',
         placeholder: 'Начни ввод текста имени или описания памяти...',
         validations: {
            "Память должна быть избрана": /^$/
         }
      },
      event_id: {
         kind: 'dynamic',
         context_names: 'memory_id',
         humanized_name: 'event_short_title',
         pathname: 'api/v0/events/ac',
         key_name: 'value',
         value_name: 'key',
         title: 'Событие',
         placeholder: 'Начни ввод имени события...',
         display_scheme: '12-6-4-3',
         validations: {
            "Событие должно быть избрано": /^$/
         }
      },
      add_date: {
         kind: 'text',
         title: 'Пора добавления',
         placeholder: 'Введи пору',
         display_scheme: '12-6-3-3',
      },
      year_date: {
         kind: 'text',
         title: 'Дата в году',
         placeholder: 'Введи дату в году',
         data: { length: '7' },
         display_scheme: '12-3-2-2',
         subscribeTo: '@bind_kind_code',
         validations: {
            "Слишком длинное значение даты в году": /^.{8,}$/,
            "Годовая дата отсутствует": (value, context) => {
               return false // !value && context.bind_kind_code != "соборный"
            },
            "В значении даты допустимы только цифры, точка, знаки отношения (%,>,<,~) или знаки + и -": /[^0-9+\.\-%<>~]/,
            "Знак отношения должен следовать за годичной датой": /^([0-9]+\.?|)[%<>~]/,
            "Опорный день после знака отношения обязателен": /^[0-9\.]+[%<>~]([^0-6]|)?$/,
            "Знак + или - может только предварять число": /^.[\-+]{1,4}$/,
            "Цифры должны быть введены обязательно": /^[\-+\.]+$/,
         }
      },
      happened_at: {
         kind: 'text',
         title: 'Случилось в...',
         placeholder: 'Введи пору',
         display_scheme: '12-6-4-2',
      },
      bind_kind_code: {
         kind: 'select',
         title: 'Вид привязки к помину',
         codeNames: {
            '': 'Избери вид привязки...',
            'несвязаный': 'Не привязаный',
            'соборный': 'Соборный помин',
            'навечерие': 'Навечерие',
            'предпразднество': 'Предпразднество',
            'попразднество': 'Попразднество',
         },
         display_scheme: '12-3-3-3',
         subscribeTo: ['@bond_to_id', '@year_date'],
         validations: {
            'Пункт из списка должен быть выбран': matchEmptyObject,
            'Вид привязки не должен иметь значения "Не привязаный" в случае, если привязка задана': (value, context) => {
               return context.bond_to_id && value && value.match(/несвязаный/)
            },
            'Вид привязки должен иметь значения "Не привязаный" в случае, если привязка отсутствует': (value, context) => {
               return !context.bond_to_id && value && !value.match(/несвязаный/)
            },
         }
      },
      bond_to_id: {
         kind: 'dynamic',
         title: 'Привязаный помин',
         humanized_name: 'bond_to_title',
         display_scheme: '12-6-4-3',
         placeholder: 'Начни ввод даты привязаного помина...',
         pathname: 'api/v0/memoes/ac',
         key_name: 'value',
         value_name: 'key',
         subscribeTo: '@bind_kind_code',
         queryKey: 'q',
         visible_if: { bind_kind_code: ["навечерие", "предпразднество", "попразднество", "соборный"] },
         context_names: {
           'calendary_id': true,
         },
         validations: {
            'Привязаная дата не должна соответствовать текущей дате': (value, context) => {
               let yearDateIn = context.bond_to_year_date || context.bond_to || "",
                   match = yearDateIn.match(/^[0-9\.]+/),
                   yearDate = match && match[0]
               return value && yearDate == context.year_date && context.bind_kind_code != 'соборный'
            },
            'Привязаный помин не должен соответствовать текущему помину для соборного типа': (value, context) => {
               return value && context.id && value == context.id && context.bind_kind_code == 'соборный'
            }
         },
      },
      memo_orders: {
         kind: 'collection',
         title: 'Чины',
         action: 'Добавь чин',
         display_scheme: '12-12-12-12',
         validations: {
            "Языки в чинах не могут совпадать": matchLanguages,
            "Азбуки в чинах не могут совпадать": matchAlphabeths,
            'Минимум один чин должен быть задан':  matchEmptyObject
         },
         meta: {
            id: {
               kind: 'hidden',
            },
            order_id: {
               kind: 'dynamic',
               title: 'Чин',
               pathname: 'api/v0/memories/ac',
               context_value: { t: "Language" },
               humanized_name: 'order',
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования чина...',
               display_scheme: '12-12-12-12',
               validations: {
                  "Чин отсутствует": matchEmptyObject,
                  'Чин содержит знаки вне перечня избранной азбуки': matchLetters,
               }
            },
         }
      },
      original_title: {
         kind: 'block',
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'text',
               title: 'Оригинальный заголовок в календаре',
               placeholder: 'Введи заголовок',
               display_scheme: '12-12-12-12',
               validations: {
                  "Заголовок отсутствует": matchEmptyObject,
               }
            },
         }
      },
      titles: {
         kind: 'collection',
         title: 'Заголовки',
         action: 'Добавь заголовок',
         single: 'Заголовок',
         placeholder: 'Введи заголовок',
         display_scheme: '12-12-12-12',
         validations: {
            "Языки в заголовках не могут совпадать": matchLanguages,
            "Азбуки в заголовках не могут совпадать": matchAlphabeths,
            'Минимум один заголовок должен быть задан для несоборного помина': (value, context) => {
               return value.isBlank() && context.bind_kind_code != 'соборный'
            }

         },
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'tale',
               title: 'Заголовок',
               placeholder: 'Введи заголовок',
               display_scheme: '12-12-12-12',
               subscribeTo: '@alphabeth_code',
               validations: {
                  "Заголовок отсутствует": matchEmptyObject,
                  'Заголовок содержит знаки вне перечня избранной азбуки': matchLetters,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-6-6',
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
               display_scheme: '12-6-6-6',
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
         }
      },
      versi: {
         kind: 'collection',
         title: 'Вирши',
         action: 'Добавь виршь',
         single: 'Виршь',
         placeholder: 'Введи виршь',
         source: "descriptions",
         filter: { type: "Versus" },
         display_scheme: '12-12-12-12',
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'tale',
               title: 'Виршь',
               placeholder: 'Введи виршь',
               display_scheme: '12-12-12-12',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Текст вирши отсутствует': matchEmptyObject,
                  'Виршь содержит знаки вне перечня избранной азбуки': matchLetters,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-6-6',
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
               display_scheme: '12-6-6-6',
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
         }
      },
      notes: {
         kind: 'collection',
         title: 'Заметки',
         action: 'Добавь заметку',
         single: 'Заметка',
         placeholder: 'Введи заметку',
         source: "descriptions",
         filter: { type: "Note" },
         display_scheme: '12-12-12-12',
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'tale',
               title: 'Заметка',
               placeholder: 'Введи заметку',
               display_scheme: '12-12-12-12',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Текст заметки отсутствует': matchEmptyObject,
                  'Заметка содержит знаки вне перечня избранной азбуки': matchLetters,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-6-6',
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
               display_scheme: '12-6-6-6',
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
         }
      },
      descriptions: {
         kind: 'collection',
         title: 'Описания',
         action: 'Добавь описание',
         single: 'Описание',
         placeholder: 'Введи описание',
         filter: { type: "Description" },
         display_scheme: '12-12-12-12',
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'tale',
               title: 'Описание',
               placeholder: 'Введи описание',
               display_scheme: '12-12-12-12',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Текст описания отсутствует': matchEmptyObject,
                  'Описание содержит знаки вне перечня избранной азбуки': matchLetters,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-6-6',
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
               display_scheme: '12-6-6-6',
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
         }
      },
      links: {
         kind: 'collection',
         display_scheme: '12-12-12-12',
         title: 'Ссылки',
         action: 'Добавь ссылку',
         placeholder: 'Введи ссылку',
         source: "links",
         meta: {
            id: {
               kind: 'hidden',
            },
            url: {
               kind: 'text',
               title: 'Ссылка',
               placeholder: 'Введи ссылку',
               display_scheme: '12-12-6-6',
               subscribeTo: '@alphabeth_code',
               validations: {
                  "Ссылка отсутствует": matchEmptyObject,
                  "Неверный формат ссылки": [ "!", UrlRegexp ],
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-4-2-2',
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
               display_scheme: '12-4-2-2',
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
            type: {
               kind: 'select',
               title: 'Вид ссылки',
               codeNames: {
                  '': 'Избери вид текста...',
                  'DescriptiveLink': 'Описательная ссылка',
                  'ServiceLink': 'Службовая ссылка',
                  'BeingLink': 'Бытийная ссылка',
               },
               display_scheme: '12-4-2-2',
               validations: {
                  'Пункт из списка должен быть выбран': matchEmptyObject,
               },
            },
         }
      },
   },
}
