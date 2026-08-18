package main

import (
	"net/url"
	"testing"
)

func TestParsePublicListParamsDefaults(t *testing.T) {
	params, errMsg := parsePublicListParams(url.Values{})
	if errMsg != "" {
		t.Fatalf("unexpected error: %s", errMsg)
	}
	if params.section != "" || params.limit != publicDefaultListLimit || params.offset != 0 {
		t.Fatalf("unexpected defaults: %+v", params)
	}
}

func TestParsePublicListParamsAcceptsLimitAndOffset(t *testing.T) {
	params, errMsg := parsePublicListParams(url.Values{
		"section": []string{"React"},
		"limit":   []string{"20"},
		"offset":  []string{"100"},
	})
	if errMsg != "" {
		t.Fatalf("unexpected error: %s", errMsg)
	}
	if params.section != "React" || params.limit != 20 || params.offset != 100 {
		t.Fatalf("unexpected params: %+v", params)
	}
}

func TestParsePublicListParamsRejectsInvalidLimit(t *testing.T) {
	_, errMsg := parsePublicListParams(url.Values{"limit": []string{"0"}})
	if errMsg == "" {
		t.Fatal("expected limit error")
	}

	_, errMsg = parsePublicListParams(url.Values{"limit": []string{"101"}})
	if errMsg == "" {
		t.Fatal("expected limit error for 101")
	}
}

func TestParsePublicListParamsRejectsInvalidOffset(t *testing.T) {
	_, errMsg := parsePublicListParams(url.Values{"offset": []string{"-1"}})
	if errMsg == "" {
		t.Fatal("expected offset error")
	}

	_, errMsg = parsePublicListParams(url.Values{"offset": []string{"abc"}})
	if errMsg == "" {
		t.Fatal("expected offset error for non-integer")
	}
}
