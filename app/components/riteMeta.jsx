import { matchLanguages, matchAlphabeths, matchLetters, matchEmptyObject, matchCodes, matchEmptyCollection, matchValidJson, matchSelection } from 'matchers'
import { makeTitle } from 'makers'

export const riteMeta = {
   default: 'abbreviation',
   remoteName: 'rite',
   remoteNames: 'admin/rites',
   title: 'Чины',
   new: 'Новое чины',
   update: 'Обнови чин',
   create: 'Создай чин',
   close: 'Закрой',
   remove: {
      title: 'Точно ли удалить чин %default?',
      yes: "Да"
   },
   row: {
      id: {
         title: 'Оз',
      },
      abbreviation: {
         title: 'Сокращение',
      },
      text: {
         title: 'Буке',
         value: (value) => {
            if (value.title) {
               return value.title
            } else if (value.text && value.text.length > 30) {
               return value.text.slice(0, 30) + '...'
            } else {
               return value.text
            }
         },
      },
      language_code: {
         title: 'Язык',
      },
      alphabeth_code: {
         title: 'Азбука',
      },
      bond_to_rite: {
         title: 'Связано с...',
      },
      root_rite: {
         title: 'Корень...',
      },
      title: {
         title: 'Заглавие',
         value: makeTitle,
         source: 'titles',
         filter: { type: "Title" },
      },
   },
   form: {
      id: {
         kind: 'hidden',
      },
      abbreviation: {
         kind: 'text',
         title: 'Сокращение',
         display_scheme: '6-6-2-2',
         placeholder: 'Впиши сокращение',
         validations: {
            'Сокращение должно быть задано': matchEmptyObject,
         }
      },
      language_code: {
         kind: 'dynamic',
         title: 'Язык',
         display_scheme: '12-3-2-2',
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
         display_scheme: '12-3-2-2',
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
      root_id: {
         kind: 'dynamic',
         humanized_name: 'root_rite',
         title: 'Корневой чин',
         display_scheme: '12-5-2-2',
         placeholder: 'Начни ввод чина...',
         pathname: 'api/v0/rites/ac',
         key_name: 'value',
         value_name: 'key',
      },
      bind_kind_rite: {
         humanized_name: 'bind_kind_humanized',
         kind: 'dynamic',
         display_scheme: '12-2-2-2',
         title: 'Вид связки',
         placeholder: 'Начни ввод связки...',
         pathname: 'api/v0/subjects/ac',
         context_value: { k: "RiteBind" },
         key_name: 'value',
         value_name: 'key',
         subscribeTo: '@bond_to_id',
         default: "несвязан", // default value
         humanized_default: "Не связан", // default value name
         validations: {
            'Вид связки из списка должен быть выбран': matchEmptyObject,
            'Вид связки не должен иметь значение "Не связан" в случае, если связанный чин задан': (value, context) => {
               return context.bond_to_id && value == "несвязан"
            },
            'Вид связки должен иметь значение "Не связан" в случае, если связанный чин отсутствует': (value, context) => {
               return !context.bond_to_id && value != "несвязан"
            },
         }
      },
      bond_to_id: {
         kind: 'dynamic',
         title: 'Связанный чин',
         humanized_name: 'bond_to_rite',
         display_scheme: '12-5-2-2',
         placeholder: 'Начни ввод чина...',
         pathname: 'api/v0/rites/ac',
         key_name: 'value',
         value_name: 'key',
         subscribeTo: ['@bind_kind_rite', '@text'],
         validations: {
            'Связанный чин не должен соответствовать названию текущего': (value, context) => {
               return value && value == context.id
            },
         }
      },

      text: {
         kind: 'tale',
         title: 'Текст',
         placeholder: 'Введи текст',
         display_scheme: '12-12-12-12',
         subscribeTo: '@alphabeth_code',
         validations: {
            'Текст отсутствует': (value, context) => {
               return !context.ref_title && matchEmptyObject(value)
            },
            'Текст содержит знаки вне перечня избранной азбуки': matchLetters,
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
      descriptions: {
         kind: 'collection',
         title: "Описания",
         action: "Добавь описание",
         display_scheme: '12-12-12-12',
         filter: { type: "Description" },
         validations: {
            'Языки в описаниях не могут совпадать': matchLanguages,
            'Азбуки в описаниях не могут совпадать': matchAlphabeths,

         },
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'tale',
               title: 'Имя',
               name: 'text',
               placeholder: 'Введи описание',
               display_scheme: '12-12-12-12',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Текст имени отсутствует': matchEmptyObject,
                  'Набранный текст содержит знаки вне перечня избранной азбуки': matchLetters,
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
   }
}
