-- Yelp Compliment Auto Sender (no keystrokes, first-name only, with modal flow)
-- Sequence per tab: click "Compliment" -> wait 2s -> fill text -> wait 5s -> click "Send"

property ONLY_FRONT_WINDOW : false -- set true to act only on the frontmost Chrome window
property URL_FILTER : "yelp.com" -- operate only on these tabs
property MODAL_OPEN_DELAY : 2 -- seconds to wait after clicking "Compliment"
property BEFORE_SEND_DELAY : 5 -- seconds to wait after filling text before clicking Send
property DELAY_BETWEEN_TABS : 5 -- polite gap between tabs (seconds)

set defaultMsg to "Hi {name}, love your reviews!" & return & "Have a good day!" & return & "" & return & "" & return & "" & return & "" & return & ""

set messageTemplate to text returned of (display dialog "Enter message (use {name}):" default answer defaultMsg buttons {"Cancel", "OK"} default button "OK" with title "Compliment Template")
set messageTemplate to my trimWhitespace(messageTemplate)

-- ===== Helpers =====
on extractNameFromTitle(t)
	try
		set AppleScript's text item delimiters to " - Yelp"
		set nm to text item 1 of t
		set AppleScript's text item delimiters to ""
		if nm is "" then return "there"
		return nm
	on error
		set AppleScript's text item delimiters to ""
		return "there"
	end try
end extractNameFromTitle

-- First token only (e.g., "Andrew A." -> "Andrew"; trims trailing punctuation)
on firstWordOnly(txt)
	try
		if txt is missing value then return "there"
		set sanitized to (txt as text)
		set wordList to words of sanitized
		if (count of wordList) is 0 then return "there"
		set fw to item 1 of wordList
		set tailers to {".", ",", ";", ":", "!", "?"}
		repeat with p in tailers
			repeat while fw ends with (contents of p) and (length of fw) > 1
				set fw to text 1 thru -2 of fw
			end repeat
		end repeat
		if fw is "" then return "there"
		return fw
	on error
		return "there"
	end try
end firstWordOnly

on replaceToken(hay, needle, rep)
	set AppleScript's text item delimiters to needle
	set parts to text items of hay
	set AppleScript's text item delimiters to rep
	set out to parts as text
	set AppleScript's text item delimiters to ""
	return out
end replaceToken

on fillTemplate(tpl, nameText)
	return my replaceToken(tpl, "{name}", nameText)
end fillTemplate

on jsEscape(t)
	set t1 to my replaceToken(t, "\\", "\\\\")
	set t2 to my replaceToken(t1, "\"", "\\\"")
	set t3 to my replaceToken(t2, return, "\\n")
	set t4 to my replaceToken(t3, linefeed, "\\n")
	return t4
end jsEscape

on trimWhitespace(theText)
	set cleaned to my trimString(theText)
	set AppleScript's text item delimiters to {return, linefeed}
	set segments to text items of cleaned
	set normalized to {}
	repeat with seg in segments
		set end of normalized to my trimString(seg)
	end repeat
	set AppleScript's text item delimiters to return
	set joined to normalized as text
	set AppleScript's text item delimiters to ""
	set resultText to my trimString(joined)
	return resultText
end trimWhitespace

on trimString(theText)
	if theText is missing value then return ""
	set whiteChars to {space, tab, return, linefeed}
	set startIndex to 1
	set endIndex to length of theText
	repeat while startIndex ≤ endIndex and character startIndex of theText is in whiteChars
		set startIndex to startIndex + 1
	end repeat
	repeat while endIndex ≥ startIndex and character endIndex of theText is in whiteChars
		set endIndex to endIndex - 1
	end repeat
	if endIndex < startIndex then return ""
	return text startIndex thru endIndex of theText
end trimString

-- Click the "Compliment" button on the page (outside modal)
on jsClickCompliment()
	return "(function(){
  const visible = el => !!el && el.offsetParent !== null;
  const buttons = Array.from(document.querySelectorAll('button,a,[role=\"button\"]'));
  const btn = buttons.find(b=>{
    if(!visible(b)) return false;
    const aria = (b.getAttribute('aria-label')||'').toLowerCase();
    if(aria.includes('compliment')) return true;
    const txt = ((b.innerText||b.textContent||'')+'').trim().toLowerCase();
    if(txt === 'compliment') return true;
    const dataTestId = (b.getAttribute('data-testid')||'').toLowerCase();
    if(dataTestId.includes('compliment')) return true;
    const classes = (b.className||'').toLowerCase();
    if(classes.includes('compliment')) return true;
    if(b.querySelector('.icon--24-compliment-v2')) return true;
    if((b.tagName === 'A' || b.tagName === 'BUTTON') && ((b.getAttribute('href')||'').toLowerCase().includes('compliment'))) return true;
    return false;
  });
  if(btn){ btn.click(); return 'clicked'; }
  return 'no-compliment';
})();"
end jsClickCompliment

-- Fill the textarea inside the Compliment modal
on jsFillComplimentText(theMessage)
	set esc to my jsEscape(theMessage)
	return "(function(){
  const visible = el => !!el && el.offsetParent !== null;
  const portal = document.getElementById('modal-portal-container');
  const dialog = portal ? portal.querySelector('[role=\"dialog\"]') : document.querySelector('[role=\"dialog\"][data-overlay=\"true\"]');
  if(!dialog) return 'no-dialog';
  const modal = dialog.querySelector('[aria-live=\"polite\"][role=\"region\"]') || dialog;
  const ta = modal.querySelector('textarea[name=\"message\"]') || dialog.querySelector('textarea');
  if(!ta || !visible(ta)) return 'no-textarea';
  const desc = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value');
  if(desc && desc.set){ desc.set.call(ta, \"" & esc & "\"); } else { ta.value = \"" & esc & "\"; }
  ta.dispatchEvent(new Event('input', {bubbles:true}));
  ta.dispatchEvent(new Event('change', {bubbles:true}));
  ta.focus();
  return 'filled';
})();"
end jsFillComplimentText

-- Click the "Send" button inside the modal
on jsClickModalSend()
	return "(function(){
  const visible = el => !!el && el.offsetParent !== null;
  const portal = document.getElementById('modal-portal-container');
  const dialog = portal ? portal.querySelector('[role=\"dialog\"]') : document.querySelector('[role=\"dialog\"][data-overlay=\"true\"]');
  if(!dialog) return 'no-dialog';
  const modal = dialog.querySelector('[aria-live=\"polite\"][role=\"region\"]') || dialog;
  const btns = Array.from(modal.querySelectorAll('button[type=\"submit\"], button[data-button], [role=\"button\"]')).filter(visible);
  const send = btns.find(b=>/\\bsend\\b/i.test((b.innerText||b.textContent||'').trim()));
  if(send){ send.click(); return 'sent'; }
  return 'no-send';
})();"
end jsClickModalSend

-- ===== Main =====
tell application "Google Chrome"
	activate
	set winCount to number of windows
	if winCount = 0 then return
	
	set winStart to 1
	set winEnd to winCount
	if ONLY_FRONT_WINDOW then
		set winStart to index of front window
		set winEnd to winStart
	end if
	
	set firstYelpWindow to 0
	repeat with wi from winStart to winEnd
		set w to window wi
		set foundYelpTab to false
		try
			set tabCount to number of tabs in w
		on error
			set tabCount to 0
		end try
		if tabCount > 0 then
			repeat with ti from 1 to tabCount
				set theURL to URL of tab ti of w
				if theURL contains URL_FILTER then
					set foundYelpTab to true
					exit repeat
				end if
			end repeat
		end if
		if foundYelpTab then
			set firstYelpWindow to wi
			exit repeat
		end if
	end repeat
	
	if firstYelpWindow is 0 then
		log "No Chrome windows contain tabs matching " & URL_FILTER
		return
	end if
	
	repeat with wi from firstYelpWindow to winEnd
		set w to window wi
		try
			set tabCount to number of tabs in w
		on error
			set tabCount to 0
		end try
		
		if tabCount > 0 then
			log "Processing window " & wi & " with " & tabCount & " tabs"
			repeat with ti from 1 to tabCount
				set t to tab ti of w
				set theURL to URL of t
				if theURL contains URL_FILTER then
					log "Processing Yelp tab " & ti & " in window " & wi
					set active tab index of w to ti
					delay 0.4
					
					-- 1) click "Compliment"
					set c1 to execute t javascript (my jsClickCompliment())
					if c1 is "clicked" then
						-- 2) wait for modal to appear (exactly as requested)
						delay MODAL_OPEN_DELAY
						
						-- 3) personalize first name and fill text
						set tabTitle to title of t
						set nameFull to my extractNameFromTitle(tabTitle)
						set firstName to my firstWordOnly(nameFull)
						set personalizedMessage to my fillTemplate(messageTemplate, firstName)
						set c2 to execute t javascript (my jsFillComplimentText(personalizedMessage))
						if c2 is "filled" then
							log "Compliment message personalized to: " & personalizedMessage
							
							-- 4) wait before sending (exactly as requested)
							delay BEFORE_SEND_DELAY
							
							-- 5) click "Send" on the modal
							set c3 to execute t javascript (my jsClickModalSend())
							if c3 is "sent" then
								log "Compliment sent for tab " & ti & " in window " & wi
							else
								log "Compliment send failed for tab " & ti & " (status: " & c3 & ")"
							end if
						else
							log "Compliment text not filled for tab " & ti & " (status: " & c2 & ")"
						end if
					else
						log "Compliment button not clicked for tab " & ti & " (status: " & c1 & ")"
					end if
					
					-- polite spacing before next tab
					delay DELAY_BETWEEN_TABS
				end if
			end repeat
		end if
	end repeat
end tell
