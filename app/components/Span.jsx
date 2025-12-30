import { Component } from 'react'

import Markdown from 'Markdown'

export default class Span extends Component {
   static defaultProps = {
      id: null,
      active: null,

      onClick: null,
      onLoadRequest: null,
   }

   state = {
      roundelUrl: this.props.thumb_url
   }

   // system
   constructor(props) {
      super(props)

      this.onClick = this.onClick.bind(this)
      this.onThumbClick = this.onThumbClick.bind(this)
      this.onSpanHeaderClick = this.onSpanHeaderClick.bind(this)
      this.onLoadImageError = this.onLoadImageError.bind(this)
   }

   componentDidMount() {
      this.$pic.addEventListener('click', this.onThumbClick)
      this.$header.addEventListener('click', this.onSpanHeaderClick)
   }

   componentWillUnmount() {
      this.$pic.removeEventListener('click', this.onThumbClick)
      this.$header.removeEventListener('click', this.onSpanHeaderClick)
   }

   // custom
   classNameForItem() {
      return 'span' + (this.props.active && "active" || "")
   }

   onClick(e) {
      if (this.props.onClick) {
         let res = this.props.onClick(this.props.id, e)

         if (res) {
            e.stopPropagation()
            e.preventDefault()
         }
      }
   }

   // events
   onThumbClick(e) {
      console.debug("[onThumbClick] ** >>> ", e)

      this.props.onLoadRequest(this.props.id)

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

   drawComponent(c) {
      let key = Object.keys(c).first(), valueName = Object.values(c).first(), value

      switch(valueName.constructor.name) {
      case 'Array':
         value = valueName.reduce((res, name) => res || this.props[name], null)
         break;
      default:
         value = this.props[valueName]
      }

      switch(key) {
      case 'md':
         return <Markdown source={value} />
      case 'span':
         return <span>{value}</span>
      default:
      }

      return null;
   }

   // props
   hasNoImage() {
      return !this.state.roundelUrl
   }

   hasImage() {
      return !this.hasNoImage()
   }

   linkTo() {
      return "/" + [this.props.name, this.props.id].compact().join("/")
   }

   render() {
      console.log("[render] * this.props:", this.props)

      return (
         <li
            className={this.classNameForItem()}
            onClick={this.onClick} >
            <div
               className='spannable-header'
               key={'object-span-' + this.props.id}
               ref={e => this.$header = e} >
               <a
                  ref={e => this.$pic = e}
                  key='pic'
                  href={this.linkTo()} >
                  {this.hasImage() &&
                     <img
                        className='small-thumb circle z-depth-1'
                        onError={this.onLoadImageError}
                        src={this.state.roundelUrl} />}
                  {this.hasNoImage() &&
                     <i className='material-icons circle terracota z-depth-1'>image</i>}</a>
               {this.props.scheme.header?.map((c) => this.drawComponent(c))}</div>
            {this.props.scheme.body && this.props.scheme.body.isPresent() && <div
               onClick={this.onThumbClick}
               className='spannable-body'>
               {this.props.scheme.body?.map((c) => this.drawComponent(c))}</div>}</li>)
   }
}
