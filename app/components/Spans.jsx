import { Component } from 'react'
import ReactScrollPagination from '@majioa/react-scroll-pagination'
import axios from 'axios'

import Span from 'Span'

export default class Spans extends Component {
   static defaultProps = {
      list: [],
      scheme: {},
      url: null,
      name: null,
      nextLoadStep: 25,

      onLoadRequest: null,
   }

   static getDerivedStateFromProps(props, state) {
      console.debug("[getDerivedStateFromProps] <<<", props, state)

      if (props !== state.prevProps) {
         return({
            list: props.list,
            prevProps: props
         })
      } else {
         return null
      }
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            prevProps: props,
            list: props.list,
            count: props.list.length,
            isNextRequesting: false,
         }
      }

      return null
   }

   // system
   state = {}

   constructor(props) {
      super(props)

      this.onSpanClick = this.onSpanClick.bind(this)
      this.onLoadSuccess = this.onLoadSuccess.bind(this)
      this.onLoadFailure = this.onLoadFailure.bind(this)
      this.fetchNext = this.fetchNext.bind(this)
   }

   componentDidMount() {
      this.collapsible = M.Collapsible.init(this.$collapsible, {})
   }

   componentWillUnmount() {
      this.collapsible.destroy()
   }

   componentDidUpdate() {
      if (this.state.isNextRequesting) {
         this.submit()
      }
   }

   // event
   onLoadSuccess(response) {
      console.debug("[onLoadSuccess] <<< response", response)
      console.debug("[onLoadSuccess] <<< response", response.data)

      let list = this.state.list.concat(response.data || [])
      this.setState({
         isNextRequesting: false,
         count: this.state.count + response.data.length,
         list: list
      })
   }

   onLoadFailure(err) {
      console.debug("[onLoadFailure] <<< response", err.response)
      console.debug("[onLoadFailure] <<< response", err.config)

      let data = err.response?.data || {}

      this.setState({
         isNextRequesting: false,
         count: this.state.count + this.props.nextLoadStep,
         trace: data.trace,
         errors: data.errors
      })
   }

   fetchNext() {
      if (this.props.total > this.state.count && !this.state.isNextRequesting) {
         console.log("[fetchNext] * getting...")

         if (this.props.url) {
            this.setState({isNextRequesting: true})
         }
      }
   }

   // props
   submit() {
      let query = {}, headers = {
             'Content-Type': 'application/json',
             'Range': 'records=' + this.state.count + '-' + (this.state.count + this.props.nextLoadStep)
          }

      console.debug("[submit] **", this.state.url, { params: query, headers: headers })
      axios.get(this.props.url + ".json", { params: query, headers: headers, timeout: 10000 })
         .then(this.onLoadSuccess.bind(this))
         .catch(this.onLoadFailure.bind(this))
   }

   onSpanClick(id, _e) {
      console.log("[onSpanClick] * getting...", id)

      if (this.props.name) {
         let url = [this.props.url, id ].join("/") + '.json', 
             ce = new CustomEvent('dneslov-url-load-request', { detail: { url: url }})

         document.dispatchEvent(ce)

         return true
      }

      return false
   }

   // custom
   render() {
      console.log("[render] * props:", this.props, "state:", this.state)

      return [
         <div
            className='row'
            id={this.props.name + '-list'}>
            <ul
               key={this.props.name + '-list'}
               ref={e => this.$collapsible = e}
               className='spannable'
               data-collapsible='expandable' >
               {this.state.list.filterMap((object) =>
                  <Span
                     key={'object-' + object.id}
                     scheme={this.props.scheme}
                     name={this.props.name}
                     onLoadRequest={this.props.onLoadRequest}
                     onClick={this.onSpanClick}
                     {...object} />)}</ul></div>,
         <ReactScrollPagination
            excludeElement='header'
            total={this.props.total}
            loadedTotal={this.state.count}
            fetchFunc={this.fetchNext} />
      ]
   }
}
