import { Component } from 'react'
import { mixin } from 'lodash-decorators'

import Chip from 'Chip'
import Name from 'Name'
import Markdown from 'Markdown'
import GetSlugColor from 'mixins/GetSlugColor'

@mixin(GetSlugColor)
export default class MemorySpan extends Component {
   static defaultProps = {
      slug: null,
      defaultCalendarySlug: null,
      roundelUrl: null,
      haits: [],
      orders: {},
      orderTweet: null,
      orderShortName: null,
      description: null,
      title: null,
      addDate: null,
      yearDate: null,
      bindKindCode: null,
      calendarySlug: null,
      usualEventCode: null,

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
      this.onLoadImageError = this.onLoadImageError.bind(this)
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
      this.props.onLoadRequest(this.props.slug)

      e.stopPropagation()
      e.preventDefault()
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

   generateUrl(hait) {
      return '/' + this.props.slug + '/' + hait.event_id
   }

   generateClassName(hait) {
      let bind_kind_code = null, event_title = null

      if (hait.bind_kind_code != "несвязаный") {
         bind_kind_code = 'event_kind';
      }

      if (hait.event_kind_code != "Veneration") {
         event_title = 'event';
      }

      return [event_title, bind_kind_code, 'happened_at'].compact()
   }

   generateTexts(hait) {
      let bind_kind_code = null, event_title = null

      if (hait.bind_kind_code != "несвязаный") {
         bind_kind_code = hait.bind_kind_code;
      }

      if (hait.event_kind_code != "Veneration") {
         event_title = hait.event_title;
      }

      return [event_title, bind_kind_code, hait.happened_at].compact()
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
                        onError={this.onLoadImageError}
                        src={this.state.roundelUrl} />}
                  {this.hasNoImage() &&
                     <i className='material-icons circle terracota z-depth-1'>perm_identity</i>}</a>
               {this.orders().map((order) => <Chip
                     className='order'
                     color={this.getSlugColor(order.first())}
                     tooltip={order.last()}
                     text={order.first()} />)}
               <span
                  className='name short'>
                  {this.props.title}</span>
               {this.props.haits.map((hait) => <Chip
                  classNames={this.generateClassName(hait)}
                  url={this.generateUrl(hait)}
                  texts={this.generateTexts(hait)} />)}
               </div>
            {this.props.description &&
               <div
                  className='collapsible-body description'
                  onClick={this.onAvatarClick} >
                  <Markdown source={this.props.description} /></div>}</li>)
   }
}
