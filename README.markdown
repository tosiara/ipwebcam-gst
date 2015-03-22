ipwebcam-gst
============

This is a shell script which allows Android users to use their phones as a webcam/microphone in Linux. The setup is as follows:

* [IP Webcam](https://market.android.com/details?id=com.pas.webcam) (on the phone) serves up a MJPEG live video stream and a WAV live audio stream through HTTP (port 8080 by default).
* From the local port in the computer, a GStreamer graph takes the MJPEG live video stream and dumps it to a loopback V4L2 device, using [v4l2loopback](https://github.com/umlaeute/v4l2loopback). The audio stream is dumped to a PulseAudio null sink.
* The sound recording device for your videochat application should be changed to the 'Monitor of Null Sink' using `pavucontrol`.
* WiFi only
