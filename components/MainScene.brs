sub init()
    m.poster = m.top.findNode("displayImage")
    m.timer = m.top.findNode("slideTimer")

    m.playlist = []
    m.currentIndex = 0

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
        showCurrentItem()
    end if
end sub

sub showCurrentItem()
    if m.playlist.Count() = 0
        return
    end if

    item = m.playlist[m.currentIndex]

    if item.type = "image"
        m.poster.uri = item.url

        duration = 10
        if item.duration <> invalid
            duration = item.duration
        end if

        m.timer.duration = duration
        m.timer.control = "start"
    end if
end sub

sub showNextItem()
    if m.playlist.Count() = 0
        return
    end if

    m.currentIndex = m.currentIndex + 1

    if m.currentIndex >= m.playlist.Count()
        m.currentIndex = 0
    end if

    showCurrentItem()
end sub
