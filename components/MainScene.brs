sub init()
    m.posterA = m.top.findNode("posterA")
    m.posterB = m.top.findNode("posterB")
    m.slideTimer = m.top.findNode("slideTimer")
    m.refreshTimer = m.top.findNode("refreshTimer")

    m.fadeAToB = m.top.findNode("fadeAToB")
    m.fadeBToA = m.top.findNode("fadeBToA")

    m.playlist = []
    m.currentIndex = 0
    m.activePoster = "A"
    m.firstLoad = true

    ' Slide rotation
    m.slideTimer.observeField("fire", "showNextItem")

    ' GitHub refresh
    m.refreshTimer.observeField("fire", "refreshPlaylist")

    loadPlaylist()

    ' Start checking GitHub every 60 seconds
    m.refreshTimer.control = "start"
end sub


sub loadPlaylist()
    m.playlistTask = CreateObject("roSGNode", "PlaylistTask")
    m.playlistTask.observeField("playlistData", "onPlaylistLoaded")
    m.playlistTask.control = "RUN"
end sub


sub refreshPlaylist()
    ' Run a fresh background task without interrupting the slideshow
    loadPlaylist()
end sub


sub onPlaylistLoaded()
    data = m.playlistTask.playlistData

    if data = invalid or data.items = invalid or data.items.Count() = 0
        return
    end if

    ' First time the app loads
    if m.firstLoad = true
        m.playlist = data.items
        m.currentIndex = 0
        m.firstLoad = false

        firstItem = m.playlist[0]

        if firstItem.type = "image"
            m.posterA.uri = firstItem.url
            m.posterA.opacity = 1.0
            m.posterB.opacity = 0.0

            startSlideTimer(firstItem)
        end if

        return
    end if

    ' Background refresh:
    ' replace playlist without restarting the slideshow
    m.playlist = data.items

    ' Safety in case the new playlist has fewer items
    if m.currentIndex >= m.playlist.Count()
        m.currentIndex = 0
    end if
end sub


sub startSlideTimer(item)
    duration = 10

    if item.duration <> invalid
        duration = item.duration
    end if

    m.slideTimer.duration = duration
    m.slideTimer.control = "start"
end sub


sub showNextItem()
    if m.playlist.Count() = 0
        return
    end if

    nextIndex = m.currentIndex + 1

    if nextIndex >= m.playlist.Count()
        nextIndex = 0
    end if

    item = m.playlist[nextIndex]

    if item.type <> "image"
        return
    end if

    if m.activePoster = "A"
        m.posterB.uri = item.url

        m.posterA.opacity = 1.0
        m.posterB.opacity = 0.0

        m.fadeAToB.control = "start"
        m.activePoster = "B"
    else
        m.posterA.uri = item.url

        m.posterB.opacity = 1.0
        m.posterA.opacity = 0.0

        m.fadeBToA.control = "start"
        m.activePoster = "A"
    end if

    m.currentIndex = nextIndex
    startSlideTimer(item)
end sub
