import { Component } from 'react'

import Chip from 'Chip'
import Name from 'Name'
import Markdown from 'Markdown'

export default class MemorySpan extends Component {
   static defaultProps = {
      slug: null,
      defaultCalendarySlug: null,
      roundelUrl: null,
      happenedAt: null,
      orders: {},
      orderTweet: null,
      orderShortName: null,
      description: null,
      title: null,
      addDate: null,
      yearDate: null,
      bindKindCode: null,
      calendarySlug: null,
      eventTitle: null,
      onLoadRequest: null,
   }

   state = {
      roundelUrl: this.props.roundelUrl
   }

   // system
   constructor(props) {
      super(props)

      this.onAvatarClick = this.onAvatarClick.bind(this)
      this.onSpanHeaderClick = this.onSpanHeaderClick.bind(this)
   }

   componentDidMount() {
      this.$avatar.addEventListener('click', this.onAvatarClick)
      this.$header.addEventListener('click', this.onSpanHeaderClick)
   }

   componentWillUnmount() {
      this.$avatar.removeEventListener('click', this.onAvatarClick)
      this.$header.removeEventListener('click', this.onSpanHeaderClick)
   }

   // events
   onAvatarClick(e) {
      e.stopPropagation()
      e.preventDefault()
      this.props.onLoadRequest(this.props.slug)
   }

   onSpanBodyClick(e) {
      this.props.onLoadRequest(this.props.slug)
   }

   onSpanHeaderClick(e) {
      if (!this.props.description) {
         e.preventDefault()
         e.stopPropagation()
      }
   }

   onLoadImageError() {
      console.warn("[onLoadImageError] ** image load error")
      this.setState({ roundelUrl: null })
   }

   // props
   hasNoImage() {
      return !this.state.roundelUrl
   }

   hasImage() {
      return !this.hasNoImage()
   }

   linkToMemory() {
      return "/" + this.props.slug
   }

   orders() {
      if (this.props.orderTweet) {
         return [[this.props.orderTweet, this.props.orderShortName]]
      } else {
         return Object.keys(this.props.orders).reduce((res, key) => {
            return res.concat([[this.props.orders[key], key]])
         }, [])
      }
   }

   render() {
      console.log("[render] > props:", this.props, "state:", this.state)

      return (
         <li
            className='collection-item avatar memory'>
            <div
               className='collapsible-header'
               key={'header-' + this.props.slug}
               ref={e => this.$header = e} >
               <a
                  ref={e => this.$avatar = e}
                  key='avatar'
                  href={this.linkToMemory()} >
                  {this.hasImage() &&
                     <img
                        className='circle z-depth-1'
                        onError={this.onLoadImageError.bind(this)}
                        src={this.state.roundelUrl} />}
                  {this.hasNoImage() &&
                     <i className='material-icons circle terracota z-depth-1'>perm_identity</i>}</a>
               {this.orders().map((order) => <Chip
                     color={'gray'}
                     tooltip={order.last()}
                     text={order.first()} />)}
               <span
                  className='name short'>
                  {this.props.title}</span>
               <Chip
                  className='year-date'
                  text={this.props.happenedAt} /></div>
            {this.props.description &&
               <div
                  className='collapsible-body description'
                  onClick={this.onSpanBodyClick.bind(this)} >
                  <Markdown source={this.props.description} /></div>}</li>)
   }
}
