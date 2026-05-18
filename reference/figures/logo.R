# Regenerate the educabr hex sticker.
#
# Inputs:  man/figures/raw/brasil.png   (Brazil silhouette, any background)
# Outputs: man/figures/logo.png         (canonical R hex sticker)
#
# After running, refresh the README snippet with:
#   usethis::use_logo("man/figures/logo.png")

# install.packages(c("hexSticker", "showtext", "sysfonts", "magick", "png"))
library(hexSticker)
library(showtext)
library(sysfonts)
library(magick)
library(png)
library(grid)

font_add_google("Fira Sans", "fira")
showtext_auto()

# Palette ---------------------------------------------------------------
hex_fill   <- "#2E8B57"   # forest green, hex background
hex_border <- "#14442B"   # darker green for hex edge
cream      <- "#F5EFE0"   # wordmark + URL

# Pre-process Brazil: drop white, trim margins, re-center in a square ---
br_src <- "man/figures/raw/brasil.png"
br_out <- "man/figures/raw/brasil-centered.png"
stopifnot(file.exists(br_src))

image_read(br_src) |>
  image_transparent("white", fuzz = 3) |>
  image_trim() |>
  image_extent("1200x1200", color = "none", gravity = "center") |>
  image_write(br_out)

br_grob <- rasterGrob(png::readPNG(br_out), interpolate = TRUE)

# Hex sticker -----------------------------------------------------------
sticker(
  subplot   = br_grob,
  package   = "educabr",
  p_family  = "fira",
  p_size    = 24,
  p_y       = 1.52,
  p_color   = cream,
  s_x       = 1.00,
  s_y       = 0.82,
  s_width   = 1.10,
  s_height  = 1.10,
  h_fill    = hex_fill,
  h_color   = hex_border,
  url       = "github.com/mancano-tales/educabr",
  u_size    = 3.8,
  u_color   = cream,
  white_around_sticker = TRUE,
  filename  = "man/figures/logo.png",
  dpi       = 600
)
