#!/bin/bash
tempdir=$(mktemp -d)
confpath=$tempdir/minetest.conf
worldpath=$tempdir/world
trap 'rm -rf "$tempdir" || :' EXIT

[ -f mesecons/mod.conf ] || { echo "Must be run in modpack root folder." >&2; exit 1; }

command -v docker >/dev/null || { echo "Docker is not installed." >&2; exit 1; }
mtg=.test/minetest_game
[ -d $mtg ] || echo "A source checkout of minetest_game was not found. This can fail if your docker image does not ship a game." >&2

mkdir "$worldpath"
cp -v .test/minetest.conf "$confpath"
chmod -R 777 "$tempdir"

args=(
	-v "$confpath":/etc/minetest/minetest.conf
	-v "$tempdir":/var/lib/minetest/.minetest
	-v "$PWD":/var/lib/minetest/.minetest/world/worldmods/mesecons
)
[ -d $mtg ] && args+=(
	-v "$(realpath $mtg)":/var/lib/minetest/.minetest/games/minetest_game
)
args+=("$DOCKER_IMAGE")
[ -d $mtg ] && args+=(--gameid minetest)
docker run --rm -i "${args[@]}"

ls -la "$worldpath"
test -f "$worldpath/mesecon_actionqueue" || exit 1
exit 0
