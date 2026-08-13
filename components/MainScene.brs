sub init()
    m.posterA = m.top.findNode("posterA")
    m.posterB = m.top.findNode("posterB")
    m.timer = m.top.findNode("slideTimer")

    m.fadeAToB = m.top.findNode("fadeAToB")
    m.fadeBToA = m.top.findNode("fadeBToA")

    m.playlist = []
    m.currentIndex = 0
    m.activePoster = "A"

    m.timer.observeField("fire", "showNextItem")

    m.playlistTask = CreateObject("roSGNode", "PlaylistTask")
    m.playlistTask.observeField("playlistData", "onPlaylistLoaded")
    m.playlistTask.control = "RUN"
end sub

sub onPlaylistLoaded()
    data = m.playlistTask.playlistData

    if data <> invalid and data.items <> invalid and data.items.Count() > 0
        m.playlist = data.items
        m.currentIndex = 0

        firstItem = m.playlist[0]

        if firstItem.type = "image"
            m.posterA.uri = firstItem.url
            m.posterA.opacity = 1.0
            m.posterB.opacity = 0.0

            startTimer(firstItem)
        end if
    end if
end sub

sub startTimer(item)
    duration = 10

    if item.duration <> invalid
        duration = item.duration
    end if

    m.timer.duration = duration
    m.timer.control = "start"
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
    startTimer(item)
end sub
