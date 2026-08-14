sub init()

    m.posterA = m.top.findNode("posterA")
    m.posterB = m.top.findNode("posterB")

    m.slideTimer = m.top.findNode("slideTimer")
    m.refreshTimer = m.top.findNode("refreshTimer")

    m.fadeAToB = m.top.findNode("fadeAToB")
    m.fadeBToA = m.top.findNode("fadeBToA")

    m.playlist = []
    m.currentIndex = 0
    m.nextIndex = 0

    m.activePoster = "A"
    m.currentUrl = ""

    m.firstImageLoaded = false
    m.waitingForNextImage = false

    m.slideTimer.observeField("fire", "prepareNextItem")
    m.refreshTimer.observeField("fire", "refreshPlaylist")

    m.posterA.observeField("loadStatus", "onPosterALoadStatus")
    m.posterB.observeField("loadStatus", "onPosterBLoadStatus")

    loadPlaylist()
    m.refreshTimer.control = "start"

end sub


sub loadPlaylist()

    m.playlistTask = CreateObject("roSGNode", "PlaylistTask")

    m.playlistTask.observeField(
        "playlistData",
        "onPlaylistLoaded"
    )

    m.playlistTask.control = "RUN"

end sub


sub refreshPlaylist()

    ' Fresh one-time GitHub request
    ' Slideshow keeps running independently

    loadPlaylist()

end sub


sub onPlaylistLoaded()

    data = m.playlistTask.playlistData

    if data = invalid
        return
    end if

    if data.items = invalid
        return
    end if

    if data.items.Count() = 0
        return
    end if

    newPlaylist = data.items


    ' -----------------------------
    ' FIRST LOAD
    ' -----------------------------

    if m.playlist.Count() = 0

        m.playlist = newPlaylist
        m.currentIndex = 0

        firstItem = m.playlist[0]

        if firstItem.type = "image"

            m.currentUrl = firstItem.url

            m.posterA.opacity = 0.0
            m.posterB.opacity = 0.0

            m.activePoster = "A"

            m.posterA.uri = firstItem.url

        end if

        return

    end if


    ' -----------------------------
    ' BACKGROUND MEDIA REFRESH
    ' -----------------------------

    foundIndex = -1

    for i = 0 to newPlaylist.Count() - 1

        if newPlaylist[i].url = m.currentUrl

            foundIndex = i
            exit for

        end if

    end for

    m.playlist = newPlaylist


    ' Keep slideshow position when possible

    if foundIndex >= 0

        m.currentIndex = foundIndex

    else

        ' Current image was removed.
        ' Next timer cycle starts at beginning.

        m.currentIndex = m.playlist.Count() - 1

    end if

end sub


sub onPosterALoadStatus()

    if m.posterA.loadStatus <> "ready"
        return
    end if


    ' Initial app image

    if m.firstImageLoaded = false

        m.firstImageLoaded = true

        m.posterA.opacity = 1.0
        m.posterB.opacity = 0.0

        m.activePoster = "A"
        m.currentUrl = m.posterA.uri

        startSlideTimer()

        return

    end if


    ' Poster A is the hidden next image

    if m.waitingForNextImage = true and m.activePoster = "B"

        performFadeBToA()

    end if

end sub


sub onPosterBLoadStatus()

    if m.posterB.loadStatus <> "ready"
        return
    end if


    ' Poster B is the hidden next image

    if m.waitingForNextImage = true and m.activePoster = "A"

        performFadeAToB()

    end if

end sub


sub startSlideTimer()

    m.slideTimer.duration = 10
    m.slideTimer.control = "start"

end sub


sub prepareNextItem()

    if m.playlist.Count() = 0

        startSlideTimer()
        return

    end if


    m.nextIndex = m.currentIndex + 1

    if m.nextIndex >= m.playlist.Count()

        m.nextIndex = 0

    end if


    item = m.playlist[m.nextIndex]


    if item.type <> "image"

        m.currentIndex = m.nextIndex
        startSlideTimer()

        return

    end if


    m.waitingForNextImage = true


    ' Keep current Poster visible.
    ' Load next image invisibly.

    if m.activePoster = "A"

        m.posterB.opacity = 0.0
        m.posterB.uri = item.url

    else

        m.posterA.opacity = 0.0
        m.posterA.uri = item.url

    end if

end sub


sub performFadeAToB()

    m.fadeAToB.control = "start"

    m.activePoster = "B"

    m.currentIndex = m.nextIndex
    m.currentUrl = m.posterB.uri

    m.waitingForNextImage = false

    startSlideTimer()

end sub


sub performFadeBToA()

    m.fadeBToA.control = "start"

    m.activePoster = "A"

    m.currentIndex = m.nextIndex
    m.currentUrl = m.posterA.uri

    m.waitingForNextImage = false

    startSlideTimer()

end sub
