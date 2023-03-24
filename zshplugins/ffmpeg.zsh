function ffresize() {
  input_file=$1
  input_file_name=$(basename "$input_file")
  input_file_extension="${input_file_name##*.}"
  input_file_name="${input_file_name%.*}"
  output_dir=$(dirname "$input_file")

  # Use fzf to prompt user to choose scaling option
  scale=$(echo "1920:-1, 1280:-1, 720:-1, 480:-1, 360:-1" | tr ',' '\n' | fzf)

  # Use ffmpeg to resize video
  ffmpeg -i "$input_file" -vf scale="$scale" "$output_dir/${input_file_name}_2.${input_file_extension}"
}
