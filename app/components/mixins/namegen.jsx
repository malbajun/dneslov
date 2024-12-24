const kinds = [
      "переложеное",
      "прилаженое",
      "переводное",
      "несвязаное",
   ]

const priorities = [
   {
      klugs: ['свщмч', 'свмчр', 'прав', 'правж', 'сщпр', 'муч', 'муц', 'мучр', 'муцр', 'вмч', 'вмц', 'смчр', 'блж', 'блжц', 'блгв', 'блгвц', 'бср', 'испв', 'стц', 'стца', 'сщстц', 'испв', 'иср', 'исц', 'ицр', 'свщисп', 'свщиср'],
      states: [ 'покаянное', 'крещенское' ],
   },
   {
      klugs: ['прпжн', 'прпк', 'прпп', 'прпмч', 'прмчр', 'прпмц', 'прмцр', 'блпр', 'мчсвт', 'мчсвтр', 'стцсвт', 'прстц', 'прстца', 'прписп', 'прписр', 'прписц', 'прпицр', 'исвт', 'иссвтр', 'прпст', 'прпсж', 'свтл', 'прпсвт'],
      states: [ 'схимное', 'иноческое', 'чернецкое' ],
   },
   {
      klugs: ['прор', 'апс'],
      states: [ 'наречёное' ],
   },
   {
      klugs: ['рапс', 'рапж'],
      states: [ 'наречёное', 'покаянное', 'крещенское' ],
   }
]

export const generateFullName = (namesIn, klugs = []) => {
   console.debug("[generateFullName] <<< ", namesIn, klugs)
   let names = namesIn.sort((a, b) => { return a.level < b.level }),
       fullName = [
      getFirstName(names, klugs),
      getNickName(names),
      getLastName(names),
      getFeatName(names)
   ].compact().flat()

   console.debug("[generateFullName] **", fullName, "from:", names)

   return fullName.slice(0, 3).join(" ")
}

const getFirstName = (namesIn, klugs) => {
   let preprios = [
      'благословенное',
      'схимное',
      'иноческое',
      'чернецкое',
      'покаянное',
      'крещенское',
      'самоданное' ]

   let prios = priorities.reduce((pp, prio) => {
      let _prios = klugs.reduce((p, nameKlug) => {
         return p.isBlank() && prio['klugs'].includes(nameKlug) && prio['states'] || p
      }, [])

      return _prios.concat(pp)
   }, preprios).uniq()

   let names = getNamesFor(prios, namesIn),
       secondaries = [] // namesIn.slice(1,-1).map((n) => n.name_text).compact()

   return names.isPresent() ? (names[0] && names[0].name_text + " " + (secondaries.isPresent() ? "(" + secondaries.join(", ") + ")" : "")) : ""
}

const getNickName = (namesIn) => {
   let prios = [
      'прозвание',
      'наречёное' ]

   console.debug("[getNickName] <<< *********** ", namesIn)
   console.debug("[getNickName] <<< *********** ", getNameFor(prios, namesIn, 4))
   return getNameFor(prios, namesIn, 4)
}

const getLastName = (namesIn) => {
   let prios = [
      'мужнина',
      'наречёная',
      'самоданная',
      'отечья',
      'матерня', ]

   return getNameFor(prios, namesIn)
}

const getFeatName = (namesIn) => {
   let prios = [
      'подвига_святительства',
      'подвига_отшельничества',
      'подвига_пастырства',
      'подвига_мученичества',
      'подвига_страстотерпчества',
      'подвига_исповедничества',
      'подвига_дияконства',
      'подвига_чтецтва',
      'подвига_учительства',
      'подвига_мученичества',
      'подвига_страстотерпчества',
      'подвига_исповедничества', ]

   return getNameFor(prios, namesIn)
}

const getNamesFor = (prios, namesIn) => {
   console.debug("[getNamesFor] <<< prios:", prios, "namesIn:", namesIn)

   let names = prios.filterMap((prio) => {
      return kinds.filterMap((k) => {
         return namesIn.find((name) => {
            return prio == name.state_code && name.name_bind_kind_name == k
         })
      })
   }).flat()

   console.debug("[getNamesFor] >>>", names)

   return names
}

const getNameFor = (prios, namesIn, count = 1) => {
   let names = getNamesFor(prios, namesIn)

   return names.slice(0, count - 1).map((n) => { return n.name_text }).join(", ")
}

