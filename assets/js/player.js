let Player = {
  player: null,

  init(domId, playerId, onReady){
    
    if (window.YT && window.YT.Player) {
      this.onIframeReady(domId, playerId, onReady)
    } else {
      window.onYouTubeIframeAPIReady = () => {
        this.onIframeReady(domId, playerId, onReady)
      }

      if(!document.querySelector('script[src*="youtube.com/iframe_api"]')){
        let youtubeScriptTag = document.createElement("script")
        youtubeScriptTag.src = "//www.youtube.com/iframe_api"
        document.head.appendChild(youtubeScriptTag)
      }
    }
  },

  onIframeReady(domId, playerId, onReady){
    console.log("Создаю плеер для:", domId, "с видео-ID:", playerId);
    this.player = new YT.Player(domId, {
      height: "360",
      width: "420",
      videoId: playerId,
      events: {
        "onReady":  (event => onReady(event) ),
        "onStateChange": (event => this.onPlayerStateChange(event) )
      }
    })
  },

  destroy(){
    if (this.player){
      this.player.destroy()
      this.player = null
    }
  },

  onPlayerStateChange(event){ },
  getCurrentTime(){ 
    return this.player ? Math.floor(this.player.getCurrentTime() * 1000) : 0 
  },
  seekTo(millsec){ 
    if (this.player) this.player.seekTo(millsec / 1000) 
  }
}
export default Player