# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

mapfile -t GTD_TXT_DATA < <(find "${GTD_TXT_REPOSITORY:-$HOME/gtd.txt/data}" \
  -maxdepth 1 -type f -not -name '*~')
GTD_TXT_DATA=("${GTD_TXT_DATA[@]}" /dev/null)  # ensure GTD_TXT_DATA is nonempty
readonly GTD_TXT_DATA

common_awk() {
  local -r AWKLIB='
    BEGIN {
      RS = "\n\n---\n\n"
      FS = "\n"
    }
    function array_empty(arr,    i) {
      for (i in arr)
        return 1
      return 0
    }
    function filename(    file) {
      file = FILENAME
      gsub(PWD "/", "", file)
      gsub(HOME, "~", file)
      return file
    }
    function showWithFile(text) {
      if (text != "")
        text = text "  "
      printf("%s%s%s%s\n", text, grey, filename(), normal)
    }
  '
  local program="$1"
  shift
  awk \
    -v HOME="$HOME" \
    -v PWD="$PWD" \
    -v grey="$(tput setaf 8)" \
    -v normal="$(tput sgr0)" \
    "$AWKLIB
     $program" \
    "$@"
}

join_by() {
  local IFS="$1"
  shift
  echo "$*"
}
