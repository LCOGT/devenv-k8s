{ ...}:
{
  config = {
    scripts.skaffold-builder-buildx.exec = ''

      args=""

      if test "$PUSH_IMAGE" = true; then
        args+="--push "
      else
        args+="--load "
      fi

      if test -n "$PLATFORMS"; then
        args+="--platform $PLATFORMS "
      fi

      if docker buildx > /dev/null 2>&1; then
        buildx_cmd="docker buildx"
      elif buildx > /dev/null 2>&1; then
        buildx_cmd="buildx"
      else
        echo "buildx not found"
        exit 1
      fi

      set -ex
      $buildx_cmd build "$BUILD_CONTEXT" --tag $IMAGE $args $SKAFFOLD_BUILDX_ARGS "$@"
    '';
  };
}
