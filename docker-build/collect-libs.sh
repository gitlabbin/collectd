#!/bin/bash

set -e

usage() {
  echo 'Usage: $1 output_dir binary_path ...'
}
# Find all dependent shared object files for the collectd installation and move
# them into the installation directory

target_path=$1
mkdir -p $target_path

shift
binary_paths=$@

if [[ ${#binary_paths[@]} == 0 ]]
then
  usage
  exit 1
fi

#echo "First copying given paths to $target_path"
#cp --parents -a -R -L $binary_paths $target_path

echo "Copying dependent libs to $target_path"

find_deps() {
  local paths=$@
  # Run all of the collectd libs/binaries through ldd and pull out the deps
  find $paths -type f -o -type l -and -executable -or -name "*.so*" | \
    xargs ldd | \
    perl -ne 'print if /.* => (.+) \(0x[0-9a-f]+\)/' | \
    perl -pe 's/.* => (.+) \(0x[0-9a-f]+\)/\1/' | \
    perl -ne '/^\ s/ || print' | \
    perl -ne '/:$/ || print' | \
    grep -v $target_path | \
    grep -v /usr/lib/jvm | \
    sort | uniq
}

all_links() {
  local file=$(basename $1)
  local dir=$(dirname $1)
  echo "${dir}/$file"
  while file=$(readlink "${dir}/$file"); do
    echo -n " ${dir}/$file"
  done
}

libs=$(find_deps $binary_paths)
# Pulling one level of transitive deps is enough for now
transitive_deps=$(find_deps $libs)
for lib in $libs $transitive_deps
do
  cp -a --parents $(all_links $lib) $target_path

  echo "Pulled in $lib" # to $new_path"
done

echo "Processed $(wc -w <<< $libs) libraries"

echo "Checking for missing lib dependencies..."

# Look for all of the deps now in the target_path and make sure we have them
new_deps=$(find_deps $target_path | sed -e "s!^$target_path!!")
for dep in $new_deps
do
  stat ${target_path}${dep} >/dev/null
  if [[ $? != 0 ]]; then
    echo "Missing dependency in target dir: $dep" >&2
    exit 1
  fi
done

#remove symlinks and replace with actual lib
for link in $(find $target_path -type l)
do
  nonlink=$(readlink -fn $link)
  if [ -f $nonlink ]; then
    echo "replacing link $link with $nonlink"
    mv $nonlink $link
  fi
done

#also copy things needed to run
#cp -a -R --parents /lib/x86_64-linux-gnu $target_path

cp -a -R --parents /lib/$TARGET_PLATFORM $target_path

for link in $(find $target_path -type l)
do
  nonlink=$(readlink -fn $link)
  if [ -f $nonlink ]; then
    echo "replacing link $link with $nonlink"
    rm $link
    cp $nonlink $link
  fi
done

# remove any symlinks left
find $target_path -type l -exec rm {} \;

echo "Everything is there!"
