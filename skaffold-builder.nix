{ ...}:
{
  config = {
    scripts.skaffold-builder-buildx.exec = ''
      set -ex

      args=""

      if test "$PUSH_IMAGE" = true; then
        args+="--push "
      fi

      if test -n "$PLATFORMS"; then
        args+="--platform $PLATFORMS "
      fi

      docker buildx build "$BUILD_CONTEXT" --tag $IMAGE $args $SKAFFOLD_BUILDX_ARGS
    '';
  };
}
