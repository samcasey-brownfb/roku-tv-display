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
    m.currentUrl = ""
    m.firstLoad = true

    m.slideTimer.observeField("fire", "showNextItem")
    m.refreshTimer.observeField("fire", "refreshPlaylist")

    loadPlaylist()

    m.refreshTimer.control = "start"
end sub


sub loadPlaylist()
    m.playlistTask = CreateObject("roSGNode", "PlaylistTask")
    m.playlistTask.observeField("playlistData", "onPlaylistLoaded")
    m.playlistTask.control = "RUN"
end sub


sub refreshPlaylist()
    loadPlaylist()
end sub


sub onPlaylistLoaded()
    data = m.playlistTask.playlistData

    if data = invalid or data.items = invalid or data.items.Count() = 0
        return
    end if

    newPlaylist = data.items

    ' First app load
    if m.firstLoad = true
        m.playlist = newPlaylist
        m.currentIndex = 0
        m.firstLoad = false

        firstItem = m.playlist[0]

        if firstItem.type = "image"
            m.posterA.uri = firstItem.url
            m.posterA.opacity = 1.0
            m.posterB.opacity = 0.0
            m.currentUrl = firstItem.url

            startSlideTimer()
        end if

        return
    end if

    ' Background refresh:
    ' keep showing the current image if it still exists
    foundIndex = -1

    for i = 0 to newPlaylist.Count() - 1
        if newPlaylist[i].url = m.currentUrl
            foundIndex = i
            exit for
        end if
    end for

    m.playlist = newPlaylist

    if foundIndex >= 0
        m.currentIndex = foundIndex
    else
        ' Current image was removed from GitHub
        m.currentIndex = 0
    end if
end sub


sub startSlideTimer()
    m.slideTimer.duration = 10
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
    m.currentUrl = item.url

    startSlideTimer()
end sub
