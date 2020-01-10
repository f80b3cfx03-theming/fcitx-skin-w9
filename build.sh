#!/usr/bin/env bash

# TODO: check for imagemagick and pngcrush

# https://www.imagemagick.org/Usage/blur/

convert="convert-im6"
dir="."
build_dir="$1"
if [ -z "$build_dir" ]; then
	build_dir="./build"
fi

grey="rgb(192, 192, 192)"
dummy_color="magenta" # there has to be a common name for this

icon_practical_filenames=("")
get_icon_practical_filenames () {
	filename_in="$1"

	case "$filename_in" in
		"direct.png")
			icon_practical_filenames=(
				"bar_en.png"
			)
			;;
		"lang_cmn_double.png")
			icon_practical_filenames=(
				"rime-im-double_pinyin.png"
				"rime-im-double_pinyin_abc.png"
				"rime-im-double_pinyin_flypy.png"
				"rime-im-double_pinyin_mspy.png"
				"rime-im-double_pinyin_pyjj.png"
			)
			;;
		"lang_cmn_luna.png")
			icon_practical_filenames=(
				"rime-im-luna_pinyin.png"
			)
			;;
		"lang_cmn_terra.png")
			icon_practical_filenames=(
				"rime-im-terra_pinyin.png"
			)
			;;
		"lang_hani_stroke.png")
			icon_practical_filenames=(
				"rime-im-stroke.png"
			)
			;;
		"lang_hani_wubi.png")
			icon_practical_filenames=(
				"rime-im-wubi86.png"
				"rime-im-wubi_pinyin.png"
				"rime-im-wubi_trad.png"
			)
			;;
		"lang_ko.png")
			icon_practical_filenames=(
				"rime-im-qyeyshanglr_hanja.png"
				"rime-im-soolegi_hangugeo.png" # personal
			)
			;;
		"lang_ko_hanja.png")
			icon_practical_filenames=(
				"rime-im-soolegi_hanja.png" # personal
			)
			;;
		"lang_ko_yethan-3.png")
			icon_practical_filenames=(
				"rime-im-soolegi_yethangeul.png" # personal
				"rime-im-slg_dubeolsik_yethangeul.png" # personal
			)
			;;
		"lang_latn.png")
			icon_practical_filenames=(
				"rime-latin.png"
			)
			;;
		"lang_latn_yunlong.png")
			icon_practical_filenames=(
				"rime-im-ipa_yunlong.png"
			)
			;;
		"lang_yue.png")
			icon_practical_filenames=(
				"rime-im-hkcantonese.png"
				"rime-im-yale.png"
				"rime-im-yytpiq.png" # personal
			)
			;;
		"lang_yue_jyutping.png")
			icon_practical_filenames=(
				"rime-im-jyutping.png"
				"rime-im-jyut6ping3.png"
				"rime-im-jyut6ping_ipa.png"
			)
			;;
		"rime.png")
			icon_practical_filenames=(
				"rime.png"
			)
			;;
		"rime-disable.png")
			icon_practical_filenames=(
				"rime-disable.png" # replaces `im-` icon while Rime is deploying
			)
			;;
		"x.png")
			icon_practical_filenames=(
				"x.png"
				# XXX
				"rime-deploy.png"
				"rime-sync.png"
			)
			;;
		*)
			return 1
			;;
	esac
}

create_icon () {
	filename_in="$1"
	filename_out="$2"

	"$convert" \
		\( \
			-page +0+0 "$dir/button-1.png" \
			-fuzz 0% \
			-fill "$grey" \
			-opaque "$dummy_color" \
		\) \
		-page +2+2 "$filename_in" \
		-layers merge \
		+repage \
		"$filename_out"
}

create_icon_shadowed () {
	filename_in="$1"
	filename_out="$2"

	"$convert" \
		\( \
			-page +0+0 "$dir/button-1.png" \
			-fuzz 0% \
			-fill "$grey" \
			-opaque "$dummy_color" \
		\) \
		-page +2+2 "$filename_in" \
		\( \
			+clone \
			-background white \
			-shadow 100x0+1+1 \
		\) \
		+swap \
		-background none \
		-layers merge \
		+repage \
		"$filename_out"
}

create_icon_2 () {
	filename_in="$1"
	filename_out="$2"

	"$convert" \
		\( \
			-page +0+0 "$dir/button-2.png" \
			-fuzz 0% \
			-fill "$grey" \
			-opaque "$dummy_color" \
		\) \
		-background transparent \
		-page +3+3 "$filename_in" \
		-layers merge \
		+repage \
		"$filename_out"
}

create_icon_shadowed_2 () {
	# adjust `+2+2` to `+3+3`
	filename_in="$1"
	filename_out="$2"

	"$convert" \
		\( \
			-page +0+0 "$dir/button-1.png" \
			-fuzz 0% \
			-fill "$grey" \
			-opaque "$dummy_color" \
		\) \
		-page +3+3 "$filename_in" \
		\( \
			+clone \
			-background white \
			-shadow 100x0+1+1 \
		\) \
		+swap \
		-background none \
		-layers merge \
		+repage \
		"$filename_out"
}

echo "build dir: $build_dir"
echo "----"

# `--parents`: do not complain if the directory exists
mkdir --parents "$build_dir"

for filename in $(find "$dir" -maxdepth 1 -name "lang_*.png" -o -name "direct.png" -o -name "x.png"); do
	filename=$(basename "$filename")
	echo "$filename"

	create_icon_shadowed "$dir/$filename" "$build_dir/.$filename"
	echo "  " "$dir/$filename" "$build_dir/.$filename"

	get_icon_practical_filenames "$filename"
	if [ $? -ne 1 ]; then
		for practical_filename in "${icon_practical_filenames[@]}"
		do
			ln -s ".$filename" "$build_dir/$practical_filename"
			echo "  " ".$filename" "$build_dir/$practical_filename"
		done
	fi
done

for filename in "$dir/fcitx.png"; do
	filename=$(basename "$filename")
	echo "$filename"

	create_icon "$dir/$filename" "$build_dir/bar_logo.png"
	echo "  " "$dir/$filename" "$build_dir/bar_logo.png"
done

for filename in $(find "$dir" -maxdepth 1 -name "rime*.png"); do
	filename=$(basename "$filename")
	echo "$filename"

	#create_icon_2 "$dir/$filename" "$build_dir/.$filename"
	create_icon_shadowed_2 "$dir/$filename" "$build_dir/.$filename"
	echo "  " "$dir/$filename" "$build_dir/.$filename"

	get_icon_practical_filenames "$filename"
	if [ $? -ne 1 ]; then
		for practical_filename in "${icon_practical_filenames[@]}"
		do
			ln -s ".$filename" "$build_dir/$practical_filename"
			echo "  " ".$filename" "$build_dir/$practical_filename"
		done
	fi
done

for filename in $(find "$dir" -maxdepth 1 -name "active*.png" -o -name "input*.png" -o -name "menu.png"); do
	filename=$(basename "$filename")
	echo "$filename"

	cp "$dir/$filename" "$build_dir/$filename"
	echo "  " "$dir/$filename" "$build_dir/$filename"
done

for filename in "$dir/fcitx_skin.conf"; do
	filename=$(basename "$filename")
	echo "$filename"

	#cp "$dir/$filename" "$build_dir/$filename"
	sed --null-data -E 's/# [^\n]+\n//g' "$dir/$filename" > "$build_dir/$filename"
	echo "  " "$dir/$filename" "$build_dir/$filename"
done

echo "----"

# `-type f`: exclude symlinks
for filename in $(find "$build_dir" -maxdepth 1 -name "*.png" -type f); do
	filename=$(basename "$filename")
	echo "$filename"

	pngcrush "$build_dir/$filename" "$build_dir/CRUSH$filename"
	mv "$build_dir/CRUSH$filename" "$build_dir/$filename"
done
