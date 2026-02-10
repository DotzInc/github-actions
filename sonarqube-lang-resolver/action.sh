#!/usr/bin/env bash

set -euo pipefail

lang="${SONAR_LANG:-}"
module="${SONAR_MODULE:-}"
module="${module#./}"
module="${module%/}"
if [ -z "$module" ] || [ "$module" = "." ]; then
  module="."
fi
resolved_module="$module"
angular_module=0
python_module=0
angular_root=0
python_root=0
angular_any=0
python_any=0

detect_angular() {
  local dir="$1"
  if [ -f "$dir/angular.json" ]; then
    return 0
  fi
  if [ -f "$dir/package.json" ] && grep -qE '"@angular/(core|cli|devkit/build-angular)"' "$dir/package.json"; then
    return 0
  fi
  return 1
}

detect_python() {
  local dir="$1"
  if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/setup.cfg" ] || [ -f "$dir/Pipfile" ]; then
    return 0
  fi
  if compgen -G "$dir/requirements*.txt" > /dev/null; then
    return 0
  fi
  return 1
}

detect_angular_any() {
  local found=0
  if find . -maxdepth 6 -type f -name angular.json \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -print -quit | grep -q .; then
    found=1
  fi

  if [ "$found" = "0" ]; then
    while IFS= read -r pkg; do
      if grep -qE '"@angular/(core|cli|devkit/build-angular)"' "$pkg"; then
        found=1
        break
      fi
    done < <(find . -maxdepth 6 -type f -name package.json \
      -not -path '*/node_modules/*' -not -path '*/.git/*' -print)
  fi

  [ "$found" = "1" ]
}

detect_python_any() {
  if find . -maxdepth 6 -type f \
    -not -path '*/.venv/*' -not -path '*/.git/*' -not -path '*/node_modules/*' \
    \( -name 'pyproject.toml' -o -name 'setup.py' -o -name 'setup.cfg' -o -name 'Pipfile' -o -name 'requirements*.txt' \) \
    -print -quit | grep -q .; then
    return 0
  fi
  return 1
}

detect_angular_module_path() {
  local file
  file=$(find . -maxdepth 6 -type f -name angular.json \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -print -quit)
  if [ -n "$file" ]; then
    dirname "${file#./}"
    return 0
  fi

  while IFS= read -r pkg; do
    if grep -qE '"@angular/(core|cli|devkit/build-angular)"' "$pkg"; then
      dirname "${pkg#./}"
      return 0
    fi
  done < <(find . -maxdepth 6 -type f -name package.json \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -print)
  return 1
}

if [ -n "$module" ] && [ "$module" != "." ] && [ -d "$module" ]; then
  if detect_angular "$module"; then
    angular_module=1
  fi
  if detect_python "$module"; then
    python_module=1
  fi
else
  if detected_module=$(detect_angular_module_path); then
    resolved_module="$detected_module"
  else
    resolved_module="."
  fi
fi

if detect_angular "."; then
  angular_root=1
fi
if detect_python "."; then
  python_root=1
fi

if detect_angular_any; then
  angular_any=1
fi
if detect_python_any; then
  python_any=1
fi

if [ "$angular_module" = "1" ] && [ "$python_module" != "1" ]; then
  lang="angular"
elif [ "$python_module" = "1" ] && [ "$angular_module" != "1" ]; then
  lang="python"
elif [ "$angular_root" = "1" ] && [ "$python_root" != "1" ]; then
  lang="angular"
elif [ "$python_root" = "1" ] && [ "$angular_root" != "1" ]; then
  lang="python"
elif [ "$angular_any" = "1" ] && [ "$python_any" != "1" ]; then
  lang="angular"
elif [ "$python_any" = "1" ] && [ "$angular_any" != "1" ]; then
  lang="python"
fi

echo "Resolved SONAR_LANG=$lang"
echo "Resolved SONAR_MODULE=$resolved_module"
echo "SONAR_LANG=$lang" >> "$GITHUB_ENV"
echo "SONAR_MODULE=$resolved_module" >> "$GITHUB_ENV"
