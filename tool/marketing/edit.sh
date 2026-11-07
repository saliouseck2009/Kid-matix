#!/usr/bin/env bash
# Turns raw screen recordings of tool/marketing/record.sh into a vertical
# video ready for TikTok, Reels or Shorts: 1080x1920, 30 frames per second,
# H.264 MP4, on-screen texts, title cards and a 3-second end card. No
# sound: add the music in the app you publish with.
#
# Usage, from anywhere:
#   bash tool/marketing/edit.sh --input marketing/videos/raw/<file>.mp4 \
#     --output marketing/videos/<name>.mp4 \
#     --start 0.5 --duration 10 \
#     --caption "0-4|Apprends tes *tables*" \
#     --caption "4-10|en *jouant* !"
#
#   bash tool/marketing/edit.sh --output marketing/videos/<name>.mp4 \
#     --title "1|Les erreurs reviennent au bon moment" \
#     --clip marketing/videos/raw/<take-1>.mp4:3:12 \
#     --title "2|Plusieurs enfants, un seul téléphone" \
#     --clip marketing/videos/raw/<take-2>.mp4 \
#     --caption "2-6|Une *erreur* ? Elle revient."
#
# Options:
#   --input FILE       the one raw recording (same as a single --clip)
#   --start SECONDS    where the clip of --input starts (default 0)
#   --duration SECONDS length of the clip of --input (default: all)
#   --clip FILE[:START[:DURATION]]
#                      a clip of a recording; repeat the option to chain
#                      clips, in order with the title cards
#   --title "NUMBER|TEXT"
#                      a 2-second card: the number in big, then the text
#   --caption "FROM-TO|TEXT"
#                      text shown from FROM to TO, in seconds of the
#                      finished video (end card excluded), white on a
#                      violet banner; *word* is yellow; \n starts a second
#                      line. Repeat the option for more texts.
#   --caption-y PIXELS top of the banner (default 150, under the TikTok
#                      header)
#   --fit pad|crop     pad (default): the whole screen, violet bars on the
#                      sides; crop: fill the frame, top and bottom cut
#   --format vertical|square
#                      vertical (default): 1080x1920; square: 1080x1080,
#                      the phone screen centered on the violet background
#                      under a title (LinkedIn, X)
#   --square-title TEXT
#                      title at the top of the square format (default
#                      "Kid Matix · les tables de multiplication en jouant")
#   --footer TEXT      text at the bottom of the screen for the whole
#                      video, end card excluded, such as the app's name
#   --max-size MB      re-encode at a lower bit rate when the file is
#                      bigger (WhatsApp takes 16 MB at most)
#   --no-end-card      leave the end card out
set -euo pipefail
readonly root="$(cd "$(dirname "$0")/../.." && pwd)"

readonly fps=30
readonly violet="5B3DF5"
# ASS colors are written blue-green-red.
readonly ass_white="HFFFFFF"
readonly ass_yellow="H31C5FF" # #FFC531
readonly ass_violet="HF53D5B" # #5B3DF5
readonly font_dir="$root/assets/fonts"
# Full name of the instance the variable font opens on: libass only finds
# the file under that name.
readonly font_name="Fredoka Light"
readonly logo="$root/tool/icon/out/icon.png"
readonly end_card_seconds=3
readonly title_card_seconds=2
readonly end_title="Kid Matix"
readonly end_line="Gratuit · sans pub · sans Internet"
readonly end_stores="Android et iPhone"
readonly caption_font_size=68
readonly caption_line_height=92
readonly caption_padding=44
readonly encode=(-c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -r "$fps")

input=""
output=""
start="0"
duration=""
fit="pad"
format="vertical"
caption_y=""
square_title="Kid Matix · les tables de multiplication en jouant"
footer=""
max_size_mb=""
has_end_card=true
captions=()
# The segments of the video, in order: "clip|FILE|START|DURATION" or
# "title|NUMBER|TEXT".
segments=()

usage() {
  sed -n '2,51p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --input) input="$2"; shift 2 ;;
    --output) output="$2"; shift 2 ;;
    --start) start="$2"; shift 2 ;;
    --duration) duration="$2"; shift 2 ;;
    --clip)
      IFS=: read -r file from length <<<"$2"
      segments+=("clip|$file|${from:-0}|${length:-}")
      shift 2
      ;;
    --title) segments+=("title|${2%%|*}|${2#*|}"); shift 2 ;;
    --caption) captions+=("$2"); shift 2 ;;
    --caption-y) caption_y="$2"; shift 2 ;;
    --fit) fit="$2"; shift 2 ;;
    --format) format="$2"; shift 2 ;;
    --square-title) square_title="$2"; shift 2 ;;
    --footer) footer="$2"; shift 2 ;;
    --max-size) max_size_mb="$2"; shift 2 ;;
    --no-end-card) has_end_card=false; shift ;;
    *) usage ;;
  esac
done
[ -z "$input" ] || segments+=("clip|$input|$start|$duration")
[ -n "$output" ] && [ "${#segments[@]}" -gt 0 ] || usage
case "$fit" in pad | crop) ;; *) usage ;; esac

# The geometry of each format: the frame, where the phone screen goes,
# the banner, the cards.
case "$format" in
  vertical)
    width=1080; height=1920
    screen_height=1920; screen_top=0
    caption_y="${caption_y:-150}"
    title_number_y=760; title_number_size=360; title_text_y=1080; title_text_size=76
    logo_size=560; logo_y=440; end_title_y=1130; end_title_size=130
    end_line_y=1290; end_stores_y=1390; end_line_size=58
    ;;
  square)
    width=1080; height=1080
    screen_height=840; screen_top=170
    caption_y="${caption_y:-880}"
    title_number_y=400; title_number_size=300; title_text_y=680; title_text_size=60
    logo_size=380; logo_y=120; end_title_y=610; end_title_size=96
    end_line_y=720; end_stores_y=800; end_line_size=46
    ;;
  *) usage ;;
esac
readonly width height

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is missing; installing it with Homebrew..."
  brew install ffmpeg
fi
filters="$(ffmpeg -hide_banner -filters 2>/dev/null)"
if ! grep -q ' ass ' <<<"$filters"; then
  echo "This ffmpeg has no 'ass' filter (libass); run: brew reinstall ffmpeg" >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$(dirname "$output")"

# Seconds as an ASS time, H:MM:SS.CC.
ass_time() {
  awk -v s="$1" 'BEGIN { printf "%d:%02d:%05.2f", s / 3600, (s % 3600) / 60, s % 60 }'
}

# Header of an ASS file sized like the video. The variable font opens on
# its lightest weight, so an outline of the text color thickens the
# letters towards the weight of the app's titles.
ass_header() {
  cat <<EOF
[Script Info]
ScriptType: v4.00+
PlayResX: $width
PlayResY: $height
WrapStyle: 2
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Text,$font_name,$caption_font_size,&$ass_white&,&$ass_white&,&H00000000&,0,0,1,2,0,5,40,40,0,1
Style: Pill,$font_name,$caption_font_size,&$ass_white&,&$ass_violet&,&$ass_violet&,0,0,3,18,0,5,40,40,0,1

[Events]
Format: Layer, Start, End, Style, Text
EOF
}

# One ASS line: text $3 centered on ($4, $5) from $1 to $2 seconds, with
# the override tags $6, in the style $7 (Text, or Pill for white text on
# a violet pill). *word* turns yellow, outline included.
ass_line() {
  local text outline="$ass_white"
  [ "${7:-Text}" != "Pill" ] || outline="$ass_violet"
  text="$(printf '%s' "$3" | sed -E \
    "s/\*([^*]+)\*/{\\\\c\&$ass_yellow\&\\\\3c\&$ass_yellow\&}\1{\\\\c\&$ass_white\&\\\\3c\&$outline\&}/g; s/\\\\n/\\\\N/g")"
  printf 'Dialogue: 0,%s,%s,%s,{\\an5\\pos(%s,%s)%s}%s\n' \
    "$(ass_time "$1")" "$(ass_time "$2")" "${7:-Text}" "$4" "$5" "${6:-}" "$text"
}

# A card of $1 seconds on the violet background with the ASS file $2,
# written to $3.
render_card() {
  ffmpeg -hide_banner -loglevel error -y \
    -f lavfi -i "color=c=0x$violet:s=${width}x$height:r=$fps:d=$1" \
    -vf "ass=$2:fontsdir=$font_dir,fade=t=in:st=0:d=0.3,setsar=1,format=yuv420p" \
    "${encode[@]}" "$3"
}

# Length in seconds of the video $1.
duration_of() {
  ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$1"
}

# ------------------------------------------------------------ Segments

if [ "$fit" = "pad" ]; then
  frame="scale=$width:$screen_height:force_original_aspect_ratio=decrease:flags=lanczos,pad=$width:$height:(ow-iw)/2:$screen_top+($screen_height-ih)/2:color=0x$violet"
else
  frame="scale=$width:$screen_height:force_original_aspect_ratio=increase:flags=lanczos,crop=$width:$screen_height,pad=$width:$height:0:$screen_top:color=0x$violet"
fi

index=0
: >"$work/segments.txt"
for segment in "${segments[@]}"; do
  index=$((index + 1))
  part="$work/segment-$index.mp4"
  IFS='|' read -r kind a b c <<<"$segment"
  if [ "$kind" = "clip" ]; then
    [ -f "$a" ] || { echo "No such recording: $a" >&2; exit 1; }
    # The screen recorder writes a frame only when the screen changes, so
    # a still screen ends the recording early: the last frame is held to
    # fill the duration asked.
    clip_length=()
    hold="null"
    if [ -n "$c" ]; then
      clip_length=(-t "$c")
      hold="tpad=stop_mode=clone:stop_duration=$c"
    fi
    ffmpeg -hide_banner -loglevel error -y -ss "$b" -i "$a" "${clip_length[@]}" \
      -vf "fps=$fps,$hold,$frame,setsar=1,format=yuv420p" -an "${encode[@]}" "$part"
  else
    ass_header >"$work/title-$index.ass"
    {
      ass_line 0 "$title_card_seconds" "$a" 540 "$title_number_y" "\\fs$title_number_size"
      ass_line 0 "$title_card_seconds" "$b" 540 "$title_text_y" "\\fs$title_text_size"
    } >>"$work/title-$index.ass"
    render_card "$title_card_seconds" "$work/title-$index.ass" "$part"
  fi
  echo "file '$part'" >>"$work/segments.txt"
done
ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i "$work/segments.txt" \
  -c copy "$work/body.mp4"

# ------------------------------------------------------------ Captions

body_filter="null"
ass_header >"$work/captions.ass"
has_texts=false
if [ "$format" = "square" ]; then
  body_length="$(duration_of "$work/body.mp4")"
  ass_line 0 "$body_length" "$square_title" 540 $((screen_top / 2)) '\fs52' \
    >>"$work/captions.ass"
  has_texts=true
fi
if [ -n "$footer" ]; then
  body_length="$(duration_of "$work/body.mp4")"
  ass_line 0 "$body_length" "$footer" 540 $((height - 48)) '\fs46' Pill \
    >>"$work/captions.ass"
  has_texts=true
fi
for caption in "${captions[@]+"${captions[@]}"}"; do
  range="${caption%%|*}"
  text="${caption#*|}"
  from="${range%-*}"
  to="${range#*-}"
  lines="$(printf '%s' "$text" | awk -F'\\\\n' '{ print NF }')"
  banner_height=$((caption_padding * 2 + caption_line_height * lines))
  body_filter="$body_filter,drawbox=x=0:y=$caption_y:w=$width:h=$banner_height:color=0x$violet:t=fill:enable='between(t,$from,$to)'"
  ass_line "$from" "$to" "$text" $((width / 2)) $((caption_y + banner_height / 2)) \
    >>"$work/captions.ass"
  has_texts=true
done
# The texts come last, over the banners.
[ "$has_texts" = false ] ||
  body_filter="$body_filter,ass=$work/captions.ass:fontsdir=$font_dir"

# ------------------------------------------------------------ End card

if [ "$has_end_card" = true ]; then
  ass_header >"$work/end.ass"
  {
    ass_line 0 "$end_card_seconds" "$end_title" 540 "$end_title_y" "\\fs$end_title_size"
    ass_line 0 "$end_card_seconds" "$end_line" 540 "$end_line_y" "\\fs$end_line_size"
    ass_line 0 "$end_card_seconds" "*$end_stores*" 540 "$end_stores_y" "\\fs$end_line_size"
  } >>"$work/end.ass"
  ffmpeg -hide_banner -loglevel error -y \
    -i "$work/body.mp4" \
    -f lavfi -i "color=c=0x$violet:s=${width}x$height:r=$fps:d=$end_card_seconds" \
    -loop 1 -t "$end_card_seconds" -i "$logo" \
    -filter_complex "
      [0:v]$body_filter,format=yuv420p[body];
      [2:v]scale=$logo_size:$logo_size:flags=lanczos[logo];
      [1:v][logo]overlay=(W-w)/2:$logo_y,ass=$work/end.ass:fontsdir=$font_dir,
        fade=t=in:st=0:d=0.3,fps=$fps,setsar=1,format=yuv420p[end];
      [body][end]concat=n=2:v=1:a=0[out]" \
    -map "[out]" -an "${encode[@]}" -movflags +faststart "$output"
else
  ffmpeg -hide_banner -loglevel error -y -i "$work/body.mp4" \
    -vf "$body_filter,format=yuv420p" -an "${encode[@]}" -movflags +faststart "$output"
fi

# ------------------------------------------------------------ Size

if [ -n "$max_size_mb" ]; then
  limit=$((max_size_mb * 1000 * 1000))
  size="$(stat -f %z "$output")"
  if [ "$size" -gt "$limit" ]; then
    # Bits per second that fit, with room for the container.
    length="$(duration_of "$output")"
    rate="$(awk -v b="$limit" -v d="$length" 'BEGIN { printf "%d", b * 8 * 0.92 / d }')"
    echo "The file weighs $size bytes; re-encoding at $rate b/s to stay under $max_size_mb MB..."
    mv "$output" "$work/big.mp4"
    ffmpeg -hide_banner -loglevel error -y -i "$work/big.mp4" \
      -c:v libx264 -preset slow -b:v "$rate" -maxrate "$rate" -bufsize $((rate * 2)) \
      -pix_fmt yuv420p -an -movflags +faststart "$output"
  fi
fi

echo "Video: $output ($(stat -f %z "$output") bytes)"
ffprobe -v error -select_streams v:0 \
  -show_entries stream=codec_name,width,height,r_frame_rate:format=duration \
  -of default=noprint_wrappers=1 "$output"
