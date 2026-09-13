import { matchLanguages, matchAlphabeths, matchLetters, matchEmptyObject, matchCodes, matchEmptyCollection, matchValidUrl } from 'matchers'
import { makeCouncil, makeDate, makeDescription, makeTweet } from 'makers'

export const eventMeta = {
   default: 'id',
   remoteName: 'event',
   remoteShow: 'api/v0/events',
   remoteNames: 'api/v0/events',
   title: 'События',
   new: 'Новое событие',
   update: 'Обнови событие',
   create: 'Создай событие',
   close: 'Закрой',
   remove: {
      title: 'Точно ли удалить событие %default?',
      yes: "Да"
   },
   row: {
      id: {
         title: 'Оз',
      },
      kind: {
         title: 'Вид',
      },
      memory_short_name: {
         title: 'Краткое имя',
      },
      happened_at: {
         title: 'Случилось в',
      },
      place: {
         title: 'Место',
      },
   },
   form: {
      id: {
         kind: 'hidden',
      },
      kind_code: {
         kind: 'dynamic',
         title: 'Вид события',
         placeholder: 'Начни ввод наименования вида события...',
         pathname: 'api/v0/subjects/ac',
         humanized_name: 'kind',
         context_value: { k: "EventKind" },
         key_name: 'value',
         value_name: 'key',
         display_scheme: '12-3-2-2',
         validations: {
            'Пункт из списка должен быть выбран': matchEmptyObject,
         },
      },
      happened_at: {
         kind: 'text',
         title: 'Случилось в...',
         placeholder: 'Введи пору',
         display_scheme: '12-3-2-2',
         validations: {
            'Время должно быть задано':  matchEmptyObject
         }
      },
      place_uno: {
         kind: 'dynamic',
         title: 'Место происшествия',
         humanized_name: 'place',
         pathname: 'api/v0/memories/ac',
         queryKey: 't',
         name: 'place_slug',
         key_name: 'value',
         value_name: 'key',
         placeholder: 'Начни ввод наименования места...',
         display_scheme: '12-3-4-4',
      },
      item_id: {
         kind: 'dynamic',
         title: 'Предмет',
         humanized_name: 'item',
         pathname: 'api/v0/items/ac',
         queryKey: 't',
         name: 'item_id',
         key_name: 'value',
         value_name: 'key',
         placeholder: 'Начни ввод наименования предмета...',
         display_scheme: '12-3-4-4',
      },
      title: {
         kind: 'text',
         title: 'Написание заголовка',
         placeholder: 'Введи текст заголовка',
         display_scheme: '12-12-12-12',
      },
      description: {
         kind: 'tale',
         title: 'Текст описания',
         placeholder: 'Введи текст описания',
         display_scheme: '12-12-12-12',
      },
   }
}
