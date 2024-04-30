const event_types = ['Resurrection', 'Repose', 'Writing', 'Appearance', 'Translation', 'Sanctification', 'Veneration']

export function makeTweet(value, languages, source = 'tweets', filter = null) {
   let tweets = languages.map((language) => {
      return value[source].reduce((res, text) => {
         return res ||
            language === text.language_code &&
            (!filter || Object.keys(filter).reduce((r, key) => {
               return r || text[key] === filter[key]
            }, null)) &&
            text.text
      }, null)
   }).filter((e) => { return e })

   if (tweets[0] && tweets[0].length > 27) {
      return tweets[0].slice(0, 27) + '...'
   } else {
      return tweets[0] || ''
   }
}

export function makeNote(value, languages, source = 'notes', filter = null) {
   let notes = languages.map((language) => {
      return value[source].reduce((res, text) => {
         return res ||
            language === text.language_code &&
            (!filter || Object.keys(filter).reduce((r, key) => {
               return r || text[key] === filter[key]
            }, null)) &&
            text.text
      }, null)
   }).filter((e) => { return e })

   if (notes[0] && notes[0].length > 27) {
      return notes[0].slice(0, 27) + '...'
   } else {
      return notes[0] || ''
   }
}

export function makeName(value, languages, source = 'names', filter = null) {
   let names = languages.map((language) => {
      return value[source].reduce((res, text) => {
         return res ||
            language === text.language_code &&
            (!filter || Object.keys(filter).reduce((r, key) => {
               return r || text[key] === filter[key]
            }, null)) &&
            text.text
      }, null)
   }).filter((e) => { return e })

   return names[0] || ''
}

// filter: hash of key: value pairs to filter out the source
export function makeTitle(value, languages, source = 'titles', filter = null) {
   let titles = languages.map((language) => {
      return value[source].reduce((res, text) => {
         return res ||
            language === text.language_code &&
            (!filter || Object.keys(filter).reduce((r, key) => {
               return r || text[key] === filter[key]
            }, null)) &&
            text.text
      }, null)
   }).filter((e) => { return e })

   return titles[0] || ''
}

export function makeDate(record) {
   let dates = [...event_types].filterMap((event_type) => {
      return record.events.find((e) => e.kind_code == event_type)?.happened_at
   })

   return dates[0] || ''
}

export function makeCouncil(value) {
   if (value.council && value.council.length > 17) {
      return value.council.slice(0, 17) + '...'
   } else {
      return value.council || ''
   }
}

export function makeDescription(value, languages, source = 'descriptions', filter = null) {
   let descriptions = languages.map((language) => {
      return value[source].reduce((res, text) => {
         return res ||
            language === text.language_code &&
            (!filter || Object.keys(filter).reduce((r, key) => {
               return r || text[key] === filter[key]
            }, null)) &&
            text.text
      }, null)
   }).filter((e) => { return e })

   if (descriptions[0] && descriptions[0].length > 27) {
      return descriptions[0].slice(0, 27) + '...'
   } else {
      return descriptions[0] || ''
   }
}
