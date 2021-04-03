// Copyright (c) 2014, Thomas Goyne <plorkyeran@aegisub.org>
//
// Permission to use, copy, modify, and distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Aegisub Project http://www.aegisub.org/

#include "text_selection_controller.h"

#ifdef WITH_WXSTC
#include <wx/stc/stc.h>

void TextSelectionController::SetControl(wxStyledTextCtrl* ctrl) {
	this->ctrl_te = ctrl;
	this->ctrl_ctl = ctrl;
	if (ctrl)
		ctrl->Bind(wxEVT_STC_UPDATEUI, &TextSelectionController::UpdateUI, this);
	use_stc = true;
}
#endif

void TextSelectionController::SetControl(wxTextCtrl* ctrl) {
	this->ctrl_te = ctrl;
	this->ctrl_ctl = ctrl;
	if (ctrl) {
		ctrl->Bind(wxEVT_KEY_DOWN, &TextSelectionController::UpdateUI, this);
		ctrl->Bind(wxEVT_LEFT_DOWN, &TextSelectionController::UpdateUI, this);
	}
#ifdef WITH_WXSTC
	use_stc = false;
#endif
}

TextSelectionController::~TextSelectionController() {
#ifdef WITH_WXSTC
	if (ctrl_ctl) {
		if (use_stc) {
			ctrl_ctl->Unbind(wxEVT_STC_UPDATEUI, &TextSelectionController::UpdateUI, this);
		}
		else {
#endif
			ctrl_ctl->Unbind(wxEVT_KEY_DOWN, &TextSelectionController::UpdateUI, this);
			ctrl_ctl->Unbind(wxEVT_LEFT_DOWN, &TextSelectionController::UpdateUI, this);
#ifdef WITH_WXSTC
		}
	}
#endif
}

#define GET(var, new_value) do { \
	int tmp = new_value;      \
	if (tmp != var) {         \
		var = tmp;            \
		changed = true;       \
	}                         \
} while(false)

void TextSelectionController::UpdateUI(wxEvent& evt) {
	if (changing) return;

	bool changed = false;
	GET(insertion_point, ctrl_te->GetInsertionPoint());
	long tmp_start, tmp_end;
	ctrl_te->GetSelection(&tmp_start, &tmp_end);
	if (tmp_start != selection_start || tmp_end != selection_end) {
		selection_start = tmp_start;
		selection_end = tmp_end;
		changed = true;
	}
	if (changed) AnnounceSelectionChanged();
}

void TextSelectionController::SetInsertionPoint(int position) {
	changing = true;
	if (insertion_point != position) {
		insertion_point = position;
		if (ctrl_te) ctrl_te->SetInsertionPoint(position);
	}
	changing = false;
	AnnounceSelectionChanged();
}

void TextSelectionController::SetSelection(int start, int end) {
	changing = true;
	if (selection_start != start || selection_end != end) {
		selection_start = start;
		selection_end = end;
		if (ctrl_te) ctrl_te->SetSelection(start, end);
	}
	changing = false;
	AnnounceSelectionChanged();
}
