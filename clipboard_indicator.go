package main

import (
	"crypto/md5"
	"flag"
	"fmt"
	"os/exec"
	"strings"
	"time"
)

var (
	interval   = flag.Duration("interval", 500*time.Millisecond, "Polling interval")
	notifyTime = flag.Duration("timeout", 1500*time.Millisecond, "Notification timeout")
	urgency    = flag.String("urgency", "low", "Notification urgency (low, normal, critical)")
	maxLen     = flag.Int("max-preview", 50, "Max preview length in notification")
	icon       = flag.String("icon", "", "Notification icon")
)

func getClipboard() (string, error) {
	cmd := exec.Command("wl-paste")
	output, err := cmd.Output()
	if err == nil {
		return string(output), nil
	}

	cmd = exec.Command("xclip", "-o", "-selection", "clipboard")
	output, err = cmd.Output()
	return string(output), err
}

func notify(content, typ string) {
	preview := content
	if len(preview) > *maxLen {
		preview = preview[:*maxLen] + "..."
	}
	preview = strings.ReplaceAll(preview, "\n", " ")

	args := []string{"-t", fmt.Sprintf("%d", notifyTime.Milliseconds()), "-u", *urgency}
	if *icon != "" {
		args = append(args, "-i", *icon)
	}
	args = append(args, typ, preview)

	cmd := exec.Command("notify-send", args...)
	cmd.Run()
}

func main() {
	flag.Parse()
	fmt.Println("Clipboard indicator started. Monitoring clipboard...")
	var lastHash [16]byte

	for {
		content, err := getClipboard()
		if err == nil && content != "" {
			currentHash := md5.Sum([]byte(content))
			if currentHash != lastHash {
				notify(content, "✓ Copied")
				lastHash = currentHash
			}
		}
		time.Sleep(*interval)
	}
}
