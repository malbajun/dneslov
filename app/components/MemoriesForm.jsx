import { Component } from 'react'
import { CookiesProvider } from 'react-cookie'
import { merge } from 'merge-anything'
import axios from 'axios'

import PickMeUpCalendar from 'PickMeUpCalendar'
import CalendariesCloud from 'CalendariesCloud'
import SearchField from 'SearchField'
import SearchConditions from 'SearchConditions'
import MemorySpans from 'MemorySpans'
import Footer from 'Footer'
import Memory from 'Memory'
import Eventee from 'Eventee'
import Resourcees from 'Resourcees'
import Resourcee from 'Resourcee'
import Gallery from 'Gallery'
import Image from 'Image'
import Rites from 'Rites'
import Rite from 'Rite'
import Login from 'Login'
import Intro from 'Intro'
import Error from 'Error'
import { getCalendariesString, getDateString, getPathsFromState, getTitleFromState, parseDateString, parseCalendariesString } from 'support'

export default class MemoriesForm extends Component {
   static defaultProps = {
      measure: "юлианский",
      calendaries_used: [],
      calendaries_cloud: [],
      query: "",
      user: null,
      memories: {
         list: [],
         page: 1,
         total: 0,
      },
      memory: null,
      resources: null,
      resource: null,
      rites: null,
      rite: null,
      images: null,
      image: null,
      error: null
   }

   state = {}

   // system
   static getDerivedStateFromProps(props, state) {
      console.debug("[getDerivedStateFromProps] <<<", { props: props, state: state })

      if (props !== state.prevProps) {
         let state = {
               prevProps: props,
               memories: props.memories.list,
               memoriesTotal: props.memories.total,
               memory: props.memory,
               eventee: props.eventee,
               images: props.images,
               image: props.image,
               resources: props.resources,
               resource: props.resource,
               rites: props.rites,
               rite: props.rite,
               user: props.user,
               attituded: props.attituded,
               error: props.error,
               calendarySlug: props.calendaries_used?.length == 1 ? props.calendaries_used[0] : null,
               calendariesCloud: props.calendaries_cloud || [],
               query: {
                  c: getCalendariesString(props) || "",
                  d: getDateString(props),
                  q: props.query,
                  p: props.memories.page,
               }
             }

         document.title = getTitleFromState(state)
         let [ path, json_path ] = getPathsFromState(state)
         if (state.error) {
            history.replaceState({ query: state.query, path: document.location.href + '.json' }, document.title, document.location.href)
         } else {
            history.replaceState({ query: state.query, path: json_path }, document.title, path)
         }
         console.debug("[getDerivedStateFromProps] <<<", { toNewState: state })
         return state
      }

      return null
   }

   // system
   constructor() {
      super()

      this.onUrlLoadRequest = this.onUrlLoadRequest.bind(this)
      this.pushSubmit = this.pushSubmit.bind(this)
   }

   updateState(state) {
      console.debug("[updateState] <<<", { state: state })
      let [ path, json_path ] = getPathsFromState(state)

      console.log("[updateState] * replace with", path)
      document.title = getTitleFromState(state)
      if (state.error) {
         history.replaceState({ query: state.query, path: document.location.href + '.json' }, document.title, document.location.href)
      } else {
         history.replaceState({ query: state.query, path: json_path }, document.title, path)
      }

      console.debug("[getDerivedStateFromProps] <<<", { newState: state })
      this.setState(state)
   }

   componentDidMount() {
      window.onpopstate = this.onPopState.bind(this)

      document.addEventListener('dneslov-url-load-request', this.onUrlLoadRequest, { passive: true })
   }

   componentWillUnmount() {
      window.onpopstate = null

      document.removeEventListener('dneslov-url-load-request', this.onUrlLoadRequest)
   }

   // props
   calendariesUsed() {
      return this.state.query.c && this.state.query.c.split(",").map((slug) => {
         return this.state.calendariesCloud.reduce((c, calendary) => {
            return c || calendary.slug == slug && calendary || null
         }, null)
      }).filter((x) => {return x})
   }

   defaultCalendarySlug() {
      return this.state.calendarySlug ||
             this.props.calendaries_used &&
             this.props.calendaries_used[0] ||
             this.state.calendariesCloud[0]?.slug
   }

   defaultUsedCalendary() {
      let calendaries = this.calendariesUsed()

      return calendaries && calendaries[0]
   }

   // handlers
   onCloudAct(data) {
      let c = this.state.query.c ? this.state.query.c.split(",").filter(c => c).concat([ data.slug ]).join(",") : null

      console.debug("[onCloudAct] **", merge(this.state.query, {c: c, p: 1}))
      this.pushSubmit(merge(this.state.query, {c: c, p: 1}))
   }

   onSearchAct(data) {
      let query = merge({}, this.state.query)

      if (data.date) {
         query.d = null
      } else if (data.slug) {
         let tokens = query.c.split(","),
             index = tokens.indexOf(data.slug)
         tokens.splice(index, 1)
         if (tokens.length == 0) {
            query.c = null
         } else {
            query.c = tokens.join(",")
         }
      } else if (data.token) {
         console.debug("[onSearchAct] **", {q: query.q})
         let tokens = query.q.split("/"),
             index = tokens.indexOf(data.token)

         console.debug("[onSearchAct] **", tokens, index, tokens.splice(index, 1))
         query.q = tokens.splice(index, 1).join("/")
      }

      this.pushSubmit(merge(query, {p: 1}))
   }

   onSearchUpdate(query) {
      this.pushSubmit(merge(this.state.query, {q: query, p: 1, d: null}))
   }

   onCalendarUpdate(value) {
      let d = (value['withDate'][1] == 'julian' && 'ю' || 'н') +  value['withDate'][0]

      this.pushSubmit(merge(this.state.query, {d: d, p: 1}), '/index.json')
   }

   onFetchNext() {
      if (! this.isNextRequesting) {
         console.log("[onFetchNext] * getting...")
         this.isNextRequesting = true
         this.submit(merge(this.state.query, {p: this.state.query.p + 1}))
      }
   }

   onMemoryLoadRequest(slug, eventId) {
      let url = '/' + [slug, eventId].compact().join("/") + '.json',
          data = { c: this.state.query.c, d: this.state.query.d }

      this.pushSubmit(data, url)
   }

   onUrlLoadRequest(e) {
      console.debug("[onUrlLoadRequest] **", { url: e.detail.url })
      let data = { c: this.state.query.c, d: this.state.query.d }, url = e.detail.url

      this.pushSubmit(data, url)
   }

   onPopState(e) {
      console.debug("[onPopState] **", { e: e.state })

      if (e.state) {
         this.submit(e.state.query.merge({p: 1}), e.state.path)
      }
   }

   // remote data processing
   // query - new query
   // path - new path request
   pushSubmit(queryIn, path) {
      console.debug("[pushSubmit] <<< ", { query: queryIn, path: path })

      let state = this.state, query = queryIn || { c: this.state.query.c, d: this.state.query.d }

      // storing current path and query
      let [ currentPath, jsonCurrentPath ] = getPathsFromState(merge(state, { query: query }))
      history.pushState({ query: state.query, path: jsonCurrentPath }, document.title, currentPath)

      // when path is undefined it is filled with current one
      path ||= jsonCurrentPath

      console.debug("[pushSubmit] **", state, query, path)
      this.submit(query, path)
   }

   submit(query, path) {
      console.debug("[submit] <<< ", { query: query, path: path })

      let url = path || '/index.json',
          request = {
            data: query,
            url: url,
          }

      document.body.classList.add('in-progress')
      axios.get(request.url, { params: request.data })
        .then(this.onLoadSuccess.bind(this))
        .catch(this.onLoadFailure.bind(this))
   }

   onLoadSuccess(response) {
      console.debug("[onLoadSuccess] <<< response", response)
      console.debug("[onLoadSuccess] <<< response", response.data, response.data.total)

      if (response.data.list) {
         this.memoriesParse(response.data, response.config)
      } else if (response.data.events) {
         this.memoryParse(response.data, response.config)
      } else if (response.data.event) {
         this.eventParse(response.data.event, response.config)
      } else if (response.data.image) {
         this.imageParse(response.data.image, response.config)
      } else {
         this.parse(response.data, response.config)
      }
   }

   onLoadFailure(err) {
      console.debug("[onLoadFailure] <<< response", err.response)
      console.debug("[onLoadFailure] <<< response", err.config)

      if (err.response) {
         let state = merge(this.state, {
            memories: [],
            memory: null,
            eventee: null,
            images: null,
            image: null,
            error: {
               message: err.response.data.message,
               code: err.response.status
            }
         })
         document.body.classList.remove('in-progress')
         this.updateState(merge(state, {query: err.response.config.params}))
      }

      this.isNextRequesting = false
   }

   memoriesParse(memories, config) {
      let state

      if (memories.page > 1) {
         let newMemories = this.state.memories.concat(memories.list)
         state = merge(this.state, {
            memories: newMemories,
            memoriesTotal: memories.total,
            memory: null,
            eventee: null,
            rites: null,
            rite: null,
            resources: null,
            resource: null,
            images: null,
            image: null,
            error: null})
      } else {
         state = merge(this.state, {
            memories: memories.list,
            memoriesTotal: memories.total,
            memory: null,
            eventee: null,
            rites: null,
            rite: null,
            resources: null,
            resource: null,
            images: null,
            image: null,
            error: null})
      }

      document.body.classList.remove('in-progress')
      this.updateState(merge(state, {query: config.params}))
      this.isNextRequesting = false
   }

   memoryParse(memory, config) {
      let state = merge(this.state,
                        { memory: memory,
                          memories: [],
                          query: config.params,
                          eventee: null,
                          rites: null,
                          rite: null,
                          resources: null,
                          resource: null,
                          images: null,
                          image: null,
                          error: null})

      document.body.classList.remove('in-progress')
      this.updateState(state)
   }

   eventParse(eventee, config) {
      let state = merge(this.state,
                        { memory: null,
                          memories: [],
                          query: config.params,
                          eventee: eventee,
                          rites: null,
                          rite: null,
                          resources: null,
                          resource: null,
                          images: null,
                          image: null,
                          error: null})

      document.body.classList.remove('in-progress')
      this.updateState(state)
   }

   galleryParse(images, config) {
      let state = merge(this.state,
                        { memory: null,
                          memories: [],
                          query: config.params,
                          eventee: null,
                          rites: null,
                          rite: null,
                          resources: null,
                          resource: null,
                          images: images,
                          error: null})

      document.body.classList.remove('in-progress')
      this.updateState(state)
   }

   imageParse(image, config) {
      let state = merge(this.state,
                        { memory: null,
                          memories: [],
                          query: config.params,
                          eventee: null,
                          rites: null,
                          rite: null,
                          resources: null,
                          resource: null,
                          images: null,
                          image: image,
                          error: null})

      document.body.classList.remove('in-progress')
      this.updateState(state)
   }

   parse(data, config) {
      let state = merge(this.state,
                        { memory: null,
                          memories: [],
                          query: config.params,
                          eventee: null,
                          rites: null,
                          rite: null,
                          resources: null,
                          resource: null,
                          images: null,
                          image: null,
                          error: null}),
          parts = config.url.split("/"),
          objectsPart = parts[1] == 'api' ? parts[3] : parts[1],
          objects =  objectsPart.replace(/\.json.*/g, ''),
          uno = parts[1] == 'api' ? parts[4] : parts[2],
          subject = uno ? objects.singularize() : objects

      console.log("[parse] **", subject)
      document.body.classList.remove('in-progress')
      this.updateState(state.merge({[subject]: data}))
   }

   dateFromQuery() {
      let date = this.state.query.d || "",
          match = date.match(/\d{2}\.\d{2}\.\d{4}/)

      return match && match[0]
   }

   calendarStyleFromQuery() {
      let date = this.state.query.d || "",
          match = date.match(/ю/)

      if (match) {
         return 'julian'
      } else {
         return 'neojulian'
      }
   }

   onSigninUser(user) {
      this.setState({ user: user })
   }

   onSignoutUser() {
      this.setState({ user: null })
   }

   render() {
      console.log("[render] * ", { props: this.props, state: this.state})

      return (
         [<header>
            <nav className='terracota'>
               <div className="nav-wrapper">
                  <a
                     className='brand-logo'
                     href='/'
                     alt="Днеслов">
                     <img
                        src="/dneslov-title.png" /></a>
                  <ul id="nav-mobile" className="right hide-on-med-and-down">
                     <li>
                        <a
                           href={"/about"}>
                           {"О проекте..."}</a></li>
                     <Login
                        onSigninUser={this.onSigninUser.bind(this)}
                        onSignoutUser={this.onSignoutUser.bind(this)}
                        user={this.state.user} /></ul></div></nav></header>,
         <main>
            <div className='container'>
               <div className='row'>
                  <Intro />
                  <form>
                     <div className='col s12 m4 l3 xl2'>
                        <div className='hidden' id='calendary' />
                        <div className='row'>
                           <PickMeUpCalendar
                              calendary={this.defaultUsedCalendary()}
                              withDate={this.dateFromQuery()}
                              calendarStyle={this.calendarStyleFromQuery()}
                              onUpdate={this.onCalendarUpdate.bind(this)} />
                           <CalendariesCloud
                              calendaries={this.state.calendariesCloud}
                              calendaries_used={this.calendariesUsed()}
                              onAct={this.onCloudAct.bind(this)} /></div></div>
                     <div className='col s12 m8 l9 xl10'>
                        {this.state.error &&
                           <Error
                              error={this.state.error} />}
                        {this.state.memory &&
                           <Memory
                              key='memory'
                              date={parseDateString(this.state.query.d).pop()}
                              calendarStyle={this.calendarStyleFromQuery()}
                              defaultCalendarySlug={this.defaultCalendarySlug()}
                              specifiedCalendarySlug={this.state.calendarySlug}
                              selectedCalendaries={this.state.query.c?.split(",")}
                              onLoadRequest={this.onMemoryLoadRequest.bind(this)}
                              {...this.state.memory} />}
                        {this.state.eventee &&
                           <Eventee
                              key='eventee'
                              date={parseDateString(this.state.query.d).pop()}
                              calendarStyle={this.calendarStyleFromQuery()}
                              defaultCalendarySlug={this.defaultCalendarySlug()}
                              specifiedCalendarySlug={this.state.calendarySlug}
                              selectedCalendaries={this.state.query.c?.split(",")}
                              onLoadRequest={this.onMemoryLoadRequest.bind(this)}
                              {...this.state.eventee} />}
                        {this.state.images &&
                           <Gallery
                              key='gallery'
                              date={parseDateString(this.state.query.d).pop()}
                              calendarStyle={this.calendarStyleFromQuery()}
                              defaultCalendarySlug={this.defaultCalendarySlug()}
                              specifiedCalendarySlug={this.state.calendarySlug}
                              selectedCalendaries={this.state.query.c?.split(",")}
                              event_id={this.props.eventee?.id}
                              total={this.props.total}
                              images={this.state.images}
                              {...this.props.attituded} />}
                        {this.state.image &&
                           <Image
                              key='image'
                              date={parseDateString(this.state.query.d).pop()}
                              calendarStyle={this.calendarStyleFromQuery()}
                              defaultCalendarySlug={this.defaultCalendarySlug()}
                              specifiedCalendarySlug={this.state.calendarySlug}
                              selectedCalendaries={this.state.query.c?.split(",")}
                              {...this.state.image} />}
                        {this.state.resources &&
                           <Resourcees
                              key='resources'
                              total={this.props.total}
                              onPushSubmit={this.pushSubmit}
                              list={this.state.resources} />}
                        {this.state.rites &&
                           <Rites
                              key='rites'
                              total={this.props.total}
                              list={this.state.rites} />}
                        {this.state.rite &&
                           <Rite
                              key='rite'
                              {...this.state.rite} />}
                        {this.state.resource &&
                           <Resourcee
                              key='resource'
                              {...this.state.resource} />}
                        {this.props.memories.list &&
                        !this.state.error &&
                        !this.state.eventee &&
                        !this.state.images &&
                        !this.state.image &&
                        !this.state.rites &&
                        !this.state.rite &&
                        !this.state.resources &&
                        !this.state.resource &&
                        !this.state.memory &&
                           <div>
                              <div className='row'>
                                 <SearchField
                                    wrapperClassName='col xl12 l12 m12 s12'
                                    with_text={this.state.query.q}
                                    onUpdate={this.onSearchUpdate.bind(this)} /></div>
                              <SearchConditions
                                 date={parseDateString(this.state.query.d).pop()}
                                 calendaries={this.calendariesUsed()}
                                 query={this.state.query.q || ""}
                                 onAct={this.onSearchAct.bind(this)} />
                              <MemorySpans
                                 memories={this.state.memories}
                                 totalMemories={this.state.memoriesTotal}
                                 calendariesCloud={parseCalendariesString(this.state.query.c)}
                                 defaultCalendarySlug={this.defaultCalendarySlug()}
                                 onLoadRequest={this.onMemoryLoadRequest.bind(this)}
                                 onFetchNext={this.onFetchNext.bind(this)}/></div>}</div></form></div></div></main>,
         <div className="progress">
            <div className="indeterminate"></div></div>,
         <Footer />])
   }
}
