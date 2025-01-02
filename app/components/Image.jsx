import { Component } from 'react'

import PureImage from 'PureImage'

export default class Image extends Component {
   static defaultProps = {
      url: null,
      thumb: null,
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

      this.setState((prevState) => { return { loaded: !errored, errored: errored }}, this.stateChanged.bind(this))
   }

   title() {
      let languages = this.props.context.text_languages

      return this.props.picture.titles.find((x) => languages.includes(x.language_code))?.text
   }

   description() {
      if (this.descriptionText) {
         return this.descriptionText
      }

      let languages = this.props.context.text_languages

      this.descriptionText = this.props.picture.descriptions.find((x) => languages.includes(x.language_code))?.text

      return this.descriptionText
   }

   render() {
      console.debug("[render] **", { 'this.props': this.props, 'this.state': this.state })

      return (
         !this.state.errored && <div
            className="card hoverable">
            <h5><div className="center">{this.title()}</div></h5>
            <div
               className="card-image">
               <img
                  alt={this.title()}
                  src={this.props.picture.url}
                  className={this.props.wrapperClassName}
                  onLoad={this.onImageCompleted.bind(this)}
                  onError={this.onImageCompleted.bind(this)} /></div>
            {this.props.picture.descriptions.isPresent() &&
               <div
                     className="card-content">
                     <p><b>{this.props.i18n.description}</b></p>
                     <p>{this.description()}</p></div>}</div>)
   }
}
