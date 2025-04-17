import { Component } from 'react'
import { mixin } from 'lodash-decorators'
import PropTypes from 'prop-types'

import Chip from 'Chip'
import Markdown from 'Markdown'
import MetaTags from 'react-meta-tags'

//@mixin(GetSlugColor)
export default class Rite extends Component {
   static defaultProps = {
      id: null,
      abbreviation: null,
      title: null,
      description: null,
      text: null,

      i18n: {
         rite: "Чинопоследование",
//         base: "Опорная память",
//         externals: "Внешние ссылки",
//         patron: "Покровительствует",
//         events: "События",
//         prosomeion: "подобен",
//         tone: "глас",
//         suffix: "-й",
      }
   }

   static propTypes = {
      id: PropTypes.number.isRequired,
      text: PropTypes.string.isRequired,
      abbreviation: PropTypes.string.isRequired,
   }

   // system
   state = {}

   constructor(props) {
      super(props)

      this.onSpanHeaderClick = this.onSpanHeaderClick.bind(this)
   }

//   componentDidMount() {
      //this.$header.addEventListener('click', this.onSpanHeaderClick)
//   }

//   componentWillUnmount() {
      //this.$header.removeEventListener('click', this.onSpanHeaderClick)
//   }

   // custom
   onSpanHeaderClick(e) {
      if (!this.hasData()) {
         e.preventDefault()
         e.stopPropagation()
      }
   }

   static getKeywords(shortName, order, names, describedMemoes) {
      let array = [
         order,
         shortName,
         names.map(x => x.name_text),
         describedMemoes.map(x => x.title)
      ].flat().uniq()

      return array.join(", ").slice(0, 255)
   }

   static getTagTitle(shortName, order, describedMemoes) {
      let array = [
         order,
         shortName,
         describedMemoes.map(x => x.title)
      ].flat().uniq()

      return array.join(" ").slice(0, 255)
   }

   static getDescription(shortName, order, describedMemoes, sortedScripta) {
      let array = [
         order,
         shortName,
         describedMemoes.map(x => x.description),
         sortedScripta.map(x => x.text)
      ].flat().uniq()

      return array.join(" ").slice(0, 255)
   }

   render() {
      console.log("[render] *", { 'this.props': this.props, 'this.state': this.state })

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
         <div className='row rite'>
            <div className={'col'}>
               <Chip
                  text={this.props.i18n.rite} />
               <span>{this.props.title || this.props.abbreviation}</span>
               <Markdown source={this.props.description} />
               <Markdown source={this.props.text} />
            </div></div>]
   }
}
