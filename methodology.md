# Methodology

No AI tools during the event ([rules](event-briefer.md#iv-event-information)). Work by hand.

## Before the event

- Install [`tools.md`](tools.md) on every laptop. Confirm each launches offline.
- Practice: [picoCTF](https://picoctf.org/), [PortSwigger Academy](https://portswigger.net/web-security), [OverTheWire](https://overthewire.org/wargames/).

## Roles

- One category each: OSINT, web, forensics, crypto/misc. Swap when stalled.
- Scope: OSINT, web, network forensics, misc ([briefer](event-briefer.md#iv-event-information)).

## Notes

- One Google Doc per challenge: commands, output, dead ends.
- Keep it transferable so anyone can pick up.

## Scoring

Tiers: easy 1-30, moderate 31-70, hard 71-100 ([briefer](event-briefer.md#b-challenge-point-system)).

- Clear all easy first.
- Then moderates in your category.
- Hards last, or when the board is thin.

## Per challenge

1. Read the prompt. Title, filename, points are hints. Puns name the technique ("Shift happens" = Caesar).
2. Run the [first pass](README.md#first-pass-on-any-file). Note oddities: wrong extension, high entropy, strange charset or header.
3. Look the signal up in the category note's trigger table.
4. Try approaches top to bottom.
5. Grep the flag prefix in plain, Base64, hex, ROT13.

## Time-box

Easy 10 min, moderate 20, hard 30.
Over budget: log findings in the doc, hand off, move on.
