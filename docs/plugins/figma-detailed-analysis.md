# FanTribe Figma Detailed Analysis

## Purpose
Comprehensive analysis of all UI elements, interactions, and implementation status in the CretorTribe-V1 Figma export. This document identifies missing flows and features that need client clarification.

**Last Updated:** February 24, 2026

---

# MODULE 1: HOME FEED

## 1.1 SocialFeed (Main Feed Container)
**File:** `/src/app/components/SocialFeed.tsx`

| Element | Handler | Visual Effect | Status |
|---------|---------|---------------|--------|
| CreatePostInput | `onClick={() => setIsCreatePostModalOpen(true)}` | Opens CreatePostModal overlay | **IMPLEMENTED** |
| Load More Button | No handler | `hover:bg-slate-50` CSS only | **NO HANDLER** |
| Sponsored "Explore Now" Button | No handler | `hover:shadow-lg hover:scale-105` CSS only | **NO HANDLER** |

---

## 1.2 CreatePostInput (Compose Box)
**File:** `/src/app/components/CreatePostInput.tsx`

| Element | Handler | Status |
|---------|---------|--------|
| Main Container | `onClick={onClick}` (opens modal) | **IMPLEMENTED** |
| Mobile + Button | Inherits parent onClick | **IMPLEMENTED** |
| Photo Button (Desktop) | No handler - CSS hover only | **NO HANDLER** |
| Video Button (Desktop) | No handler - CSS hover only | **NO HANDLER** |
| Audio Button (Desktop) | No handler - CSS hover only | **NO HANDLER** |
| Tag Gear Button (Desktop) | No handler - CSS hover only | **NO HANDLER** |

**Client Clarification Needed:**
- Should quick action buttons open modal with pre-selected media type?

---

## 1.3 CreatePostModal
**File:** `/src/app/components/CreatePostModal.tsx`

| Element | Handler Code | Status |
|---------|-------------|--------|
| Close Button (X) | `onClick={onClose}` | **IMPLEMENTED** |
| Caption Textarea | `onChange={(e) => setCaption(e.target.value)}` | **IMPLEMENTED** |
| Photo Upload Button | `onClick={() => imageInputRef.current?.click()}` triggers hidden input `accept="image/*"` | **IMPLEMENTED** |
| Video Upload Button | `onClick={() => videoInputRef.current?.click()}` triggers hidden input `accept="video/*"` | **IMPLEMENTED** |
| Audio Upload Button | `onClick={() => audioInputRef.current?.click()}` triggers hidden input `accept="audio/*"` | **IMPLEMENTED** |
| Remove Media (X) | `onClick={() => setUploadedMedia(uploadedMedia.filter((_, i) => i !== index))}` | **IMPLEMENTED** |
| Gear Search Input | `onChange` + `onFocus` - filters 20 products, shows top 5 matches | **IMPLEMENTED** |
| Gear Suggestion Item | `onClick={() => handleGearSelect(product)}` adds to selectedGear | **IMPLEMENTED** |
| Remove Gear Tag (X) | `onClick={() => handleRemoveGear(product.id)}` | **IMPLEMENTED** |
| Visibility: Public | `onClick={() => setVisibility('public')}` | **IMPLEMENTED** |
| Visibility: Followers | `onClick={() => setVisibility('followers')}` | **IMPLEMENTED** |
| Visibility: Private | `onClick={() => setVisibility('private')}` | **IMPLEMENTED** |
| Schedule Toggle | `onClick={() => setShowScheduler(!showScheduler)}` | **IMPLEMENTED** |
| Date Picker | `onChange={(e) => setScheduledDate(e.target.value)}` | **IMPLEMENTED** |
| Time Picker | `onChange={(e) => setScheduledTime(e.target.value)}` | **IMPLEMENTED** |
| Publish Now Button | `handlePost()` → `console.log('Publishing post:', {...}); resetForm(); onClose();` | **PARTIAL (console.log)** |
| Schedule Post Button | `handleSchedulePost()` → `console.log('Scheduling post:', {...}); resetForm(); onClose();` | **PARTIAL (console.log)** |
| Cancel Button | `onClick={onClose}` | **IMPLEMENTED** |
| Backdrop Click | `onClick={onClose}` | **IMPLEMENTED** |

**Product Database:** 20 products across 5 brands (Behringer, Midas, Turbosound, Klark Teknik, TC Electronic, TC Helicon)

**Client Clarification Needed:**
- What happens after publish? Redirect? Toast notification?
- How should visibility "Followers" work in Discourse?
- Character limit validation (currently shows /2000)?

---

## 1.4 PostCard
**File:** `/src/app/components/PostCard.tsx`

### Media Display
| Element | Handler | Status |
|---------|---------|--------|
| Video Play Button | No handler - visual play triangle only | **NO HANDLER** |
| Audio Play Button | No handler - visual play triangle only | **NO HANDLER** |
| Image | Static display | **IMPLEMENTED** |

**Client Clarification Needed:**
- Should videos auto-play on scroll?
- Should audio show waveform with playback progress?
- What video player controls are needed?

### Reaction Bar (via ReactionBar component)
| Element | Handler | Status |
|---------|---------|--------|
| Reaction Counter Button | `onClick={() => setShowPicker(!showPicker)}` | **IMPLEMENTED** |
| React Button | `onClick={() => setShowPicker(!showPicker)}` + `onMouseEnter` | **IMPLEMENTED** |
| Emoji in Picker | `onClick={() => handleReaction(reaction.emoji)}` | **IMPLEMENTED** |
| Backdrop (Close Picker) | `onClick={() => setShowPicker(false)}` | **IMPLEMENTED** |

**Reaction Logic (handleReaction):**
```javascript
// If user already reacted with this emoji → unreact (decrement)
// If user switching reactions → decrement old, increment new
// If new reaction → increment and set userReaction
// User can only have ONE active reaction at a time
```

**6 Reactions Available:** ❤️ Love, 🔥 Fire, 👏 Clap, 🎵 Vibe, 💯 Perfect, 🚀 Amazing

### Action Bar
| Element | Handler | Status |
|---------|---------|--------|
| Comment Count Icon | None (informational) | **DISPLAY ONLY** |
| Share Button | `onClick={() => setIsShareModalOpen(true)}` | **IMPLEMENTED** |
| Save/Bookmark Button | `handleSave()` → `setIsSaved(!isSaved)` toggles state | **IMPLEMENTED (local state)** |

### Comments Section
| Element | Handler | Status |
|---------|---------|--------|
| Comment Input | `onChange={(e) => setCommentText(e.target.value)}` | **IMPLEMENTED** |
| Send Button | `onClick={handleSubmitComment}` adds to local comments array | **IMPLEMENTED (local only)** |
| Reply Button | `onClick={() => setReplyingTo(comment.id)}` | **IMPLEMENTED** |
| Cancel Reply | `onClick={() => { setReplyingTo(null); setCommentText(''); }}` | **IMPLEMENTED** |
| Enter Key | `handleKeyDown` - Enter submits, Esc cancels | **IMPLEMENTED** |

**Comment Submission Logic:**
```javascript
const newComment = {
  id: comments.length + 1,
  author: currentUserName || 'You',
  initials: ...,
  text: commentText,
  timestamp: 'Just now',
  replyTo: replyingTo || undefined,
};
setComments([newComment, ...comments]); // Adds to top
```

**Client Clarification Needed:**
- How are comments persisted to backend?
- Can users edit/delete their comments?
- Pagination for comments?
- Should comment icon scroll to comments section?

---

## 1.5 PostMenu (3-Dot Menu)
**File:** `/src/app/components/PostMenu.tsx`

**Handler Pattern:** All menu items use `console.log('Post action: ${action}'); onClose();`

### Own Posts Menu
| Option | Icon | Action Parameter | Status |
|--------|------|-----------------|--------|
| Pin to Profile | Pin | `'pin'` | **PARTIAL (console.log)** |
| Edit Post | Edit3 | `'edit'` | **PARTIAL (console.log)** |
| Copy Link | Link2 | `'copy-link'` | **PARTIAL (console.log)** |
| Turn Off Comments | MessageSquareOff | `'turn-off-comments'` | **PARTIAL (console.log)** |
| Delete Post | Trash2 | `'delete'` (red styling) | **PARTIAL (console.log)** |

### Other Users' Posts Menu
| Option | Icon | Action Parameter | Conditional | Status |
|--------|------|-----------------|-------------|--------|
| Save Post | Bookmark | `'save'` | Always | **PARTIAL (console.log)** |
| Copy Link | Link2 | `'copy-link'` | Always | **PARTIAL (console.log)** |
| Follow [Username] | UserPlus | `'follow'` | `if !isFollowing` | **PARTIAL (console.log)** |
| Not Interested | EyeOff | `'hide'` | Always | **PARTIAL (console.log)** |
| Mute [Username] | Eye | `'mute'` | Always | **PARTIAL (console.log)** |
| Report Post | Flag | `'report'` | Always | **PARTIAL (console.log)** |
| Block [Username] | Ban | `'block'` (red styling) | Always | **PARTIAL (console.log)** |

**Menu Animation:** Framer Motion spring (opacity, scale 0.95→1, y: -10→0)

**Client Clarification Needed:**
- What does "Pin to Profile" mean exactly? Pinned section on profile?
- What is the edit flow? Opens modal? Inline editing?
- What happens after blocking? Hide all posts? Redirect?
- Where does report go? Admin queue?

---

## 1.6 ShareModal
**File:** `/src/app/components/ShareModal.tsx`

| Element | Handler | Status |
|---------|---------|--------|
| Close Button (X) | `onClick={onClose}` | **IMPLEMENTED** |
| Copy Link Button | `handleCopyLink()` → `navigator.clipboard.writeText(postUrl)`, shows "Copied" for 2s | **FULLY IMPLEMENTED** |
| Twitter Share | `window.open()` → Twitter intent URL | **FULLY IMPLEMENTED** |
| Facebook Share | `window.open()` → Facebook sharer URL | **FULLY IMPLEMENTED** |
| WhatsApp Share | `window.open()` → wa.me URL | **FULLY IMPLEMENTED** |
| Email Share | `window.location.href` → mailto: URL | **FULLY IMPLEMENTED** |
| Backdrop | `onClick={onClose}` | **IMPLEMENTED** |

**Share URLs Generated:**
```javascript
// Twitter: https://twitter.com/intent/tweet?url=${postUrl}&text=Check out this post by ${userName}!
// Facebook: https://www.facebook.com/sharer/sharer.php?u=${postUrl}
// WhatsApp: https://wa.me/?text=${encodeURIComponent(`Check out this post by ${userName}! ${postUrl}`)}
// Email: mailto:?subject=Check out this post&body=Check out this post by ${userName}: ${postUrl}
```

---

## 1.7 LiveChat (Floating Widget)
**File:** `/src/app/components/LiveChat.tsx`

| Element | Handler | Status |
|---------|---------|--------|
| Emoji Button | No handler | **NO HANDLER** |
| Chat Input | `onChange={(e) => setInputValue(e.target.value)}` | **IMPLEMENTED** |
| Send Button | `onClick={handleSendMessage}` | **IMPLEMENTED** |
| Enter Key | `onKeyPress` → Enter submits | **IMPLEMENTED** |

**Send Message Logic:**
```javascript
const newMessage = {
  id: `${Date.now()}`,
  user: 'You',
  avatar: 'You',
  message: inputValue,
  verification: 'gold',
  timestamp: new Date(),
};
setMessages((prev) => [...prev, newMessage]);
setInputValue('');
```

**Auto-Scroll:** `useEffect` scrolls to bottom on new messages
**Auto-Messages:** 60% chance every 4 seconds to add random sample message

**Client Clarification Needed:**
- Is this a global live chat or per-tribe?
- Emoji picker integration needed?
- Real-time messaging integration (WebSocket)?

---

## 1.8 RightSidebar (Trending Panel)
**Note:** Referenced in layout but specific handlers not visible in main components

| Element | Status |
|---------|--------|
| Trending tribe items | **NO HANDLER** |
| "See all tribes" link | **NO HANDLER** |
| Live stream items | **NO HANDLER** |
| "View all live streams" link | **NO HANDLER** |
| "Discover Creators" button | **NO HANDLER** |

**Client Clarification Needed:**
- Where do trending tribe items link to?
- What is "Discover Creators" page?

---

# MODULE 2: EXPLORE TRIBES

## 2.1 ExploreTribes Page
**File:** `/src/app/components/ExploreTribes.tsx`

| Element | Handler | Status |
|---------|---------|--------|
| Filter Dropdown Toggle | `onClick={() => setIsFilterOpen(!isFilterOpen)}` | **IMPLEMENTED** |
| Filter Option Click | `handleFilterSelect(filter)` → `setActiveFilter(filter); setIsFilterOpen(false);` | **IMPLEMENTED** |
| Backdrop Click | Closes dropdown | **IMPLEMENTED** |
| Load More Button | No handler - CSS hover effects only | **NO HANDLER** |

**Filter Options:** All, Production, Guitar, Vocals, Local

**Filter Logic:**
```javascript
const filteredTribes = allTribes.filter((tribe) => {
  const matchesFilter = activeFilter === 'All' || tribe.category === activeFilter;
  const matchesSearch = tribe.name.toLowerCase().includes(searchQuery.toLowerCase());
  return matchesFilter && matchesSearch;
});
```

**Missing UI Elements:**
- Search input (state `searchQuery` exists but NO input field rendered)
- Sort options

**Client Clarification Needed:**
- What search functionality is needed?
- What sort options (newest, most members, most active)?

---

## 2.2 TribeCard
**File:** `/src/app/components/TribeCard.tsx`

| Element | Handler | Status |
|---------|---------|--------|
| Card Click | `handleCardClick()` → `console.log('Tribe detail page - coming soon!')` (navigation commented out) | **PARTIAL (console.log)** |
| Join Tribe Button | `handleJoinClick(e)` → `e.stopPropagation(); console.log('Joining tribe: ${name}')` | **PARTIAL (console.log)** |
| Request to Join Button | Same as above (shows when `privacy === 'Private'`) | **PARTIAL (console.log)** |
| Live Badge | Display only | **DISPLAY ONLY** |
| Category Badge | Display only | **DISPLAY ONLY** |
| Verified Badge | Display only (shows if `isVerified === true`) | **DISPLAY ONLY** |

**Visual Effects on Hover:**
- Image scales 105%
- Shadow increases to shadow-xl
- Border color changes to slate-300
- Gradient overlay appears
- Tribe name text changes to vibrant-red

**Client Clarification Needed:**
- What is the "Live" indicator tied to? Live streaming?
- What makes a tribe "verified"?
- What is the join workflow for private tribes?

---

## 2.3 TribeDetailPage
**File:** `/src/app/pages/TribeDetailPage.tsx`

### Header Section
| Element | Handler | Status |
|---------|---------|--------|
| Back Button | `onClick={() => navigate('/explore')}` | **IMPLEMENTED** |
| Live Badge | Display only (shows if `tribe.isLive`) | **DISPLAY ONLY** |
| Join/Joined Toggle | `handleJoinToggle()` → `setIsJoined(!isJoined); console.log(...)` | **PARTIAL (console.log, local state only)** |
| Notification Bell | No handler | **NO HANDLER** |
| Search Icon | No handler | **NO HANDLER** |
| More Options (3-dot) | No handler | **NO HANDLER** |

**Note:** Header action buttons (notification, search, more) only visible when `isJoined === true`

### Tab Navigation
| Tab | Handler | Status |
|-----|---------|--------|
| Feed | `onClick={() => setActiveTab('feed')}` | **IMPLEMENTED** |
| About | `onClick={() => setActiveTab('about')}` | **IMPLEMENTED** |
| Members | `onClick={() => setActiveTab('members')}` | **IMPLEMENTED** |
| Events | `onClick={() => setActiveTab('events')}` | **IMPLEMENTED** |

### Feed Tab
| Element | Handler | Status |
|---------|---------|--------|
| Non-member Notice | Shows when `!isJoined` | **DISPLAY ONLY** |
| Non-member "Join" Button | `onClick={handleJoinToggle}` | **PARTIAL** |
| Posts (PostCard) | See PostCard section | **PARTIAL** |

### About Tab
| Element | Handler | Status |
|---------|---------|--------|
| Description Display | None | **DISPLAY ONLY** |
| Rules List | None | **DISPLAY ONLY** |
| Admin "Message" Button | No handler | **NO HANDLER** |

**Client Clarification Needed:**
- How are tribe rules created/edited?
- What does "Message" admin do? Opens DM?

### Members Tab
| Element | Handler | Status |
|---------|---------|--------|
| Search Members Button | No handler | **NO HANDLER** |
| Member Cards | No handler (hover effect only) | **NO HANDLER** |

**Member Card Features:**
- Avatar with tier badge (gold/silver/bronze gradient)
- Name and username
- "Admin" badge for admins (red background)

**Client Clarification Needed:**
- Does clicking member open their profile?
- What search filters exist?

### Events Tab
| Element | Handler | Status |
|---------|---------|--------|
| Empty State Display | None | **DISPLAY ONLY** |

**Placeholder Message:** "Jam sessions, workshops, and tribe gatherings will be listed here"

**Client Clarification Needed:**
- What is the events system? Calendar integration?
- Who can create events?
- What notification options exist?
- What's in the more options menu?

---

# MODULE 3: CHAT

## 3.1 ChatPage - Direct Messages
**File:** `/src/app/pages/ChatPage.tsx`

### Tab Selection
| Element | Handler | Status |
|---------|---------|--------|
| Direct Tab | `onClick={() => { setActiveTab('direct'); setIsBroadcastMode(false); }}` | **IMPLEMENTED** |
| Broadcasts Tab | `onClick={() => { setActiveTab('broadcasts'); setIsBroadcastMode(true); }}` | **IMPLEMENTED** |

### Filter Pills
| Filter | Handler | Status |
|--------|---------|--------|
| All | `onClick={() => setActiveFilter('all')}` | **IMPLEMENTED** |
| Unread | `onClick={() => setActiveFilter('unread')}` | **IMPLEMENTED** |
| VIPs | `onClick={() => setActiveFilter('vips')}` (gradient styling) | **IMPLEMENTED** |
| Collaborators | `onClick={() => setActiveFilter('collaborators')}` | **IMPLEMENTED** |

**Filtering Logic:** Filters `mockConversations` array based on `activeFilter` state

### Conversation List
| Element | Handler | Status |
|---------|---------|--------|
| Conversation Row | `onClick={() => setSelectedConversation(conv)}` | **IMPLEMENTED** |

**Conversation Display Features:**
- Avatar with VIP ring (gold/orange if applicable)
- Online status dot
- User name + CRM badge (Superfan/Collaborator)
- Timestamp
- Unread indicator (blue dot)

### Chat Header
| Element | Handler | Status |
|---------|---------|--------|
| Mobile Back Button | `onClick={() => setSelectedConversation(null)}` | **IMPLEMENTED** |
| Star Button | `onClick={() => setIsStarred(!isStarred)}` (yellow highlight when starred) | **IMPLEMENTED** |
| Context Sidebar Toggle | `onClick={() => setShowContextSidebar(!showContextSidebar)}` (desktop only, animated) | **IMPLEMENTED** |
| More Options Button | `onClick={() => setShowOptionsMenu(!showOptionsMenu)}` | **IMPLEMENTED** |

### Options Menu (Dropdown)
**Handler Pattern:** All items use `onClick={() => setShowOptionsMenu(false)}` - menu closes but NO action performed

| Option | Icon | Status |
|--------|------|--------|
| Mute conversation | BellOff | **PARTIAL (closes menu only)** |
| Pin conversation | Pin | **PARTIAL (closes menu only)** |
| Mark as unread | Mail | **PARTIAL (closes menu only)** |
| Archive chat | Archive | **PARTIAL (closes menu only)** |
| Block user | Ban | **PARTIAL (closes menu only)** |
| Delete conversation | Trash2 (red) | **PARTIAL (closes menu only)** |
| Report user | Flag (red) | **PARTIAL (closes menu only)** |

**Client Clarification Needed:**
- What does "archive" do vs "delete"?
- Where do reports go?

### Message Composer
| Element | Handler | Status |
|---------|---------|--------|
| Emoji Button | No handler | **NO HANDLER** |
| Attachment Button | No handler | **NO HANDLER** |
| Microphone Button | No handler | **NO HANDLER** |
| Zap/Quick Button | No handler | **NO HANDLER** |
| Message Input | `value={messageInput} onChange={(e) => setMessageInput(e.target.value)}` | **IMPLEMENTED** |
| Send Button | No handler | **NO HANDLER** |

**Client Clarification Needed:**
- What attachment types allowed?
- Voice messages supported?
- What are quick actions (zap button)?

### Message Types in UI
- Text messages
- Image messages
- Product cards (with "View Product" button - **NO HANDLER**)

### Context Sidebar (Desktop)
| Element | Handler | Status |
|---------|---------|--------|
| Profile Display | None | **DISPLAY ONLY** |
| Lifetime Value | None | **DISPLAY ONLY** |
| Shared Files | No handler (hover effect only) | **NO HANDLER** |
| Shared Links | `href="#"` placeholder | **PARTIAL (no navigation)** |
| Private Notes Textarea | No onChange handler | **PARTIAL (no state binding)** |

**Client Clarification Needed:**
- Is CRM data integration needed?
- How are notes saved?

---

## 3.2 ChatPage - Broadcasts

### Broadcast Composer
| Element | Handler | Status |
|---------|---------|--------|
| Mobile Back Button | `onClick={() => setActiveTab('direct')}` | **IMPLEMENTED** |
| Recipient Dropdown | `value={broadcastRecipients} onChange={(e) => setBroadcastRecipients(e.target.value)}` | **IMPLEMENTED** |
| Message Textarea | No onChange handler | **PARTIAL (no state binding)** |
| Emoji Button | No handler | **NO HANDLER** |
| Attachment Button | No handler | **NO HANDLER** |
| Send Broadcast Button | No handler | **NO HANDLER** |

**Recipient Options:**
- All Gold Tier Fans
- All Diamond Tier Fans
- All Superfans
- Recent Buyers
- All Followers

### Previous Broadcasts
| Element | Handler | Status |
|---------|---------|--------|
| Broadcast Cards | None | **DISPLAY ONLY** |

**Client Clarification Needed:**
- What recipient segments are available?
- Can broadcasts include media?
- Analytics tracking needed?

---

# MODULE 4: USER PROFILE

## 4.1 Profile Header
**File:** `/src/app/pages/UserProfilePage.tsx`

### Cover Area Actions
| Element | Handler | Status |
|---------|---------|--------|
| Share Button | No handler | **NO HANDLER** |
| Settings Button | No handler | **NO HANDLER** |

### Profile Actions
| Element | Handler | Status |
|---------|---------|--------|
| Subscribe Button | `onClick={() => setIsSubscribed(!isSubscribed)}` | **IMPLEMENTED** |

**Subscribe Button States:**
- Not subscribed: Gradient (indigo-500 to purple-600) + white text + "Subscribe"
- Subscribed: slate-200 background + slate-700 text + "Subscribed"

### Profile Stats
| Stat | Handler | Status |
|------|---------|--------|
| Followers (1.2k) | None | **DISPLAY ONLY (not clickable)** |
| Tribes (15) | None | **DISPLAY ONLY (not clickable)** |
| Co-Creations (12) | None | **DISPLAY ONLY (not clickable)** |

### Metadata
| Element | Handler | Status |
|---------|---------|--------|
| Website Link | `href="#"` placeholder | **PARTIAL (no navigation)** |

**Client Clarification Needed:**
- What does share profile do?
- What's on settings page?
- Should stats be clickable (show followers list)?

---

## 4.2 Profile Tabs

### Tab Navigation
| Tab | Handler | Status |
|-----|---------|--------|
| Posts | `onClick={() => setActiveTab('posts')}` | **IMPLEMENTED** |
| Gear Collection | `onClick={() => setActiveTab('gear')}` | **IMPLEMENTED** |
| Co-Creations | `onClick={() => setActiveTab('co-creations')}` | **IMPLEMENTED** |
| Shop | `onClick={() => setActiveTab('shop')}` | **IMPLEMENTED** |

**Active Tab Styling:** Gradient background (indigo-500 to purple-600) + white text + shadow

### Posts Tab
| Element | Handler | Status |
|---------|---------|--------|
| Post Options (MoreHorizontal) | No handler | **NO HANDLER** |
| Like Button | No handler (hover effect only) | **NO HANDLER** |
| Comment Button | No handler (hover effect only) | **NO HANDLER** |
| Share Button | No handler (hover effect only) | **NO HANDLER** |

### Gear Collection Tab
| Element | Handler | Status |
|---------|---------|--------|
| Gear Card Click | No handler (hover effect only) | **NO HANDLER** |
| Update Now Button (firmware-update) | No handler | **NO HANDLER** |
| View Listing Button (for-sale) | No handler | **NO HANDLER** |
| Track Status Button (in-repair) | No handler | **NO HANDLER** |
| View Details Button (up-to-date) | No handler | **NO HANDLER** |

**Gear Status Types:**
- `firmware-update` → Orange styling
- `for-sale` → Purple styling
- `in-repair` → Red styling
- `up-to-date` → Slate styling

**Client Clarification Needed:**
- What is firmware update flow?
- Where does "View Listing" go (marketplace)?
- What is "Track Status" for repairs?

### Co-Creations Tab
| Element | Handler | Status |
|---------|---------|--------|
| Co-Creation Card | Has `cursor-pointer` but no onClick handler | **PARTIAL (hover only)** |
| Collaborator Tags | None | **DISPLAY ONLY** |

**Co-Creation Card Features:**
- Thumbnail with hover scale effect
- Type badge (top-right)
- Title, collaborators, date

**Client Clarification Needed:**
- What is co-creation detail view?
- What collaboration types exist?

### Shop Tab
| Element | Handler | Status |
|---------|---------|--------|
| Get Notified Button | No handler | **NO HANDLER** |

**Placeholder:** "Coming Soon" with teal-cyan gradient button

**Client Clarification Needed:**
- What is the shop feature?
- Is this deferred to Phase 2?

---

## 4.3 Verification Tiers

**Supported Tiers in Code:**
| Tier | Ring Color |
|------|------------|
| Bronze | `ring-[rgb(205,127,50)]` |
| Silver | `ring-[rgb(192,192,192)]` |
| Gold | `ring-[rgb(255,215,0)]` |
| Blue | `ring-[rgb(59,130,246)]` |

**Client Clarification Needed:**
- What criteria for each tier?
- How are tiers assigned?

---

# SUMMARY: MISSING FLOWS REQUIRING CLIENT INPUT

## High Priority (Affects Core Features)

1. **Post Creation Flow** - What happens after publish? Success feedback? Toast notification?
2. **Video/Audio Playback** - Native player or custom? Auto-play on scroll?
3. **Pin to Profile** - What does this mean exactly? Pinned section on profile page?
4. **Block/Mute User** - What's blocked? All content? DMs? Profile access?
5. **Report Flow** - Where do reports go? Admin review queue?
6. **Tribe Join Flow** - Private vs public approval workflow?
7. **Message Sending** - How are DMs sent? Real-time WebSocket?
8. **Comment Persistence** - How are comments saved to backend?

## Medium Priority (Feature Completeness)

9. **Gear Product Links** - Where does "View Product" link to?
10. **Tribe Events** - What's the events system? Calendar integration?
11. **Notification Settings** - Per-tribe? Global? What options?
12. **Search Functionality** - What's searchable? Filters available?
13. **Broadcast Recipients** - What segments exist? Custom segments?
14. **CRM Data** - Where does lifetime value come from?
15. **Tribe More Options Menu** - What's in the 3-dot menu?
16. **Admin Messaging** - Opens DM? Special admin chat?

## Low Priority (Nice-to-Have Details)

17. **Emoji Picker** - Standard set or custom?
18. **Voice Messages** - Supported?
19. **File Attachments** - What types? Size limits?
20. **Quick Actions (Zap)** - What are these for?
21. **Edit/Delete Comments** - Supported?
22. **Comment Pagination** - Load more pattern?

---

# IMPLEMENTATION STATUS COUNTS

| Category | Implemented | Partial (console.log) | No Handler |
|----------|-------------|----------------------|------------|
| SocialFeed | 1 | 0 | 2 |
| CreatePostInput | 2 | 0 | 4 |
| CreatePostModal | 16 | 2 | 0 |
| PostCard | 9 | 0 | 2 |
| PostMenu | 0 | 12 | 0 |
| ReactionBar | 4 | 0 | 0 |
| ShareModal | 7 | 0 | 0 |
| LiveChat | 3 | 0 | 1 |
| ExploreTribes | 3 | 0 | 1 |
| TribeCard | 0 | 2 | 0 |
| TribeDetailPage | 5 | 1 | 5 |
| ChatPage (DM) | 12 | 7 | 6 |
| ChatPage (Broadcast) | 2 | 1 | 3 |
| UserProfilePage | 5 | 1 | 13 |
| **TOTAL** | **69** | **26** | **37** |

**Overall:** 132 interactive elements analyzed
- 52% Implemented (69)
- 20% Partial/Console.log (26)
- 28% No Handler (37)
