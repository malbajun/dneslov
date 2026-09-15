import { Component } from 'react'
import { mixin } from 'lodash-decorators'
import PropTypes from 'prop-types'

import StackGrid from "react-stack-grid"
import PureImage from 'PureImage'
import ImageCard from 'ImageCard'
import Markdown from 'Markdown'
import MetaTags from 'react-meta-tags'
import ReactScrollPagination from '@majioa/react-scroll-pagination'
import axios from 'axios'
import { getUrlsFrom } from 'support'

export default class Gallery extends Component {
   static defaultProps = {
      images: [],
      total: null,
      slug: null,
      gallery_title: null,
      gallery_event: null,
      attitude_to: null,

      grid: true,
      url: null,
      nextLoadStep: 25,
      active: null,
      defaultCalendarySlug: null,
      specifiedCalendarySlug: null,
      wrapperYearDateClass: "",
      selectedCalendaries: [],
      calendarStyle: 'julian',
      i18n: {
         title: "Выставка",
         on_topic: " на тему "
      },
   }

   static propTypes = {
      images: PropTypes.array.isRequired,
      total: PropTypes.number.isRequired,
      gallery_title: PropTypes.string.isRequired,
      defaultCalendarySlug: PropTypes.string,
      specifiedCalendarySlug: PropTypes.string,

      active: PropTypes.string,
      wrapperYearDateClass: PropTypes.string,
      selectedCalendaries: PropTypes.array,
      calendarStyle: PropTypes.string,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            prevProps: props,
            images: [],
            galleryTitle: props.gallery_title,
            query: props.query,
            nonLoadedImages: props.images,
            totalImages: props.total,
            fetchedImages: props.images.length,
            images: [],
            isNextRequesting: false,
            url: props.url || Gallery.generateUrl(props),
            tagKeywords: Gallery.getKeywords(props.gallery_title, props.title),
            tagTitle: Gallery.getTitle(props.gallery_title, props.title),
         }
      }

      return null
   }

   state = { nonLoadedImages: [] }

   static generateUrl(props) {
      return '/' + [props.slug, props.event_id, 'gallery.json'].compact().join('/')
   }

   static getKeywords(shortName, title) {
      let re = RegExp("[\\s,]+", "i"),
          array = [
             shortName,
             title
          ].compact().uniq()

      return array.join(", ").slice(0, 255)
   }

   static getTitle(shortName, title) {
      let array = [
         shortName,
         title
      ].uniq()

      return array.join(" ").slice(0, 255)
   }

   static collectTitles(props) {
      return props.images.reduce((res, x) => {
         return res.concat([x.title])
      }, [])
   }

   constructor(props) {
      super(props)

      this.onImageClick = this.onImageClick.bind(this)
      this.onImageLoaded = this.onImageLoaded.bind(this)
      this.onImageErrored = this.onImageErrored.bind(this)
      this.onLoadSuccess = this.onLoadSuccess.bind(this)
      this.onLoadFailure = this.onLoadFailure.bind(this)
      this.fetchNext = this.fetchNext.bind(this)
   }

   componentDidUpdate() {
      if (this.state.isNextRequesting) {
         this.submit()
      }
   }

   // props
   fetchNext() {
      if (this.state.totalImages > this.state.fetchedImages && !this.state.isNextRequesting) {
         console.log("[fetchNext] * getting...")

         if (this.state.url) {
            this.setState({isNextRequesting: true})
         }

         //if (this.props.onFetchNext) {
         //   this.props.onFetchNext()
         //}
      }
   }

   submit() {
      let query = {}, headers = {
             'Content-Type': 'application/json',
             'Range': 'records=' + this.state.fetchedImages + '-' + (this.state.fetchedImages + this.props.nextLoadStep)
          }

      if (this.props.calendariesCloud) {
         query["c"] = this.props.calendariesCloud
      }

      console.debug("[submit] **", this.state.url, { params: query, headers: headers })
      axios.get(this.state.url, { params: query, headers: headers })
         .then(this.onLoadSuccess.bind(this))
         .catch(this.onLoadFailure.bind(this))
   }

   getClassName() {
      return this.state.isNextRequesting ? 'in-progress' : ''
   }

   // event
   onLoadSuccess(response) {
      console.debug("[onLoadSuccess] <<< response", response)
      console.debug("[onLoadSuccess] <<< response", response.data, response.data.total)

      let list = this.state.nonLoadedImages.concat(response.data.images || [])
      this.setState({
         isNextRequesting: false,
         fetchedImages: this.state.fetchedImages + response.data.images.length,
         nonLoadedImages: list
      })
   }

   onLoadFailure(err) {
      console.debug("[onLoadFailure] <<< response", err.response)
      console.debug("[onLoadFailure] <<< response", err.config)

      let data = err.response?.data || {}

      this.setState({
         isNextRequesting: false,
         fetchedImages: this.state.fetchedImages + this.props.nextLoadStep,
         trace: data.trace,
         errors: data.errors
      })
   }

   onImageClick(uid, imageUrl, ext) {
      console.debug("[onImageClick] <<<", uid, imageUrl, ext)
      let url = "/gallery/" + uid, target = ext ? "_blank" : "_self"

      window.open(url, target)
   }

   onImageErrored(_i, uid) {
      let index = this.state.nonLoadedImages.findIndex((i) => i.uid == uid),
          _items = this.state.nonLoadedImages.splice(index, 1)

      console.debug("[onImageErrored] **", uid)
      this.setState({
         nonLoadedImages: this.state.nonLoadedImages
      })
   }

   onImageLoaded(_i, uid) {
      let index = this.state.nonLoadedImages.findIndex((i) => i.uid == uid),
          items = this.state.nonLoadedImages.splice(index, 1)

      console.debug("[onImageLoaded] **", uid)
      this.setState({
         images: this.state.images.concat(items),
         nonLoadedImages: this.state.nonLoadedImages
      })
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
               content={this.state.tagTitle} /></MetaTags>,
         <h4>
            <span>{this.props.i18n.title}</span>
            {this.state.galleryTitle &&
               <span>&nbsp;
                  <a href={"/" + this.props.slug}>{this.state.galleryTitle}</a></span>}</h4>,
         <h5>{this.props.gallery_event && <span>{this.props.i18n.on_topic}<a href={"/" + this.props.slug + '/' + this.props.event_id}>{this.props.gallery_event}</a></span>}</h5>,
         <div className='row gallery'>
            <div
               className="container">
               {this.state.nonLoadedImages.map((picture, index) =>
                  <div
                     className="hidden">
                     <PureImage
                        key={"hidden-pure-image-" + picture.uid}
                        uid={picture.uid}
                        src={picture.thumb_url}
                        onError={this.onImageErrored}
                        onLoad={this.onImageLoaded} /></div>)}
               <StackGrid
                  columnWidth={150}>
                  {this.state.images.map((picture, index) =>
                     <div key={"div-image-" + picture.uid}>
                     <PureImage
                        key={"pure-image-" + picture.uid}
                        uid={picture.uid}
                        wrapperClassName='icon'
                        src={picture.thumb_url}
                        tooltip={picture.title}
                        onClick={this.onImageClick}/></div>)}
               </StackGrid>
                  </div>
            {!this.props.grid && this.state.images.isPresent() && this.state.images.map((picture, index) =>
               <div className='col s4 image'>
                  <ImageCard
                     key={picture.uid}
                     uid={picture.uid}
                     url={picture.url}
                     slug={this.props.slug}
                     event_id={this.props.event_id}
                     thumb={picture.thumb_url}
                     title={picture.title}
                     index={index} /></div>)}
               <div
                  className={"loader" + this.getClassName()}>
               <ReactScrollPagination
                  excludeElement='header'
                  total={this.state.totalImages}
                  loadedTotal={this.state.fetchedImages}
                  fetchFunc={this.fetchNext} /></div></div>]
   }
}
