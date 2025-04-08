import { Component } from 'react'
import { mixin } from 'lodash-decorators'
import PropTypes from 'prop-types'

import ImageCard from 'ImageCard'
import Markdown from 'Markdown'
import MetaTags from 'react-meta-tags'
import { getUrlsFrom } from 'support'

export default class Gallery extends Component {
   static defaultProps = {
      images: [],
      attitude_to: null,
      slug: null,

      active: null,
      defaultCalendarySlug: null,
      specifiedCalendarySlug: null,
      wrapperYearDateClass: "",
      selectedCalendaries: [],
      calendarStyle: 'julian',
      i18n: {
         title: "Выставка"
      },
   }

   static propTypes = {
      defaultCalendarySlug: PropTypes.string,
      specifiedCalendarySlug: PropTypes.string,
      images: PropTypes.array.isRequired,
      attitude_to: PropTypes.string.isRequired,
      slug: PropTypes.string.isRequired,

      active: PropTypes.string,
      wrapperYearDateClass: PropTypes.string,
      selectedCalendaries: PropTypes.array,
      calendarStyle: PropTypes.string,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         let titles = Gallery.collectTitles(props),
             descriptions = Gallery.collectDescriptions(props)

         return {
            prevProps: props,
            images: props.images,
            attitudeTo: props.attitude_to,
            query: props.query,
            tagKeywords: Gallery.getKeywords(props.attitude_to, titles),
            tagTitle: Gallery.getTitle(props.attitude_to, titles),
            tagDescription: Gallery.getDescription(props.attitude_to, descriptions),
         }
      }

      return null
   }

   state = {}

//   getDescription() {
//      let array = (this.props.images[0]?.titles || []).concat(this.props.images[0]?.descriptions || []),
//          desc = array.reduce((res, x) => { return res + " " + x.text }, "")
//
//      return (this.state.attitudeTo + ": " + desc).slice(0, 255)
//   }
//
   static getKeywords(shortName, titles) {
      let re = RegExp("[\\s,]+", "i"),
          array = [
         shortName,
         titles.map((x) => x.split(re))
      ].flat().compact().uniq()

      return array.join(", ").slice(0, 255)
   }

   static getTitle(shortName, titles) {
      let array = [
         shortName,
         titles
      ].flat().uniq()

      return array.join(" ").slice(0, 255)
   }

   static getDescription(shortName, descriptions) {
      let array = [
         shortName,
         descriptions
      ].flat().uniq()

      return array.join(" ").slice(0, 255)
   }

   static collectTitles(props) {
      return props.images.reduce((res, x) => {
         return res.concat(x.titles.map(y => y.text))
      }, [])
   }

   static collectDescriptions(props) {
      return props.images.reduce((res, x) => {
         return res.concat(x.descriptions.map(y => y.text))
      }, [])
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
         <h4>
            <span>{this.props.i18n.title} "</span>
            <a href={"/" + this.props.slug}>{this.state.attitudeTo}</a>"</h4>,
         <div className='row gallery'>
            {this.state.images.isPresent() && this.state.images.map((picture, index) =>
               <div className='col s4 image'>
                  <ImageCard
                     key={picture.uid}
                     uid={picture.uid}
                     url={picture.url}
                     slug={this.props.slug}
                     event_id={this.props.event_id}
                     thumb={picture.thumb_url}
                     title={picture.titles[0]?.text}
                     index={index}
                     description={picture.descriptions[0]?.text} /></div>)}</div>]
   }
}
