#!/bin/bash

IP=192.168.0.1
PORT=8080

GSTLAUNCH=gst-launch-0.10
GST_DEBUG=souphttpsrc:0,videoflip:0,ffmpegcolorspace:0,v4l2sink:0,pulse:0
FLIP_METHOD=none

DEVICE=/dev/video0
for d in /dev/video*; do
        if v4l2-ctl -d "$d" -D | grep -q "v4l2 loopback"; then
            DEVICE=$d
            echo $d
            break
        fi
done

NULL_SINK=$(LC_ALL=C pactl list sinks | \
            sed -n -e '/Name:/h; /module-null-sink/{x; s/\s*Name:\s*//g; p; q}' )


"$GSTLAUNCH" -vt --gst-plugin-spew --gst-debug="$GST_DEBUG" \
  souphttpsrc location="http://$IP:$PORT/videofeed" do-timestamp=true is-live=true \
    ! multipartdemux \
    ! jpegdec \
    ! ffmpegcolorspace ! "video/x-raw-yuv, format=(fourcc)YV12" \
    ! videoflip method="$FLIP_METHOD" ! videorate ! "video/x-raw-yuv, framerate=25/1" \
    ! v4l2sink device="$DEVICE" \
  souphttpsrc location="http://$IP:$PORT/audio.wav" do-timestamp=true is-live=true \
    ! wavparse ! audioconvert \
    ! volume volume=3 ! rglimiter \
    ! pulsesink device="$NULL_SINK" sync=false \
  2>&1 | tee feed.log

