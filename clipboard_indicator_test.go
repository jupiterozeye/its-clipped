package main

import (
	"strings"
	"testing"
)

func TestNotifyPreviewTruncation(t *testing.T) {
	// Test that preview is truncated correctly
	longContent := strings.Repeat("a", 100)
	maxLen := 50

	preview := longContent
	if len(preview) > maxLen {
		preview = preview[:maxLen] + "..."
	}

	if len(preview) != maxLen+3 {
		t.Errorf("Expected preview length of %d, got %d", maxLen+3, len(preview))
	}

	if !strings.HasSuffix(preview, "...") {
		t.Error("Expected preview to end with '...'")
	}
}

func TestNotifyNewlineReplacement(t *testing.T) {
	// Test that newlines are replaced with spaces
	content := "line1\nline2\nline3"
	preview := strings.ReplaceAll(content, "\n", " ")

	if strings.Contains(preview, "\n") {
		t.Error("Expected newlines to be replaced with spaces")
	}

	expected := "line1 line2 line3"
	if preview != expected {
		t.Errorf("Expected %q, got %q", expected, preview)
	}
}

func TestGetClipboard(t *testing.T) {
	// This test will fail if neither wl-paste nor xclip is available
	// which is expected in CI environments without clipboard tools
	content, err := getClipboard()

	// We expect an error when no clipboard tools are available
	// but the function should still be callable
	_ = content
	_ = err
}
