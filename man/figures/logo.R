# Regenerate the educabr hex sticker.
#
# Inputs:  man/figures/raw/educabr-art.png  (transparent PNG, square, ~1024 px,
#                                            Brazil silhouette + open book,
#                                            no text, no hex frame)
# Outputs: man/figures/logo.png             (canonical R hex sticker)
#
# After running, update the README snippet with:
#   usethis::use_logo("man/figures/logo.png")

# install.packages(c("hexSticker", "showtext", "sysfonts"))
library(hexSticker)
library(showtext)
library(sysfonts)

font_add_google("Fira Sans", "fira")
showtext_auto()

art <- "man/figures/raw/educabr-art.png"
stopifnot(file.exists(art))

palette <- list(
  fill   = "#2E8B57",  # forest green, matches the current identity
  border = "#14442B",  # darker green for the hex edge
  cream  = "#F5EFE0"   # wordmark + URL
)

sticker(
  subplot   = art,
  package   = "educabr",
  p_family  = "fira",
  p_size    = 22,
  p_y       = 1.50,
  p_color   = palette$cream,
  s_x       = 1.00,
  s_y       = 0.85,
  s_width   = 1.20,
  s_height  = 1.20,
  h_fill    = palette$fill,
  h_color   = palette$border,
  url       = "github.com/mancano-tales/educabr",
  u_size    = 4.2,
  u_color   = palette$cream,
  white_around_sticker = TRUE,
  filename  = "man/figures/logo.png",
  dpi       = 600
)
