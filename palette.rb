#!/usr/bin/env ruby
# frozen_string_literal: true

# The holed palette: a neutral gradient from #000000 to #ffffff plus accents
# spaced geometrically around the OKLCH hue wheel, with derived bright and
# tint variants and the 16-slot terminal mapping. Everything that is a colour
# value in holed comes from this file; generate.rb renders it into Lua and
# terminal configs. Run it directly to preview the palette as swatches.

# ---------------------------------------------------------------------------
# Tunables
# ---------------------------------------------------------------------------
NEUTRAL_STEPS = 8           # number of greys, including #000000 and #ffffff
NEUTRAL_FLOOR_Y = 0.01      # linear luminance of the first grey above black (1 = white)
NEUTRAL_TINT_HUE = 300.0    # OKLCH hue of the tint applied to the greys
NEUTRAL_TINT_CHROMA = 0.008 # peak tint chroma; fades to 0 at both endpoints

ACCENT_COUNT = 11           # accents spaced evenly around the hue wheel
ACCENT_START_HUE = 15.0     # OKLCH hue of the first accent, in degrees
ACCENT_LIGHTNESS = 0.76     # mean OKLCH L of the accents (0..1)
ACCENT_LIGHTNESS_SWING = 0.08 # L follows a cosine: +swing at PEAK_HUE, -swing opposite
ACCENT_LIGHTNESS_PEAK_HUE = 95.0 # hue where the accents are lightest (yellow)
ACCENT_CHROMA = 0.09        # OKLCH C shared by every accent

BRIGHT_LIGHTNESS_BOOST = 0.08 # bright (ANSI 8-15) variants: accent L plus this
TINT_LIGHTNESS = 0.24       # tints: a hue-cast grey for line backgrounds
TINT_CHROMA = 0.035
TINT_DIM_LIGHTNESS = 0.26   # dimmed tints: slightly lighter, a third of the chroma
TINT_DIM_CHROMA = 0.012
MID_LIGHTNESS = 0.55        # mid-tones: readable as text on black and as a bg under fg
MID_CHROMA = 0.11

# ANSI slots 0-15. Neutrals by name; accents by name, or [:bright, name].
TERMINAL = [
  :gray1, :red, :green, :yellow, :blue, :purple, :cyan, :gray6,
  :gray4, %i[bright red], %i[bright green], %i[bright yellow],
  %i[bright blue], %i[bright purple], %i[bright cyan], :white
].freeze

# ---------------------------------------------------------------------------
# Colour maths (sRGB <-> OKLab <-> OKLCH)
# ---------------------------------------------------------------------------
module Color
  module_function

  def srgb_to_linear(c)
    c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
  end

  def linear_to_srgb(c)
    c <= 0.0031308 ? 12.92 * c : 1.055 * (c**(1 / 2.4)) - 0.055
  end

  def cbrt(x)
    x.negative? ? -((-x)**(1.0 / 3)) : x**(1.0 / 3)
  end

  # Returns [L, a, b] for an sRGB triple in 0..1.
  def rgb_to_oklab(r, g, b)
    r, g, b = [r, g, b].map { |c| srgb_to_linear(c) }
    l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
    m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
    s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
    [
      0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    ]
  end

  # Returns an sRGB triple in 0..1, possibly outside that range.
  def oklab_to_rgb(lab_l, a, b)
    l = (lab_l + 0.3963377774 * a + 0.2158037573 * b)**3
    m = (lab_l - 0.1055613458 * a - 0.0638541728 * b)**3
    s = (lab_l - 0.0894841775 * a - 1.2914855480 * b)**3
    [
      4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
      -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
      -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    ].map { |c| linear_to_srgb(c) }
  end

  def oklch_to_rgb(l, c, h)
    rad = h * Math::PI / 180
    oklab_to_rgb(l, c * Math.cos(rad), c * Math.sin(rad))
  end

  def in_gamut?(rgb)
    rgb.all? { |c| c >= -1e-6 && c <= 1 + 1e-6 }
  end

  # Converts OKLCH to an in-gamut sRGB triple, reducing chroma if required so
  # that lightness and hue are preserved exactly.
  def oklch_to_srgb(l, c, h)
    rgb = oklch_to_rgb(l, c, h)
    unless in_gamut?(rgb)
      lo, hi = 0.0, c
      20.times do
        mid = (lo + hi) / 2
        if in_gamut?(oklch_to_rgb(l, mid, h)) then lo = mid else hi = mid end
      end
      rgb = oklch_to_rgb(l, lo, h)
    end
    rgb.map { |v| v.clamp(0.0, 1.0) }
  end

  def to_hex(rgb)
    format('#%02x%02x%02x', *rgb.map { |c| (c * 255).round })
  end

  def to_bytes(rgb)
    rgb.map { |c| (c * 255).round }
  end
end

# ---------------------------------------------------------------------------
# Palette generation
# ---------------------------------------------------------------------------
Swatch = Struct.new(:key, :label, :rgb) do
  def hex = Color.to_hex(rgb)
end

# Black, then greys whose linear luminance grows geometrically from
# NEUTRAL_FLOOR_Y up to 1.0 (white). OKLab lightness is the cube root of
# luminance, so this is an even OKLCH ramp with a floor, slightly denser near black.
def neutral_lightness(i)
  return 0.0 if i.zero?
  steps = NEUTRAL_STEPS - 2
  ratio = (1 / NEUTRAL_FLOOR_Y)**(1.0 / steps)
  y = NEUTRAL_FLOOR_Y * ratio**(i - 1)
  l, = Color.rgb_to_oklab(*[y].cycle.first(3).map { |v| Color.linear_to_srgb(v) })
  l
end

def neutrals
  Array.new(NEUTRAL_STEPS) do |i|
    l = neutral_lightness(i)
    chroma = NEUTRAL_TINT_CHROMA * Math.sin(Math::PI * l)
    rgb = Color.oklch_to_srgb(l, chroma, NEUTRAL_TINT_HUE)
    key = case i
          when 0 then :black
          when NEUTRAL_STEPS - 1 then :white
          else :"gray#{i}"
          end
    Swatch.new(key, format('%-7s L%.2f', key, l), rgb)
  end
end

# Approximate OKLCH hue angles of familiar colour names, for labelling.
HUE_NAMES = {
  red: 25.0, orange: 55.0, yellow: 85.0, lime: 115.0,
  green: 145.0, teal: 180.0, cyan: 210.0, blue: 245.0,
  violet: 275.0, purple: 310.0, magenta: 340.0
}.freeze

def hue_name(hue)
  name, = HUE_NAMES.min_by do |_, h|
    d = (hue - h).abs % 360
    [d, 360 - d].min
  end
  name
end

def accent_lightness(hue)
  rad = (hue - ACCENT_LIGHTNESS_PEAK_HUE) * Math::PI / 180
  ACCENT_LIGHTNESS + ACCENT_LIGHTNESS_SWING * Math.cos(rad)
end

def accent_hues
  step = 360.0 / ACCENT_COUNT
  Array.new(ACCENT_COUNT) { |i| (ACCENT_START_HUE + i * step) % 360 }
end

def accent_swatch(hue, l, c, prefix: nil)
  key = hue_name(hue)
  label = format('%-8s %3d° L%.2f', [prefix, key].compact.join(' '), hue.round, l)
  Swatch.new(key, label, Color.oklch_to_srgb(l, c, hue))
end

def accents
  accent_hues.map { |h| accent_swatch(h, accent_lightness(h), ACCENT_CHROMA) }
end

def brights
  accent_hues.map { |h| accent_swatch(h, accent_lightness(h) + BRIGHT_LIGHTNESS_BOOST, ACCENT_CHROMA, prefix: 'bright') }
end

def tints
  accent_hues.map { |h| accent_swatch(h, TINT_LIGHTNESS, TINT_CHROMA, prefix: 'tint') }
end

def tint_dims
  accent_hues.map { |h| accent_swatch(h, TINT_DIM_LIGHTNESS, TINT_DIM_CHROMA, prefix: 'dim') }
end

def mids
  accent_hues.map { |h| accent_swatch(h, MID_LIGHTNESS, MID_CHROMA, prefix: 'mid') }
end

# The whole palette as nested hashes of hex strings, keyed by stable names.
def palette
  by_key = ->(swatches) { swatches.to_h { |s| [s.key, s.hex] } }
  base = by_key.(neutrals).merge(by_key.(accents))
  bright = by_key.(brights)
  term = TERMINAL.map { |slot| slot.is_a?(Array) ? bright.fetch(slot[1]) : base.fetch(slot) }
  { base: base, bright: bright, tint: by_key.(tints), tint_dim: by_key.(tint_dims), mid: by_key.(mids), term: term }
end

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
def render(swatch)
  r, g, b = Color.to_bytes(swatch.rgb)
  l, = Color.rgb_to_oklab(*swatch.rgb)
  fg = l > 0.6 ? '0;0;0' : '255;255;255'
  "\e[48;2;#{r};#{g};#{b}m\e[38;2;#{fg}m #{swatch.hex} \e[0m #{swatch.label}"
end

if __FILE__ == $PROGRAM_NAME
  puts 'Neutral gradient'
  neutrals.each { |s| puts render(s) }
  puts
  puts "Accents (L=#{ACCENT_LIGHTNESS}±#{ACCENT_LIGHTNESS_SWING} C=#{ACCENT_CHROMA})"
  accents.each { |s| puts render(s) }
  puts
  puts "Bright accents (L+#{BRIGHT_LIGHTNESS_BOOST})"
  brights.each { |s| puts render(s) }
  puts
  puts "Tints (L=#{TINT_LIGHTNESS} C=#{TINT_CHROMA})"
  tints.each { |s| puts render(s) }
  puts
  puts "Dimmed tints (L=#{TINT_DIM_LIGHTNESS} C=#{TINT_DIM_CHROMA})"
  tint_dims.each { |s| puts render(s) }
  puts
  puts "Mid-tones (L=#{MID_LIGHTNESS} C=#{MID_CHROMA})"
  mids.each { |s| puts render(s) }
  puts
  puts 'Terminal'
  p = palette
  p[:term].each_with_index do |hex, i|
    slot = TERMINAL[i]
    puts render(Swatch.new(nil, format('%-2d %s', i, slot.is_a?(Array) ? slot.join(' ') : slot),
                           hex[1..].scan(/../).map { |h| h.to_i(16) / 255.0 }))
  end
end
