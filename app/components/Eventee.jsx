import { Component } from 'react'
import { mixin } from 'lodash-decorators'
import PropTypes from 'prop-types'

import Memory from 'Memory'
import Carousel from 'Carousel'
import Chip from 'Chip'
import Name from 'Name'
import Description from 'Description'
import GetSlugColor from 'mixins/GetSlugColor'
import Player from 'Player'
import Markdown from 'Markdown'
import MetaTags from 'react-meta-tags'
import { getUrlsFrom } from 'support'

@mixin(GetSlugColor)
export default class Eventee extends Component {
   static defaultProps = {
      happened_at: null,
      memory: null,
      title: null,
      place: {},
      titles: [],
      scripta: [],
      memoes: [],
      links: [],
      describedMemoIds: [],

      active: null,
      defaultCalendarySlug: null,
      specifiedCalendarySlug: null,
      wrapperYearDateClass: "",
      selectedCalendaries: [],
      calendarStyle: 'julian',

      i18n: {
         gallery: "Выставка",
         base: "Опорная память",
         externals: "Внешние ссылки",
         patron: "Покровительствует",
         events: "События",
         prosomeion: "подобен",
         tone: "глас",
         suffix: "-й",
      }
   }

   static propTypes = {
      happened_at: PropTypes.string.isRequired,
      defaultCalendarySlug: PropTypes.string,
      specifiedCalendarySlug: PropTypes.string,
      memory: PropTypes.object.isRequired,
      specific_title: PropTypes.string,
      title: PropTypes.string,
      place: PropTypes.object.isRequired,
      titles: PropTypes.array.isRequired,
      scripta: PropTypes.array.isRequired,
      memoes: PropTypes.array.isRequired,
      links: PropTypes.array.isRequired,
      describedMemoIds: PropTypes.array,
      date: PropTypes.string.isRequired,

      active: PropTypes.string,
      wrapperYearDateClass: PropTypes.string,
      selectedCalendaries: PropTypes.array,
      calendarStyle: PropTypes.string,
   }

   static types = ["Subject", "Event"]

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         let cal = Eventee.calculateDefaultCalendarySlug(props),
             order = Eventee.getOrder(props),
             describedMemoes = Eventee.getDescribedMemoes(props),
             selectedScripta = Eventee.selectScripta(props),
             sortedScripta = Eventee.sortedScripta(selectedScripta)
         //let memo = Eventee.getMemo(props)

         return {
            prevProps: props,
            playingAudioUrl: null,
            defaultCalendarySlug: cal,
            order: order,
            title: Eventee.getTitle(props),
            describedMemoes: describedMemoes,
            klugs: Eventee.collectKlugs(props),
            links: Eventee.getLinks(props),
            iconLinks: Eventee.getIconLinks(props),
            scripta: selectedScripta,
            sortedScripta: sortedScripta,
            tagKeywords: Eventee.getKeywords(props.short_name, order, props.names, describedMemoes),
            tagTitle: Eventee.getTagTitle(props.short_name, order, describedMemoes),
            tagDescription: Eventee.getDescription(props.short_name, order, describedMemoes, sortedScripta),
         }
      }

      return null
   }

   static calculateDefaultCalendarySlug(props) {
      return props.selectedCalendaries &&
         props.selectedCalendaries.reduce((cal, calendarySlug) => {
            if (!cal) {
               cal = props.titles.reduce((cal, title) => {
                  if (!cal && title.calendary == calendarySlug) {
                     cal = calendarySlug
                  }

                  return cal
               }, null)
            }

            return cal
         }, props.defaultCalendarySlug) || props.defaultCalendarySlug
   }

   static collectKlugs(props) {
         return props.memoes.map((m) => {
            return Object.keys(m.orders)
         }).flat().concat([ props.memory.slug ]).compact().uniq()
   }

   static getDescribedMemoes(props) {
      let dMs = props.memoes.filter((m) => {
         return m.description && !props.describedMemoIds.includes(m.id)
      })

      return dMs
   }

//   static getDescribedMemoes(props) {
//      let describedMemoes = props.memoes.filter((m) => {
//         return Memory.descriptionKindCodes.indexOf(m.kind_code) >= 0
//      }).sortByArray(Memory.descriptionKindCodes, "kind_code").map((m) => {
//         return m
//      }).flat().compact().reduce((res, memo) => {
//      console.log("[render] ******", memo)
//         if (memo.description) {
//            res[memo.calendary_slug] ||= memo
//         }
//         return res
//      }, {})
//      console.log("[render] ******", props.memoes, describedMemoes)
//
//      return Object.values(describedMemoes).compact()
//   }
//
   static getLinks(props) {
      let links = [ "WikiLink", "BeingLink", "PatericLink" ].map((type) => {
         return props.links.selectByKey("type", type)
      }).flat()

      return links
   }

   static getIconLinks(props) {
      return props.links.selectByKey("type", "IconLink")
   }

   static getMemo(props) {
      let titles = props.memoes.sort((x, y) => {
         return x.calendary_slug == props.defaultCalendarySlug ? -1 : 0
      })

      return titles[0]
   }

   static selectScripta(props) {
      return props.scripta.filter(c => { return c.text })
   }

   static sortedScripta(selectedScripta) {
      let keys = Object.keys(Memory.ScriptumTable)

      return selectedScripta.sort((a, b) => {
         return keys.indexOf(a.type) - keys.indexOf(b.type)
      })
   }

   static getTitle(props) {
      let titles = props.titles.sortByArray(this.types, "type")

      return titles[0]?.text
   }

   static isInCalendaries(props, memo) {
      let selected = props.selectedCalendaries.filter(calendarySlug => {
         return memo.calendary_slug == calendarySlug
      })

      return selected.length > 0
   }

   static getOrder(props) {
      return props.memoes.reduce((order, m) => {
         return order || this.isInCalendaries(props, m) && Object.values(m.orders)[0]
      }, null)
   }

   // system
   state = {}

   constructor(props) {
      super(props)

      this.onSpanHeaderClick = this.onSpanHeaderClick.bind(this)
      this.onActivePlay = this.onActivePlay.bind(this)
      this.onImageClick = this.onImageClick.bind(this)
   }

   componentDidMount() {
      //this.$header.addEventListener('click', this.onSpanHeaderClick)
   }

   componentWillUnmount() {
      //this.$header.removeEventListener('click', this.onSpanHeaderClick)
   }

   // custom
   hasData() {
      return this.props.scripta.length > 0 || this.hasDescription()
   }

   classNameForItem() {
      return 'collection-item event ' + (this.props.active && "active" || "")
   }

   classNameForYearDate() {
      return 'year-date right ' + (this.props.active && "nearby" || "")
   }

   hasDescription() {
      let memo = this.state.describedMemoes[0]

      return memo && memo.description
   }

   onActivePlay(url) {
      this.setState({playingAudioUrl: url})
   }

   onSpanHeaderClick(e) {
      if (!this.hasData()) {
         e.preventDefault()
         e.stopPropagation()
      }
   }

   onImageClick(e) {
      let url = "/" + this.props.memory.slug + "/" + this.props.id + "/gallery"

      e.preventDefault()
      e.stopPropagation()

      window.open(url, "_self")
   }

//   getDescription() {
//      return this.props.short_name + " " +
//             this.props.names.reduce((res, x) => { return res + " " + x.name_text }, "") +
//             this.props.titles.reduce((res, x) => { return res + " " + x.text }, "")
//   }
//
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

   getScriptumTitle(scriptum) {
      return [
         [
            Memory.ScriptumTable[scriptum.type],
            scriptum.title && "«" + scriptum.title + "»",
         ].compact().join(" "),
         scriptum.prosomeion_title && (this.props.i18n.prosomeion + " «" + scriptum.prosomeion_title + "»"),
         scriptum.tone && (this.props.i18n.tone + " " + scriptum.tone + this.props.i18n.suffix),
      ].compact().join(", ")
   }

   getInfoClass() {
      return this.props.image_url ? " x10 l9 m8 s7" : " s12"
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
         <div className='row event'>
            <div className={'col' + this.getInfoClass()}>
               <div className='row'>
                  {! this.props.specific_title && [
                     this.state.order &&
                        <Chip
                           color={this.getSlugColor(this.props.order || this.props.memory?.order)}
                           text={this.state.order} />,
                     <Name
                        short_name={this.props.memory?.short_name}
                        url={getUrlsFrom(this.props.specifiedCalendarySlug, this.props.memory.slug)[0]}
                        defaultNameInCalendary={this.state.title}
                        klugs={this.state.klugs}
                        names={this.props.names} />,
                     <Chip
                        color={this.getSlugColor(this.state.title)}
                        text={this.state.title} />,]}
                  {this.props.specific_title &&
                     <span>
                        {this.props.specific_title}</span>}
                  {this.props.place?.name &&
                     <Chip
                        className='place'
                        text={this.props.place.name} />}
                  {this.props.happened_at && <Chip
                     className='happened-at'
                     text={this.props.happened_at} />}</div>
            {this.props.date && false && <Chip
               cclassName={this.classNameForYearDate()}
               text={this.props.date} />}
               {this.state.scripta.isPresent() &&
                  <div className='row'>
                     <div className='col s12'>
                        {this.state.sortedScripta.map((scriptum) =>
                           <div className='row'>
                              <div className='col s12 title'>
                                 <span>
                                    {this.getScriptumTitle(scriptum)}</span>a
                                 {scriptum.audio_url && <Player
                                     url={scriptum.audio_url}
                                     onActivePlay={this.onActivePlay}
                                     playing={scriptum.audio_url == this.state.playingAudioUrl}
                                  />}</div>
                              <div className='col s12 scriptum'>
                                 <Markdown source={scriptum.text} /></div></div>)}</div></div>}</div>
            {this.props.image_url &&
               <div className='col x2 l3 m4 s5 image'>
                  <a
                     className={"btn btn-image"}
                     onClick={this.onImageClick}>
                     <img
                        src={this.props.image_url}
                        onClick={this.onImageClick} /></a></div>}</div>,
         <div className='row'>
            {this.state.describedMemoes.isPresent() &&
               <Description
                  describedMemoes={this.state.describedMemoes}
                  specifiedCalendarySlug={this.props.specifiedCalendarySlug}
                  defaultCalendarySlug={this.state.defaultCalendarySlug} />}
            {this.state.links.isPresent() &&
               <div className='col s12'>
                  <div className='row'>
                     <div className='col s12 title'>
                        {this.props.i18n.externals}</div>
                     <div className='col s12'>
                        {this.state.links.map((link) =>
                           <Chip
                              key={link.id}
                              url={link.url}
                              color={Memory.getColorForLink(link)}
                              text={Memory.getLinkText(link)} />)}</div></div></div>}</div>]
   }
}
