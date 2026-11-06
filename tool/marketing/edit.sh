#!/usr/bin/env bash
# Turns a raw screen recording of tool/marketing/record.sh into a vertical
# video ready for TikTok, Reels or Shorts: 1080x1920, 30 frames per second,
# H.264 MP4, on-screen texts, and a 3-second end card. No sound: add the
# music in the app you publish with.
#
# Usage, from anywhere:
#   bash tool/marketing/edit.sh --input marketing/videos/raw/<file>.mp4 \
#     --output marketing/videos/<name>.mp4 \
#     --start 0.5 --duration 10 \
#     --caption "0-4|Apprends tes *tables*" \
#     --caption "4-10|en *jouant* !"
#
# Options:
#   --input FILE       raw recording (required)
#   --output FILE      video to write (required)
#   --start SECONDS    where the clip starts in the recording (default 0)
#   --duration SECONDS length of the clip, end card excluded (default: all)
#   --caption "FROM-TO|TEXT"
#                      text shown from FROM to TO, in seconds of the clip,
#                      white on a violet banner; *word* is yellow; \n starts
#                      a second line. Repeat the option for more texts.
#   --caption-y PIXELS top of the banner (default 150, under the TikTok
#                      header)
#   --fit pad|crop     pad (default): the whole screen, violet bars on the
#                      sides; crop: fill the frame, top and bottom cut
#   --no-end-card      leave the end card out
set -euo pipefail
readonly root="$(cd "$(dirname "$0")/../.." && pwd)"

readonly width=1080
readonly height=1920
readonly fps=30
readonly violet="5B3DF5"
# ASS colors are written blue-green-red.
readonly ass_white="HFFFFFF"
readonly ass_yellow="H31C5FF" # #FFC531
readonly font_dir="$root/assets/fonts"
# Full name of the instance the variable font opens on: libass only finds
# the file under that name.
readonly font_name="Fredoka Light"
readonly logo="$root/tool/icon/out/icon.png"
readonly end_card_seconds=3
readonly end_title="Kid Matix"
readonly end_line="Gratuit · sans pub · sans Internet"
readonly end_stores="Android et iPhone"
readonly caption_font_size=68
readonly caption_line_height=92
readonly caption_padding=44

input=""
output=""
start="0"
duration=""
fit="pad"
caption_y=150
has_end_card=true
captions=()

usage() {
  sed -n '2,27p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --input) input="$2"; shift 2 ;;
    --output) output="$2"; shift 2 ;;
    --start) start="$2"; shift 2 ;;
    --duration) duration="$2"; shift 2 ;;
    --caption) captions+=("$2"); shift 2 ;;
    --caption-y) caption_y="$2"; shift 2 ;;
    --fit) fit="$2"; shift 2 ;;
    --no-end-card) has_end_card=false; shift ;;
    *) usage ;;
  esac
done
[ -n "$input" ] && [ -n "$output" ] || usage
[ -f "$input" ] || { echo "No such recording: $input" >&2; exit 1; }
case "$fit" in pad | crop) ;; *) usage ;; esac

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

[Events]
Format: Layer, Start, End, Style, Text
EOF
}

# One ASS line: text $3 centered on ($4, $5) from $1 to $2 seconds, with
# the override tags $6. *word* turns yellow, outline included.
ass_line() {
  local text
  text="$(printf '%s' "$3" | sed -E \
    "s/\*([^*]+)\*/{\\\\c\&$ass_yellow\&\\\\3c\&$ass_yellow\&}\1{\\\\c\&$ass_white\&\\\\3c\&$ass_white\&}/g; s/\\\\n/\\\\N/g")"
  printf 'Dialogue: 0,%s,%s,Text,{\\an5\\pos(%s,%s)%s}%s\n' \
    "$(ass_time "$1")" "$(ass_time "$2")" "$4" "$5" "${6:-}" "$text"
}

# ---------------------------------------------------------------- Clip

if [ "$fit" = "pad" ]; then
  frame="scale=$width:$height:force_original_aspect_ratio=decrease:flags=lanczos,pad=$width:$height:(ow-iw)/2:(oh-ih)/2:color=0x$violet"
else
  frame="scale=$width:$height:force_original_aspect_ratio=increase:flags=lanczos,crop=$width:$height"
fi
clip_filter="fps=$fps,$frame,setsar=1"

if [ "${#captions[@]}" -gt 0 ]; then
  ass_header >"$work/captions.ass"
  for caption in "${captions[@]}"; do
    range="${caption%%|*}"
    text="${caption#*|}"
    from="${range%-*}"
    to="${range#*-}"
    lines="$(printf '%s' "$text" | awk -F'\\\\n' '{ print NF }')"
    banner_height=$((caption_padding * 2 + caption_line_height * lines))
    clip_filter="$clip_filter,drawbox=x=0:y=$caption_y:w=$width:h=$banner_height:color=0x$violet:t=fill:enable='between(t,$from,$to)'"
    ass_line "$from" "$to" "$text" $((width / 2)) $((caption_y + banner_height / 2)) \
      >>"$work/captions.ass"
  done
  clip_filter="$clip_filter,ass=$work/captions.ass:fontsdir=$font_dir"
fi

clip_time=(-ss "$start")
[ -z "$duration" ] || clip_time+=(-t "$duration")

# ------------------------------------------------------------ End card

if [ "$has_end_card" = true ]; then
  ass_header >"$work/end.ass"
  {
    ass_line 0 "$end_card_seconds" "$end_title" 540 1130 '\fs130'
    ass_line 0 "$end_card_seconds" "$end_line" 540 1290 '\fs58'
    ass_line 0 "$end_card_seconds" "*$end_stores*" 540 1390 '\fs58'
  } >>"$work/end.ass"
  ffmpeg -hide_banner -loglevel error -y \
    "${clip_time[@]}" -i "$input" \
    -f lavfi -i "color=c=0x$violet:s=${width}x$height:r=$fps:d=$end_card_seconds" \
    -loop 1 -t "$end_card_seconds" -i "$logo" \
    -filter_complex "
      [0:v]$clip_filter,format=yuv420p[clip];
      [2:v]scale=560:560:flags=lanczos[logo];
      [1:v][logo]overlay=(W-w)/2:440,ass=$work/end.ass:fontsdir=$font_dir,
        fade=t=in:st=0:d=0.3,fps=$fps,setsar=1,format=yuv420p[end];
      [clip][end]concat=n=2:v=1:a=0[out]" \
    -map "[out]" -an -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p \
    -r "$fps" -movflags +faststart "$output"
else
  ffmpeg -hide_banner -loglevel error -y \
    "${clip_time[@]}" -i "$input" \
    -vf "$clip_filter,format=yuv420p" \
    -an -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p \
    -r "$fps" -movflags +faststart "$output"
fi

echo "Video: $output"
ffprobe -v error -select_streams v:0 \
  -show_entries stream=codec_name,width,height,r_frame_rate:format=duration \
  -of default=noprint_wrappers=1 "$output"
