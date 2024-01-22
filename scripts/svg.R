ecdata <- jsonlite::fromJSON("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.json")

svglite::svglite("test.svg",
                 web_fonts = list("https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:ital,wght@0,400;0,700;1,400;1,700&display=swap",
                                  "https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Condensed:ital,wght@0,400;0,700;1,400;1,700&display=swap"))
ggplot(mtcars) +
  annotate("text", label = "FFf gjfsgd fdshfdsk", x = .5, y = .5, family = "IBM Plex Sans")
dev.off()
