# 🧪 Edge Case Tests - Nov 30

## Session Recovery (HOST)
- [ ] Host creates session → Closes app → Reopens → "Rejoin as Host?" dialog appears
- [ ] Click "Rejoin as Host" → Navigates to lobby (if waiting) or LiveHostView (if active)
- [ ] Host in lobby → Close app → Reopen → Rejoin → See same participants

## Session Recovery (PARTICIPANT)
- [ ] Participant joins → Closes app → Reopens → "Rejoin Quiz?" dialog appears
- [ ] Click "Rejoin" → Reconnects to session
- [ ] Click "Dismiss" → Clears session, no popup again
- [ ] Session expired on server → No crash, handles gracefully

## Host Disconnection (during quiz)
- [ ] Host closes app → Reopens → Can rejoin as host
- [ ] Host reconnects → Participants see "Host reconnected"
- [ ] Host gone 2+ mins → Session ends for all

## Participant Disconnection
- [ ] Lose internet → Reconnection overlay shows
- [ ] Internet back → Auto-reconnects, still in session
- [ ] Disconnect during question → Can still answer after reconnect

## Concurrency (50+ users)
- [ ] 50 join at same time → No crashes
- [ ] 50 answer same question → All recorded correctly
- [ ] Leaderboard accurate for all 50

## Anti-Cheat
- [ ] Submit answer twice → Second one rejected
- [ ] Submit after timer ends → Rejected
- [ ] Invalid session code → Error message

## Session States
- [ ] Join before start → Works
- [ ] Join after started → Rejected
- [ ] Host ends quiz → All participants notified
- [ ] Host disconnects mid-question → Participants see message

## Self-Paced Mode
- [ ] No timer pressure → Works
- [ ] Each user progresses independently
- [ ] Final results shown correctly
