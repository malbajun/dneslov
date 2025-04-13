import { Component } from 'react'

import PureImage from 'PureImage'
import MetaTags from 'react-meta-tags'

export default class Image extends Component {
   static defaultProps = {
      url: null,
      title: null,
      description: null,
      index: null,

      wrapperClassName: "",
      onLoad: null,
      onError: null,

      i18n: {
         description: "Описание:",
      }
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         console.log("[render] *", { 'props': props, 'state': state })

         return {
            prevProps: props,
            imageUrl: props.url,
            tagKeywords: Image.getTag(props.attitude_to, props.title),
            tagTitle: Image.getTag(props.attitude_to, props.title),
            tagDescription: Image.getTag(props.attitude_to, props.description),
         }
      }

      return null
   }

   static getTag(first, second) {
      let array = [
         first,
         second
      ].uniq()

      return array.join(":").slice(0, 255)
   }

   state = {
      loaded: false,
      errored: false,
      showModal: false,
   }

   // system
   constructor(props) {
      super(props)

      this.onDocumentClick = this.onDocumentClick.bind(this)
   }

   componentDidMount() {
      document.addEventListener('click', this.onDocumentClick, { passive: true })
      this.componentDidRender()
   }

   componentWillUnmount() {
      document.removeEventListener('click', this.onDocumentClick)
      this.modal?.destroy()
   }

    componentDidUpdate() {
      this.componentDidRender()
   }

   // custom
   componentDidRender() {
      this.modal = M.Modal.init(this.$modal, {})
   }

   stateChanged() {
      if (this.state.errored) {
         //this.componentReady()
         this.props.onError && this.props.onError(this.props.index)
      } else if (this.state.loaded) {
         //this.componentReady()
         this.props.onLoad && this.props.onLoad(this.props.index)
      }
   }

   onDocumentClick(e) {
      // TODO click to transparent area of the modal, get fired to the modal, not the
      // page. Fix it then.
   }

   onImageCompleted(e) {
      let errored = false

      if (e && e.type === "error") {
         errored = true
      }

      this.setState((prevState) => {
         return {
            loaded: !errored, errored: errored
         }
      }, this.stateChanged.bind(this))
   }

   render() {
      console.debug("[render] **", { 'this.props': this.props, 'this.state': this.state })

      return [
         <MetaTags>
            <meta
               id="meta-title"
               name="title"
               content={this.state.tagTitle} />
            <meta
               id="meta-keywords"
               name="keywords"
               content={this.state.tagKeywords} />
            <meta
               id="meta-description"
               name="description"
               content={this.state.tagDescription} /></MetaTags>,
         <h5><div className="center">{this.props.title}</div></h5>,
         <div
            className="card hoverable">
            <div
               className="card-image">
               {!this.state.errored && <img
                  alt={this.props.title}
                  src={this.props.url}
                  className={this.props.wrapperClassName}
                  onLoad={this.onImageCompleted.bind(this)}
                  onError={this.onImageCompleted.bind(this)} />}</div>
            {this.props.description &&
               <div
                  className="card-content">
                  <p><b>{this.props.i18n.description}</b></p>
                  <p>{this.props.description}</p></div>}</div>]
   }
}
