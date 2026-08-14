sub init()
    m.top.functionName = "loadMediaFolder"
end sub


sub loadMediaFolder()
    url = "https://api.github.com/repos/samcasey-brownfb/roku-tv-display/contents/media"

    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.SetUrl(url)

    request.AddHeader("User-Agent", "Brown-Football-Roku-TV")
    request.AddHeader("Accept", "application/vnd.github+json")

    response = request.GetToString()

    if response = invalid or response = ""
        return
    end if

    files = ParseJson(response)

    if files = invalid
        return
    end if

    playlist = []

    for each file in files
        if file.type = "file"

            name = LCase(file.name)
            isImage = false

            if Right(name, 4) = ".png"
                isImage = true
            else if Right(name, 4) = ".jpg"
                isImage = true
            else if Right(name, 5) = ".jpeg"
                isImage = true
            end if

            if isImage
                playlist.Push({
                    type: "image",
                    url: file.download_url
                })
            end if

        end if
    end for

    if playlist.Count() > 0
        m.top.playlistData = {
            items: playlist
        }
    end if
end sub
