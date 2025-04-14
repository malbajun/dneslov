import { Component } from 'react'
import ReactScrollPagination from '@majioa/react-scroll-pagination'
import axios from 'axios'

import MemorySpan from 'MemorySpan'

export default class MemorySpans extends Component {
   static defaultProps = {
      memories: [],
      bondMemoryId: null,
      totalMemories: 0,
      nextLoadStep: 25,
      calendariesCloud: null,
      defaultCalendarySlug: null,
      hideIfBlank: null,
      manualFetch: null,
      onFetchNext: null,
      onLoadRequest: null,
      url: null,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            prevProps: props,
            memories: props.memories,
            totalMemories: props.totalMemories,
            isNextRequesting: false
         }
      }

      return null
   }

   state = {
      isNextRequesting: false,
      memories: [],
      totalMemories: 0
   }

   // system
   constructor(props) {
      super(props)

      this.fetchNext = this.fetchNext.bind(this)
   }

   componentDidMount() {
      this.collapsible = M.Collapsible.init(this.$collapsible, {})
   }

   componentWillUnmount() {
      this.collapsible?.destroy()
   }

   // props
   fetchNext() {
      if (this.state.totalMemories > this.state.memories.length) {
         if (this.props.url) {
            this.requestForNext()
         }

         if (this.props.onFetchNext) {
            this.props.onFetchNext()
         }
      }
   }

   componentDidUpdate() {
      if (this.state.isNextRequesting) {
         this.submit()
      }
   }

   requestForNext() {
      console.log("[requestForNext] * getting...")

      this.setState({isNextRequesting: true})
   }

   submit() {
      let query = { c: this.props.calendariesCloud },
          headers = {
             'Content-Type': 'application/json',
             'Range': 'records=' + this.state.memories.length + '-' + (this.state.memories.length + this.props.nextLoadStep)
          }

      axios.get(this.props.url, { params: query, headers: headers })
         .then(this.onLoadSuccess.bind(this))
         .catch(this.onLoadFailure.bind(this))
   }

   // event
   onLoadSuccess(response) {
      console.debug("[onLoadSuccess] <<< response", response)
      console.debug("[onLoadSuccess] <<< response", response.data, response.data.total)

      let list = this.state.memories.concat(response.data || [])
      this.setState({isNextRequesting: false, memories: list})
   }

   onLoadFailure(err) {
      console.debug("[onLoadFailure] <<< response", err.response)
      console.debug("[onLoadFailure] <<< response", err.config)

      let data = err.response?.data || {}

      this.setState({isNextRequesting: false, trace: data.trace, errors: data.errors})
   }

   isPresent() {
      return this.state.memories.length > 0
   }

   calendarySlugs() {
      return this.props.calendariesCloud || [ this.props.defaultCalendarySlug ]
   }

   descriptionFirst(memory) {
      return this.calendarySlugs().reduce((text, slug) => {
         return text || memory.descriptions.reduce((desc, description) => {
            return desc || description.calendary && description.calendary.slug == slug && description.text || null
         }, null)
      }, null)
   }

   calculateDefaultCalendaryIn(array) {
      return this.calendarySlugs().reduce((cal, calendarySlug) => {
         if (cal) {
            return cal
         } else {
            return array.reduce((cal, value) => {
               if (!cal && value.calendary == calendarySlug) {
                  return calendarySlug
               } else {
                  return cal
               }
            }, null)
         }
      }, null)
   }

   titleFirst(memory) {
      var cal = this.calculateDefaultCalendaryIn(memory.titles),
          title = memory.titles.find((title) => { return title.calendary == cal })

      return memory.default_name_in_calendary || title.text
   }

   getClassName() {
      return this.state.isNextRequesting ? 'in-progress' : ''
   }

   render() {
      console.log("[render] > props:", this.props, "state:", this.state)

      return (
         <div className='row'
            id='memories-list'>
            {this.isPresent() &&
               <ul
                  key='span-list'
                  ref={e => this.$collapsible = e}
                  className={'collapsible collection ' + this.getClassName()}
                  data-collapsible='expandable' >
                  {this.state.memories.map((memory) =>
                     <MemorySpan
                        key={memory.slug}
                        slug={memory.slug}
                        title={memory.title}
                        defaultCalendarySlug={this.props.defaultCalendarySlug}
                        url={memory.url}
                        roundelUrl={memory.roundel_url}
                        happenedAt={memory.happened_at}
                        orders={memory.orders}
                        orderTweet={memory.order_tweet}
                        orderShortName={memory.order_short_name}
                        description={memory.description || memory.note}
                        addDate={memory.add_date}
                        yearDate={memory.year_date}
                        bindKindCode={memory.bind_kind_code}
                        calendarySlug={memory.calendary_slug}
                        eventId={memory.event_id}
                        eventTitle={memory.event_title}
                        usualEventCode={memory.usual_event_code}
                        onLoadRequest={this.props.onLoadRequest} />)}</ul>}
            {this.props.manualFetch && this.state.totalMemories > this.state.memories.length &&
               <div className="paginator">
                  {this.state.isNextRequesting &&
                     <div className="loader"></div>}
                  {!this.state.isNextRequesting && <a
                     className="btn-floating btn-medium waves-effect waves-light red"
                     onClick={this.fetchNext}>
                     <i className="material-icons">file_download</i></a>}</div>}
            {!this.props.manualFetch &&
               <ReactScrollPagination
                  excludeElement='header'
                  total={this.state.totalMemories}
                  loadedTotal={this.state.memories.length}
                  fetchFunc={this.fetchNext} />}
            {!this.isPresent() && !this.props.hideIfBlank &&
               <div className='card-panel'>
                  <p className='flow-text'>Ничегошеньки не нашлось</p></div>}</div>)}}
